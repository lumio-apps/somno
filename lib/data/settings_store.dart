import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class SettingsStore {
  static const String _lastOffKey = 'last_off_ms';

  T _at<T>(List<T> values, int? index, T fallback) {
    if (index == null || index < 0 || index >= values.length) {
      return fallback;
    }
    return values[index];
  }

  Future<SomnoSettings> load() async {
    final p = await SharedPreferences.getInstance();
    const d = SomnoSettings();
    return SomnoSettings(
      mode: _at(TrackingMode.values, p.getInt('mode'), d.mode),
      nightStart: p.getInt('night_start') ?? d.nightStart,
      nightEnd: p.getInt('night_end') ?? d.nightEnd,
      dayStart: p.getInt('day_start') ?? d.dayStart,
      dayEnd: p.getInt('day_end') ?? d.dayEnd,
      minGapHours: (p.getInt('min_gap_hours') ?? d.minGapHours).clamp(1, 5).toInt(),
      goalMinutes: (p.getInt('goal_minutes') ?? d.goalMinutes).clamp(240, 720).toInt(),
      birthYear: p.getInt('birth_year'),
      themeMode: _at(ThemeMode.values, p.getInt('theme_mode'), d.themeMode),
      localeCode: p.getString('locale_code') ?? d.localeCode,
      trackingEnabled: p.getBool('tracking_enabled') ?? d.trackingEnabled,
      onboarded: p.getBool('onboarded') ?? d.onboarded,
      autoUpdateCheck: p.getBool('auto_update_check') ?? d.autoUpdateCheck,
      accentIndex: (p.getInt('accent') ?? d.accentIndex).clamp(0, 3).toInt(),
    );
  }

  Future<void> save(SomnoSettings s) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('mode', s.mode.index);
    await p.setInt('night_start', s.nightStart);
    await p.setInt('night_end', s.nightEnd);
    await p.setInt('day_start', s.dayStart);
    await p.setInt('day_end', s.dayEnd);
    await p.setInt('min_gap_hours', s.minGapHours);
    await p.setInt('goal_minutes', s.goalMinutes);
    final year = s.birthYear;
    if (year != null) {
      await p.setInt('birth_year', year);
    }
    await p.setInt('theme_mode', s.themeMode.index);
    await p.setString('locale_code', s.localeCode);
    await p.setBool('tracking_enabled', s.trackingEnabled);
    await p.setBool('onboarded', s.onboarded);
    await p.setBool('auto_update_check', s.autoUpdateCheck);
    await p.setInt('accent', s.accentIndex);
  }

  Future<int?> loadLastUpdateCheck() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('last_update_check_ms');
  }

  Future<void> saveLastUpdateCheck(int value) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('last_update_check_ms', value);
  }

  Future<int?> loadLastOff() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_lastOffKey);
  }

  Future<void> saveLastOff(int? value) async {
    final p = await SharedPreferences.getInstance();
    if (value == null) {
      await p.remove(_lastOffKey);
    } else {
      await p.setInt(_lastOffKey, value);
    }
  }
}
