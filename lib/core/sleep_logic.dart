import 'dart:convert';

import '../data/models.dart';

/// One raw event written by the Kotlin service.
///
/// Types: `off` (screen off), `unlock` (user unlocked), `boot` (phone restarted),
/// `start` (tracking service started fresh), `restart` (Android restarted the
/// service by itself).
class NativeEvent {
  const NativeEvent(this.timeMs, this.type);

  final int timeMs;
  final String type;

  static List<NativeEvent> parse(String json) {
    try {
      final data = jsonDecode(json);
      if (data is! List) {
        return const <NativeEvent>[];
      }
      final out = <NativeEvent>[];
      for (final item in data) {
        if (item is Map && item['t'] is num && item['e'] is String) {
          out.add(NativeEvent((item['t'] as num).toInt(), item['e'] as String));
        }
      }
      out.sort((a, b) => a.timeMs.compareTo(b.timeMs));
      return out;
    } on FormatException {
      return const <NativeEvent>[];
    }
  }
}

class DetectionResult {
  const DetectionResult(this.sessions, this.lastOffMs);

  final List<SleepSession> sessions;

  /// Screen-off time that is still waiting for an unlock, if any.
  final int? lastOffMs;
}

/// A gap longer than this is not treated as sleep (phone simply forgotten).
const int kMaxAutoSessionMinutes = 16 * 60;

/// Whether [minute] (minutes after midnight) lies inside the window.
/// A window that ends before it starts wraps past midnight.
/// Equal start and end means the whole day.
bool minuteInWindow(int minute, int start, int end) {
  if (start == end) {
    return true;
  }
  if (start < end) {
    return minute >= start && minute < end;
  }
  return minute >= start || minute < end;
}

/// Whether a sleep that starts at [start] is allowed by the tracking mode.
bool startCounts(DateTime start, SomnoSettings s) {
  final minute = start.hour * 60 + start.minute;
  switch (s.mode) {
    case TrackingMode.any:
      return true;
    case TrackingMode.night:
      return minuteInWindow(minute, s.nightStart, s.nightEnd);
    case TrackingMode.day:
      return minuteInWindow(minute, s.dayStart, s.dayEnd);
  }
}

/// Turns raw events into sleep sessions.
///
/// A session is the time from the first screen-off to the next unlock, when
/// that gap is at least the minimum gap and starts inside the tracking window.
DetectionResult detectSessions({
  required List<NativeEvent> events,
  required int? lastOffMs,
  required SomnoSettings settings,
}) {
  final minGapMs = settings.minGapHours * 3600000;
  final maxGapMs = kMaxAutoSessionMinutes * 60000;
  final out = <SleepSession>[];
  int? lastOff = lastOffMs;

  for (final e in events) {
    switch (e.type) {
      case 'off':
        lastOff ??= e.timeMs;
      case 'unlock':
        final off = lastOff;
        if (off != null) {
          final gap = e.timeMs - off;
          final startsOk =
              startCounts(DateTime.fromMillisecondsSinceEpoch(off), settings);
          if (gap >= minGapMs && gap <= maxGapMs && startsOk) {
            out.add(SleepSession(startMs: off, endMs: e.timeMs));
          }
        }
        lastOff = null;
      case 'boot' || 'start':
        // The phone was off or tracking was not running, so the gap is unknown.
        lastOff = null;
      default:
        break;
    }
  }
  return DetectionResult(out, lastOff);
}

/// Recommended sleep for an age (National Sleep Foundation, 2015).
class AgeRange {
  const AgeRange(this.minAge, this.maxAge, this.minHours, this.maxHours);

  final int minAge;
  final int maxAge;
  final int minHours;
  final int maxHours;
}

const List<AgeRange> kAgeRanges = <AgeRange>[
  AgeRange(0, 0, 12, 17),
  AgeRange(1, 2, 11, 14),
  AgeRange(3, 5, 10, 13),
  AgeRange(6, 13, 9, 11),
  AgeRange(14, 17, 8, 10),
  AgeRange(18, 64, 7, 9),
  AgeRange(65, 200, 7, 8),
];

AgeRange rangeForAge(int age) {
  for (final r in kAgeRanges) {
    if (age >= r.minAge && age <= r.maxAge) {
      return r;
    }
  }
  return kAgeRanges.last;
}

/// Middle of the recommended range, rounded to 30 minutes.
int goalMinutesForAge(int age) {
  final r = rangeForAge(age);
  final mid = (r.minHours + r.maxHours) * 30;
  return (mid / 30).round() * 30;
}
