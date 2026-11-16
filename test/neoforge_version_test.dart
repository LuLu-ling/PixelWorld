import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/forge.dart';

void main() {
  test('NeoForge 版本号按数字比较，同号时测试版在前', () {
    expect(compareNeoForgeVersions('26.3.0.10', '26.3.0.9'), greaterThan(0));
    expect(compareNeoForgeVersions('26.3.0.0-beta', '26.3.0.0'), lessThan(0));
    expect(compareNeoForgeVersions('21.1.266', '21.1.266'), 0);
    expect(compareNeoForgeVersions('1.20.1-47.1.105', '1.20.1-47.1.99'), greaterThan(0));
  });

  test('NeoForge 版本号对应的游戏版本', () {
    expect(neoForgeGameVersion('26.3.0.103'), '26.3');
    expect(neoForgeGameVersion('26.1.2.5'), '26.1.2');
    expect(neoForgeGameVersion('21.1.266'), '1.21.1');
    expect(neoForgeGameVersion('21.0.10-beta'), '1.21');
  });
}
