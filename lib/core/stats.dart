import 'dart:math';

import '../data/models.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class DayTotal {
  const DayTotal(this.day, this.minutes);

  final DateTime day;
  final int minutes;
}

/// Total sleep per calendar day. A session belongs to the day you woke up.
Map<DateTime, int> minutesByDay(List<SleepSession> sessions) {
  final out = <DateTime, int>{};
  for (final s in sessions) {
    final key = dateOnly(s.end);
    out[key] = (out[key] ?? 0) + s.minutes;
  }
  return out;
}

List<SleepSession> sessionsOnDay(List<SleepSession> sessions, DateTime day) {
  return sessions.where((s) => dateOnly(s.end) == day).toList();
}

/// The most recent day that has any sleep, or null.
DateTime? latestSleepDay(List<SleepSession> sessions) {
  if (sessions.isEmpty) {
    return null;
  }
  var latest = sessions.first.end;
  for (final s in sessions) {
    if (s.end.isAfter(latest)) {
      latest = s.end;
    }
  }
  return dateOnly(latest);
}

SleepSession? longestSession(List<SleepSession> sessions) {
  SleepSession? best;
  for (final s in sessions) {
    if (best == null || s.minutes > best.minutes) {
      best = s;
    }
  }
  return best;
}

/// The last [n] days ending on [today], oldest first.
List<DayTotal> lastNDays(Map<DateTime, int> byDay, DateTime today, int n) {
  final out = <DayTotal>[];
  for (var i = n - 1; i >= 0; i--) {
    final day = DateTime(today.year, today.month, today.day - i);
    out.add(DayTotal(day, byDay[day] ?? 0));
  }
  return out;
}

/// Average over days that have sleep. Zero when there is none.
int averageMinutes(List<DayTotal> days) {
  var sum = 0;
  var count = 0;
  for (final d in days) {
    if (d.minutes > 0) {
      sum += d.minutes;
      count++;
    }
  }
  if (count == 0) {
    return 0;
  }
  return (sum / count).round();
}

/// Sleeps between these lengths are kept apart as naps.
const int kNapMinMinutes = 20;
const int kNapMaxMinutes = 90;

bool isNap(SleepSession s) {
  final m = s.minutes;
  return m >= kNapMinMinutes && m <= kNapMaxMinutes;
}

/// A day counts toward the streak at this share of the daily goal.
const double kStreakShare = 0.9;

/// Days in a row that reached the goal, counting back from [today]. When
/// today has no full night yet, the count starts from yesterday.
int goalStreak(Map<DateTime, int> byDay, DateTime today, int goal) {
  if (goal <= 0) {
    return 0;
  }
  final need = goal * kStreakShare;
  var day = DateTime(today.year, today.month, today.day);
  if ((byDay[day] ?? 0) < need) {
    day = DateTime(day.year, day.month, day.day - 1);
  }
  var count = 0;
  while ((byDay[day] ?? 0) >= need) {
    count++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return count;
}

class SleepDebt {
  const SleepDebt(this.minutes, this.days);

  /// Positive: slept less than the goal. Negative: slept more.
  final int minutes;

  /// Days with sleep that were counted.
  final int days;
}

/// Goal minus real sleep over the last [days] days that have sleep.
/// Null when fewer than two days have data.
SleepDebt? sleepDebt(
  Map<DateTime, int> byDay,
  DateTime today,
  int goal, {
  int days = 7,
}) {
  var sum = 0;
  var counted = 0;
  for (var i = 0; i < days; i++) {
    final day = DateTime(today.year, today.month, today.day - i);
    final m = byDay[day] ?? 0;
    if (m > 0) {
      sum += goal - m;
      counted++;
    }
  }
  if (counted < 2) {
    return null;
  }
  return SleepDebt(sum, counted);
}

double _spread(List<double> values) {
  final mean = values.reduce((a, b) => a + b) / values.length;
  var squares = 0.0;
  for (final v in values) {
    squares += (v - mean) * (v - mean);
  }
  return sqrt(squares / values.length);
}

/// 0 to 100: how steady the bed and wake times were over the last [days]
/// days. Uses the longest sleep of each day. Null with fewer than 3 days.
int? consistencyScore(
  List<SleepSession> sessions,
  DateTime today, {
  int days = 7,
}) {
  final from = DateTime(today.year, today.month, today.day - (days - 1));
  final best = <DateTime, SleepSession>{};
  for (final s in sessions) {
    final d = dateOnly(s.end);
    if (d.isBefore(from) || d.isAfter(today)) {
      continue;
    }
    final current = best[d];
    if (current == null || s.minutes > current.minutes) {
      best[d] = s;
    }
  }
  if (best.length < 3) {
    return null;
  }
  final beds = <double>[];
  final wakes = <double>[];
  for (final s in best.values) {
    var bed = s.start.hour * 60 + s.start.minute;
    if (bed < 720) {
      bed += 1440;
    }
    beds.add(bed.toDouble());
    wakes.add((s.end.hour * 60 + s.end.minute).toDouble());
  }
  final spread = (_spread(beds) + _spread(wakes)) / 2;
  return (100 - spread / 90 * 100).clamp(0, 100).round();
}
