import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/changelog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('loadChangelog', () {
    test('当前版本随安装包打包了更新日志', () async {
      final log = await loadChangelog(currentChangelogVersion);
      expect(log, isNotNull);
      expect(log, contains('## '));
    });

    test('nightly 复用的更新日志也已打包', () async {
      expect(await loadChangelog(nightlyChangelogVersion), isNotNull);
    });

    test('没有更新日志的版本返回 null', () async {
      expect(await loadChangelog('0.0.0-none'), isNull);
    });
  });

  group('changelogVersionFor', () {
    test('nightly 用下一个版本，其他通道用自身版本', () {
      expect(changelogVersionFor('0.3.3', 'nightly'), nightlyChangelogVersion);
      expect(changelogVersionFor('0.3.3', 'stable'), '0.3.3');
      expect(changelogVersionFor('0.3.3', 'preview'), '0.3.3');
    });
  });

  group('changelogSummary', () {
    test('跳过标题，带上所属的小标题', () {
      const md = '## 新增\n\n- **macOS 支持 1.12.2。**\n- 其他内容';
      expect(changelogSummary(md), '新增：macOS 支持 1.12.2。');
    });

    test('去掉链接与强调标记', () {
      const md = '## 修复\n\n- 修复 [某问题](https://example.invalid)，见 `issue`';
      expect(changelogSummary(md), '修复：修复 某问题，见 issue');
    });

    test('过长的内容截断并加省略号', () {
      final md = '## 新增\n\n- ${'长' * 200}';
      final summary = changelogSummary(md, maxLength: 20);
      expect(summary, '新增：${'长' * 20}…');
    });

    test('没有任何内容时返回空字符串', () {
      expect(changelogSummary('## 新增\n\n'), '');
    });
  });
}
