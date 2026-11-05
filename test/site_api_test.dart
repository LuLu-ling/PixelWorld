import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/site_api.dart';
import 'package:pcl_pw/core/updater.dart';

Map<String, dynamic> release(String tag, {bool pre = false, String commit = 'abc'}) => {
  'tag': tag,
  'name': 'PCL.PW $tag',
  'body': '更新内容',
  'prerelease': pre,
  'commit': commit,
  'publishedAt': '2026-11-05T12:00:00Z',
  'page': 'https://example.invalid/releases/tag/$tag',
  'assets': [
    {'name': 'PCL.PW-0.3.0-android-arm64.apk', 'url': 'https://example.invalid/a.apk', 'size': 123, 'sha256': 'A' * 64},
    {'name': 'b.zip', 'url': 'https://example.invalid/b.zip', 'size': 5, 'sha256': null},
  ],
};

Notice notice(Map<String, dynamic> extra) => Notice.tryParse({'id': 'n1', 'title': '标题', ...extra})!;

bool visible(
  Notice n, {
  String platform = 'windows',
  String channel = 'stable',
  String version = '0.3.0',
  DateTime? now,
  Set<String> dismissed = const {},
}) => n.visibleFor(
  platform: platform,
  channel: channel,
  version: version,
  now: now ?? DateTime.utc(2026, 11, 5),
  dismissed: dismissed,
);

