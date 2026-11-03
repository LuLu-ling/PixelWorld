import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 手机上的电量与网络状态。启动器全屏时系统状态栏被隐藏，显示在标题栏里
class DeviceStatus extends StatefulWidget {
  const DeviceStatus({super.key});

  @override
  State<DeviceStatus> createState() => _DeviceStatusState();
}

class _DeviceStatusState extends State<DeviceStatus> with WidgetsBindingObserver {
  static const _channel = MethodChannel('pclpw/device');

  int? _battery;
  bool _charging = false;
  String _network = 'none';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 从游戏或其他应用返回时立即刷新
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    try {
      final r = await _channel.invokeMapMethod<String, dynamic>('status');
      if (r == null || !mounted) return;
      setState(() {
        _battery = (r['battery'] as num?)?.toInt();
        _charging = r['charging'] == true;
        _network = r['network'] as String? ?? 'none';
      });
    } catch (_) {
      // 读取失败时保持上次的状态
    }
  }

  IconData get _batteryIcon {
    if (_charging) return Icons.battery_charging_full;
    final b = _battery ?? 100;
    if (b <= 15) return Icons.battery_alert;
    if (b <= 30) return Icons.battery_2_bar;
    if (b <= 50) return Icons.battery_3_bar;
    if (b <= 70) return Icons.battery_5_bar;
    if (b <= 90) return Icons.battery_6_bar;
    return Icons.battery_full;
  }

  (IconData, String) get _networkInfo => switch (_network) {
    'wifi' => (Icons.wifi, 'Wi-Fi'),
    'cellular' => (Icons.signal_cellular_alt, '移动数据'),
    'ethernet' => (Icons.settings_ethernet, '有线网络'),
    'other' => (Icons.public, '已联网'),
    _ => (Icons.wifi_off, '未联网'),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (netIcon, netLabel) = _networkInfo;
    final low = !_charging && (_battery ?? 100) <= 15;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: netLabel,
          child: Icon(netIcon, size: 18, color: _network == 'none' ? scheme.error : scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: _charging ? '正在充电' : '电量',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotatedBox(
                quarterTurns: 1,
                child: Icon(_batteryIcon, size: 18, color: low ? scheme.error : scheme.onSurfaceVariant),
              ),
              const SizedBox(width: 2),
              Text(
                _battery == null ? '--' : '$_battery%',
                style: theme.textTheme.labelMedium?.copyWith(color: low ? scheme.error : scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
