import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'paths.dart';

enum AccountType { offline, microsoft }

class Account {
  Account({
    required this.id,
    required this.type,
    required this.name,
    required this.uuid,
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  final String id;
  final AccountType type;
  final String name;
  final String uuid;
  final String accessToken;
  final String? refreshToken;

  /// 毫秒时间戳
  final int? expiresAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'name': name,
    'uuid': uuid,
    'accessToken': accessToken,
    if (refreshToken != null) 'refreshToken': refreshToken,
    if (expiresAt != null) 'expiresAt': expiresAt,
  };

  static Account fromJson(Map<String, dynamic> j) => Account(
    id: '${j['id']}',
    type: j['type'] == 'microsoft' ? AccountType.microsoft : AccountType.offline,
    name: '${j['name']}',
    uuid: '${j['uuid']}',
    accessToken: '${j['accessToken']}',
    refreshToken: j['refreshToken'] as String?,
    expiresAt: (j['expiresAt'] as num?)?.toInt(),
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

/// 账户列表，保存在应用数据目录的 accounts.json。
/// 目前只有离线账户；微软账户的令牌在迁移微软登录时改为加密保存。
class AccountStore {
  AccountStore._(this.accounts);

  final List<Account> accounts;

  static File get _file => File(p.join(Paths.appData, 'accounts.json'));

  static AccountStore load() {
    try {
      if (_file.existsSync()) {
        final list = jsonDecode(_file.readAsStringSync()) as List;
        return AccountStore._(list.whereType<Map<String, dynamic>>().map(Account.fromJson).toList());
      }
    } catch (_) {
      // 文件损坏时从空列表开始
    }
    return AccountStore._([]);
  }

  Future<void> _save() async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(jsonEncode([for (final a in accounts) a.toJson()]));
  }

  static final _namePattern = RegExp(r'^[A-Za-z0-9_]{3,16}$');

  static String? validateOfflineName(String name) => _namePattern.hasMatch(name) ? null : '用户名需为 3-16 位字母、数字或下划线';

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
