import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import '../app_scope.dart';
import '../core/changelog.dart';
import '../core/news.dart';
import '../core/site_api.dart';
import '../core/updater.dart';

/// 首页提示：正在使用的版本与免费声明（参照 PCL-CE 首页的提示）
class HomeHints extends StatelessWidget {
  const HomeHints({super.key, this.compact = false});

  /// 桌面：合成一张低调的小卡片；「测试版」那句可以关掉，免费声明一直保留
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) return const _CompactHints();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Hint(
          icon: Icons.info_outline,
          text:
              '你正在使用 ${AppInfo.name} ${AppInfo.version} 测试版。这是第三方 Minecraft 启动器，'
              '功能还在完善中，遇到问题请到 GitHub 反馈。',
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

class _CompactHints extends StatelessWidget {
  const _CompactHints();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cfg = AppScope.of(context).config;
    final showBeta = cfg.dismissedBetaHint != AppInfo.version;
    final style = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.5);
    Widget link(String label, String url) => TextButton(
      onPressed: () => launchUrl(Uri.parse(url)),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 30),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: VisualDensity.compact,
      ),
      child: Text(label),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(Icons.info_outline, size: 17, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  [
                    if (showBeta) '${AppInfo.name} ${AppInfo.version} 测试版，功能还在完善中，遇到问题请到 GitHub 反馈。',
                    '本软件完全免费、开源。如果你是付费获得的，请向卖家申请退款，并从 GitHub 获取正版。',
                  ].join('\n'),
                  style: style,
                ),
              ),
              if (showBeta)
                IconButton(
                  tooltip: '关闭测试版提示（免费声明会保留）',
                  onPressed: () => cfg.update({'dismissedBetaHint': AppInfo.version}),
                  visualDensity: VisualDensity.compact,
                  iconSize: 16,
                  icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showBeta) link('反馈问题', '${AppInfo.repoUrl}/issues'),
              link('获取正版', '${AppInfo.repoUrl}/releases'),
            ],
          ),
        ],
      ),
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

/// 首页的更新日志提示条：显示当前版本的更新日志（随发布包打包的 release-notes/v<版本>.md），
/// 可以展开全文；关闭后同一个版本不再显示，换版本后重新出现
class ChangelogHint extends StatefulWidget {
  const ChangelogHint({super.key});

  @override
  State<ChangelogHint> createState() => _ChangelogHintState();
}

class _ChangelogHintState extends State<ChangelogHint> {
  // 每次启动只读一次资源，切换页面不会重复读取
  final _future = loadCurrentChangelog();
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cfg = AppScope.of(context).config;
    // 主色相必须为蓝色，与首页其他提示条一致
    final fg = scheme.onSecondaryContainer;
    return FutureBuilder<String?>(
      future: _future,
      builder: (context, snap) {
        final log = snap.data;
        final version = currentChangelogVersion;
        if (log == null || cfg.dismissedChangelog == version) return const SizedBox.shrink();
        final summary = changelogSummary(log);
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Material(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.new_releases_outlined, color: fg, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '更新日志 · v$version${AppInfo.channel == 'nightly' ? '（Nightly）' : ''}',
                              style: theme.textTheme.titleSmall?.copyWith(color: fg, fontWeight: FontWeight.bold),
                            ),
                            if (!_expanded && summary.isNotEmpty)
                              Text(
                                summary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(color: fg),
                              ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _expanded = !_expanded),
                        child: Text(_expanded ? '收起' : '展开'),
                      ),
                      IconButton(
                        tooltip: '关闭',
                        onPressed: () => cfg.update({'dismissedChangelog': version}),
                        icon: Icon(Icons.close, size: 20, color: fg),
                      ),
                    ],
                  ),
                  if (_expanded)
                    Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 4),
                      child: MarkdownBody(
                        data: log,
                        onTapLink: (_, href, _) {
                          final uri = href == null ? null : Uri.tryParse(href);
                          if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
                            launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                          p: theme.textTheme.bodyMedium?.copyWith(color: fg),
                          a: theme.textTheme.bodyMedium?.copyWith(color: fg, decoration: TextDecoration.underline),
                          code: theme.textTheme.bodyMedium?.copyWith(color: fg, fontFamily: 'monospace'),
                          listBullet: theme.textTheme.bodyMedium?.copyWith(color: fg),
                          h2: theme.textTheme.titleSmall?.copyWith(color: fg, fontWeight: FontWeight.bold),
                          h3: theme.textTheme.titleSmall?.copyWith(color: fg),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 顶栏「公告」按钮：当前版本的更新日志提示和启动器公告
Future<void> showNoticesDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text('公告'),
    content: const SizedBox(
      width: 560,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [ChangelogHint(), HomeNotices(showEmpty: true)],
        ),
      ),
    ),
    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭'))],
  ),
);

