import 'core/i18n/strings.dart';

/// 名称与外部链接。名称规则见仓库根目录的 PCL-GUIDE.md。
abstract final class AppInfo {
  static const name = 'Pixel World';
  static String get fullName => tr.appInfoPixelWorldLauncher;

  /// 新 UI 使用的品牌名；正式改名时再统一替换 [name]
  static const brandName = 'Pixel World';
  static const version = '0.3.4';

  /// 构建信息，由 CI 通过 --dart-define 写入；本地构建为空
  static const commit = String.fromEnvironment('PCLPW_COMMIT');

  /// 微软登录默认的 Client ID，由 CI 通过 --dart-define 注入；本地构建为空
  static const msClientId = String.fromEnvironment('PCLPW_MS_CLIENT_ID');

  /// 这个构建所属的更新通道：stable、preview 或 nightly
  static const channel = String.fromEnvironment('PCLPW_CHANNEL', defaultValue: 'stable');

  static const repoApi = 'https://api.github.com/repos/zhuzhi-09/PixelWorld';

  /// 自有静态接口（按路径版本化），依次尝试，全部失败时更新检查回落到 GitHub API。
  /// zhuzhi.site 已于 2026-11 到期弃用，不再访问，以免域名被他人注册后返回伪造的更新信息。
  static const siteApiBases = [
    'https://pixelworld.paperzhu.com/api/v1',
    'https://raw.githubusercontent.com/zhuzhi-09/PixelWorld/site/docs/api/v1',
  ];

  /// update.json 签名的 Ed25519 公钥（Base64，32 字节）。私钥只在仓库的 Actions 密钥 UPDATE_SIGNING_KEY 里，
  /// 发布工作流用它签名（见 release.yml 的 Update API 步骤）。换密钥时旧版本会改用 GitHub API 检查更新
  static const updateSigningKey = 'U0I7l4ViNu90Cc1bAwcOSGyI0Vl7CpZ+YC+dqNvrAP0=';

  static const repoUrl = 'https://github.com/zhuzhi-09/PixelWorld';

  static const authorName = 'Paper.Zhu';
  static const sponsorUrl = 'https://afdian.com/a/Paper_Zhu';
  static const pclCeRepoUrl = 'https://github.com/PCL-Community/PCL-CE';
}
