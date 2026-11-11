import 'dart:convert';
import 'dart:io';

import 'accounts.dart';

const _msAuth = 'https://login.microsoftonline.com/consumers/oauth2/v2.0';
const _scope = 'XboxLive.signin offline_access';

class DeviceCode {
  DeviceCode({required this.userCode, required this.verificationUri, required this.expiresIn});

  final String userCode;
  final String verificationUri;
  final int expiresIn;
}

final _client = HttpClient()..connectionTimeout = const Duration(seconds: 20);

Future<(int, Map<String, dynamic>)> _request(
  String method,
  String url, {
  Object? json,
  Map<String, String>? form,
  String? bearer,
}) async {
  final req = await _client.openUrl(method, Uri.parse(url));
  req.headers.set(HttpHeaders.acceptHeader, 'application/json');
  if (bearer != null) req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
  if (form != null) {
    req.headers.contentType = ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8');
    req.write(Uri(queryParameters: form).query);
  } else if (json != null) {
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(json));
  }
  final res = await req.close().timeout(const Duration(seconds: 30));
  final body = await res.transform(utf8.decoder).join();
  Map<String, dynamic> data;
  try {
    data = body.isEmpty ? {} : jsonDecode(body) as Map<String, dynamic>;
  } catch (_) {
    data = {};
  }
  return (res.statusCode, data);
}

/// Xbox 的错误码转为可读的说明
Never _xboxError(int status, Map<String, dynamic> data, String url) {
  switch (data['XErr']) {
    case 2148916233:
      throw Exception('该微软账户尚未创建 Xbox 档案');
    case 2148916238:
      throw Exception('未成年账户需要加入家庭组后才能登录');
  }
  final reason = '${data['errorMessage'] ?? data['error_description'] ?? data['Message'] ?? data['error'] ?? ''}'
      .trim();
  if (reason.contains('Invalid app registration')) {
    throw Exception(
      'Minecraft 拒绝了这个 Azure 应用（$status Invalid app registration）。'
      '新应用需要先通过 Mojang 的审核（https://aka.ms/mce-reviewappid），'
      '审核通过后要用同一个 Client ID 重新登录；刚通过时可能要等一段时间才生效',
    );
  }
  throw Exception('请求失败（$status）：$url${reason.isEmpty ? '' : '\n$reason'}');
}

Future<Map<String, dynamic>> _postJson(String url, Object body) async {
  final (status, data) = await _request('POST', url, json: body);
  if (status >= 400) _xboxError(status, data, url);
  return data;
}

/// 用微软令牌换取 Minecraft 令牌与档案
Future<Account> _minecraftFromMs(String msAccess, String msRefresh) async {
  final xbl = await _postJson('https://user.auth.xboxlive.com/user/authenticate', {
    'Properties': {'AuthMethod': 'RPS', 'SiteName': 'user.auth.xboxlive.com', 'RpsTicket': 'd=$msAccess'},
    'RelyingParty': 'http://auth.xboxlive.com',
    'TokenType': 'JWT',
  });
  final xsts = await _postJson('https://xsts.auth.xboxlive.com/xsts/authorize', {
    'Properties': {
      'SandboxId': 'RETAIL',
      'UserTokens': [xbl['Token']],
    },
    'RelyingParty': 'rp://api.minecraftservices.com/',
    'TokenType': 'JWT',
  });
  final uhs = (((xbl['DisplayClaims'] as Map)['xui'] as List).first as Map)['uhs'];
  final mc = await _postJson('https://api.minecraftservices.com/authentication/login_with_xbox', {
    'identityToken': 'XBL3.0 x=$uhs;${xsts['Token']}',
  });
  final mcToken = '${mc['access_token']}';
  final (status, profile) = await _request(
    'GET',
    'https://api.minecraftservices.com/minecraft/profile',
    bearer: mcToken,
  );
  if (status == 404) throw Exception('该账户没有购买 Minecraft: Java Edition');
  if (status >= 400) {
    final reason = '${profile['errorMessage'] ?? profile['error'] ?? ''}'.trim();
    throw Exception('获取档案失败（$status）${reason.isEmpty ? '' : '：$reason'}');
  }
  return Account(
    id: newId(),
    type: AccountType.microsoft,
    name: '${profile['name']}',
    uuid: '${profile['id']}',
    accessToken: mcToken,
    refreshToken: msRefresh,
    expiresAt: DateTime.now().millisecondsSinceEpoch + ((mc['expires_in'] as num?)?.toInt() ?? 86400) * 1000,
  );
}

