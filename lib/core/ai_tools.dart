import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import '../app_state.dart';
import '../widgets/loader_label.dart';
import '../widgets/optifine_compat.dart';
import 'ai_client.dart';
import 'crash.dart';
import 'instance.dart';
import 'instance_config.dart';
import 'install.dart';
import 'instance_files.dart';
import 'loaders.dart';
import 'modrinth.dart';
import 'paths.dart';

/// 操作的类型：只读操作默认直接执行；其余都要用户允许
enum ToolKind {
  read,

  /// 安装、启用或禁用、备份：可以在本次对话中允许同类操作
  write,

  /// 删除、替换、恢复：每次都要确认
  danger,
}

/// 准备好的操作：确认卡片显示 [title] 与 [details]，用户允许后执行 [run]
class ToolPlan {
  ToolPlan(this.title, this.run, {this.details = const []});

  final String title;
  final List<String> details;

  /// 返回给模型的执行结果
  final Future<String> Function() run;
}

class AiToolDef {
  const AiToolDef({required this.spec, required this.kind, required this.label, required this.prepare});

  final AiTool spec;
  final ToolKind kind;

  /// 简短的操作名，例如「安装模组」
  final String label;

  /// 校验参数并准备操作，不产生任何修改
  final Future<ToolPlan> Function(Map<String, dynamic> args) prepare;
}

class ToolError implements Exception {
  ToolError(this.message);

  final String message;

  @override
  String toString() => message;
}

const _versionParam = {'type': 'string', 'description': '版本名称（list_versions 返回的 id）'};

Map<String, dynamic> _schema(Map<String, dynamic> props, [List<String> required = const []]) => {
  'type': 'object',
  'properties': props,
  'required': required,
  'additionalProperties': false,
};

/// AI 可以使用的启动器操作。只开放这些固定操作，并且只能访问游戏文件夹中的内容；
/// 下载只通过 Modrinth API 解析，模型不能指定下载地址。
class AiToolbox {
  AiToolbox(this.state);

  final AppState state;

