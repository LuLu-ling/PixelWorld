import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/download.dart';

void main() {
  late Directory dir;
  late HttpServer server;
  final body = List.generate(4096, (i) => i % 251);
  final good = sha1.convert(body).toString();
  var hits = 0;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('pclpw_verify');
    hits = 0;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      hits++;
      req.response.add(req.uri.path == '/short' ? body.sublist(0, 100) : body);
      await req.response.close();
    });
  });

  tearDown(() async {
    await server.close(force: true);
    await dir.delete(recursive: true);
  });

  String url(String name) => 'http://127.0.0.1:${server.port}/$name';
  Downloader dl() => Downloader(useMirror: false, concurrency: 2);

  test('大小相同但内容损坏的文件，有 SHA-1 时会被重新下载', () async {
    final path = p.join(dir.path, 'a.jar');
    File(path).writeAsBytesSync(List.filled(body.length, 0));
    final item = DownloadItem(url: url('a'), path: path, sha1: good, size: body.length);
    expect(await Downloader.isComplete(item), isFalse);
    await dl().downloadAll([item], (_, _) {});
    expect(File(path).readAsBytesSync(), body);
    expect(await Downloader.isComplete(item), isTrue);
  });

  test('只有大小信息时按大小判断', () async {
    final path = p.join(dir.path, 'b');
    File(path).writeAsBytesSync([1, 2, 3]);
    expect(await Downloader.isComplete(DownloadItem(url: url('b'), path: path, size: 3)), isTrue);
    expect(await Downloader.isComplete(DownloadItem(url: url('b'), path: path, size: 4)), isFalse);
    expect(await Downloader.isComplete(DownloadItem(url: url('b'), path: path)), isTrue);
    File(path).writeAsBytesSync([]);
    expect(await Downloader.isComplete(DownloadItem(url: url('b'), path: path)), isFalse);
  });

  test('SHA-1 不匹配时不写入正式文件', () async {
    final path = p.join(dir.path, 'c.jar');
    final item = DownloadItem(url: url('c'), path: path, sha1: '0' * 40);
    await expectLater(dl().downloadFile(item), throwsException);
    expect(File(path).existsSync(), isFalse);
    expect(dir.listSync(), isEmpty, reason: '不应留下临时文件');
  });

  test('下载到的大小与预期不符时不写入正式文件', () async {
    final path = p.join(dir.path, 'd.jar');
    final item = DownloadItem(url: url('short'), path: path, size: body.length);
    await expectLater(dl().downloadFile(item), throwsException);
    expect(File(path).existsSync(), isFalse);
  });

  test('校验过的文件不再重复下载，文件被改动后重新校验', () async {
    final path = p.join(dir.path, 'e.jar');
    final item = DownloadItem(url: url('e'), path: path, sha1: good, size: body.length);
    await dl().downloadAll([item], (_, _) {});
    expect(hits, 1);
    await dl().downloadAll([item], (_, _) {});
    expect(hits, 1);
    // 同样大小、不同内容，修改时间变化
    await Future<void>.delayed(const Duration(milliseconds: 20));
    File(path).writeAsBytesSync(List.filled(body.length, 9));
    File(path).setLastModifiedSync(DateTime.now().add(const Duration(seconds: 5)));
    await dl().downloadAll([item], (_, _) {});
    expect(hits, 2);
    expect(File(path).readAsBytesSync(), body);
  });

  test('GitHub 地址带 ghproxy 镜像回退，其他地址没有', () {
    const url = 'https://github.com/a/b/releases/download/v1/x.jar';
    final mirrors = githubMirrorsFor(url);
    expect(mirrors, contains('https://ghproxy.net/$url'));
    expect(mirrors, contains('https://gh-proxy.com/$url'));
    expect(mirrors, contains('https://ghfast.top/$url'));
    expect(githubMirrorsFor('https://raw.githubusercontent.com/a/b/main/x.json'), isNotEmpty);
    expect(githubMirrorsFor('https://libraries.minecraft.net/x.jar'), isEmpty);
  });
}
