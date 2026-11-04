import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/java.dart';
import 'package:pcl_pw/core/version.dart';

void main() {
  VersionJson main(String mainClass) => VersionJson({'id': 'x', 'mainClass': mainClass});

  test('LaunchWrapper 版本使用 Java 9 及以上时提醒', () {
    final forge112 = main('net.minecraft.launchwrapper.Launch');
    expect(javaTooNewWarning(forge112, 8), isNull);
    expect(javaTooNewWarning(forge112, 17), contains('Java 17'));
  });

  test('原版与新版加载器不提醒', () {
    expect(javaTooNewWarning(main('net.minecraft.client.main.Main'), 17), isNull);
    expect(javaTooNewWarning(main('cpw.mods.bootstraplauncher.BootstrapLauncher'), 21), isNull);
  });
}
