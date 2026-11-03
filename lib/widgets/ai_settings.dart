import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/ai_client.dart';

/// AI 排障的接口设置：用户自己填写接口地址、模型与 API Key
class AiSettingsForm extends StatefulWidget {
  const AiSettingsForm({super.key, this.onSaved, this.showButtons = true});

  final VoidCallback? onSaved;

  /// 在对话框中时，保存与测试按钮放在对话框底部
  final bool showButtons;

  @override
  State<AiSettingsForm> createState() => AiSettingsFormState();
}

class AiSettingsFormState extends State<AiSettingsForm> {
  bool _loaded = false;
  late AiProvider _provider;
  final _url = TextEditingController();
  final _model = TextEditingController();
  final _key = TextEditingController();
  bool _showKey = false;
  bool _testing = false;
  String? _result;
  bool _ok = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final s = AiSettings.load(AppScope.read(context).config);
    _provider = s.provider;
    _url.text = s.baseUrl;
    _model.text = s.model;
    _key.text = s.apiKey;
  }

  @override
  void dispose() {
    _url.dispose();
    _model.dispose();
    _key.dispose();
    super.dispose();
  }

  AiSettings get _current =>
      AiSettings(provider: _provider, baseUrl: _url.text.trim(), model: _model.text.trim(), apiKey: _key.text.trim());

  Future<void> save() async {
    await _current.save(AppScope.read(context).config);
    if (!mounted) return;
    toast(context, '已保存');
    widget.onSaved?.call();
  }

  Future<void> test() async {
    final s = _current;
    if (!s.ready) {
      setState(() {
        _ok = false;
        _result = '请填写接口地址、模型${s.isLocal ? '' : '和 API Key'}';
      });
      return;
    }
    setState(() {
      _testing = true;
      _result = null;
    });
    try {
      final reply = await aiChat(s, '你是一个连接测试助手。', const [AiMessage('user', '只回复两个字：成功')]).join();
      setState(() {
        _ok = true;
        _result = '连接成功，模型回复：${reply.trim().characters.take(40)}';
      });
    } catch (e) {
      setState(() {
        _ok = false;
        _result = errorText(e);
      });
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  bool get testing => _testing;

  /// 测试连接的结果；对话框中显示在按钮旁
  Widget get resultText => _result == null
      ? const SizedBox.shrink()
      : Text(
          _result!,
          style: TextStyle(color: _ok ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error),
        );

  Widget get testLabel => _testing
      ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
      : const Text('测试连接');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cfg = AppScope.of(context).config;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('常用服务', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in aiPresets)
              ActionChip(
                label: Text(preset.label),
                onPressed: () => setState(() {
                  _provider = preset.provider;
                  _url.text = preset.url;
                  if (preset.model.isNotEmpty) _model.text = preset.model;
                }),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SegmentedButton<AiProvider>(
          segments: const [
            ButtonSegment(value: AiProvider.openai, label: Text('OpenAI 兼容接口')),
            ButtonSegment(value: AiProvider.anthropic, label: Text('Anthropic 接口')),
          ],
          selected: {_provider},
          onSelectionChanged: (s) => setState(() => _provider = s.first),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _url,
          decoration: InputDecoration(
            labelText: '接口地址',
            hintText: _provider == AiProvider.anthropic ? 'https://api.anthropic.com' : 'https://api.example.com/v1',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _model,
          decoration: const InputDecoration(labelText: '模型', hintText: '模型名称见服务商的文档', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _key,
          obscureText: !_showKey,
          decoration: InputDecoration(
            labelText: 'API Key',
            helperText: '加密保存在本机，只会发送给上面填写的接口地址；本机运行的服务可以不填',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              tooltip: _showKey ? '隐藏' : '显示',
              icon: Icon(_showKey ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => _showKey = !_showKey),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('发送前确认内容'),
          subtitle: const Text('每次分析前显示将要发送的日志与环境信息'),
          value: cfg.aiConfirm,
          onChanged: (v) => cfg.update({'aiConfirm': v}),
        ),
        if (widget.showButtons) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton(onPressed: save, child: const Text('保存')),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: _testing ? null : test, child: testLabel),
            ],
          ),
        ],
        if (_result != null && widget.showButtons) ...[const SizedBox(height: 12), resultText],
      ],
    );
  }
}

Future<void> showAiSettingsDialog(BuildContext context) {
  final form = GlobalKey<AiSettingsFormState>();
  return showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setLocal) => AlertDialog(
        title: const Text('AI 排障设置'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: AiSettingsForm(key: form, showButtons: false, onSaved: () => Navigator.pop(context)),
          ),
        ),
        actionsOverflowButtonSpacing: 8,
        actions: [
          if (form.currentState != null) SizedBox(width: 240, child: form.currentState!.resultText),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          OutlinedButton(
            onPressed: form.currentState?.testing ?? false
                ? null
                : () async {
                    final t = form.currentState?.test();
                    setLocal(() {});
                    await t;
                    if (context.mounted) setLocal(() {});
                  },
            child: form.currentState?.testLabel ?? const Text('测试连接'),
          ),
          FilledButton(onPressed: () => form.currentState?.save(), child: const Text('保存')),
        ],
      ),
    ),
  );
}
