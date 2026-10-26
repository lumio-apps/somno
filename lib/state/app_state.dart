import 'package:flutter/widgets.dart';

import '../core/sleep_logic.dart';
import '../data/models.dart';
import '../data/native_bridge.dart';
import '../data/session_db.dart';
import '../data/settings_store.dart';

enum SaveResult { ok, endBeforeStart, tooLong, overlap, future }

class AppState extends ChangeNotifier {
  AppState({SettingsStore? store, SessionDb? db, NativeBridge? native})
      : _store = store ?? SettingsStore(),
        _db = db ?? SessionDb(),
        _native = native ?? NativeBridge();

  final SettingsStore _store;
  final SessionDb _db;
  final NativeBridge _native;

  SomnoSettings settings = const SomnoSettings();
  List<SleepSession> sessions = const <SleepSession>[];
  bool loaded = false;

  /// Null while unknown. False means Android may stop the tracker.
  bool? batteryOk;

  bool _syncing = false;

  Future<void> init() async {
    settings = await _store.load();
    sessions = await _db.all();
    loaded = true;
    notifyListeners();
    if (settings.onboarded) {
      await onResume();
    }
  }

  Future<void> onResume() async {
    if (!loaded || !settings.onboarded) {
      return;
    }
    await syncNative();
    await refreshBattery();
  }

  Future<void> refreshBattery() async {
    final ok = await _native.isBatteryUnrestricted();
    if (ok != batteryOk) {
      batteryOk = ok;
      notifyListeners();
    }
  }

  /// Reads the screen events saved by the Android service and turns them
  /// into sleep sessions.
  Future<void> syncNative() async {
    if (_syncing) {
      return;
    }
    _syncing = true;
    try {
      final events = NativeEvent.parse(await _native.drainEvents());
      if (!settings.trackingEnabled) {
        await _store.saveLastOff(null);
        return;
      }
      if (events.isNotEmpty) {
        final result = detectSessions(
          events: events,
          lastOffMs: await _store.loadLastOff(),
          settings: settings,
        );
        var changed = false;
        for (final s in result.sessions) {
          if (!_overlaps(s.startMs, s.endMs, null)) {
            await _db.insert(s);
            changed = true;
          }
        }
        await _store.saveLastOff(result.lastOffMs);
        if (changed) {
          sessions = await _db.all();
          notifyListeners();
        }
      }
      await _native.ensureTracking();
    } finally {
      _syncing = false;
    }
  }

  bool _overlaps(int startMs, int endMs, int? excludeId) {
    for (final s in sessions) {
      if (s.id == excludeId) {
        continue;
      }
      if (s.startMs < endMs && s.endMs > startMs) {
        return true;
      }
    }
    return false;
  }

  Future<void> updateSettings(
    SomnoSettings Function(SomnoSettings current) change,
  ) async {
    settings = change(settings);
    notifyListeners();
    await _store.save(settings);
  }

  Future<void> setTracking(bool on) async {
    await updateSettings((s) => s.copyWith(trackingEnabled: on));
    await _store.saveLastOff(null);
    if (on) {
      await _native.startTracking();
    } else {
      await _native.stopTracking();
    }
  }

  Future<void> completeOnboarding({
    required int birthYear,
    required int goalMinutes,
    required TrackingMode mode,
  }) async {
    await updateSettings(
      (s) => s.copyWith(
        birthYear: birthYear,
        goalMinutes: goalMinutes,
        mode: mode,
        trackingEnabled: true,
        onboarded: true,
      ),
    );
    await _native.startTracking();
    await refreshBattery();
  }

  Future<void> requestNotifications() => _native.requestNotifications();

  Future<void> openBatterySettings() => _native.openBatterySettings();

  Future<SaveResult> saveSession({
    SleepSession? existing,
    required DateTime start,
    required DateTime end,
  }) async {
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;
    if (endMs <= startMs) {
      return SaveResult.endBeforeStart;
    }
    if (endMs - startMs > const Duration(hours: 24).inMilliseconds) {
      return SaveResult.tooLong;
    }
    if (endMs > DateTime.now().millisecondsSinceEpoch + 60000) {
      return SaveResult.future;
    }
    if (_overlaps(startMs, endMs, existing?.id)) {
      return SaveResult.overlap;
    }
    if (existing == null) {
      await _db.insert(
        SleepSession(startMs: startMs, endMs: endMs, source: kSourceManual),
      );
    } else {
      await _db.update(
        existing.copyWith(
          startMs: startMs,
          endMs: endMs,
          source:
              existing.source == kSourceManual ? kSourceManual : kSourceEdited,
        ),
      );
    }
    sessions = await _db.all();
    notifyListeners();
    return SaveResult.ok;
  }

  Future<void> deleteSession(SleepSession s) async {
    final id = s.id;
    if (id == null) {
      return;
    }
    await _db.delete(id);
    sessions = await _db.all();
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    return scope!.notifier!;
  }
}
