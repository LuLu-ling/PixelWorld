import '../command.dart';
import 'app_language.dart';

/// 切换界面语言：保存到 [LanguageStore]，订阅设置的界面随之按新语言重建
class ChangeLanguageCommand implements Command {
  const ChangeLanguageCommand(this._store, this.language);

  final LanguageStore _store;
  final AppLanguage language;

  @override
  Future<void> execute() async {
    if (_store.current != language) await _store.save(language);
  }
}