  late final List<AiToolDef> all = [
    AiToolDef(
      spec: AiTool('list_versions', '列出当前游戏文件夹中已安装的所有版本，以及当前选择的版本。', _schema({})),
      kind: ToolKind.read,
      label: '查看版本列表',
      prepare: (_) async => ToolPlan('查看版本列表', _listVersions),
    ),
    AiToolDef(
      spec: AiTool(
        'get_version_info',
        '查看一个版本的详细信息：加载器、Java 与内存设置、模组数量、存档列表、运行目录。',
        _schema({'version': _versionParam}, ['version']),
      ),
      kind: ToolKind.read,
      label: '查看版本信息',
      prepare: (a) async {
        final v = _version(a);
        return ToolPlan('查看 ${v.id} 的信息', () => _versionInfo(v));
      },
    ),
    AiToolDef(
      spec: AiTool('list_mods', '列出一个版本的模组文件（mods 文件夹），包括是否启用。', _schema({'version': _versionParam}, ['version'])),
      kind: ToolKind.read,
      label: '查看模组列表',
      prepare: (a) async {
        final v = _version(a);
        return ToolPlan('查看 ${v.id} 的模组', () => _listMods(v));
      },
    ),
    AiToolDef(
      spec: AiTool(
        'list_files',
        '列出一个版本运行目录中某个文件夹的内容（例如 config、saves、resourcepacks）。',
        _schema(
          {
            'version': _versionParam,
            'path': {'type': 'string', 'description': '相对于版本运行目录的文件夹路径，留空表示根目录'},
          },
          ['version'],
        ),
      ),
      kind: ToolKind.read,
      label: '查看文件',
      prepare: (a) async {
        final v = _version(a);
        final dir = await _gameDir(v);
        final rel = '${a['path'] ?? ''}'.trim();
        final abs = rel.isEmpty ? dir : _inside(dir, rel);
        // 文件夹不存在是正常的查看结果（例如还没有装光影），不算失败
        return ToolPlan(
          '查看 ${v.id}/${rel.isEmpty ? '' : rel}',
          () async => Directory(abs).existsSync() ? _listDir(dir, abs) : '文件夹不存在：$rel',
        );
      },
    ),
    AiToolDef(
      spec: AiTool(
        'read_log',
        '读取一个版本的日志（已截取错误相关部分并去除隐私信息）。kind：latest 为最近一次的游戏日志，crash 为最新的崩溃报告，debug 为调试日志。',
        _schema(
          {
            'version': _versionParam,
            'kind': {
              'type': 'string',
              'enum': ['latest', 'crash', 'debug'],
            },
          },
          ['version', 'kind'],
        ),
      ),
      kind: ToolKind.read,
      label: '读取日志',
      prepare: (a) async {
        final v = _version(a);
        final kind = '${a['kind']}';
        return ToolPlan(
          '读取 ${v.id} 的${const {'crash': '崩溃报告', 'debug': '调试日志'}[kind] ?? '游戏日志'}',
          () => _readLog(v, kind),
        );
      },
    ),
    AiToolDef(
      spec: AiTool(
        'search_mods',
        '在 Modrinth 上搜索与某个版本兼容的模组，返回项目 ID、名称和简介。',
        _schema(
          {
            'query': {'type': 'string', 'description': '搜索关键词（英文名称效果最好）'},
            'version': _versionParam,
          },
          ['query', 'version'],
        ),
      ),
      kind: ToolKind.read,
      label: '搜索模组',
      prepare: (a) async {
        final v = _version(a);
        final q = '${a['query'] ?? ''}'.trim();
        if (q.isEmpty) throw ToolError('请提供搜索关键词');
        return ToolPlan('在 Modrinth 搜索「$q」', () => _search(v, q));
      },
    ),
    AiToolDef(
      spec: AiTool(
        'list_game_versions',
        '列出可以安装的 Minecraft Java 版版本，以及最新的正式版和快照。',
        _schema({
          'type': {
            'type': 'string',
            'enum': ['release', 'snapshot', 'all'],
            'description': '默认 release（正式版）',
          },
          'query': {'type': 'string', 'description': '可选：按版本号筛选，例如 1.20'},
        }),
      ),
      kind: ToolKind.read,
      label: '查看可安装的版本',
      prepare: (a) async =>
          ToolPlan('查看可安装的 Minecraft 版本', () => _gameVersions('${a['type'] ?? 'release'}', '${a['query'] ?? ''}')),
    ),
    AiToolDef(
      spec: AiTool(
        'list_loader_versions',
        '列出某个 Minecraft 版本可用的加载器版本（新的在前，标注推荐的稳定版）。'
            'loader 可选：${LoaderKind.values.map((k) => k.name).join('、')}。OptiFine 会注明需要的 Forge 版本。',
        _schema(
          {
            'game_version': {'type': 'string', 'description': 'Minecraft 版本号，例如 1.20.1'},
            'loader': {
              'type': 'string',
              'enum': [for (final k in LoaderKind.values) k.name],
            },
          },
          ['game_version', 'loader'],
        ),
      ),
      kind: ToolKind.read,
      label: '查看加载器版本',
      prepare: (a) async {
        final kind = _loaderKind(a['loader']);
        final game = '${a['game_version'] ?? ''}'.trim();
        if (kind == null) throw ToolError('不支持的加载器：${a['loader']}');
        return ToolPlan('查看 $game 的 ${kind.label} 版本', () => _loaderVersions(kind, game));
      },
    ),
    AiToolDef(
      spec: AiTool(
        'install_game',
        '安装一个 Minecraft 版本，可以同时安装加载器与 OptiFine，完成后会选中这个版本。'
            '不指定 loader 时安装原版；loader 为 optifine 时安装独立的 OptiFine 版本。'
            '不指定 loader_version 时使用推荐的稳定版。optifine 参数用于在 Forge、NeoForge、Fabric 等加载器上把 OptiFine 作为模组一起安装。'
            '安装需要下载较多文件，可能要几分钟。',
        _schema(
          {
            'game_version': {'type': 'string', 'description': 'Minecraft 版本号，例如 1.20.1'},
            'loader': {
              'type': 'string',
              'enum': [for (final k in LoaderKind.values) k.name],
            },
            'loader_version': {'type': 'string', 'description': 'list_loader_versions 返回的完整版本号'},
            'optifine': {'type': 'string', 'description': '可选：同时安装的 OptiFine 版本（list_loader_versions 返回的版本号）'},
            'name': {'type': 'string', 'description': '可选：版本名称，默认按加载器自动命名'},
          },
          ['game_version'],
        ),
      ),
      kind: ToolKind.write,
      label: '安装游戏版本',
      prepare: _prepareInstall,
    ),
    AiToolDef(
      spec: AiTool('select_version', '把启动页当前选择的版本切换为指定的已安装版本。', _schema({'version': _versionParam}, ['version'])),
      kind: ToolKind.write,
      label: '切换版本',
      prepare: (a) async {
        final v = _version(a);
        return ToolPlan('把当前版本切换为 ${v.id}', () async {
          await state.selectVersion(v.id);
          return '已切换为 ${v.id}';
        }, details: ['${v.id}（${describeVersion(v)}）']);
      },
    ),
    AiToolDef(
      spec: AiTool(
        'install_mod',
        '从 Modrinth 安装模组到一个版本，会一并安装必需的前置模组。默认选择与该版本兼容的最新正式版。',
        _schema(
          {
            'version': _versionParam,
            'project': {'type': 'string', 'description': 'Modrinth 项目 ID 或 slug'},
            'mod_version_id': {'type': 'string', 'description': '可选：指定 Modrinth 的版本 ID'},
          },
          ['version', 'project'],
        ),
      ),
      kind: ToolKind.write,
      label: '安装模组',
      prepare: (a) async {
        final v = _version(a);
        final mv = await _resolveMod(v, a);
        return ToolPlan(
          '安装模组 ${mv.name}',
          () => _install(v, mv),
          details: [
            '版本：${v.id}',
            '文件：${mv.fileName}（${_size(mv.fileSize)}）',
            '来源：Modrinth',
            if (mv.requires.isNotEmpty) '会同时安装必需的前置模组',
          ],
        );
      },
    ),
    AiToolDef(
      spec: AiTool(
        'set_mods_enabled',
        '启用或禁用一个版本中的模组（与 PCL 相同，禁用时在文件名后加 .disabled）。',
        _schema(
          {
            'version': _versionParam,
            'files': {
              'type': 'array',
              'items': {'type': 'string'},
              'description': 'mods 文件夹中的文件名',
            },
            'enabled': {'type': 'boolean'},
          },
          ['version', 'files', 'enabled'],
        ),
      ),
      kind: ToolKind.write,
      label: '启用或禁用模组',
      prepare: (a) async {
        final v = _version(a);
        final enabled = a['enabled'] == true;
        final files = await _modFiles(v, a['files']);
        return ToolPlan('${enabled ? '启用' : '禁用'} ${files.length} 个模组', () async {
          for (final f in files) {
            await setModEnabled(f, enabled);
          }
          return '已${enabled ? '启用' : '禁用'}：${files.map((f) => f.name).join('、')}';
        }, details: ['版本：${v.id}', for (final f in files) f.name]);
      },
    ),
    AiToolDef(
      spec: AiTool(
        'backup',
        '把一个版本运行目录中的文件或文件夹（例如 saves/世界名、mods、config）打包备份。',
        _schema(
          {
            'version': _versionParam,
            'paths': {
              'type': 'array',
              'items': {'type': 'string'},
              'description': '相对于版本运行目录的路径',
            },
            'label': {'type': 'string', 'description': '可选：备份的简短说明，用于文件名'},
          },
          ['version', 'paths'],
        ),
      ),
      kind: ToolKind.write,
      label: '备份',
      prepare: (a) async {
        final v = _version(a);
        final dir = await _gameDir(v);
        final paths = _existing(dir, a['paths']);
        final size = paths.fold<int>(0, (s, e) => s + _sizeOf(p.join(dir, e)));
        return ToolPlan('备份 ${paths.length} 项', () async {
          final zip = await _backup(v, dir, paths, '${a['label'] ?? ''}');
          return '已备份到 ${p.basename(zip)}';
        }, details: ['版本：${v.id}', ...paths, '大小约 ${_size(size)}，保存到游戏文件夹的 backups 中']);
      },
    ),
    AiToolDef(
      spec: AiTool('list_backups', '列出一个版本的备份及其包含的内容。', _schema({'version': _versionParam}, ['version'])),
      kind: ToolKind.read,
      label: '查看备份',
      prepare: (a) async {
        final v = _version(a);
        return ToolPlan('查看 ${v.id} 的备份', () => _listBackups(v));
      },
    ),
    AiToolDef(
      spec: AiTool(
        'delete_files',
        '删除一个版本运行目录中的文件或文件夹。文件会移到回收站，可以从回收站恢复。',
        _schema(
          {
            'version': _versionParam,
            'paths': {
              'type': 'array',
              'items': {'type': 'string'},
              'description': '相对于版本运行目录的路径，例如 mods/xxx.jar',
            },
          },
          ['version', 'paths'],
        ),
      ),
      kind: ToolKind.danger,
      label: '删除文件',
      prepare: (a) async {
        final v = _version(a);
        final dir = await _gameDir(v);
        final paths = _existing(dir, a['paths']);
        return ToolPlan('删除 ${paths.length} 项（移到回收站）', () async {
          for (final rel in paths) {
            await moveToTrash(p.join(dir, rel));
          }
          return '已移到回收站：${paths.join('、')}';
        }, details: ['版本：${v.id}', for (final rel in paths) '$rel（${_size(_sizeOf(p.join(dir, rel)))}）']);
      },
    ),
    AiToolDef(
      spec: AiTool(
        'replace_mod',
        '用 Modrinth 上的另一个版本替换一个模组文件：先备份旧文件，再把旧文件移到回收站，然后安装新版本。',
        _schema(
          {
            'version': _versionParam,
            'file': {'type': 'string', 'description': 'mods 文件夹中要替换的文件名'},
            'project': {'type': 'string', 'description': 'Modrinth 项目 ID 或 slug'},
            'mod_version_id': {'type': 'string', 'description': '可选：指定 Modrinth 的版本 ID'},
          },
          ['version', 'file', 'project'],
        ),
      ),
      kind: ToolKind.danger,
      label: '替换模组',
      prepare: (a) async {
        final v = _version(a);
        final old = (await _modFiles(v, [a['file']])).single;
        final mv = await _resolveMod(v, a);
        if (mv.fileName == old.name.replaceFirst(RegExp(r'\.disabled$'), '')) throw ToolError('新旧文件相同，不需要替换');
        return ToolPlan('替换模组 ${old.name}', () async {
          final dir = await _gameDir(v);
          final rel = p.relative(old.path, from: dir);
          final zip = await _backup(v, dir, [rel], 'replace');
          await moveToTrash(old.path);
          final r = await _install(v, mv);
          return '旧文件已备份到 ${p.basename(zip)} 并移到回收站。$r';
        }, details: ['版本：${v.id}', '旧文件：${old.name}', '新文件：${mv.fileName}（${mv.name}，来自 Modrinth）', '旧文件会先备份，再移到回收站']);
      },
    ),
    AiToolDef(
      spec: AiTool(
        'restore_backup',
        '从备份恢复：先把当前的对应内容备份并移到回收站，再解压备份。',
        _schema(
          {
            'version': _versionParam,
            'backup': {'type': 'string', 'description': 'list_backups 返回的备份文件名'},
          },
          ['version', 'backup'],
        ),
      ),
      kind: ToolKind.danger,
      label: '从备份恢复',
      prepare: (a) async {
        final v = _version(a);
        final name = p.basename('${a['backup'] ?? ''}');
        final zip = p.join(_backupDir(v), name);
        if (!name.endsWith('.zip') || !File(zip).existsSync()) throw ToolError('找不到备份：$name');
        final manifest = await _manifest(zip);
        if (manifest == null) throw ToolError('这个备份不是由 PCL.PW 创建的，无法恢复');
        final dir = await _gameDir(v);
        return ToolPlan('从备份 $name 恢复', () async {
          final current = manifest
              .where((rel) => FileSystemEntity.typeSync(p.join(dir, rel)) != FileSystemEntityType.notFound)
              .toList();
          String? before;
          if (current.isNotEmpty) {
            before = await _backup(v, dir, current, 'before-restore');
            for (final rel in current) {
              await moveToTrash(p.join(dir, rel));
            }
          }
          await _extract(zip, dir);
          return '已恢复：${manifest.join('、')}${before == null ? '' : '。恢复前的内容已备份到 ${p.basename(before)}'}';
        }, details: ['版本：${v.id}', '将恢复：${manifest.join('、')}', '当前的对应内容会先备份，再移到回收站']);
      },
    ),
  ];

