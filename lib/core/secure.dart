import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// 用系统机制加密本地保存的令牌。
/// Windows 使用 DPAPI（与当前用户绑定，Electron 的 safeStorage 也是这样做的）；
/// 其他平台暂未接入钥匙串，原样保存。
abstract final class SecureData {
  static bool get available => Platform.isWindows;

  static Uint8List protect(Uint8List data) => available ? _dpapi(data, encrypt: true) : data;

  static Uint8List unprotect(Uint8List data) => available ? _dpapi(data, encrypt: false) : data;

  static Uint8List _dpapi(Uint8List data, {required bool encrypt}) {
    return using((arena) {
      final input = arena<CRYPT_INTEGER_BLOB>();
      final output = arena<CRYPT_INTEGER_BLOB>();
      final buf = arena<Uint8>(data.length);
      buf.asTypedList(data.length).setAll(0, data);
      input.ref
        ..cbData = data.length
        ..pbData = buf;
      final ok = encrypt
          ? CryptProtectData(input, null, null, null, 0, output).value
          : CryptUnprotectData(input, null, null, null, 0, output).value;
      if (!ok) throw Exception(encrypt ? '加密失败' : '解密失败');
      try {
        return Uint8List.fromList(output.ref.pbData.asTypedList(output.ref.cbData));
      } finally {
        HLOCAL(output.ref.pbData).close();
      }
    });
  }
}
