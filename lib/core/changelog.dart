import 'package:flutter/services.dart';

import '../app_info.dart';

/// 随安装包打包的更新日志，与发布说明使用同一份文件（release-notes/v<版本>.md）
String changelogAsset(String version) => 'release-notes/v$version.md';

/// Nightly 构建没有自己的发布说明，复用下一个版本的更新日志；
/// 发版时把这里跟着改成再下一个版本（同时先写好对应的 release-notes）
const nightlyChangelogVersion = '0.3.4';

/// 这个构建应显示的更新日志版本：nightly 用下一个版本的说明，其余用自身版本
String changelogVersionFor(String version, String channel) => channel == 'nightly' ? nightlyChangelogVersion : version;

/// 当前构建应显示的更新日志版本
String get currentChangelogVersion => changelogVersionFor(AppInfo.version, AppInfo.channel);

/// 读取指定版本的更新日志；没有这个文件或内容为空时返回 null
Future<String?> loadChangelog(String version) async {
  try {
    final text = (await rootBundle.loadString(changelogAsset(version))).trim();
    return text.isEmpty ? null : text;
  } catch (_) {
    // 没有写发布说明的版本没有对应文件
    return null;
  }
}

Future<String?>? _current;

/// 当前构建的更新日志，整个进程只读一次
Future<String?> loadCurrentChangelog() => _current ??= loadChangelog(currentChangelogVersion);

/// 更新日志的第一条内容，收起时用于提示；去掉 Markdown 标记，并带上所属的小标题
String changelogSummary(String markdown, {int maxLength = 90}) {
  String? section;
  for (final line in markdown.split('\n')) {
    var text = line.trim();
    if (text.isEmpty) continue;
    if (text.startsWith('#')) {
      section = text.replaceFirst(RegExp(r'^#+\s*'), '').trim();
      continue;
    }
    text = text.replaceFirst(RegExp(r'^[-*+]\s+'), '');
    text = text.replaceAllMapped(RegExp(r'\[([^\]]*)\]\([^)]*\)'), (m) => m.group(1)!);
    text = text.replaceAll(RegExp(r'[*_`>]'), '');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.isEmpty) continue;
    if (text.length > maxLength) text = '${text.substring(0, maxLength)}…';
    return section == null || section.isEmpty ? text : '$section：$text';
  }
  return '';
}