  List<AiTool> get specs => [for (final t in all) t.spec];

  AiToolDef? find(String name) => all.where((t) => t.spec.name == name).firstOrNull;

  // ---------- 安装游戏 ----------

  static LoaderKind? _loaderKind(Object? v) {
    final s = '${v ?? ''}'.trim().toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    if (s.isEmpty) return null;
    return LoaderKind.values.where((k) => k.name == s).firstOrNull;
  }

  Future<String> _gameVersions(String type, String query) async {
    final r = await remoteVersions(state.downloader);
    final q = query.trim();
    final list = r.list.where((v) {
      if (q.isNotEmpty && !v.id.contains(q)) return false;
      return switch (type) {
        'snapshot' => v.type == 'snapshot',
        'all' => true,
        _ => v.type == 'release',
      };
    }).toList();
    return [
      '最新正式版：${r.latestRelease}，最新快照：${r.latestSnapshot}',
      if (list.isEmpty) '没有符合条件的版本',
      for (final v in list.take(60)) '- ${v.id}（${v.type}${v.fool ? '，愚人节版本' : ''}，${v.releaseTime.split('T').first}）',
      if (list.length > 60) '……共 ${list.length} 个，只列出最新的 60 个，可以用 query 筛选',
    ].join('\n');
  }

  Future<String> _loaderVersions(LoaderKind kind, String game) async {
    final list = await loaderVersions(state.downloader, kind, game);
    if (list.isEmpty) return '${kind.label} 没有适用于 $game 的版本';
    final recommended = list.where((v) => v.stable).firstOrNull ?? list.first;
    return [
      '推荐：${recommended.version}',
      for (final v in list.take(30))
        '- ${v.version}${v.stable ? '' : '（测试版）'}'
            '${kind == LoaderKind.optifine ? (v.requiredForge == null
                      ? '，不兼容 Forge'
                      : v.requiredForge!.isEmpty
                      ? ''
                      : '，需要 Forge ${v.requiredForge}') : ''}',
      if (list.length > 30) '……共 ${list.length} 个，只列出最新的 30 个',
    ].join('\n');
  }

  Future<ToolPlan> _prepareInstall(Map<String, dynamic> a) async {
    final game = '${a['game_version'] ?? ''}'.trim();
    if (game.isEmpty) throw ToolError('请提供 Minecraft 版本号');
    final remote = await remoteVersions(state.downloader);
    final rv = remote.list.where((v) => v.id == game).firstOrNull;
    if (rv == null) throw ToolError('没有名为 $game 的 Minecraft 版本，可以先用 list_game_versions 查看');

    final loaderArg = '${a['loader'] ?? ''}'.trim();
    final kind = loaderArg.isEmpty || loaderArg == 'vanilla' ? null : _loaderKind(loaderArg);
    if (loaderArg.isNotEmpty && loaderArg != 'vanilla' && kind == null) throw ToolError('不支持的加载器：$loaderArg');

    // 加载器版本：指定的必须存在；没有指定时用推荐的稳定版
    var loaderVersion = '';
    if (kind != null) {
      final list = await loaderVersions(state.downloader, kind, game);
      if (list.isEmpty) throw ToolError('${kind.label} 没有适用于 $game 的版本');
      final wanted = '${a['loader_version'] ?? ''}'.trim();
      final pick = wanted.isEmpty
          ? (list.where((v) => v.stable).firstOrNull ?? list.first)
          : list.where((v) => v.version == wanted || v.label == wanted).firstOrNull;
      if (pick == null) throw ToolError('${kind.label} 没有版本 $wanted，可以先用 list_loader_versions 查看');
      loaderVersion = pick.version;
    }

    // OptiFine 作为模组一起安装（与 PCL 相同）
    final ofArg = '${a['optifine'] ?? ''}'.trim();
    String? optifine;
    if (ofArg.isNotEmpty) {
      if (kind == LoaderKind.optifine) throw ToolError('loader 已经是 optifine，不需要再指定 optifine');
      if (!canAddOptiFine(loaderOfKind(kind))) throw ToolError('${kind?.label ?? '原版'} 不能与 OptiFine 一起安装');
      final list = await loaderVersions(state.downloader, LoaderKind.optifine, game);
      final of = list.where((v) => v.version == ofArg || v.label == ofArg).firstOrNull;
      if (of == null) throw ToolError('OptiFine 没有适用于 $game 的版本 $ofArg');
      if (kind == LoaderKind.forge && of.requiredForge == null) throw ToolError('OptiFine $ofArg 不兼容 Forge');
      optifine = of.version;
    }

    final nameArg = '${a['name'] ?? ''}'.trim();
    final name = nameArg.isEmpty ? null : nameArg;
    final shown = name ?? defaultVersionName(kind, game, loaderVersion);
    try {
      // 由官方安装器命名的加载器（Forge 等）只在指定名称时检查
      if (name != null || kind == null || kind == LoaderKind.fabric || kind == LoaderKind.quilt) {
        checkVersionName(state.paths, shown);
      }
    } catch (e) {
      throw ToolError(errorMessage(e));
    }

    return ToolPlan(
      '安装 $shown',
      () async {
        final id = await state.installVersion(
          game,
          loader: kind,
          loaderVersion: loaderVersion,
          name: name,
          optifine: optifine,
        );
        return '已安装为 $id，并已设为当前选择的版本';
      },
      details: [
        'Minecraft $game（${rv.type == 'release' ? '正式版' : rv.type}）',
        if (kind != null) loaderComponent(kind, game, loaderVersion),
        if (optifine != null)
          '${loaderComponent(LoaderKind.optifine, game, optifine)}（${optiFineNote(loaderOfKind(kind), null)}）',
        '版本名称：$shown',
        '从${state.config.downloadSource == 'bmclapi' ? ' BMCLAPI 镜像' : '官方源'}下载，可能需要几分钟；进度可以在任务页查看',
      ],
    );
  }

  static String errorMessage(Object e) => '$e'.replaceFirst(RegExp(r'^Exception: ?'), '');

  // ---------- 辅助 ----------

  InstanceInfo _version(Map<String, dynamic> a) {
    final id = '${a['version'] ?? ''}'.trim();
    final v = state.instance(id);
    if (v == null) {
      throw ToolError('找不到版本「$id」。已安装的版本：${state.versions.map((v) => v.id).join('、')}');
    }
    return v;
  }

  Future<String> _gameDir(InstanceInfo v) => state.gameDirOf(v);

  /// 相对路径转为绝对路径，并确认在运行目录内
  static String _inside(String dir, String rel) {
    rel = rel.replaceAll('\\', '/').trim();
    if (rel.isEmpty || p.isAbsolute(rel) || rel.split('/').contains('..')) throw ToolError('路径无效：$rel');
    final abs = p.normalize(p.join(dir, rel));
    if (!p.isWithin(dir, abs)) throw ToolError('只能访问版本运行目录中的文件：$rel');
    return abs;
  }

  /// 校验路径列表并返回规范化的相对路径
  List<String> _existing(String dir, Object? list) {
    final items = (list is List ? list : const []).map((e) => '$e').where((e) => e.trim().isNotEmpty).toList();
    if (items.isEmpty) throw ToolError('请提供路径');
    return [
      for (final rel in items)
        () {
          final abs = _inside(dir, rel);
          if (FileSystemEntity.typeSync(abs) == FileSystemEntityType.notFound) throw ToolError('文件不存在：$rel');
          return p.relative(abs, from: dir).replaceAll('\\', '/');
        }(),
    ];
  }

  Future<List<InstanceFile>> _modFiles(InstanceInfo v, Object? list) async {
    final names = (list is List ? list : const []).map((e) => '$e'.trim()).where((e) => e.isNotEmpty).toList();
    if (names.isEmpty) throw ToolError('请提供模组文件名');
    final mods = listInstanceFiles(await _gameDir(v), InstanceFolder.mods);
    return [
      for (final n in names)
        mods.where((m) => m.name == n || m.name == '$n.disabled' || '${m.name}.disabled' == n).firstOrNull ??
            (throw ToolError('mods 文件夹中没有 $n')),
    ];
  }

  Future<ResourceVersion> _resolveMod(InstanceInfo v, Map<String, dynamic> a) async {
    final project = '${a['project'] ?? ''}'.trim();
    if (project.isEmpty) throw ToolError('请提供 Modrinth 项目 ID');
    final loaders = modrinthLoaders(v.loader);
    if (loaders.isEmpty) throw ToolError('${v.id} 不能安装模组（没有模组加载器）');
    final list = await Modrinth.versions(project, gameVersion: v.gameVersion, loaders: loaders);
    final wanted = '${a['mod_version_id'] ?? ''}'.trim();
    final pick = wanted.isNotEmpty
        ? list.where((x) => x.id == wanted).firstOrNull
        : list.where((x) => x.type == 'release').firstOrNull ?? list.firstOrNull;
    if (pick == null) {
      throw ToolError(
        wanted.isNotEmpty
            ? '版本 $wanted 不存在，或与 ${v.id} 不兼容'
            : '$project 没有适用于 ${v.gameVersion}（${loaders.join('/')}）的版本',
      );
    }
    return pick;
  }

  Future<String> _install(InstanceInfo v, ResourceVersion mv) async {
    final r = await state.installResource(mv, ResourceType.mod, v);
    return [
      if (r.installed.isNotEmpty) '已安装：${r.installed.join('、')}',
      if (r.skipped.isNotEmpty) '已存在，跳过：${r.skipped.join('、')}',
      if (r.missing.isNotEmpty) '找不到兼容版本的前置：${r.missing.join('、')}',
    ].join('；');
  }

  static String _size(int b) => b >= 1 << 20
      ? '${(b / (1 << 20)).toStringAsFixed(1)} MB'
      : b >= 1024
      ? '${(b / 1024).toStringAsFixed(0)} KB'
      : '$b B';

  static int _sizeOf(String path) {
    final t = FileSystemEntity.typeSync(path);
    if (t == FileSystemEntityType.file) return File(path).lengthSync();
    if (t != FileSystemEntityType.directory) return 0;
    var n = 0;
    for (final e in Directory(path).listSync(recursive: true, followLinks: false)) {
      if (e is File) n += e.lengthSync();
    }
    return n;
  }

  // ---------- 只读操作 ----------

  Future<String> _listVersions() async {
    if (state.versions.isEmpty) return '当前游戏文件夹中没有已安装的版本';
    return [
      for (final v in state.versions)
        '- ${v.id}：${describeVersion(v)}${v.id == state.config.selectedVersion ? '（当前选择）' : ''}',
    ].join('\n');
  }

  Future<String> _versionInfo(InstanceInfo v) async {
    final dir = await _gameDir(v);
    final s = readInstanceSettings(state.paths.versionDir(v.id));
    final mods = listInstanceFiles(
      dir,
      InstanceFolder.mods,
    ).where((f) => f.name.endsWith('.jar') || f.disabled).toList();
    final worlds = worldsOf(dir);
    final java = switch (s.java) {
      JavaGlobal() => '跟随全局设置',
      JavaAuto() => '自动选择',
      JavaExist(:final path) || JavaRelative(:final path) => path,
    };
    return [
      '版本：${v.id}（${describeVersion(v)}）',
      '运行目录：${dir == state.paths.root ? '游戏文件夹根目录（未隔离）' : 'versions/${v.id}（已隔离）'}',
      'Java：${state.redactor().apply(java)}',
      '内存：${switch (s.memoryMode) {
        'custom' => '自定义',
        'auto' => '自动',
        _ => '跟随全局设置',
      }}',
      if (v.modable)
        '模组：${mods.where((m) => !m.disabled).length} 个启用，${mods.where((m) => m.disabled).length} 个禁用'
      else
        '这个版本没有模组加载器',
      '存档：${worlds.isEmpty ? '无' : worlds.join('、')}',
    ].join('\n');
  }

  Future<String> _listMods(InstanceInfo v) async {
    final mods =
        listInstanceFiles(
            await _gameDir(v),
            InstanceFolder.mods,
          ).where((f) => !f.isDir && (f.name.endsWith('.jar') || f.disabled)).toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (mods.isEmpty) return 'mods 文件夹中没有模组';
    return [for (final m in mods.take(400)) '- ${m.name}${m.disabled ? '（已禁用）' : ''}，${_size(m.size)}'].join('\n');
  }

  String _listDir(String root, String dir) {
    final entries = Directory(dir).listSync()..sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    if (entries.isEmpty) return '文件夹是空的';
    return [
      for (final e in entries.take(300))
        e is Directory
            ? '- ${p.relative(e.path, from: root).replaceAll('\\', '/')}/'
            : '- ${p.relative(e.path, from: root).replaceAll('\\', '/')}（${_size(_sizeOf(e.path))}）',
      if (entries.length > 300) '……共 ${entries.length} 项，只列出前 300 项',
    ].join('\n');
  }

  Future<String> _readLog(InstanceInfo v, String kind) async {
    final dir = await _gameDir(v);
    File? f;
    if (kind == 'crash') {
      final d = Directory(p.join(dir, 'crash-reports'));
      final files = d.existsSync()
          ? d.listSync().whereType<File>().where((f) => f.path.endsWith('.txt')).toList()
          : <File>[];
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      f = files.firstOrNull;
    } else {
      f = File(p.join(dir, 'logs', kind == 'debug' ? 'debug.log' : 'latest.log'));
    }
    if (f == null || !f.existsSync()) throw ToolError('没有找到${kind == 'crash' ? '崩溃报告' : '日志'}');
    final bytes = await f.readAsBytes();
    final text = utf8.decode(
      bytes.length > 4 << 20 ? bytes.sublist(bytes.length - (4 << 20)) : bytes,
      allowMalformed: true,
    );
    return '${p.basename(f.path)}（修改于 ${f.statSync().modified.toString().substring(0, 19)}）\n'
        '${state.redactor().apply(excerptLog(text, budget: 16000))}';
  }

  Future<String> _search(InstanceInfo v, String q) async {
    final loaders = modrinthLoaders(v.loader);
    if (loaders.isEmpty) throw ToolError('${v.id} 不能安装模组（没有模组加载器）');
    final r = await Modrinth.search(
      type: ResourceType.mod,
      query: q,
      gameVersion: v.gameVersion,
      loader: loaders.first,
    );
    if (r.hits.isEmpty) return '没有找到与 ${v.gameVersion}（${loaders.first}）兼容的结果';
    return [
      for (final h in r.hits.take(10))
        '- ${h.title}（项目 ID：${h.id}，slug：${h.slug}，下载 ${h.downloads} 次）：${h.description.length > 120 ? '${h.description.substring(0, 120)}…' : h.description}',
    ].join('\n');
  }

  // ---------- 备份 ----------

  String _backupDir(InstanceInfo v) => p.join(state.paths.root, 'backups', v.id);

  static const _manifestName = 'pclpw-backup.json';

  /// 打包备份，返回备份文件路径。备份中记录了包含的路径，恢复时按此替换
  Future<String> _backup(InstanceInfo v, String dir, List<String> paths, String label) async {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final stamp = '${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}${two(now.second)}';
    final safe = label.trim().replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '_');
    final out = p.join(_backupDir(v), '$stamp${safe.isEmpty ? '' : '-$safe'}.zip');
    await Directory(p.dirname(out)).create(recursive: true);
    final enc = ZipFileEncoder()..create(out);
    try {
      for (final rel in paths) {
        final abs = p.join(dir, rel);
        if (FileSystemEntity.isDirectorySync(abs)) {
          for (final f in Directory(abs).listSync(recursive: true, followLinks: false).whereType<File>()) {
            await enc.addFile(f, p.relative(f.path, from: dir).replaceAll('\\', '/'));
          }
        } else {
          await enc.addFile(File(abs), rel);
        }
      }
      enc.addArchiveFile(
        ArchiveFile.string(
          _manifestName,
          jsonEncode({'version': v.id, 'paths': paths, 'created': now.toIso8601String()}),
        ),
      );
    } finally {
      await enc.close();
    }
    return out;
  }

  Future<List<String>?> _manifest(String zip) async {
    final input = InputFileStream(zip);
    try {
      final archive = ZipDecoder().decodeStream(input);
      final m = archive.findFile(_manifestName);
      if (m == null) return null;
      final j = jsonDecode(utf8.decode(m.content));
      return ((j as Map)['paths'] as List).map((e) => '$e').toList();
    } catch (_) {
      return null;
    } finally {
      await input.close();
    }
  }

  Future<void> _extract(String zip, String dir) async {
    final input = InputFileStream(zip);
    try {
      final archive = ZipDecoder().decodeStream(input);
      for (final f in archive.files) {
        if (!f.isFile || f.name == _manifestName) continue;
        final abs = _inside(dir, f.name);
        await File(abs).parent.create(recursive: true);
        await File(abs).writeAsBytes(f.content);
      }
    } finally {
      await input.close();
    }
  }

  Future<String> _listBackups(InstanceInfo v) async {
    final d = Directory(_backupDir(v));
    final zips = d.existsSync()
        ? (d.listSync().whereType<File>().where((f) => f.path.endsWith('.zip')).toList())
        : <File>[];
    if (zips.isEmpty) return '${v.id} 还没有备份';
    zips.sort((a, b) => b.path.compareTo(a.path));
    return [
      for (final z in zips.take(50))
        '- ${p.basename(z.path)}（${_size(z.lengthSync())}）：${(await _manifest(z.path))?.join('、') ?? '不是 PCL.PW 创建的备份'}',
    ].join('\n');
  }
}

/// 记录 AI 执行过的修改操作，便于追查
Future<void> logAiOperation(String title, String result) async {
  try {
    final f = File(p.join(Paths.appData, 'ai_operations.log'));
    await f.writeAsString(
      '${jsonEncode({'time': DateTime.now().toIso8601String(), 'title': title, 'result': result})}\n',
      mode: FileMode.append,
    );
  } catch (_) {
    // 记录失败不影响操作
  }
}
