import 'package:flutter/services.dart';

/// Talks to the Kotlin side (screen on/off listener, battery settings).
class NativeBridge {
  static const MethodChannel _channel =
      MethodChannel('online.lumioapps.somno/native');

  Future<void> _call(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on Exception {
      // Not running on Android (for example in tests): nothing to do.
    }
  }

  Future<void> startTracking() => _call('startTracking');

  Future<void> stopTracking() => _call('stopTracking');

  Future<void> ensureTracking() => _call('ensureTracking');

  Future<void> openBatterySettings() => _call('openBatterySettings');

  Future<void> requestNotifications() => _call('requestNotifications');

  /// JSON list of {"t": millis, "e": "off" | "unlock" | "boot" | "start" | "restart"}.
  Future<String> drainEvents() async {
    try {
      final result = await _channel.invokeMethod<String>('drainEvents');
      return result ?? '[]';
    } on Exception {
      return '[]';
    }
  }

  /// True when Android will not battery-restrict the app.
  Future<bool> isBatteryUnrestricted() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('isBatteryUnrestricted');
      return result ?? true;
    } on Exception {
      return true;
    }
  }
}
