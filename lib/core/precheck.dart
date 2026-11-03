import 'accounts.dart';

/// 启动前的正版购买劝导与赞助劝导。
///
/// 按《PCL 存储库合理使用指南》第 4 条，需要与 PCL 的 McLaunchPrecheck 一致或更严格。
/// PCL 按系统语言区分两种规则；PCL.PW 不按地区或语言区分，所有人都使用其中更严格的一种：
/// 没有登录过正版账号时，每次离线启动都弹出提示，可以购买正版（打开商店页面后照常启动，与 PCL 相同）、
/// 试玩（--demo）或返回。登录过一次正版账号后（hintBuy），不再进行正版购买劝导。

/// 弹出赞助劝导的启动次数（与 PCL 相同）
const sponsorCounts = {
  10, 20, 40, 60, 80, 100, 120, 150, 200, 250, 300, 350, 400, 500, 600, 700, 800, 900, 1000, //
  1200, 1400, 1600, 1800, 2000,
};

/// 正版购买页面
const buyMinecraftUrl = 'https://www.minecraft.net/store/minecraft-java-bedrock-edition-pc';

/// 是否需要正版验证：离线账户且从未登录过正版账号
bool needsOwnershipCheck(Account acc, {required bool hintBuy}) => !hintBuy && acc.type == AccountType.offline;

/// 本次启动是否弹出赞助劝导
bool shouldAskSponsor(int launchCount) => sponsorCounts.contains(launchCount);

/// 正版验证对话框的选择
enum OwnershipChoice { buy, demo, cancel }
