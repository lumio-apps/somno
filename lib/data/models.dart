import 'package:flutter/material.dart';

enum TrackingMode { night, day, any }

const int kSourceAuto = 0;
const int kSourceEdited = 1;
const int kSourceManual = 2;

class SleepSession {
  const SleepSession({
    this.id,
    required this.startMs,
    required this.endMs,
    this.source = kSourceAuto,
  });

  final int? id;
  final int startMs;
  final int endMs;
  final int source;

  DateTime get start => DateTime.fromMillisecondsSinceEpoch(startMs);
  DateTime get end => DateTime.fromMillisecondsSinceEpoch(endMs);
  int get minutes => ((endMs - startMs) / 60000).round();

  SleepSession copyWith({int? id, int? startMs, int? endMs, int? source}) {
    return SleepSession(
      id: id ?? this.id,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      source: source ?? this.source,
    );
  }
}

class SomnoSettings {
  const SomnoSettings({
    this.mode = TrackingMode.night,
    this.nightStart = 21 * 60,
    this.nightEnd = 10 * 60,
    this.dayStart = 13 * 60,
    this.dayEnd = 17 * 60,
    this.minGapHours = 3,
    this.goalMinutes = 480,
    this.birthYear,
    this.themeMode = ThemeMode.system,
    this.localeCode = '',
    this.trackingEnabled = false,
    this.onboarded = false,
    this.autoUpdateCheck = true,
    this.accentIndex = 0,
  });

  final TrackingMode mode;

  /// Minutes after midnight.
  final int nightStart;
  final int nightEnd;
  final int dayStart;
  final int dayEnd;

  final int minGapHours;
  final int goalMinutes;
  final int? birthYear;
  final ThemeMode themeMode;

  /// Empty string means "follow the system language".
  final String localeCode;
  final bool trackingEnabled;
  final bool onboarded;
  final bool autoUpdateCheck;

  /// Index into the accent colours in palette.dart.
  final int accentIndex;

  SomnoSettings copyWith({
    TrackingMode? mode,
    int? nightStart,
    int? nightEnd,
    int? dayStart,
    int? dayEnd,
    int? minGapHours,
    int? goalMinutes,
    int? birthYear,
    ThemeMode? themeMode,
    String? localeCode,
    bool? trackingEnabled,
    bool? onboarded,
    bool? autoUpdateCheck,
    int? accentIndex,
  }) {
    return SomnoSettings(
      mode: mode ?? this.mode,
      nightStart: nightStart ?? this.nightStart,
      nightEnd: nightEnd ?? this.nightEnd,
      dayStart: dayStart ?? this.dayStart,
      dayEnd: dayEnd ?? this.dayEnd,
      minGapHours: minGapHours ?? this.minGapHours,
      goalMinutes: goalMinutes ?? this.goalMinutes,
      birthYear: birthYear ?? this.birthYear,
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      trackingEnabled: trackingEnabled ?? this.trackingEnabled,
      onboarded: onboarded ?? this.onboarded,
      autoUpdateCheck: autoUpdateCheck ?? this.autoUpdateCheck,
      accentIndex: accentIndex ?? this.accentIndex,
    );
  }
}
