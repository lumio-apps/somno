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
