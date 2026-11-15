import 'dart:async';

import 'package:flutter/material.dart';

import '../app_info.dart';

/// 启动画面：图标和名称淡入放大；等背景图片和主题色准备好（[ready]）后淡出，露出界面。
/// 设了背景图片时，背景是异步加载的，没有这一层会先闪一下没有背景的界面再切换。
/// 至少显示一小会儿让动画播完，最多等 3 秒（加载卡住也不会一直挡着）
class LaunchSplash extends StatefulWidget {
  const LaunchSplash({super.key, required this.ready, required this.child});

  final bool ready;
  final Widget child;

  @override
  State<LaunchSplash> createState() => _LaunchSplashState();
}

class _LaunchSplashState extends State<LaunchSplash> with TickerProviderStateMixin {
  static const _minShow = Duration(milliseconds: 650);
  static const _maxWait = Duration(seconds: 3);

  late final _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 520))..forward();
  late final _outro = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
  bool _minDone = false, _timedOut = false, _gone = false;
  Timer? _min, _max;

  @override
  void initState() {
    super.initState();
    _min = Timer(_minShow, () => setState(() => _minDone = true));
    _max = Timer(_maxWait, () => setState(() => _timedOut = true));
    _outro.addStatusListener((s) {
      if (s == AnimationStatus.completed) setState(() => _gone = true);
    });
  }

  @override
  void dispose() {
    _min?.cancel();
    _max?.cancel();
    _intro.dispose();
    _outro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gone) return widget.child;
    if (_minDone && (widget.ready || _timedOut) && !_outro.isAnimating && !_outro.isCompleted) _outro.forward();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final intro = CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic);
    return Stack(
      fit: StackFit.expand,
      children: [
        // 界面在下面照常建好（背景、首页数据同时加载），淡出时直接露出来
        widget.child,
        FadeTransition(
          opacity: ReverseAnimation(CurvedAnimation(parent: _outro, curve: Curves.easeInCubic)),
          child: ColoredBox(
            color: scheme.surface,
            child: Center(
              child: FadeTransition(
                opacity: intro,
                child: ScaleTransition(
                  scale: Tween(begin: .86, end: 1.0).animate(intro),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/icon/icon.png', width: 72, height: 72, filterQuality: FilterQuality.medium),
                      const SizedBox(height: 14),
                      Text(
                        AppInfo.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