/// 微软账户的设备代码登录。用户在浏览器中输入代码，这里轮询直到完成。
class MicrosoftLogin {
  MicrosoftLogin(this.clientId);

  final String clientId;
  bool _cancelled = false;

  void cancel() => _cancelled = true;

  Future<Account> run(void Function(DeviceCode) onCode) async {
    if (clientId.trim().isEmpty) throw Exception('请先在「设置 - 其他」中填写 Azure 应用 Client ID');
    final (status, dc) = await _request(
      'POST',
      '$_msAuth/devicecode',
      form: {'client_id': clientId.trim(), 'scope': _scope},
    );
    if (status >= 400 || dc['device_code'] == null) {
      throw Exception('无法开始登录：${dc['error_description'] ?? dc['error'] ?? status}');
    }
    final expiresIn = (dc['expires_in'] as num).toInt();
    onCode(
      DeviceCode(userCode: '${dc['user_code']}', verificationUri: '${dc['verification_uri']}', expiresIn: expiresIn),
    );

    var interval = Duration(seconds: (dc['interval'] as num?)?.toInt() ?? 5);
    final deadline = DateTime.now().add(Duration(seconds: expiresIn));
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(interval);
      if (_cancelled) throw const LoginCancelled();
      final (_, t) = await _request(
        'POST',
        '$_msAuth/token',
        form: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
          'client_id': clientId.trim(),
          'device_code': '${dc['device_code']}',
        },
      );
      switch (t['error']) {
        case 'authorization_pending':
          continue;
        case 'slow_down':
          interval += const Duration(seconds: 5);
          continue;
        case null:
          return _minecraftFromMs('${t['access_token']}', '${t['refresh_token']}');
        default:
          throw Exception('登录失败：${t['error']}');
      }
    }
    throw Exception('登录超时');
  }
}

class LoginCancelled implements Exception {
  const LoginCancelled();

  @override
  String toString() => '已取消登录';
}

/// 启动前刷新即将过期的微软账户
Future<Account> refreshIfNeeded(Account acc, String clientId) async {
  final expiresAt = acc.expiresAt ?? 0;
  if (acc.type != AccountType.microsoft || expiresAt > DateTime.now().millisecondsSinceEpoch + 5 * 60000) return acc;
  // 从 PCL-CE 导入的令牌无法用本启动器的 Client ID 刷新
  if (acc.importedLegacy) {
    final expired = Exception('账户 ${acc.name} 的登录已过期（导入自 PCL-CE，无法续期），请使用微软登录重新添加');
    if (acc.expiresAt != null) throw expired;
    // 没有记录过期时间：向档案接口确认令牌是否仍然有效；网络问题时照常启动
    final int status;
    try {
      (status, _) = await _request(
        'GET',
        'https://api.minecraftservices.com/minecraft/profile',
        bearer: acc.accessToken,
      );
    } catch (_) {
      return acc;
    }
    if (status == 401 || status == 403) throw expired;
    return acc;
  }
  if (clientId.trim().isEmpty || acc.refreshToken == null) throw Exception('微软账户已过期，请重新登录');
  final (_, t) = await _request(
    'POST',
    '$_msAuth/token',
    form: {
      'grant_type': 'refresh_token',
      'client_id': clientId.trim(),
      'refresh_token': acc.refreshToken!,
      'scope': _scope,
    },
  );
  if (t['error'] != null || t['access_token'] == null) throw Exception('微软账户已过期，请重新登录');
  return (await _minecraftFromMs('${t['access_token']}', '${t['refresh_token']}')).copyWithId(acc.id);
}
