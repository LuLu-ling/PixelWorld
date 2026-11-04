import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// 用系统机制加密本地保存的令牌与 API Key。
/// Windows 使用 DPAPI（与当前用户绑定，Electron 的 safeStorage 也是这样做的）。
/// 其他平台暂未接入系统密钥库，[protect] 原样返回，数据只受应用私有目录的权限保护
/// （安卓上已关闭应用数据备份，避免随系统备份带出）。[available] 为 false 时界面不应声称已加密。
abstract final class SecureData {
  static bool get available => Platform.isWindows;

  static Uint8List protect(Uint8List data) => available ? _dpapi(data, encrypt: true) : data;

  static Uint8List unprotect(Uint8List data, {List<int>? entropy}) =>
      available ? _dpapi(data, encrypt: false, entropy: entropy) : data;

  static Uint8List _dpapi(Uint8List data, {required bool encrypt, List<int>? entropy}) {
    return using((arena) {
      Pointer<CRYPT_INTEGER_BLOB> blob(List<int> bytes) {
        final b = arena<CRYPT_INTEGER_BLOB>();
        final buf = arena<Uint8>(bytes.isEmpty ? 1 : bytes.length);
        buf.asTypedList(bytes.length).setAll(0, bytes);
        b.ref
          ..cbData = bytes.length
          ..pbData = buf;
        return b;
      }

      final input = blob(data);
      final extra = entropy == null ? null : blob(entropy);
      final output = arena<CRYPT_INTEGER_BLOB>();
      final ok = encrypt
          ? CryptProtectData(input, null, extra, null, 0, output).value
          : CryptUnprotectData(input, null, extra, null, 0, output).value;
      if (!ok) throw Exception(encrypt ? '加密失败' : '解密失败');
      try {
        return Uint8List.fromList(output.ref.pbData.asTypedList(output.ref.cbData));
      } finally {
        HLOCAL(output.ref.pbData).close();
      }
    });
  }
}
