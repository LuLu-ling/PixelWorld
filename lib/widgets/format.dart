/// 下载量等数字：1.2 万、3.0 亿
String formatCount(int n) {
  if (n >= 100000000) return '${(n / 100000000).toStringAsFixed(1)} 亿';
  if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)} 万';
  return '$n';
}

String formatSize(int bytes) {
  if (bytes >= 1 << 30) return '${(bytes / (1 << 30)).toStringAsFixed(1)} GB';
  if (bytes >= 1 << 20) return '${(bytes / (1 << 20)).toStringAsFixed(1)} MB';
  if (bytes >= 1 << 10) return '${(bytes / (1 << 10)).toStringAsFixed(0)} KB';
  return '$bytes B';
}

/// 3 天前、2 个月前
String timeAgo(String iso) {
  final t = DateTime.tryParse(iso);
  if (t == null) return '';
  final d = DateTime.now().difference(t);
  if (d.inDays >= 365) return '${d.inDays ~/ 365} 年前';
  if (d.inDays >= 30) return '${d.inDays ~/ 30} 个月前';
  if (d.inDays >= 1) return '${d.inDays} 天前';
  if (d.inHours >= 1) return '${d.inHours} 小时前';
  return '刚刚';
}

String formatDate(DateTime t) =>
    '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} '
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
