import 'dart:io';

import 'package:path/path.dart' as p;

import '../../app_state.dart';
import '../android_storage.dart';
import '../paths.dart';
import '../safe_path.dart';

/// AI 可以访问的一个文件夹（「根」）。模型只看到 [id] 和相对路径，看不到 [path]。
enum RootKind { workspace, game, downloads, user }

class AgentRoot {
  const AgentRoot({required this.id, required this.label, required this.path, required this.writable, required this.kind});

  /// 小写字母、数字和连字符
  final String id;
  final String label;

  /// 真实的绝对路径（已解析符号链接）
  final String path;
  final bool writable;
  final RootKind kind;
}

/// AI 自己的工作区：应用数据目录下，可以随意读写
String get aiWorkspaceDir => p.join(Paths.appData, 'ai', 'workspace');

/// 删除的文件移到这里，不直接删掉
String get aiTrashDir => p.join(Paths.appData, 'ai', 'trash');

final rootIdPattern = RegExp(r'^[a-z0-9][a-z0-9-]{0,31}$');

String? _real(String path) {
  try {
    final d = Directory(path);
    return d.existsSync() ? d.resolveSymbolicLinksSync() : null;
  } catch (_) {
    return null;
  }
}

/// 当前可用的根。内置根在运行时生成（路径不会过期），用户根来自设置。
/// 模型没有任何工具可以添加或修改根，只能由用户在设置界面操作。
Future<List<AgentRoot>> agentRoots(AppState state) async {
  final roots = <AgentRoot>[];
  final ws = Directory(aiWorkspaceDir);
  if (!ws.existsSync()) ws.createSync(recursive: true);
  roots.add(AgentRoot(id: 'workspace', label: 'AI 工作区', path: _real(ws.path) ?? ws.path, writable: true, kind: RootKind.workspace));

  // 当前版本的运行目录：只读，修改游戏文件仍然走带备份和校验的专用工具
  final v = state.selectedVersion;
  if (v != null) {
    try {
      final dir = _real(await state.gameDirOf(v));
      if (dir != null) {
        roots.add(AgentRoot(id: 'game', label: '当前版本（${v.id}）', path: dir, writable: false, kind: RootKind.game));
      }
    } catch (_) {}
  }

  if (Platform.isAndroid && await AndroidStorage.hasAccess()) {
    final dir = _real(p.join(AndroidStorage.root, 'Download'));
    if (dir != null) roots.add(AgentRoot(id: 'downloads', label: '下载目录', path: dir, writable: true, kind: RootKind.downloads));
  }

  final taken = {for (final r in roots) r.id};
  for (final r in state.config.aiUserRoots) {
    final id = '${r['id']}';
    final path = '${r['path']}';
    if (!rootIdPattern.hasMatch(id) || taken.contains(id) || !p.isAbsolute(path)) continue;
    final real = _real(path);
    if (real == null) continue;
    roots.add(AgentRoot(id: id, label: '${r['label'] ?? id}', path: real, writable: r['writable'] == true, kind: RootKind.user));
    taken.add(id);
  }
  return roots;
}

/// 给新添加的文件夹起一个 id：文件夹名里的字母数字，重复时加序号
String newRootId(String path, Iterable<String> taken) {
  final used = {...taken, 'workspace', 'game', 'downloads'};
  // 文件夹名：两种斜杠都认，不依赖当前系统的路径规则
  final name = path.split(RegExp(r'[\\/]')).lastWhere((s) => s.isNotEmpty, orElse: () => path);
  var base = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  base = base.replaceAll(RegExp(r'^-+|-+$'), '');
  if (base.isEmpty || !rootIdPattern.hasMatch(base)) base = 'folder';
  if (base.length > 24) base = base.substring(0, 24).replaceAll(RegExp(r'-+$'), '');
  var id = base;
  for (var i = 2; used.contains(id); i++) {
    id = '$base-$i';
  }
  return id;
}

/// 按「根 id + 相对路径」找到文件（界面上打开 AI 写的文件用）；不存在或不安全时返回 null
Future<File?> resolveAgentFile(AppState state, String rootId, String rel) async {
  final root = (await agentRoots(state)).where((r) => r.id == rootId).firstOrNull;
  if (root == null || rel.trim().isEmpty) return null;
  try {
    final f = File(resolveInside(root.path, rel.trim().replaceAll(r'\', '/')));
    return f.existsSync() ? f : null;
  } on UnsafePathException {
    return null;
  }
}
