import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// 一次游戏运行的信息，游戏退出后用于收集崩溃现场
class GameRun {
  GameRun({
    required this.versionId,
    required this.description,
    required this.gameDir,
    required this.loaderLibs,
    required this.javaPath,
    required this.javaMajor,
    required this.memoryGb,
    required this.startedAt,
    required this.secrets,
  });

  final String versionId;

  /// 例如「Forge + OptiFine · 1.20.1」
  final String description;
  final String gameDir;

  /// 加载器相关的依赖库，例如 net.fabricmc:fabric-loader:0.16.9
  final List<String> loaderLibs;
  final String javaPath;
  final int javaMajor;
  final double memoryGb;
  final DateTime startedAt;

  /// 需要从日志中去掉的信息：玩家名、UUID、令牌、服务器地址
  final Redactor secrets;

  int? exitCode;

  /// 用户手动结束了游戏
  bool killed = false;
}

/// 一段日志（已截取、已去除隐私信息）
class LogSource {
  const LogSource(this.name, this.text);

  final String name;
  final String text;
}

/// 本地规则找到的问题
class Finding {
  const Finding(this.title, this.detail, [this.evidence = const []]);

  final String title;
  final String detail;

  /// 日志中对应的行
  final List<String> evidence;
}

/// 用于分析的崩溃信息
class CrashReport {
  CrashReport({required this.title, required this.environment, required this.sources, this.mods = const []})
    : findings = analyzeLogs(sources.map((s) => s.text).join('\n'));

  final String title;

  /// 环境信息，每行一项
  final List<String> environment;
  final List<LogSource> sources;
  final List<String> mods;
  final List<Finding> findings;

  /// 与 AI 的对话（离开错误分析页后保留）：第一条为 toPrompt() 的内容
  final chat = <({String role, String content})>[];

  /// 游戏是否真的崩溃了（有崩溃报告、JVM 错误日志，或日志里有已知问题）
  bool get hasEvidence => sources.any((s) => s.name != '游戏输出') || findings.isNotEmpty;

  /// 发送给 AI 的内容
  String toPrompt() {
    final b = StringBuffer();
    if (environment.isNotEmpty) {
      b.writeln('## 环境');
      for (final e in environment) {
        b.writeln('- $e');
      }
      b.writeln();
    }
    if (findings.isNotEmpty) {
      b.writeln('## 启动器本地规则的初步判断');
      for (final f in findings) {
        b.writeln('- ${f.title}：${f.detail}');
      }
      b.writeln();
    }
    if (mods.isNotEmpty) {
      b.writeln('## 已启用的模组文件（${mods.length} 个）');
      b.writeln(mods.join('\n'));
      b.writeln();
    }
    for (final s in sources) {
      b.writeln('## ${s.name}');
      b.writeln('```');
      b.writeln(s.text);
      b.writeln('```');
      b.writeln();
    }
    return b.toString().trim();
  }
}

// ---------- 收集 ----------

