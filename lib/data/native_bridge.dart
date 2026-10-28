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

  /// Starts the tracker only when it is needed, and stops it when it is not.
  Future<void> ensureTracking() => _call('ensureTracking');

  /// Tells the tracker the sleep window. [mode] is the TrackingMode index.
  Future<void> setWindow({
    required int mode,
    required int start,
    required int end,
  }) async {
    try {
      await _channel.invokeMethod<void>('setWindow', <String, int>{
        'mode': mode,
        'start': start,
        'end': end,
      });
    } on Exception {
      // Not running on Android (for example in tests): nothing to do.
    }
  }

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

  /// Turns the daily bedtime reminder on or off. [localeCode] is the app
  /// language, or empty to follow the phone.
  Future<void> setReminder({
    required bool enabled,
    required int minute,
    required String localeCode,
  }) async {
    try {
      await _channel.invokeMethod<void>('setReminder', <String, Object>{
        'enabled': enabled,
        'minute': minute,
        'locale': localeCode,
      });
    } on Exception {
      // Not running on Android (for example in tests): nothing to do.
    }
  }

  /// Folder in the app cache where downloaded updates are kept.
  Future<String> updatesDir() async {
    try {
      final result = await _channel.invokeMethod<String>('updatesDir');
      return result ?? '';
    } on Exception {
      return '';
    }
  }

  /// Opens the Android installer for [path]. Returns "ok", "permission"
  /// (the user must first allow installs from Somno) or "error".
  Future<String> installApk(String path) async {
    try {
      final result = await _channel
          .invokeMethod<String>('installApk', <String, String>{'path': path});
      return result ?? 'error';
    } on Exception {
      return 'error';
    }
  }

  /// True when the user allowed Usage access, so Android's own screen
  /// history can be read.
  Future<bool> hasUsageAccess() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasUsageAccess');
      return result ?? false;
    } on Exception {
      return false;
    }
  }

  Future<void> openUsageAccess() => _call('openUsageAccess');

  Future<bool> openAutostart() async {
    try {
      final result = await _channel.invokeMethod<bool>('openAutostart');
      return result ?? false;
    } on Exception {
      return false;
    }
  }

  /// Screen events from Android's own history between two times, in the same
  /// JSON form as [drainEvents].
  Future<String> screenHistory(int fromMs, int toMs) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'screenHistory',
        <String, int>{'from': fromMs, 'to': toMs},
      );
      return result ?? '[]';
    } on Exception {
      return '[]';
    }
  }

  /// Facts about the tracker for the status screen.
  Future<Map<String, Object?>> trackingStatus() async {
    try {
      final result =
          await _channel.invokeMapMethod<String, Object?>('trackingStatus');
      return result ?? <String, Object?>{};
    } on Exception {
      return <String, Object?>{};
    }
  }

  /// The installed version name, for example "1.0.1". Empty when unknown.
  Future<String> appVersion() async {
    try {
      final result = await _channel.invokeMethod<String>('appVersion');
      return result ?? '';
    } on Exception {
      return '';
    }
  }

  /// Opens an https link in the browser. False when nothing could open it.
  Future<bool> openUrl(String url) async {
    try {
      final result = await _channel
          .invokeMethod<bool>('openUrl', <String, String>{'url': url});
      return result ?? false;
    } on Exception {
      return false;
    }
  }

  /// Opens Digital Wellbeing. False when it is missing on this phone and the
  /// normal Settings opened instead.
  Future<bool> openWellbeing() async {
    try {
      final result = await _channel.invokeMethod<bool>('openWellbeing');
      return result ?? false;
    } on Exception {
      return false;
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
