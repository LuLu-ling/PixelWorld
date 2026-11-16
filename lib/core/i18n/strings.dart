import 'package:flutter/widgets.dart' show Locale;

import '../../l10n/app_localizations.dart';

/// core 里给用户看的文字（任务名、阶段、错误、启动日志）。core 没有 BuildContext，从这里读当前语言的词条；
/// 界面层在语言确定或切换时调用 [useCoreStrings]（见 main.dart），没有界面时（安装器、测试）为简体中文
AppLocalizations get tr => _strings;
AppLocalizations _strings = lookupAppLocalizations(const Locale('zh'));

void useCoreStrings(AppLocalizations strings) => _strings = strings;
