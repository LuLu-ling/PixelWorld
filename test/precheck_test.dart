import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/accounts.dart';
import 'package:pcl_pw/core/precheck.dart';

Account _acc(AccountType type) => Account(id: 'x', type: type, name: 'Steve', uuid: '0', accessToken: '0');

void main() {
  test('没有验证过正版时，只有微软账户能直接启动', () {
    expect(needsOwnershipCheck(_acc(AccountType.microsoft), hintBuy: false), isFalse);
    for (final t in [AccountType.offline, AccountType.yggdrasil, AccountType.yggdrasilConnect]) {
      expect(needsOwnershipCheck(_acc(t), hintBuy: false), isTrue, reason: '$t');
    }
  });

  test('验证过正版后，所有账户都能启动', () {
    for (final t in AccountType.values) {
      expect(needsOwnershipCheck(_acc(t), hintBuy: true), isFalse, reason: '$t');
    }
  });
}
