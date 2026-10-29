// Plain helpers for app screen time. No Flutter, so they are easy to test.
// The numbers come live from Android and are never saved.

/// One app and how long it was on screen.
class AppUse {
  const AppUse({required this.package, required this.label, required this.ms});

  factory AppUse.fromMap(Map<Object?, Object?> m) {
    final ms = m['ms'];
    final pkg = m['package'];
    final label = m['label'];
    return AppUse(
      package: pkg is String ? pkg : '',
      label: label is String && label.isNotEmpty
          ? label
          : (pkg is String ? pkg : ''),
      ms: ms is num ? ms.toInt() : 0,
    );
  }

  final String package;
  final String label;
  final int ms;
}

/// Everything the screen time card shows.
class ScreenTimeReport {
  const ScreenTimeReport({
    required this.today,
    required this.weekMs,
    required this.yesterdaySoFarMs,
  });

  /// Apps used today, most used first.
  final List<AppUse> today;

  /// Total screen time for the last 7 days, oldest first. The last value is
  /// today so far.
  final List<int> weekMs;

  /// Yesterday's screen time up to the same time of day as now.
  final int yesterdaySoFarMs;

  int get todayMs => totalMs(today);

  /// Average over the days that have any screen time.
  int get weekAverageMs => averageMs(weekMs);
}

int totalMs(List<AppUse> apps) {
  var sum = 0;
  for (final a in apps) {
    sum += a.ms;
  }
  return sum;
}

/// The [n] most used apps.
List<AppUse> topApps(List<AppUse> apps, int n) {
  final sorted = List<AppUse>.of(apps)..sort((a, b) => b.ms.compareTo(a.ms));
  return sorted.length <= n ? sorted : sorted.sublist(0, n);
}

/// Average of the days that have any screen time. Days with none are left out,
/// because they usually mean Android no longer has that day's history.
int averageMs(List<int> days) {
  final used = days.where((d) => d > 0).toList();
  if (used.isEmpty) {
    return 0;
  }
  return (used.fold<int>(0, (a, b) => a + b) / used.length).round();
}

/// How much [now] differs from [before], in whole percent (negative means
/// less). Null when [before] is too small to compare.
int? percentChange(int now, int before) {
  const minBefore = 5 * 60000;
  if (before < minBefore) {
    return null;
  }
  return ((now - before) * 100 / before).round();
}

/// Milliseconds as whole minutes, rounded.
int minutesOf(int ms) => (ms / 60000).round();