/// 游戏退出后收集崩溃现场：崩溃报告、JVM 错误日志与游戏输出
Future<CrashReport> collectCrash(GameRun run, List<String> output) async {
  final r = run.secrets;
  final since = run.startedAt.subtract(const Duration(seconds: 5));
  final sources = <LogSource>[];

  File? newest(String dir, bool Function(String name) match) {
    final d = Directory(dir);
    if (!d.existsSync()) return null;
    final files = d
        .listSync()
        .whereType<File>()
        .where((f) => match(p.basename(f.path)))
        .where((f) => f.statSync().modified.isAfter(since))
        .toList();
    files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    return files.firstOrNull;
  }

  final report = newest(p.join(run.gameDir, 'crash-reports'), (n) => n.endsWith('.txt'));
  if (report != null) {
    sources.add(LogSource('崩溃报告 ${p.basename(report.path)}', r.apply(_head(await _read(report), 20000))));
  }
  final hsErr = newest(run.gameDir, (n) => n.startsWith('hs_err_pid') && n.endsWith('.log'));
  if (hsErr != null) {
    // JVM 错误日志的开头说明了出错的位置（例如显卡驱动的 dll）
    final lines = (await _read(hsErr)).split(RegExp(r'\r?\n'));
    sources.add(LogSource('JVM 错误日志 ${p.basename(hsErr.path)}', r.apply(lines.take(80).join('\n'))));
  }
  var text = output.join('\n');
  if (text.trim().isEmpty) {
    final latest = File(p.join(run.gameDir, 'logs', 'latest.log'));
    if (latest.existsSync() && latest.statSync().modified.isAfter(since)) text = await _read(latest);
  }
  if (text.trim().isNotEmpty) sources.add(LogSource('游戏输出', r.apply(excerptLog(text))));

  final modsDir = Directory(p.join(run.gameDir, 'mods'));
  final mods = modsDir.existsSync()
      ? (modsDir.listSync().whereType<File>().map((f) => p.basename(f.path)).where((n) => n.endsWith('.jar')).toList()
          ..sort())
      : <String>[];

  return CrashReport(
    title: run.versionId,
    environment: [
      '版本：${run.versionId}（${run.description}）',
      if (run.loaderLibs.isNotEmpty) '加载器：${run.loaderLibs.join('，')}',
      'Java：${run.javaMajor}（${r.apply(run.javaPath)}）',
      '分配内存：${run.memoryGb.toStringAsFixed(1)} GB',
      '系统：${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      if (run.exitCode != null) '退出代码：${run.exitCode}',
    ],
    sources: sources,
    mods: mods.map(r.apply).toList(),
  );
}

/// 用户手动提供的日志
CrashReport reportFromText(String name, String text, Redactor r) => CrashReport(
  title: name,
  environment: ['系统：${Platform.operatingSystem} ${Platform.operatingSystemVersion}'],
  sources: [LogSource(name, r.apply(excerptLog(text)))],
);

/// 读取文本文件，过大时只读最后 4 MB
Future<String> _read(File f) async {
  final bytes = await f.readAsBytes();
  const max = 4 << 20;
  return utf8.decode(bytes.length > max ? bytes.sublist(bytes.length - max) : bytes, allowMalformed: true);
}

String _head(String s, int max) => s.length <= max ? s : '${s.substring(0, max)}\n...（以下省略 ${s.length - max} 个字符）';

// ---------- 截取 ----------

final _important = RegExp(
  r'Exception|Error|Caused by|FATAL|/ERROR\]|\[ERROR\]|Missing|requires|Mixin|crash|Incompatible|Duplicate|Could not|Failed',
);
final _frame = RegExp(r'^\s+(at |\.\.\. \d+ more)');

/// 截取日志中与错误相关的部分：异常及其堆栈、错误行，以及结尾的若干行
String excerptLog(String text, {int budget = 24000, int tail = 150}) {
  // 合并连续的重复行（刷屏的日志）
  final raw = text.split(RegExp(r'\r?\n'));
  final lines = <String>[];
  var repeat = 0;
  for (final l in raw) {
    if (lines.isNotEmpty && l == lines.last) {
      repeat++;
      continue;
    }
    if (repeat > 0) lines.add('（上一行重复 $repeat 次）');
    repeat = 0;
    lines.add(l);
  }
  if (repeat > 0) lines.add('（上一行重复 $repeat 次）');
  if (lines.join('\n').length <= budget) return lines.join('\n');

  final keep = List.filled(lines.length, false);
  for (var i = (lines.length - tail).clamp(0, lines.length); i < lines.length; i++) {
    keep[i] = true;
  }
  for (var i = 0; i < lines.length; i++) {
    if (!_important.hasMatch(lines[i]) || _frame.hasMatch(lines[i])) continue;
    // 错误行前 2 行，以及之后最多 15 行堆栈
    for (var j = (i - 2).clamp(0, lines.length); j <= i; j++) {
      keep[j] = true;
    }
    var frames = 0;
    for (var j = i + 1; j < lines.length && frames < 15 && _frame.hasMatch(lines[j]); j++, frames++) {
      keep[j] = true;
    }
  }

  final parts = <String>[];
  var skipped = 0;
  for (var i = 0; i < lines.length; i++) {
    if (keep[i]) {
      if (skipped > 0) parts.add('...（省略 $skipped 行）');
      skipped = 0;
      parts.add(lines[i]);
    } else {
      skipped++;
    }
  }
  var out = parts.join('\n');
  if (out.length > budget) {
    // 仍然太长：保留开头的错误与结尾
    final head = out.substring(0, budget * 2 ~/ 5);
    final end = out.substring(out.length - budget * 3 ~/ 5);
    out = '$head\n...（中间省略 ${out.length - budget} 个字符）\n$end';
  }
  return out;
}

