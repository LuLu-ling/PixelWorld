import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/version.dart';

void main() {
  test('Apple 芯片：LWJGL 3.2 换成 3.3.1 与 arm64 本地库，java-objc-bridge 换成 1.1', () {
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
      'ca.weblite:java-objc-bridge:1.1',
      'com.mojang:brigadier:1.0.17',
      'org.lwjgl:lwjgl:3.3.1',
    ]);
    expect(
      mavenPath('org.lwjgl:lwjgl:3.3.1:natives-macos-arm64'),
      'org/lwjgl/lwjgl/3.3.1/lwjgl-3.3.1-natives-macos-arm64.jar',
    );
  });
}
