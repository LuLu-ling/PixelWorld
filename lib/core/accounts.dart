import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'paths.dart';
import 'secure.dart';
import 'safe_write.dart';
import 'i18n/strings.dart';

/// 账户类型：离线、微软。
/// 外置登录（authlib-injector / Yggdrasil）已移除：Mojang 的 AppID 审核标准不允许使用第三方验证服务
enum AccountType { offline, microsoft }

/// 旧版本保存的外置登录账户类型，读取时丢弃
const _removedTypes = {'yggdrasil', 'yggdrasilConnect'};

class Account {
  Account({
    required this.id,
    required this.type,
    required this.name,
    required this.uuid,
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.importedLegacy = false,
  });

  final String id;
  final AccountType type;
  final String name;
  final String uuid;
  final String accessToken;
  final String? refreshToken;

  /// 毫秒时间戳
  final int? expiresAt;

  /// 从 PCL-CE 导入的微软账户：刷新令牌属于 PCL-CE 的应用，过期后需要重新登录
  final bool importedLegacy;

  String get typeLabel => switch (type) {
    AccountType.offline => tr.oobeOfflineAccount,
    AccountType.microsoft => tr.oobeMicrosoftAccount,
  };

  Account copyWith({String? id, String? name, String? accessToken, String? refreshToken, int? expiresAt}) => Account(
    id: id ?? this.id,
    type: type,
    name: name ?? this.name,
    uuid: uuid,
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    expiresAt: expiresAt ?? this.expiresAt,
    importedLegacy: importedLegacy,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'name': name,
    'uuid': uuid,
    'accessToken': accessToken,
    'refreshToken': ?refreshToken,
    'expiresAt': ?expiresAt,
    if (importedLegacy) 'importedFrom': 'pcl',
  };

  static Account fromJson(Map<String, dynamic> j) => Account(
    id: '${j['id']}',
    type: AccountType.values.asNameMap()[j['type']] ?? AccountType.offline,
    name: '${j['name']}',
    uuid: '${j['uuid']}',
    accessToken: '${j['accessToken']}',
    refreshToken: j['refreshToken'] as String?,
    expiresAt: (j['expiresAt'] as num?)?.toInt(),
    importedLegacy: j['importedFrom'] == 'pcl',
  );
}

String _randomHex(int bytes) {
  final r = Random.secure();
  return List.generate(bytes, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
}

String newId() => _randomHex(16);

/// 与 Java UUID.nameUUIDFromBytes("OfflinePlayer:" + name) 一致
String offlineUuid(String name) {
  final h = md5.convert(utf8.encode('OfflinePlayer:$name')).bytes.toList();
  h[6] = (h[6] & 0x0f) | 0x30;
  h[8] = (h[8] & 0x3f) | 0x80;
  return h.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// 账户列表，加密保存在应用数据目录的 accounts.dat（见 [SecureData]）
class AccountStore {
  AccountStore._(this.accounts, {this.removedExternal = 0});

  final List<Account> accounts;

  /// 读取时丢弃的旧外置登录账户数量（界面提示一次）
  int removedExternal;

  static File get _file => File(p.join(Paths.configDir, 'accounts.dat'));

  /// 早期版本明文保存的账户文件，读取后迁移到 accounts.dat
  static File get _legacyFile => File(p.join(Paths.configDir, 'accounts.json'));

  static AccountStore _parse(String text) {
    final all = (jsonDecode(text) as List).whereType<Map<String, dynamic>>().toList();
    final kept = all.where((j) => !_removedTypes.contains(j['type'])).toList();
    final store = AccountStore._(kept.map(Account.fromJson).toList(), removedExternal: all.length - kept.length);
    if (store.removedExternal > 0) unawaited(store._save().catchError((_) {}));
    return store;
  }

  static AccountStore load() {
    try {
      if (_file.existsSync()) {
        return _parse(utf8.decode(SecureData.unprotect(_file.readAsBytesSync())));
      }
      if (_legacyFile.existsSync()) {
        final store = _parse(_legacyFile.readAsStringSync());
        store._save().then((_) => _legacyFile.delete()).catchError((_) => _legacyFile);
        return store;
      }
    } catch (_) {
      // 文件损坏或无法解密时从空列表开始
    }
    return AccountStore._([]);
  }

  Future<void> _save() async {
    final text = jsonEncode([for (final a in accounts) a.toJson()]);
    await writeFileSafely(_file, SecureData.protect(Uint8List.fromList(utf8.encode(text))));
    unawaited(Paths.backupConfigFile(_file));
  }

  /// 添加或更新账户（同类型、同 UUID 视为同一账户）
  Future<Account> upsert(Account acc) => _put(acc, (a) => a.type == acc.type && a.uuid == acc.uuid);

  /// 导入（PCL-CE）：离线账户按名称匹配，避免 UUID 生成方式不同导致重复；其他账户同 [upsert]
  Future<Account> importAccount(Account acc) => acc.type == AccountType.offline
      ? _put(acc, (a) => a.type == AccountType.offline && a.name == acc.name)
      : upsert(acc);

  Future<Account> _put(Account acc, bool Function(Account) same) async {
    final i = accounts.indexWhere(same);
    if (i >= 0) {
      acc = acc.copyWith(id: accounts[i].id);
      accounts[i] = acc;
    } else {
      accounts.add(acc);
    }
    await _save();
    return acc;
  }

  static final _namePattern = RegExp(r'^[A-Za-z0-9_]{3,16}$');

  static String? validateOfflineName(String name) => _namePattern.hasMatch(name) ? null : tr.accountsUsernamesMust316;

  Future<Account> addOffline(String name) async {
    final error = validateOfflineName(name);
    if (error != null) throw Exception(error);
    final existing = accounts.indexWhere((a) => a.type == AccountType.offline && a.name == name);
    final acc = Account(
      id: existing >= 0 ? accounts[existing].id : newId(),
      type: AccountType.offline,
      name: name,
      uuid: offlineUuid(name),
      accessToken: _randomHex(16),
    );
    if (existing >= 0) {
      accounts[existing] = acc;
    } else {
      accounts.add(acc);
    }
    await _save();
    return acc;
  }

  Future<void> remove(String id) async {
    accounts.removeWhere((a) => a.id == id);
    await _save();
  }

  Account? find(String id) => accounts.where((a) => a.id == id).firstOrNull ?? accounts.firstOrNull;
}
