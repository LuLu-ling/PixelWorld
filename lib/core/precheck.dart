import 'accounts.dart';
import 'i18n/strings.dart';

/// 启动前的正版验证与赞助提示。
///
/// Mojang 要求启动器先验证用户拥有游戏、完成登录，才能开始游戏。所以离线账户和外置登录账户
/// 要在登录过一次购买了 Minecraft 的微软账户之后（hintBuy）才能添加和启动；
/// 在那之前用它们启动，只能选择去登录或去购买。

/// 弹出赞助提示的启动次数
const sponsorCounts = {10, 30, 60, 100, 200, 400, 800, 1200, 2000};

/// 正版购买页面
const buyMinecraftUrl = 'https://www.minecraft.net/store/minecraft-java-bedrock-edition-pc';

/// 是否需要正版验证：不是微软账户（离线、外置登录），且从未登录过购买了游戏的微软账户
bool needsOwnershipCheck(Account acc, {required bool hintBuy}) => !hintBuy && acc.type != AccountType.microsoft;

/// 离线账户和外置登录不可用时的说明
String get ownershipRequiredHint => tr.precheckOwnershipRequired;

/// 本次启动是否弹出赞助提示
bool shouldAskSponsor(int launchCount) => sponsorCounts.contains(launchCount);

/// 正版验证对话框的选择：去登录微软账户、打开购买页面、返回（都不启动游戏）
enum OwnershipChoice { login, store, cancel }
