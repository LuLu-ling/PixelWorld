import 'package:intl/intl.dart';

import '../l10n/l10n.dart';

/// 下载量等数字，按界面语言缩写：1.2万、1.2K
String formatCount(AppLocalizations l, int n) =>
    NumberFormat.compact(locale: l.localeName == 'zh_Hant' ? 'zh_TW' : l.localeName).format(n);

String formatSize(int bytes) {
  if (bytes >= 1 << 30) return '${(bytes / (1 << 30)).toStringAsFixed(1)} GB';
  if (bytes >= 1 << 20) return '${(bytes / (1 << 20)).toStringAsFixed(1)} MB';
  if (bytes >= 1 << 10) return '${(bytes / (1 << 10)).toStringAsFixed(0)} KB';
  return '$bytes B';
}

/// 3 天前、2 个月前
String timeAgo(AppLocalizations l, String iso) {
  final t = DateTime.tryParse(iso);
  if (t == null) return '';
  final d = DateTime.now().difference(t);
  if (d.inDays >= 365) return l.formatOtherYearsAgo(d.inDays ~/ 365);
  if (d.inDays >= 30) return l.formatOtherMonthsAgo(d.inDays ~/ 30);
  if (d.inDays >= 1) return l.formatOtherDaysAgo(d.inDays);
  if (d.inHours >= 1) return l.formatOtherHoursAgo(d.inHours);
  return l.formatJustNow;
}

String formatDate(DateTime t) =>
    '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} '
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
