import 'dart:async';

import 'auth.dart';
import 'http_json.dart';
import '../i18n/strings.dart';

class OAuthToken {
  OAuthToken(Map<String, dynamic> j)
    : accessToken = '${j['access_token']}',
      refreshToken = j['refresh_token'] as String?,
      idToken = j['id_token'] as String?,
      expiresAt = DateTime.now().millisecondsSinceEpoch + ((j['expires_in'] as num?)?.toInt() ?? 3600) * 1000;

  final String accessToken;
  final String? refreshToken;
  final String? idToken;

  /// 毫秒时间戳
  final int expiresAt;
}

/// 进行中的设备代码登录：取得代码后保存下来，启动器被系统杀掉后重新打开时可以接着等用户完成授权
class PendingDeviceCode {
  PendingDeviceCode({required this.deviceCode, required this.code, required this.interval, required this.expiresAt});

  final String deviceCode;
  final DeviceCode code;

  /// 轮询间隔（秒）
  final int interval;

  /// 代码过期时间（毫秒时间戳）
  final int expiresAt;

  bool get expired => DateTime.now().millisecondsSinceEpoch >= expiresAt;

  Map<String, dynamic> toJson() => {
    'deviceCode': deviceCode,
    'userCode': code.userCode,
    'verificationUri': code.verificationUri,
    'completeUri': ?code.completeUri,
    'interval': interval,
    'expiresAt': expiresAt,
  };

  static PendingDeviceCode? fromJson(Map<String, dynamic> j) {
    final device = j['deviceCode'], user = j['userCode'], uri = j['verificationUri'], at = j['expiresAt'];
    if (device is! String || user is! String || uri is! String || at is! num) return null;
    return PendingDeviceCode(
      deviceCode: device,
      code: DeviceCode(userCode: user, verificationUri: uri, completeUri: j['completeUri'] as String?, resumed: true),
      interval: (j['interval'] as num?)?.toInt() ?? 5,
      expiresAt: at.toInt(),
    );
  }
}

/// OAuth 2.0 公共客户端：设备代码流（RFC 8628）与刷新令牌。微软登录与 Yggdrasil Connect 共用
class OAuthClient {
  const OAuthClient({required this.clientId, required this.tokenEndpoint, this.deviceEndpoint});

  final String clientId;
  final String tokenEndpoint;
  final String? deviceEndpoint;

  static String _describe(Map<String, dynamic> j, int status) => '${j['error_description'] ?? j['error'] ?? status}';

  static final _wake = StreamController<void>.broadcast();

  /// 立即查一次授权结果，不等下一个轮询间隔。用户从浏览器切回启动器时调用
  static void wakeUp() => _wake.add(null);

  /// 设备代码登录：取得代码后交给 [onCode] 展示（[onPending] 可以把它保存下来），
  /// 然后轮询直到用户在浏览器中完成授权。传入 [resume] 时不再申请新代码，接着等之前保存的那个。
  ///
  /// 安卓上用户去浏览器授权时，启动器在后台，网络可能被系统暂停：轮询遇到网络错误不算失败，
  /// 一直等到代码过期为止
  Future<OAuthToken> deviceLogin(
    String scope,
    void Function(DeviceCode) onCode, {
    required bool Function() cancelled,
    void Function(PendingDeviceCode)? onPending,
    PendingDeviceCode? resume,
  }) async {
    final PendingDeviceCode pending;
    if (resume != null) {
      pending = resume;
    } else {
      final r = await requestJson('POST', deviceEndpoint!, form: {'client_id': clientId, 'scope': scope});
      final dc = r.map;
      if (!r.ok || dc['device_code'] == null) throw Exception(tr.oauthCantStartSign(_describe(dc, r.status)));
      pending = PendingDeviceCode(
        deviceCode: '${dc['device_code']}',
        code: DeviceCode(
          userCode: '${dc['user_code']}',
          verificationUri: '${dc['verification_uri']}',
          completeUri: dc['verification_uri_complete'] as String?,
        ),
        interval: (dc['interval'] as num?)?.toInt() ?? 5,
        expiresAt: DateTime.now().millisecondsSinceEpoch + (dc['expires_in'] as num).toInt() * 1000,
      );
      onPending?.call(pending);
    }
    onCode(pending.code);

    var interval = Duration(seconds: pending.interval);
    // 接着等之前的代码时先马上查一次：用户多半已经在浏览器里授权完了
    var first = resume != null;
    while (!pending.expired) {
      if (!first) await Future.any([Future<void>.delayed(interval), _wake.stream.first]);
      first = false;
      if (cancelled()) throw const LoginCancelled();
      final JsonResponse t;
      try {
        t = await requestJson(
          'POST',
          tokenEndpoint,
          form: {
            'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
            'client_id': clientId,
            'device_code': pending.deviceCode,
          },
        );
      } on Exception {
        // 网络暂时不通（在后台被限制、切换网络等），下一轮再试
        continue;
      }
      if (t.status >= 500) continue;
      switch (t.map['error']) {
        case 'authorization_pending':
          continue;
        case 'slow_down':
          interval += const Duration(seconds: 5);
          continue;
        case 'access_denied':
          throw Exception(tr.oauthAuthorizationDenied);
        case 'expired_token':
          throw Exception(tr.oauthSignTimedOutPlease);
        case null when t.ok && t.map['access_token'] != null:
          return OAuthToken(t.map);
        default:
          throw Exception(tr.oauthSignFailed(_describe(t.map, t.status)));
      }
    }
    throw Exception(tr.oauthSignTimedOutPlease);
  }

  /// 用刷新令牌换新的令牌；刷新令牌已失效时返回 null（网络错误照常抛出）
  Future<OAuthToken?> refresh(String refreshToken, {String? scope}) async {
    final t = await requestJson(
      'POST',
      tokenEndpoint,
      form: {'grant_type': 'refresh_token', 'client_id': clientId, 'refresh_token': refreshToken, 'scope': ?scope},
    );
    if (t.status >= 500) throw Exception(tr.oauthAuthenticationServerTemporarilyUnavailable(t.status));
    return t.ok && t.map['access_token'] != null ? OAuthToken(t.map) : null;
  }
}
