import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/version.dart';

void main() {
  test('Apple 芯片：LWJGL 3.2 换成 3.3.1 与 arm64 本地库，java-objc-bridge 换成 1.1.0-mmachina.1', () {
    final libs = appleSiliconLibraries([
      {'name': 'org.lwjgl:lwjgl:3.2.2'},
      {'name': 'org.lwjgl:lwjgl:3.2.1'},
      {'name': 'org.lwjgl:lwjgl-glfw:3.2.2'},
      {'name': 'ca.weblite:java-objc-bridge:1.0.0'},
      {'name': 'com.mojang:brigadier:1.0.17'},
      {'name': 'org.lwjgl:lwjgl:3.3.1'},
    ]).map((l) => l['name']).toList();
    expect(libs, [
      'org.lwjgl:lwjgl:3.3.1',
      'org.lwjgl:lwjgl:3.3.1:natives-macos-arm64',
      'org.lwjgl:lwjgl-glfw:3.3.1',
      'org.lwjgl:lwjgl-glfw:3.3.1:natives-macos-arm64',
      'ca.weblite:java-objc-bridge:1.1.0-mmachina.1',
      'com.mojang:brigadier:1.0.17',
      'org.lwjgl:lwjgl:3.3.1',
    ]);
    expect(
      mavenPath('org.lwjgl:lwjgl:3.3.1:natives-macos-arm64'),
      'org/lwjgl/lwjgl/3.3.1/lwjgl-3.3.1-natives-macos-arm64.jar',
    );
  });
  test('Apple 芯片：LWJGL 2 换成 2.9.4 与 arm64 本地库，旧版 JNA 换成 5.14.0', () {
    final libs = appleSiliconLibraries([
      {'name': 'org.lwjgl.lwjgl:lwjgl:2.9.4-nightly-20150209'},
      {'name': 'org.lwjgl.lwjgl:lwjgl_util:2.9.4-nightly-20150209'},
      {
        'name': 'org.lwjgl.lwjgl:lwjgl-platform:2.9.2-nightly-20140822',
        'natives': {'osx': 'natives-osx'},
      },
      {'name': 'net.java.dev.jna:jna:4.4.0'},
      {'name': 'net.java.dev.jna:platform:3.4.0'},
    ]);
    expect(libs.map((l) => l['name']), [
      'org.lwjgl.lwjgl:lwjgl:2.9.4-nightly-20150209',
      'org.lwjgl.lwjgl:lwjgl_util:2.9.4-nightly-20150209',
      'org.lwjgl.lwjgl:lwjgl-platform:2.9.4-nightly-20150209',
      'net.java.dev.jna:jna:5.14.0',
      'net.java.dev.jna:jna-platform:5.14.0',
    ]);
    final natives = libs[2]['downloads']['classifiers']['natives-osx-arm64'] as Map;
    expect(libs[2]['natives'], {'osx': 'natives-osx-arm64'});
    expect(natives['sha1'], 'eff546c0b319d6ffc7a835652124c18089c67f36');
  });
}
