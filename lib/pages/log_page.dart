import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../app_state.dart';
import '../widgets/side_nav.dart';

/// 游戏日志：实时输出，自动滚动到底部
class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final _scroll = ScrollController();
  bool _follow = true;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Color _lineColor(String line, ColorScheme s) {
    if (RegExp(r'/(ERROR|FATAL)\]|Exception|^\s+at ').hasMatch(line)) return s.error;
    if (line.contains('/WARN]')) return s.tertiary;
    if (line.startsWith('[Pixel World]') || line.startsWith('[PCL.PW]')) return s.primary;
    return s.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: ContentPanel(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(switch (state.gameState) {
                      GameState.running => '游戏运行中',
                      GameState.preparing => '正在启动',
                      GameState.idle => state.lastExitCode == null ? '游戏未运行' : '游戏已退出，代码 ${state.lastExitCode}',
                    }, style: Theme.of(context).textTheme.titleSmall),
                  ),
                  FilterChip(
                    label: const Text('自动滚动'),
                    selected: _follow,
                    onSelected: (v) => setState(() => _follow = v),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: '复制全部',
                    icon: const Icon(Icons.copy_all_outlined),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: state.log.value.join('\n')));
                      toast(context, '已复制日志');
                    },
                  ),
                  if (state.gameState == GameState.running)
                    TextButton.icon(onPressed: state.killGame, icon: const Icon(Icons.stop), label: const Text('结束游戏')),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: state.log,
                builder: (context, lines, _) {
                  if (_follow) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
                    });
                  }
                  if (lines.isEmpty) {
                    return Center(
                      child: Text('启动游戏后，日志会显示在这里', style: TextStyle(color: scheme.onSurfaceVariant)),
                    );
                  }
                  return SelectionArea(
                    child: ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: lines.length,
                      itemBuilder: (context, i) => Text(
                        lines[i],
                        style: TextStyle(
                          fontFamily: 'Consolas',
                          fontFamilyFallback: const ['Cascadia Mono', 'Menlo', 'monospace', 'Microsoft YaHei UI'],
                          fontSize: 12.5,
                          height: 1.45,
                          color: _lineColor(lines[i], scheme),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
