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

  Future<List<int>> _get(String url, {int retries = 3}) async {
    final candidates = [mirror(url), if (mirror(url) != url) url]; // 镜像失败时回退到官方源
    Object? lastErr;
    for (final target in candidates) {
      // BMCLAPI 会重定向到随机的社区节点，个别节点的证书链不完整（不发送中间证书），
      // 系统浏览器能自动补全而 Dart 不能；重新请求会分到另一个节点，所以握手失败时多试几次
      var handshakeRetries = 6;
      for (var i = 0; i < retries; i++) {
        try {
          final req = await _client.getUrl(Uri.parse(target));
          final res = await req.close().timeout(const Duration(seconds: 60));
          if (res.statusCode == 200) {
            final b = BytesBuilder(copy: false);
            await for (final chunk in res.timeout(const Duration(seconds: 60))) {
              b.add(chunk);
            }
            return b.takeBytes();
          }
          await res.drain<void>();
          lastErr = HttpException('HTTP ${res.statusCode} $target');
          if (res.statusCode == 404) break;
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

  Future<void> downloadFile(DownloadItem item) async {
    final data = await _get(item.url);
    if (item.sha1 != null && sha1.convert(data).toString() != item.sha1) {
      throw Exception('校验失败：${item.path}');
    }
    final f = File(item.path);
    await f.parent.create(recursive: true);
    final tmp = File('${item.path}.$pid.tmp');
    await tmp.writeAsBytes(data, flush: true);
    await tmp.rename(item.path);
  }

  /// 并发下载，跳过已完整的文件
  Future<void> downloadAll(List<DownloadItem> items, void Function(int done, int total) onProgress) async {
    final unique = {for (final i in items) i.path: i}.values;
    final pending = <DownloadItem>[];
    for (final item in unique) {
      if (!await isComplete(item)) pending.add(item);
    }
    var done = 0;
    final total = pending.length;
    onProgress(0, total);
    if (total == 0) return;

    final errors = <Object>[];
    var cursor = 0;
    Future<void> worker() async {
      while (cursor < pending.length) {
        final item = pending[cursor++];
        try {
          await downloadFile(item);
        } catch (e) {
          errors.add(e);
        }
        onProgress(++done, total);
      }
    }

    await Future.wait(List.generate(max(1, min(concurrency, 64)), (_) => worker()));
    if (errors.isNotEmpty) throw Exception('${errors.length} 个文件下载失败，例如：${errors.first}');
  }
}
