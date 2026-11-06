import 'accounts.dart';

/// 启动前的正版购买提示与赞助提示。
///
/// 没有登录过正版账号时，每次离线启动都会提示，可以打开购买页面（不启动）、
/// 这次先离线启动、试玩（--demo）或返回。登录过一次正版账号后（hintBuy），
/// 不再进行正版购买提示。

/// 弹出赞助提示的启动次数
const sponsorCounts = {10, 30, 60, 100, 200, 400, 800, 1200, 2000};

/// 正版购买页面
const buyMinecraftUrl = 'https://www.minecraft.net/store/minecraft-java-bedrock-edition-pc';

/// 是否需要正版验证：离线账户且从未登录过正版账号
bool needsOwnershipCheck(Account acc, {required bool hintBuy}) => !hintBuy && acc.type == AccountType.offline;

/// 本次启动是否弹出赞助提示
bool shouldAskSponsor(int launchCount) => sponsorCounts.contains(launchCount);

/// 正版验证对话框的选择：打开购买页面（不启动）、这次先离线启动、试玩、返回
enum OwnershipChoice { store, launch, demo, cancel }