void main() {
  group('Release.fromSite', () {
    test('解析发布条目', () {
      final r = Release.fromSite(release('v0.3.0'));
      expect(r.tag, 'v0.3.0');
      expect(r.version, '0.3.0');
      expect(r.name, 'PCL.PW v0.3.0');
      expect(r.body, '更新内容');
      expect(r.prerelease, isFalse);
      expect(r.commit, 'abc');
      expect(r.publishedAt, DateTime.utc(2026, 11, 5, 12));
      expect(r.page, contains('v0.3.0'));
      expect(r.assets, hasLength(2));
      expect(r.assets[0].size, 123);
      expect(r.assets[0].sha256, 'a' * 64);
      expect(r.assets[1].sha256, isNull);
      expect(assetFor(r, android: true)?.url, 'https://example.invalid/a.apk');
    });

    test('nightly 按提交号判断', () {
      final r = Release.fromSite(release('nightly', pre: true, commit: 'abcdef1234567890'));
      expect(r.isNightly, isTrue);
      expect(isNewer(r, currentCommit: 'abcdef1'), isFalse);
      expect(isNewer(r, currentCommit: '1234567'), isTrue);
    });

    test('不合法的 sha256 被忽略', () {
      final j = release('v1.0.0');
      (j['assets'] as List)[0]['sha256'] = 'xyz';
      expect(Release.fromSite(j).assets[0].sha256, isNull);
    });
  });

  group('update.json', () {
    test('解析各通道，null 通道不出现', () {
      final m = parseUpdateChannels({
        'format': 1,
        'channels': {'stable': release('v0.3.0'), 'preview': null, 'nightly': release('nightly', pre: true)},
      })!;
      expect(m.keys, unorderedEquals(['stable', 'nightly']));
      expect(m['stable']!.tag, 'v0.3.0');
    });

    test('format 不为 1 时忽略', () {
      expect(parseUpdateChannels({'format': 2, 'channels': {}}), isNull);
      expect(parseUpdateChannels({'channels': {}}), isNull);
    });

    test('channels 缺失或条目无效时不崩溃', () {
      expect(parseUpdateChannels({'format': 1}), isNull);
      final m = parseUpdateChannels({
        'format': 1,
        'channels': {
          'stable': {'name': '没有标签'},
          'preview': 'bad',
        },
      })!;
      expect(m, isEmpty);
    });
  });

  group('Notice 解析', () {
    test('完整字段', () {
      final n = Notice.tryParse({
        'id': 'a',
        'level': 'warning',
        'title': 'T',
        'body': '**B**',
        'url': 'https://example.invalid/x',
        'urlText': '查看详情',
        'platforms': ['windows'],
        'channels': ['stable'],
        'minVersion': '0.3.0',
        'maxVersion': '0.4.0',
        'start': '2026-11-01T00:00:00Z',
        'end': '2026-12-01T00:00:00Z',
        'dismissible': false,
        'unknown': 1,
      })!;
      expect(n.level, NoticeLevel.warning);
      expect(n.url, 'https://example.invalid/x');
      expect(n.urlText, '查看详情');
      expect(n.platforms, ['windows']);
      expect(n.dismissible, isFalse);
      expect(n.start, DateTime.utc(2026, 11, 1));
    });

    test('默认值', () {
      final n = notice({});
      expect(n.level, NoticeLevel.info);
      expect(n.body, '');
      expect(n.dismissible, isTrue);
      expect(n.platforms, isNull);
      expect(notice({'level': 'weird'}).level, NoticeLevel.info);
    });

    test('非 http(s) 链接被丢弃', () {
      expect(notice({'url': 'file:///c:/windows'}).url, isNull);
      expect(notice({'url': 'javascript:alert(1)'}).url, isNull);
    });

    test('格式不是 1 时忽略整个文件', () {
      expect(
        Notice.parseAll({
          'format': 2,
          'notices': [
            {'id': 'a', 'title': 'T'},
          ],
        }),
        isEmpty,
      );
    });

    test('无效条目被跳过，重复编号只保留第一个', () {
      final list = Notice.parseAll({
        'format': 1,
        'notices': [
          {'id': 'a', 'title': 'T'},
          'oops',
          null,
          {'title': '没有编号'},
          {'id': 'b'},
          {'id': 'c', 'title': 5},
          {'id': 'a', 'title': '重复'},
          {'id': 'd', 'title': 'D', 'platforms': 'windows'},
          {'id': 'e', 'title': 'E'},
        ],
      });
      expect(list.map((n) => n.id), ['a', 'd', 'e']);
      expect(list.first.title, 'T');
      expect(list[1].platforms, isNull);
    });

    test('notices 不是列表时返回空', () {
      expect(Notice.parseAll({'format': 1, 'notices': {}}), isEmpty);
      expect(Notice.parseAll({'format': 1}), isEmpty);
    });
  });

  group('Notice.visibleFor', () {
    test('没有限制时总是显示', () {
      expect(visible(notice({})), isTrue);
    });

    test('平台与通道', () {
      final n = notice({
        'platforms': ['android', 'macos'],
        'channels': ['preview'],
      });
      expect(visible(n, platform: 'windows', channel: 'preview'), isFalse);
      expect(visible(n, platform: 'android', channel: 'stable'), isFalse);
      expect(visible(n, platform: 'android', channel: 'preview'), isTrue);
    });

    test('版本范围含边界', () {
      final n = notice({'minVersion': '0.3.0', 'maxVersion': '0.4.0'});
      expect(visible(n, version: '0.2.9'), isFalse);
      expect(visible(n, version: '0.3.0'), isTrue);
      expect(visible(n, version: '0.4.0'), isTrue);
      expect(visible(n, version: '0.4.1'), isFalse);
      expect(visible(notice({'minVersion': '0.3.0'}), version: '0.9.0'), isTrue);
      expect(visible(notice({'maxVersion': '0.3.0'}), version: '0.1.0'), isTrue);
    });

    test('显示时间窗口', () {
      final n = notice({'start': '2026-11-01T00:00:00Z', 'end': '2026-11-10T00:00:00Z'});
      expect(visible(n, now: DateTime.utc(2026, 10, 31)), isFalse);
      expect(visible(n, now: DateTime.utc(2026, 11, 5)), isTrue);
      expect(visible(n, now: DateTime.utc(2026, 11, 11)), isFalse);
    });

    test('已关闭的公告不再显示，不可关闭的除外', () {
      expect(visible(notice({}), dismissed: {'n1'}), isFalse);
      expect(visible(notice({}), dismissed: {'other'}), isTrue);
      expect(visible(notice({'dismissible': false}), dismissed: {'n1'}), isTrue);
    });
  });
}
