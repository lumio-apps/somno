import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

import '../core/sleep_logic.dart';
import '../core/stats.dart';
import '../core/version.dart';
import '../data/models.dart';
import '../data/native_bridge.dart';
import '../data/session_db.dart';
import '../data/settings_store.dart';
import '../data/update_service.dart';

enum SaveResult { ok, endBeforeStart, tooLong, overlap, future }

enum UpdateResult { available, upToDate, failed }

/// started: the Android installer opened. permission: the user must allow
/// installs from Somno first. browser: the release has no APK file.
enum InstallResult { started, permission, browser, failed }

class AppState extends ChangeNotifier {
  AppState({
    SettingsStore? store,
    SessionDb? db,
    NativeBridge? native,
    UpdateService? updates,
  })  : _store = store ?? SettingsStore(),
        _db = db ?? SessionDb(),
        _native = native ?? NativeBridge(),
        _updates = updates ?? UpdateService();

  final SettingsStore _store;
  final SessionDb _db;
  final NativeBridge _native;
  final UpdateService _updates;

  SomnoSettings settings = const SomnoSettings();
  List<SleepSession> sessions = const <SleepSession>[];
  bool loaded = false;

  /// Sleeps that are not naps. Streak, debt and averages use these.
  List<SleepSession> get nightSessions =>
      sessions.where((s) => !isNap(s)).toList();

  List<SleepSession> get napSessions => sessions.where(isNap).toList();

  /// Null while unknown. False means Android may stop the tracker.
  bool? batteryOk;

  bool _syncing = false;

  /// True when Usage access is allowed. Null while unknown.
  bool? usageAccess;

  /// Installed version name, for example "1.0.0".
  String appVersion = '';

  /// A newer release found on GitHub, or null.
  UpdateInfo? availableUpdate;
  bool checkingUpdate = false;
  bool _updateHidden = false;

  /// The update to offer on the Today screen.
  UpdateInfo? get updateToOffer => _updateHidden ? null : availableUpdate;

  Future<void> init() async {
    settings = await _store.load();
    sessions = await _db.all();
    appVersion = await _native.appVersion();
    if (settings.reminderEnabled) {
      await _syncReminder();
    }
    loaded = true;
    notifyListeners();
    if (settings.onboarded) {
      await onResume();
      unawaited(autoCheckUpdates());
    }
  }

  /// Checks at most once a day, and only when the user allows it.
  Future<void> autoCheckUpdates() async {
    if (!settings.autoUpdateCheck) {
      return;
    }
    final last = await _store.loadLastUpdateCheck();
    final now = DateTime.now().millisecondsSinceEpoch;
    if (last != null && now - last < const Duration(hours: 24).inMilliseconds) {
      return;
    }
    await checkForUpdates();
  }

  Future<UpdateResult> checkForUpdates() async {
    if (checkingUpdate || appVersion.isEmpty) {
      return UpdateResult.failed;
    }
    checkingUpdate = true;
    notifyListeners();
    try {
      final info = await _updates.latest();
      await _store
          .saveLastUpdateCheck(DateTime.now().millisecondsSinceEpoch);
      if (isNewerVersion(info.tag, appVersion)) {
        availableUpdate = info;
        _updateHidden = false;
        return UpdateResult.available;
      }
      availableUpdate = null;
      return UpdateResult.upToDate;
    } on Exception {
      return UpdateResult.failed;
    } finally {
      checkingUpdate = false;
      notifyListeners();
    }
  }

  void hideUpdateBanner() {
    _updateHidden = true;
    notifyListeners();
  }

  Future<bool> openUrl(String url) => _native.openUrl(url);

  String? _apkPath;
  String? _apkTag;

  /// Downloads the new APK inside the app (once) and opens the installer.
  Future<InstallResult> installUpdate(
    UpdateInfo info,
    void Function(double progress) onProgress,
  ) async {
    final url = info.apkUrl;
    if (url == null) {
      await _native.openUrl(info.pageUrl);
      return InstallResult.browser;
    }
    try {
      var path = _apkPath;
      if (path == null || _apkTag != info.tag || !File(path).existsSync()) {
        final dir = await _native.updatesDir();
        if (dir.isEmpty) {
          return InstallResult.failed;
        }
        final folder = Directory(dir);
        if (folder.existsSync()) {
          for (final old in folder.listSync()) {
            if (old is File) {
              old.deleteSync();
            }
          }
        }
        path = await _updates.download(
          url,
          '$dir/Somno-${info.tag}.apk',
          onProgress,
        );
        _apkPath = path;
        _apkTag = info.tag;
      }
      final result = await _native.installApk(path);
      if (result == 'ok') {
        return InstallResult.started;
      }
      if (result == 'permission') {
        return InstallResult.permission;
      }
      return InstallResult.failed;
    } on Exception {
      return InstallResult.failed;
    }
  }

  /// False when Digital Wellbeing was not found and Settings opened instead.
  Future<bool> openWellbeing() => _native.openWellbeing();

  Future<void> onResume() async {
    if (!loaded || !settings.onboarded) {
      return;
    }
    await syncNative();
    await refreshBattery();
  }

  /// Re-reads Usage access and battery settings, for example after the user
  /// comes back from the system settings.
  Future<void> refreshAccess() async {
    final usage = await _native.hasUsageAccess();
    if (usage != usageAccess) {
      usageAccess = usage;
      notifyListeners();
    }
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
      var events = NativeEvent.parse(await _native.drainEvents());
      final now = DateTime.now().millisecondsSinceEpoch;
      final hasUsage = await _native.hasUsageAccess();
      if (hasUsage != usageAccess) {
        usageAccess = hasUsage;
        notifyListeners();
      }
      if (!settings.trackingEnabled) {
        await _store.saveLastOff(null);
        await _store.saveLastUsageQuery(now);
        return;
      }
      if (hasUsage) {
        // Android's own screen history does not depend on the tracker
        // surviving the night, so it is preferred when it has events.
        const day = 24 * 3600000;
        final saved = await _store.loadLastUsageQuery();
        var from = saved == null ? now - day : saved - 5000;
        if (from < now - 7 * day) {
          from = now - 7 * day;
        }
        final history =
            NativeEvent.parse(await _native.screenHistory(from, now));
        await _store.saveLastUsageQuery(now);
        if (history.isNotEmpty) {
          events = history;
        }
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
    final before = settings;
    settings = change(settings);
    notifyListeners();
    await _store.save(settings);
    if (before.reminderEnabled != settings.reminderEnabled ||
        before.reminderMinute != settings.reminderMinute ||
        before.localeCode != settings.localeCode) {
      await _syncReminder();
    }
  }

  Future<void> _syncReminder() {
    return _native.setReminder(
      enabled: settings.reminderEnabled,
      minute: settings.reminderMinute,
      localeCode: settings.localeCode,
    );
  }

  Future<void> setTracking(bool on) async {
    await updateSettings((s) => s.copyWith(trackingEnabled: on));
    await _store.saveLastOff(null);
    await _store.saveLastUsageQuery(DateTime.now().millisecondsSinceEpoch);
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

  Future<void> openUsageAccess() => _native.openUsageAccess();

  Future<bool> openAutostart() => _native.openAutostart();

  Future<Map<String, Object?>> trackingStatus() => _native.trackingStatus();

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
