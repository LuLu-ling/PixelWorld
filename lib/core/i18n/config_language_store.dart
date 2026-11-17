import '../config.dart';
import 'app_language.dart';

/// 把界面语言保存在启动器配置（config.json）里
class ConfigLanguageStore implements LanguageStore {
  const ConfigLanguageStore(this._config);

  final LauncherConfig _config;

  @override
  AppLanguage get current => _config.language;

  @override
  Future<void> save(AppLanguage language) => _config.update({LauncherConfig.languageKey: language.tag});
}
