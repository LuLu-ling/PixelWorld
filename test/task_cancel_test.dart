import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/download.dart';
import 'package:pcl_pw/core/task.dart';

void main() {
  test('任务可以中断并标记步骤', () {
    final t = TaskProgress('测试', steps: const ['下载', '安装'], canCancel: true);
    t.beginStep('下载');
    t.cancel();
    expect(t.cancelled, isTrue);
    t.markCancelled();
    expect(t.state, TaskState.cancelled);
    expect(t.steps.first.state, TaskStepState.cancelled);
  });

  test('中断任务会删除登记的文件和目录', () async {
    final root = await Directory.systemTemp.createTemp('pclpw_cancel');
    final file = File('${root.path}/mods/a.jar');
    await file.parent.create(recursive: true);
    await file.writeAsString('x');
    final dir = Directory('${root.path}/versions/test')..createSync(recursive: true);
    final t = TaskProgress('测试', canCancel: true);
    t.registerCleanupPath(file.path);
    t.registerCleanupPath(dir.path);
    expect(await t.cleanupFiles(), 2);
    expect(file.existsSync(), isFalse);
    expect(dir.existsSync(), isFalse);
    await root.delete(recursive: true);
  });

  test('下载器响应任务中断', () async {
    final root = await Directory.systemTemp.createTemp('pclpw_cancel_dl');
    final item = DownloadItem(url: 'http://127.0.0.1:1/x', path: '${root.path}/x');
    final sw = Stopwatch()..start();
    await expectLater(
      Downloader(useMirror: false, concurrency: 1).downloadAll([item], (_, _) {}, cancelled: () => true),
      throwsA(anything),
    );
    expect(sw.elapsed.inSeconds, lessThan(5));
    await root.delete(recursive: true);
  });
}
