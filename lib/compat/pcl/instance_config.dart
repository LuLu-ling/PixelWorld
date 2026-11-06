import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../../core/cat_ini.dart';
import 'paths.dart';

/// 实例的 Java 选择
sealed class JavaPref {
  const JavaPref();
}

class JavaGlobal extends JavaPref {
  const JavaGlobal();
}

class JavaAuto extends JavaPref {
  const JavaAuto();
}

class JavaExist extends JavaPref {
  const JavaExist(this.path);
  final String path;
}

class JavaRelative extends JavaPref {
  const JavaRelative(this.path);
  final String path;
}

/// 实例独立设置，读写 `versions/<id>/PCL/config.v1.yml`，与 PCL-CE 共用
class InstanceSettings {
  InstanceSettings({
    required this.isolation,
    required this.memoryMode,
    required this.memoryTick,
    required this.memoryInitialTick,
    required this.jvmArgs,
    required this.gameArgs,
    required this.java,
    required this.server,
    required this.versionType,
    required this.title,
    required this.preLaunchCommand,
    required this.preLaunchWait,
    required this.classpathHead,
    required this.renderer,
  });

  /// null 表示尚未决定，首次启动时按全局策略决定并写入
  final bool? isolation;

  /// global / auto / custom
  final String memoryMode;
  final int memoryTick;
  final int memoryInitialTick;
  final String jvmArgs;
  final String gameArgs;
  final JavaPref java;
  final String server;
  final String versionType;
  final String title;
  final String preLaunchCommand;
  final bool preLaunchWait;
  final String classpathHead;

  /// 安卓渲染器，空表示跟随全局设置（PCL.PW 独有的键，PCL-CE 会原样保留）
  final String renderer;
}

/// PCL-CE 的实例独立配置：`versions/<id>/PCL/config.v1.yml`（扁平的 YAML 映射）。
/// 旧版 PCL 使用 `versions/<id>/PCL/setup.ini`，读取时自动迁移，写入时保留未知键，
/// 以便与 PCL-CE 互相切换时不丢设置。
String _yamlPath(String versionDir) => pclInstanceConfig(versionDir);
String _iniPath(String versionDir) => pclInstanceLegacyConfig(versionDir);

Map<String, dynamic> _raw(String versionDir) {
  final f = File(_yamlPath(versionDir));
  if (f.existsSync()) {
    try {
      final doc = loadYaml(f.readAsStringSync());
      if (doc is YamlMap) return {for (final e in doc.entries) '${e.key}': e.value};
    } catch (_) {
      // 文件损坏时按旧版 ini 读取
    }
  }
  // 与 PCL-CE 的 CatIniMigration 一致：每行 key:value
  return readCatIni(_iniPath(versionDir));
}

String _str(Object? v, [String d = '']) => v == null ? d : '$v';
int _num(Object? v, int d) => v == null || v == '' ? d : (num.tryParse('$v')?.toInt() ?? d);
bool? _bool(Object? v) {
  if (v == null || v == '') return null;
  return v == true || RegExp(r'^(true|1)$', caseSensitive: false).hasMatch('$v');
}

/// Java 选择：新版为 JSON（kind: exist/global/relative/auto），旧版为路径或「使用全局设置」
JavaPref _parseJava(Object? v) {
  final s = _str(v, '使用全局设置').trim();
  if (s.isEmpty) return const JavaAuto();
  if (s == '使用全局设置') return const JavaGlobal();
  try {
    final j = jsonDecode(s) as Map<String, dynamic>;
    final kind = _str(j['kind'] ?? j['Kind']).toLowerCase();
    if (kind == 'exist') return JavaExist(_str(j['javaExePath'] ?? j['JavaExePath']));
    if (kind == 'relative') return JavaRelative(_str(j['relativePath'] ?? j['RelativePath']));
    if (kind == 'auto') return const JavaAuto();
    return const JavaGlobal();
  } catch (_) {
    return JavaExist(s);
  }
}

String serializeJava(JavaPref j) => switch (j) {
  JavaGlobal() => '使用全局设置',
  JavaAuto() => jsonEncode({'kind': 'auto'}),
  JavaRelative(:final path) => jsonEncode({'kind': 'relative', 'RelativePath': path}),
  JavaExist(:final path) => jsonEncode({'kind': 'exist', 'JavaExePath': path}),
};

InstanceSettings readInstanceSettings(String? versionDir) {
  final r = versionDir == null ? <String, dynamic>{} : _raw(versionDir);
  // 版本隔离：V2 为布尔；未设置时尝试旧版 V1（1 开启 / 2 关闭）
  var isolation = _bool(r['VersionArgumentIndieV2']);
  if (isolation == null) {
    final v1 = _num(r['VersionArgumentIndie'], -1);
    if (v1 == 1) isolation = true;
    if (v1 == 2) isolation = false;
  }
  final ramType = _num(r['VersionRamType'], 2);
  return InstanceSettings(
    isolation: isolation,
    memoryMode: ramType == 0 ? 'auto' : (ramType == 1 ? 'custom' : 'global'),
    memoryTick: _num(r['VersionRamCustom'], 15),
    memoryInitialTick: _num(r['VersionRamCustomInitial'], 0),
    jvmArgs: _str(r['VersionAdvanceJvm']),
    gameArgs: _str(r['VersionAdvanceGame']),
    java: _parseJava(r['VersionArgumentJavaSelect']),
    server: _str(r['VersionServerEnter']),
    versionType: _str(r['VersionArgumentInfo']),
    title: _str(r['VersionArgumentTitle']),
    preLaunchCommand: _str(r['VersionAdvanceRun']),
    preLaunchWait: _bool(r['VersionAdvanceRunWait']) ?? true,
    classpathHead: _str(r['VersionAdvanceClasspathHead']),
    renderer: _str(r['PclpwAndroidRenderer']),
  );
}

/// 只写入给出的键，其余键（包括 PCL.PW 不认识的）原样保留。
/// 值使用 PCL-CE 的键名，例如 {'VersionArgumentIndieV2': true}。
Future<void> writeInstanceRaw(String versionDir, Map<String, Object> patch) async {
  final f = File(_yamlPath(versionDir));
  YamlEditor? editor;
  if (f.existsSync()) {
    try {
      editor = YamlEditor(f.readAsStringSync());
      if (editor.parseAt([]) is! YamlMap) editor = null;
    } catch (_) {
      editor = null;
    }
  }
  if (editor == null) {
    // 新建（或从旧版 setup.ini 迁移），整体写成块状映射，与 PCL-CE 的格式一致
    editor = YamlEditor('')..update([], {...readCatIni(_iniPath(versionDir)), ...patch});
  } else {
    for (final e in patch.entries) {
      editor.update([e.key], e.value);
    }
  }
  await f.parent.create(recursive: true);
  await f.writeAsString(editor.toString());
}

Future<void> writeInstanceJava(String versionDir, JavaPref java) =>
    writeInstanceRaw(versionDir, {'VersionArgumentJavaSelect': serializeJava(java)});