/// 首页公告：来自自有静态接口（notices.json），失败或没有公告时不显示任何内容
class HomeNotices extends StatefulWidget {
  const HomeNotices({super.key, this.showEmpty = false});

  /// 没有公告时显示一行「暂无公告」（用在公告对话框里）
  final bool showEmpty;

  @override
  State<HomeNotices> createState() => _HomeNoticesState();
}

class _HomeNoticesState extends State<HomeNotices> {
  // 每次启动只获取一次，切换页面不会重复请求
  final _future = loadNotices();

  @override
  Widget build(BuildContext context) {
    final cfg = AppScope.of(context).config;
    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        final now = DateTime.now();
        final dismissed = cfg.dismissedNotices.toSet();
        final shown = [
          for (final n in snap.data ?? const <Notice>[])
            if (n.visibleFor(
              platform: noticePlatform,
              channel: UpdateChannel.parse(cfg.updateChannel).name,
              version: AppInfo.version,
              now: now,
              dismissed: dismissed,
            ))
              n,
        ];
        if (shown.isEmpty) {
          if (!widget.showEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              snap.connectionState == ConnectionState.waiting ? '正在获取公告…' : '暂无公告',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.only(top: widget.showEmpty ? 0 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final n in shown)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _NoticeCard(
                    key: ValueKey(n.id),
                    notice: n,
                    onDismiss: () => cfg.update({
                      'dismissedNotices': [...cfg.dismissedNotices, n.id],
                    }),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({super.key, required this.notice, required this.onDismiss});

  final Notice notice;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (icon, bg, fg) = switch (notice.level) {
      NoticeLevel.info => (Icons.campaign_outlined, scheme.secondaryContainer, scheme.onSecondaryContainer),
      NoticeLevel.warning => (Icons.warning_amber_rounded, scheme.tertiaryContainer, scheme.onTertiaryContainer),
      NoticeLevel.error => (Icons.error_outline, scheme.errorContainer, scheme.onErrorContainer),
    };
    final url = notice.url;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, color: fg, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      notice.title,
                      style: theme.textTheme.titleSmall?.copyWith(color: fg, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (notice.body.trim().isNotEmpty)
                    MarkdownBody(
                      data: notice.body,
                      onTapLink: (_, href, _) {
                        final uri = href == null ? null : Uri.tryParse(href);
                        if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
                          launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                        p: theme.textTheme.bodyMedium?.copyWith(color: fg),
                        a: theme.textTheme.bodyMedium?.copyWith(color: fg, decoration: TextDecoration.underline),
                        code: theme.textTheme.bodyMedium?.copyWith(color: fg, fontFamily: 'monospace'),
                        listBullet: theme.textTheme.bodyMedium?.copyWith(color: fg),
                      ),
                    ),
                ],
              ),
            ),
            if (url != null)
              TextButton(
                onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
                child: Text(notice.urlText ?? '查看详情'),
              ),
            if (notice.dismissible)
              IconButton(
                tooltip: '关闭',
                onPressed: onDismiss,
                icon: Icon(Icons.close, size: 20, color: fg),
              ),
            if (!notice.dismissible) const SizedBox(width: 8),
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
