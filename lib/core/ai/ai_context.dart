import 'dart:convert';

/// 已知模型的上下文长度（按各家文档核对；未知的模型返回 null，使用设置中的值或默认值）
int? knownContextWindow(String model) {
  final m = model.toLowerCase();
  // DeepSeek V4 / V4.1：1M 上下文
  if (m.startsWith('deepseek-flash') || m.startsWith('deepseek-v4')) return 1000000;
  if (m.startsWith('claude-haiku-4')) return 200000;
  if (m.startsWith('claude-')) return 1000000;
  return null;
}

/// 未知模型的默认上下文长度
const defaultContextWindow = 128000;

/// 粗略估算 tokens：中日韩文字约 0.7 个/字，其他约 3.5 个字符一个
int estimateTokens(String text) {
  var cjk = 0;
  for (final r in text.runes) {
    if (r >= 0x2E80 && r <= 0x9FFF || r >= 0xAC00 && r <= 0xD7AF || r >= 0xFF00 && r <= 0xFFEF) cjk++;
  }
  return (cjk * 0.7 + (text.length - cjk) / 3.5).round();
}

/// 系统提示与工具说明大约占用的 tokens（没有用量数据时用于估算）
const promptOverheadTokens = 3500;

/// 压缩时保留的最近几轮对话
const keepRecentTurns = 2;

/// 压缩上下文时使用的系统提示
const compactSystemPrompt = '''
你负责为 Minecraft 启动器 Pixel World 的 AI 助手压缩对话记录。把给出的较早对话整理成摘要，之后的对话会用这份摘要代替原文继续进行。

摘要要保留：
- 用户的目标、问题和偏好；
- 涉及的具体信息：版本名、加载器、模组名与文件名、路径、版本号、报错的关键内容；
- 已经得出的结论和依据；
- 已经执行的操作及结果，包括用户拒绝或取消的操作；
- 尚未解决的问题和计划的下一步。

要求：只根据对话内容整理，不要补充或推测；去掉寒暄和重复内容；用简体中文和条目列表；不超过 1000 字。如果给出了已有的摘要，把它和新的对话合并成一份完整的摘要。只输出摘要本身。
''';

/// 放在压缩后的历史最前面，告诉模型这是摘要
const summaryLead = '【较早对话的摘要】以下是这次对话较早部分的摘要（原文已压缩），之后是最近的对话：';

String _clip(String s, int max) => s.length <= max ? s : '${s.substring(0, max)}…（省略 ${s.length - max} 个字符）';

/// 把一段对话整理成文字，供模型压缩
String transcriptOf(
  Iterable<({String role, String content, List<({String name, Map<String, dynamic> args})> calls})> ms,
) {
  final b = StringBuffer();
  for (final m in ms) {
    switch (m.role) {
      case 'user':
        b.writeln('用户：${_clip(m.content, 6000)}');
      case 'tool':
        b.writeln('操作结果：${_clip(m.content, 1500)}');
      default:
        if (m.content.isNotEmpty) b.writeln('助手：${_clip(m.content, 4000)}');
        for (final c in m.calls) {
          b.writeln('助手调用操作：${c.name} ${jsonEncode(c.args)}');
        }
    }
    b.writeln();
  }
  final text = b.toString();
  // 压缩请求本身也不能太长：只保留最后的部分
  const max = 200000;
  return text.length <= max ? text : '…（更早的内容省略）\n${text.substring(text.length - max)}';
}
