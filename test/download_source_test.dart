import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/network_check.dart';

NetResult ok(int kbPerSec) => NetResult.ok(
  latency: const Duration(milliseconds: 100),
  bytes: kbPerSec * 1024,
  elapsed: const Duration(seconds: 1),
);

void main() {
  test('自动选择：一边连不上就用另一边', () {
    expect(DownloadSourcePicker.decide(const NetResult.failed('超时'), ok(500)), isTrue);
    expect(DownloadSourcePicker.decide(ok(500), const NetResult.failed('超时')), isFalse);
  });

  test('自动选择：官方源明显更快（1.3 倍以上）才用官方源', () {
    expect(DownloadSourcePicker.decide(ok(1000), ok(500)), isFalse);
    expect(DownloadSourcePicker.decide(ok(600), ok(500)), isTrue);
    expect(DownloadSourcePicker.decide(ok(200), ok(500)), isTrue);
  });

  test('下载时另一边成功会改为优先它', () {
    DownloadSourcePicker.reportFallback(mirrorWorked: false);
    expect(DownloadSourcePicker.preferMirror, isFalse);
    DownloadSourcePicker.reportFallback(mirrorWorked: true);
    expect(DownloadSourcePicker.preferMirror, isTrue);
  });
}