// ---------- 去除隐私信息 ----------

/// 去掉日志中的令牌、玩家名、UUID、用户目录和 IP 地址
class Redactor {
  Redactor({List<String> tokens = const [], List<String> names = const [], List<String> uuids = const []})
    : _tokens = tokens.where((t) => t.length >= 8).toList(),
      _names = names.where((n) => n.length >= 3).toList(),
      _uuids = [
        for (final u in uuids)
          if (u.isNotEmpty) ...{u.toLowerCase(), u.replaceAll('-', '').toLowerCase()},
      ];

  final List<String> _tokens;
  final List<String> _names;
  final List<String> _uuids;

  static final _jwt = RegExp(r'eyJ[\w-]{8,}\.[\w-]{8,}\.[\w-]{8,}');
  static final _tokenArg = RegExp(r'(--accessToken|--session)\s+\S+');
  static final _ip = RegExp(r'(?<![\d.])(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})(?![\d.])');
  static final _home = RegExp(
    r'([A-Za-z]:[\\/]+(?:Users|Documents and Settings)[\\/]+)[^\\/\s"]+',
    caseSensitive: false,
  );
  static final _unixHome = RegExp(r'(/(?:home|Users)/)[^/\s"]+');

  String apply(String s) {
    for (final t in _tokens) {
      s = s.replaceAll(t, '<令牌>');
    }
    s = s.replaceAll(_jwt, '<令牌>').replaceAllMapped(_tokenArg, (m) => '${m[1]} <令牌>');
    for (final u in _uuids) {
      s = s.replaceAll(RegExp(RegExp.escape(u), caseSensitive: false), '<UUID>');
    }
    for (final n in _names) {
      s = s.replaceAll(RegExp('(?<![\\w])${RegExp.escape(n)}(?![\\w])'), '<玩家>');
    }
    s = s.replaceAllMapped(_home, (m) => '${m[1]}<用户>').replaceAllMapped(_unixHome, (m) => '${m[1]}<用户>');
    s = s.replaceAllMapped(_ip, (m) {
      final parts = [for (var i = 1; i <= 4; i++) int.parse(m[i]!)];
      if (parts.any((x) => x > 255)) return m[0]!;
      // 本机与局域网地址不算隐私
      final local = parts[0] == 127 || parts[0] == 10 || parts[0] == 0 || (parts[0] == 192 && parts[1] == 168);
      return local ? m[0]! : '<IP>';
    });
    return s;
  }
}

// ---------- 本地规则 ----------

