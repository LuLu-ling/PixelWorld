/// 名称与外部链接。名称规则见仓库根目录的 PCL-GUIDE.md。
abstract final class AppInfo {
  static const name = 'PCL.PW';
  static const fullName = 'PCL.PW（PixelsWorld 修改版）';
  static const version = '0.3.0';

  /// 构建信息，由 CI 通过 --dart-define 写入；本地构建为空
  static const commit = String.fromEnvironment('PCLPW_COMMIT');

  /// 这个构建所属的更新通道：stable、preview 或 nightly
  static const channel = String.fromEnvironment('PCLPW_CHANNEL', defaultValue: 'stable');

  static const repoApi = 'https://api.github.com/repos/zhuzhi-09/PCL.PW';

  /// 自有静态接口（按路径版本化），依次尝试，全部失败时更新检查回落到 GitHub API
  static const siteApiBases = [
    'https://pcl.pw.zhuzhi.site/api/v1',
    'https://raw.githubusercontent.com/zhuzhi-09/PCL.PW/site/docs/api/v1',
  ];

  static const repoUrl = 'https://github.com/zhuzhi-09/PCL.PW';

  // 按指南第 3 条，关于页首位为龙腾猫跃的署名及赞助链接
  static const pclAuthor = '龙腾猫跃';
  static const pclSponsorUrl = 'https://afdian.com/a/LTCat';
  static const pclRepoUrl = 'https://github.com/Meloong-Git/PCL';
  static const pclCeRepoUrl = 'https://github.com/PCL-Community/PCL-CE';
}
