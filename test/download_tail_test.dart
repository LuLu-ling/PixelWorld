import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/download.dart';

void main() {
  test('结尾卡住的连接会被另一个连接顶替', () async {
    final hits = <String, int>{};
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      final n = hits[req.uri.path] = (hits[req.uri.path] ?? 0) + 1;
      req.response.headers.contentType = ContentType.binary;
      // 第一个连接发一点数据后卡住，模拟分到的慢节点
      if (req.uri.path == '/stall' && n == 1) {
        req.response.add(List.filled(100, 1));
        await req.response.flush();
        await Future<void>.delayed(const Duration(seconds: 30));
      }
      req.response.add(List.filled(1000, 7));
      await req.response.close().catchError((_) {});
    });

    final dir = await Directory.systemTemp.createTemp('pclpw_dl');
    final items = [
      for (final name in ['a', 'b', 'c', 'stall'])
        DownloadItem(url: 'http://127.0.0.1:${server.port}/$name', path: '${dir.path}/$name'),
    ];
    final sw = Stopwatch()..start();
    await Downloader(useMirror: false, concurrency: 4).downloadAll(items, (_, _) {});
    sw.stop();

    expect(sw.elapsed.inSeconds, lessThan(10));
    expect(hits['/stall'], 2);
    for (final item in items) {
      expect(await File(item.path).length(), 1000);
    }
    await server.close(force: true);
    await dir.delete(recursive: true);
  });

  test('所有 worker 都被慢文件占住时也能补位', () async {
    final hits = <String, int>{};
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      final n = hits[req.uri.path] = (hits[req.uri.path] ?? 0) + 1;
      req.response.headers.contentType = ContentType.binary;
      if (req.uri.path == '/stall' && n == 1) {
        req.response.add(List.filled(100, 1));
        await req.response.flush();
        await Future<void>.delayed(const Duration(seconds: 30));
      }
      req.response.add(List.filled(1000, 7));
      await req.response.close().catchError((_) {});
    });

    final dir = await Directory.systemTemp.createTemp('pclpw_dl_one');
    final items = [
      DownloadItem(url: 'http://127.0.0.1:${server.port}/stall', path: '${dir.path}/stall', size: 1000),
      DownloadItem(url: 'http://127.0.0.1:${server.port}/fast', path: '${dir.path}/fast', size: 1000),
    ];
    final sw = Stopwatch()..start();
    await Downloader(useMirror: false, concurrency: 1).downloadAll(items, (_, _) {});
    sw.stop();

    expect(sw.elapsed.inSeconds, lessThan(10));
    expect(hits['/stall'], 2);
    for (final item in items) {
      expect(await File(item.path).length(), item.size);
    }
    await server.close(force: true);
    await dir.delete(recursive: true);
  });
}
