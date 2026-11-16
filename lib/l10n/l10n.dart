import 'package:flutter/widgets.dart';

import '../core/i18n/app_language.dart';
import 'app_localizations.dart';

export '../core/i18n/app_language.dart';
export 'app_localizations.dart';

/// 界面文字：`context.l10n.xxx`。词条在同目录的 app_*.arb，新增后运行 `flutter gen-l10n`
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// 领域里的语言与 Flutter 的 [Locale] 对应（表现层）
extension AppLanguageLocale on AppLanguage {
  /// 「跟随系统」为 null，由 [AppL10n.resolve] 按系统语言选择
  Locale? get locale => switch (this) {
    AppLanguage.system => null,
    AppLanguage.enUS => const Locale('en', 'US'),
    AppLanguage.enGB => const Locale('en', 'GB'),
    AppLanguage.zhHans => const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    AppLanguage.zhHant => const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  };

  /// 语言选择器里的名称：具体语言用它自己的写法，「跟随系统」随当前界面语言
  String label(AppLocalizations l) => nativeName ?? l.languageSystem;
}

/// 几处共用的设置值名称
extension SettingLabels on AppLocalizations {
  /// 版本隔离策略（见 config.dart 的 isolationModes）
  String isolationMode(int mode) => switch (mode) {
    0 => isolationOff,
    1 => isolationModable,
    2 => isolationUnstable,
    3 => isolationModableUnstable,
    _ => isolationAll,
  };
}

/// MaterialApp 的多语言配置
abstract final class AppL10n {
  static final supportedLocales = [for (final l in AppLanguage.values) ?l.locale];

  static const delegates = AppLocalizations.localizationsDelegates;

  /// 把用户选的语言或系统语言列表归到支持的语言之一（中文简繁、英式美式都在领域层判断）
  static Locale resolve(List<Locale>? preferred, Iterable<Locale> _) {
    final match = preferred
        ?.map((l) => AppLanguage.match(l.languageCode, script: l.scriptCode, region: l.countryCode))
        .nonNulls
        .firstOrNull;
    return (match ?? AppLanguage.fallback).locale!;
  }
}
