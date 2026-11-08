import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/download.dart';

void main() {
  test('大文件使用 Range 分块并行下载', () async {
    final data = Uint8List(9 * 1024 * 1024)..fillRange(0, 9 * 1024 * 1024, 7);
    var requests = 0;
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      requests++;
      final range = req.headers.value(HttpHeaders.rangeHeader);
      if (range == null) {
        req.response.statusCode = HttpStatus.ok;
        req.response.add(data);
      } else {
        final m = RegExp(r'bytes=(\d+)-(\d+)').firstMatch(range);
        final start = int.parse(m!.group(1)!);
        final end = int.parse(m.group(2)!);
        req.response.statusCode = HttpStatus.partialContent;
        req.response.headers.set(HttpHeaders.contentRangeHeader, 'bytes $start-$end/${data.length}');
        req.response.add(data.sublist(start, end + 1));
      }
      await req.response.close();
    });

    final dir = await Directory.systemTemp.createTemp('pclpw_chunk');
    final item = DownloadItem(url: 'http://127.0.0.1:${server.port}/big', path: '${dir.path}/big', size: data.length);
    await Downloader(useMirror: false, concurrency: 1).downloadAll([item], (_, _) {});
    expect(requests, greaterThanOrEqualTo(4));
    expect(await File(item.path).length(), data.length);
    await server.close(force: true);
    await dir.delete(recursive: true);
  });
}
