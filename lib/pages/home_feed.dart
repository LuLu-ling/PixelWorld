import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import '../app_scope.dart';
import '../core/news.dart';

/// 首页提示：正在使用的版本与免费声明（参照 PCL-CE 首页的提示）
class HomeHints extends StatelessWidget {
  const HomeHints({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Hint(
          icon: Icons.info_outline,
          text:
              '你正在使用 ${AppInfo.name} ${AppInfo.version} 测试版。这是第三方基于 PCL 二次创作的启动器，'
              '功能还在完善中，遇到问题请到 GitHub 反馈，不要打扰 PCL 作者。',
          action: ('反馈问题', '${AppInfo.repoUrl}/issues'),
        ),
        const SizedBox(height: 8),
        _Hint(
          icon: Icons.volunteer_activism_outlined,
          text: '本软件完全免费、开源。如果你是付费购买或下载的，那么你可能被骗了，请向卖家申请退款，并从 GitHub 获取正版。',
          action: ('获取正版', '${AppInfo.repoUrl}/releases'),
          warning: true,
        ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text, required this.action, this.warning = false});

  final IconData icon;
  final String text;
  final (String, String) action;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // 主色相必须为蓝色，警示用错误色只用于图标
    final bg = scheme.secondaryContainer;
    final fg = scheme.onSecondaryContainer;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Icon(icon, color: warning ? scheme.error : fg, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: fg)),
            ),
            TextButton(onPressed: () => launchUrl(Uri.parse(action.$2)), child: Text(action.$1)),
          ],
        ),
      ),
    );
  }
}

/// Minecraft 版本动态（简介来自中文 Minecraft Wiki）
class VersionNewsFeed extends StatefulWidget {
  const VersionNewsFeed({super.key});

  @override
  State<VersionNewsFeed> createState() => _VersionNewsFeedState();
}

class _VersionNewsFeedState extends State<VersionNewsFeed> {
  late Future<List<VersionNews>> _future = loadVersionNews(AppScope.read(context).downloader);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
          child: Row(
            children: [
              Text('Minecraft 版本动态', style: theme.textTheme.titleMedium),
              const SizedBox(width: 8),
              Text('来自 Minecraft Wiki', style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
              const Spacer(),
              IconButton(
                tooltip: '刷新',
                onPressed: () => setState(() => _future = loadVersionNews(AppScope.read(context).downloader)),
                icon: const Icon(Icons.refresh, size: 20),
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: _future,
          builder: (context, snap) {
            if (snap.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text('加载失败：${errorText(snap.error!)}', style: TextStyle(color: scheme.onSurfaceVariant)),
              );
            }
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return Column(children: [for (final n in snap.data!) _NewsCard(news: n)]);
          },
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.news});

  final VersionNews news;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final release = news.type == 'release';
    final t = news.releaseTime;
    return Card.filled(
      color: scheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(news.wikiUrl)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.image != null)
              SizedBox(
                width: 180,
                height: 112,
                child: Image.network(
                  news.image!,
                  fit: BoxFit.cover,
                  cacheWidth: 360,
                  errorBuilder: (_, _, _) => ColoredBox(color: scheme.surfaceContainerHighest),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: release ? scheme.primaryContainer : scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            release ? '正式版' : '快照',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: release ? scheme.onPrimaryContainer : scheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(news.id, style: theme.textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                        ),
                        Text(
                          '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}',
                          style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      news.summary.isEmpty ? 'Minecraft Wiki 还没有这个版本的介绍，点击查看页面。' : news.summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