/// 用规则匹配常见问题，命中的结论也会一起发给 AI
List<Finding> analyzeLogs(String text) {
  final lines = text.split('\n');
  List<String> grep(RegExp re, {int max = 6}) =>
      lines.where(re.hasMatch).map((l) => l.trim()).toSet().take(max).toList();
  final out = <Finding>[];
  void rule(RegExp re, String title, String detail) {
    final hit = grep(re);
    if (hit.isNotEmpty) out.add(Finding(title, detail, hit));
  }

  // Java 版本
  final version = RegExp(
    r'class file version (\d+)\.\d+\), this version of the Java Runtime only recognizes class file versions up to (\d+)',
  ).firstMatch(text);
  if (version != null) {
    out.add(
      Finding(
        'Java 版本过低',
        '需要 Java ${int.parse(version[1]!) - 44} 或更高，当前 Java 只支持到 Java ${int.parse(version[2]!) - 44}。'
            '请在版本设置中选择更新的 Java。',
        grep(RegExp('UnsupportedClassVersionError')),
      ),
    );
  } else {
    rule(RegExp('UnsupportedClassVersionError'), 'Java 版本过低', '有模组或游戏文件需要更新的 Java，请在版本设置中选择更新的 Java。');
  }
  rule(
    RegExp(r'AppClassLoader cannot be cast to (class )?java\.net\.URLClassLoader'),
    '需要 Java 8',
    '旧版 Forge（1.12.2 及更早）只能在 Java 8 上运行，请在版本设置中选择 Java 8。',
  );

  // 内存
  rule(RegExp(r'java\.lang\.OutOfMemoryError'), '内存不足', '游戏可用的内存不够。可以在版本设置中加大内存，或减少模组、光影与高清材质。');
  rule(
    RegExp(r'Could not reserve enough space|Initial heap size set to a larger value|Invalid maximum heap size'),
    '内存设置无效',
    '分配的内存超出了系统或 32 位 Java 的上限，请调小内存，或换用 64 位 Java。',
  );

  // 模组依赖与冲突
  rule(
    RegExp(
      r'requires .*(which is missing|but only the wrong version is present)|Missing or unsupported mandatory dependencies|Missing Mods:|Mod ID: .*Requested by',
    ),
    '缺少前置模组或版本不对',
    '有模组需要的前置模组没有安装，或版本不符合要求。按下面的日志行安装或更新对应模组。',
  );
  rule(
    RegExp(
      r'Duplicate mod|DuplicateModsFoundException|Found duplicate mods|duplicate mods? found',
      caseSensitive: false,
    ),
    '模组重复',
    '同一个模组装了多份（可能是不同版本），请删除多余的文件。',
  );
  rule(
    RegExp(
      r'Mixin apply failed|MixinApplyError|InvalidMixinException|Mixin transformation of .* failed|MixinTransformerError',
    ),
    'Mixin 注入失败',
    '通常是模组之间不兼容，或模组与当前 Minecraft、加载器版本不匹配。日志中会写出出错的模组。',
  );
  rule(
    RegExp(
      r'is a Forge mod|requires Forge|NeoForge mod.*Fabric|fabric.*not compatible with (Neo)?Forge',
      caseSensitive: false,
    ),
    '模组与加载器不匹配',
    '装了其他加载器的模组，例如在 Fabric 上装了 Forge 模组。',
  );

  // OptiFine
  rule(
    RegExp(
      r'(optifine|OptiFine).*(NoSuchMethodError|NoSuchFieldError|ClassNotFoundException|IllegalAccess)|(NoSuchMethodError|NoSuchFieldError).*optifine',
      caseSensitive: false,
    ),
    'OptiFine 不兼容',
    'OptiFine 与当前的 Forge 或其他模组不兼容。可以换用 OptiFine 要求的 Forge 版本，或移除 OptiFine。',
  );

  // 显卡与驱动
  rule(
    RegExp(
      r'Pixel format not accelerated|GLFW error 65542|WGL: The driver does not appear to support OpenGL|No OpenGL context|Failed to create (the )?display|OpenGL 3\.2 .*not supported|EXCEPTION_ACCESS_VIOLATION.*(ig[0-9a-z]+icd|atio6axx|nvoglv)|(ig[0-9a-z]+icd(32|64)|atio6axx|atig6pxx|nvoglv(32|64))\.dll',
      caseSensitive: false,
    ),
    '显卡驱动问题',
    '显卡驱动不支持或出错。请到显卡厂商官网更新驱动；笔记本可以让游戏使用独立显卡。',
  );

  // 其他
  rule(RegExp(r'Could not find or load main class'), '找不到主类', '游戏文件可能不完整，或路径中含有特殊字符。可以尝试补全文件或换一个不含特殊字符的文件夹。');
  rule(RegExp(r'Manually triggered debug crash'), '手动触发的崩溃', '这是按住 F3 + C 触发的调试崩溃，不是错误。');
  rule(RegExp(r'Suspected Mods?:\s*(?!NONE|None|Unknown)\S'), '崩溃报告怀疑的模组', '崩溃报告指出了可能导致崩溃的模组，可以先禁用它试试。');
  return out;
}
