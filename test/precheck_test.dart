import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/accounts.dart';
import 'package:pcl_pw/compat/pcl/import.dart';
import 'package:pcl_pw/core/precheck.dart';

Account _acc(AccountType type) => Account(id: 'x', type: type, name: 'Steve', uuid: '0', accessToken: '0');

void main() {
  test('没有验证过正版时，只有微软账户能直接启动', () {
    expect(needsOwnershipCheck(_acc(AccountType.microsoft), hintBuy: false), isFalse);
    expect(needsOwnershipCheck(_acc(AccountType.offline), hintBuy: false), isTrue);
  });

  test('只有微软和离线两种账户（外置登录已移除）', () {
    expect(AccountType.values, [AccountType.offline, AccountType.microsoft]);
  });

  test('从 PCL 导入时跳过外置登录档案', () {
    for (final type in ['Authlib', 'YggdrasilConnect']) {
      final pr = {
        'profileType': type,
        'username': 'Steve',
        'uuid': 'abc',
        'server': 'https://littleskin.cn/api/yggdrasil',
      };
      expect(pclAccount(pr), isNull, reason: type);
      expect(pclExternalProfile(pr), isTrue, reason: type);
    }
    final offline = pclAccount({'profileType': 'Offline', 'username': 'Steve', 'uuid': 'abc'});
    expect(offline?.type, AccountType.offline);
    expect(pclExternalProfile({'profileType': 'Microsoft'}), isFalse);
  });

  test('验证过正版后，所有账户都能启动', () {
    for (final t in AccountType.values) {
      expect(needsOwnershipCheck(_acc(t), hintBuy: true), isFalse, reason: '$t');
    }
  });
}
