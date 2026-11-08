/// 名称与外部链接。名称规则见仓库根目录的 PCL-GUIDE.md。
abstract final class AppInfo {
  static const name = 'Pixel World';
  static const fullName = 'Pixel World 启动器';

  /// 新 UI 使用的品牌名；正式改名时再统一替换 [name]
  static const brandName = 'Pixel World';
  static const version = '0.3.3';

  /// 构建信息，由 CI 通过 --dart-define 写入；本地构建为空
  static const commit = String.fromEnvironment('PCLPW_COMMIT');

  /// 这个构建所属的更新通道：stable、preview 或 nightly
  static const channel = String.fromEnvironment('PCLPW_CHANNEL', defaultValue: 'stable');

  static const repoApi = 'https://api.github.com/repos/zhuzhi-09/PixelWorld';

  /// 自有静态接口（按路径版本化），依次尝试，全部失败时更新检查回落到 GitHub API。
  /// 旧域名在迁移期保留，作为第二候选。
  static const siteApiBases = [
    'https://pixelworld.zhuzhi.site/api/v1',
    'https://pcl.pw.zhuzhi.site/api/v1',
    'https://raw.githubusercontent.com/zhuzhi-09/PixelWorld/site/docs/api/v1',
  ];

  static const repoUrl = 'https://github.com/zhuzhi-09/PixelWorld';

  static const authorName = 'Paper.Zhu';
  static const sponsorUrl = 'https://afdian.com/a/Paper_Zhu';
  static const pclCeRepoUrl = 'https://github.com/PCL-Community/PCL-CE';
}
