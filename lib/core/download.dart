import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../app_info.dart';

const _bmclapi = 'https://bmclapi2.bangbang93.com';

const _mirrors = [
  ('https://piston-meta.mojang.com', _bmclapi),
  ('https://launchermeta.mojang.com', _bmclapi),
  ('https://piston-data.mojang.com', _bmclapi),
  ('https://launcher.mojang.com', _bmclapi),
  ('https://resources.download.minecraft.net', '$_bmclapi/assets'),
  ('https://libraries.minecraft.net', '$_bmclapi/maven'),
  ('https://maven.fabricmc.net', '$_bmclapi/maven'),
  ('https://meta.fabricmc.net', '$_bmclapi/fabric-meta'),
  ('https://maven.minecraftforge.net', '$_bmclapi/maven'),
  ('https://maven.neoforged.net/releases', '$_bmclapi/maven'),
];

class DownloadItem {
  DownloadItem({required this.url, required this.path, this.sha1, this.size});

  final String url;
  final String path;
  final String? sha1;
  final int? size;
}

/// 下载器。下载源（官方 / BMCLAPI）与并发数来自设置。
class Downloader {
  Downloader({required this.useMirror, required this.concurrency});

  final bool useMirror;
  final int concurrency;

  static final _client = HttpClient()
    ..userAgent = '${AppInfo.name}/${AppInfo.version}'
    ..connectionTimeout = const Duration(seconds: 20);

  /// 根据下载源设置把官方地址替换为镜像地址
  String mirror(String url) {
    if (!useMirror) return url;
    for (final (from, to) in _mirrors) {
      if (url.startsWith(from)) return to + url.substring(from.length);
    }
    return url;
  }

  /// 低于这个速度视为分到了慢节点（字节/秒），断开重连
  static const _slowSpeed = 64 * 1024;

  Future<List<int>> _get(String url, {int retries = 3, bool Function()? cancelled}) async {
    final candidates = [mirror(url), if (mirror(url) != url) url]; // 镜像失败时回退到官方源
    Object? lastErr;
    for (final target in candidates) {
      // BMCLAPI 会重定向到随机的社区节点，个别节点的证书链不完整（不发送中间证书），
      // 系统浏览器能自动补全而 Dart 不能；重新请求会分到另一个节点，所以握手失败时多试几次
      var handshakeRetries = 6;
      for (var i = 0; i < retries; i++) {
        // 最后一次尝试不再按速度断开，避免网络本身慢时永远下不完
        final checkSpeed = i < retries - 1;
        try {
          final req = await _client.getUrl(Uri.parse(target));
          final res = await req.close().timeout(const Duration(seconds: 30));
          if (res.statusCode == 200) {
            final b = BytesBuilder(copy: false);
            final sw = Stopwatch()..start();
            await for (final chunk in res.timeout(const Duration(seconds: 20))) {
              if (cancelled?.call() ?? false) throw const _Cancelled();
              b.add(chunk);
              final secs = sw.elapsedMilliseconds / 1000;
              if (checkSpeed && secs > 8 && b.length / secs < _slowSpeed) {
                throw HttpException('下载速度过慢，更换节点重试：$target');
              }
            }
            return b.takeBytes();
          }
          await res.drain<void>();
          lastErr = HttpException('HTTP ${res.statusCode} $target');
          if (res.statusCode == 404) break;
        } on _Cancelled {
          rethrow;
        } on HandshakeException catch (e) {
          lastErr = e;
          if (handshakeRetries-- > 0) {
            i--;
            continue;
          }
        } catch (e) {
          lastErr = e;
        }
        await Future<void>.delayed(Duration(milliseconds: 500 * (i + 1)));
      }
    }
    throw lastErr ?? Exception('下载失败：$url');
  }

  Future<dynamic> fetchJson(String url) async => jsonDecode(utf8.decode(await _get(url)));

  Future<String> fetchText(String url) async => utf8.decode(await _get(url));

  /// 文件已存在且大小匹配即视为完整（全量校验 sha1 太慢）
  static Future<bool> isComplete(DownloadItem item) async {
    final f = File(item.path);
    if (!await f.exists()) return false;
    final len = await f.length();
    return item.size != null ? len == item.size : len > 0;
  }

  static var _tmpSeq = 0;

  /// [cancelled] 返回 true 时放弃下载（同一文件的另一个连接已经完成）
  Future<void> downloadFile(DownloadItem item, {bool Function()? cancelled}) async {
    final data = await _get(item.url, cancelled: cancelled);
    if (item.sha1 != null && sha1.convert(data).toString() != item.sha1) {
      throw Exception('校验失败：${item.path}');
    }
    if (cancelled?.call() ?? false) return;
    final f = File(item.path);
    await f.parent.create(recursive: true);
    // 同一文件可能有两个连接同时下载，临时文件名要区分
    final tmp = File('${item.path}.$pid.${_tmpSeq++}.tmp');
    await tmp.writeAsBytes(data, flush: true);
    await tmp.rename(item.path);
  }

  /// 并发下载，跳过已完整的文件
  Future<void> downloadAll(List<DownloadItem> items, void Function(int done, int total) onProgress) async {
    final unique = {for (final i in items) i.path: i}.values;
    final jobs = <_Job>[];
    for (final item in unique) {
      if (!await isComplete(item)) jobs.add(_Job(item));
    }
    // 大文件先下，免得最后剩下几个大文件单线程慢慢下
    jobs.sort((a, b) => (b.item.size ?? 0).compareTo(a.item.size ?? 0));
    var done = 0;
    final total = jobs.length;
    onProgress(0, total);
    if (total == 0) return;

    final errors = <Object>[];
    final allDone = Completer<void>();
    void finish(_Job job) {
      job.finished = true;
      onProgress(++done, total);
      if (done == total) allDone.complete();
    }

    Future<void> run(_Job job) async {
      job.running++;
      job.startedAt ??= DateTime.now();
      try {
        await downloadFile(job.item, cancelled: () => job.finished);
        if (!job.finished) finish(job);
      } catch (e) {
        job.error ??= e;
      } finally {
        job.running--;
        // 所有连接都失败才算失败
        if (!job.finished && job.running == 0) {
          errors.add(job.error!);
          finish(job);
        }
      }
    }

    var cursor = 0;
    Future<void> worker() async {
      while (true) {
        if (cursor < jobs.length) {
          await run(jobs[cursor++]);
          continue;
        }
        if (jobs.every((j) => j.finished)) return;
        // 队列已空：给下载了一段时间还没完成的文件再开一个连接，先完成的为准，
        // 这样结尾不会被个别慢节点拖住
        final now = DateTime.now();
        final slow = jobs
            .where((j) => !j.finished && !j.hedged && j.running > 0 && now.difference(j.startedAt!).inSeconds >= 3)
            .firstOrNull;
        if (slow == null) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          continue;
        }
        slow.hedged = true;
        await run(slow);
      }
    }

    // 全部文件有结果就返回，不等被淘汰的连接超时
    for (var i = 0; i < max(1, min(concurrency, 64)); i++) {
      unawaited(worker());
    }
    await allDone.future;
    if (errors.isNotEmpty) throw Exception('${errors.length} 个文件下载失败，例如：${errors.first}');
  }
}

/// downloadAll 中的一个文件，可能同时有两个连接在下载
class _Job {
  _Job(this.item);

  final DownloadItem item;
  DateTime? startedAt;
  var running = 0;
  var hedged = false;
  var finished = false;
  Object? error;
}

class _Cancelled implements Exception {
  const _Cancelled();
}
