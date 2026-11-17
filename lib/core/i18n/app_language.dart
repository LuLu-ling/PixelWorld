/// 启动器的界面语言（领域模型，不依赖 Flutter）。[tag] 是 BCP 47 语言标签，也是保存在配置里的值
enum AppLanguage {
  system('system', null),
  enUS('en-US', 'English (US)'),
  enGB('en-GB', 'English (UK)'),
  zhHans('zh-Hans', '简体中文'),
  zhHant('zh-Hant', '繁體中文');

  const AppLanguage(this.tag, this.nativeName);

  final String tag;

  /// 用这种语言自己写的名称；「跟随系统」没有固定名称，由界面翻译
  final String? nativeName;

  /// 系统语言都不支持时使用
  static const fallback = enUS;

  static AppLanguage parse(Object? tag) => values.firstWhere((l) => l.tag == tag, orElse: () => system);

  /// 把一个系统语言归到支持的语言之一，不支持时返回 null。
  /// 中文按文字（没有文字代码时按地区）分简繁；英文按地区分英式与美式
  static AppLanguage? match(String language, {String? script, String? region}) => switch (language) {
    'zh' when script == 'Hant' || script == null && const {'TW', 'HK', 'MO'}.contains(region) => zhHant,
    'zh' => zhHans,
    'en' when const {'GB', 'IE', 'AU', 'NZ'}.contains(region) => enGB,
    'en' => enUS,
    _ => null,
  };

  /// 「自动设置游戏语言」写入 options.txt 的语言；跟随系统时为 null，沿用系统语言
  String? get gameLocale => switch (this) {
    system => null,
    enUS => 'en_US',
    enGB => 'en_GB',
    zhHans => 'zh_CN',
    zhHant => 'zh_TW',
  };
}

/// 语言设置的存取（端口）：命令和界面只依赖它，不关心保存在哪里
abstract interface class LanguageStore {
  AppLanguage get current;

  Future<void> save(AppLanguage language);
}
