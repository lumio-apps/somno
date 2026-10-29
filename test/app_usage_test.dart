import 'package:flutter_test/flutter_test.dart';
import 'package:somno/core/app_usage.dart';

AppUse app(String name, int minutes) =>
    AppUse(package: 'p.$name', label: name, ms: minutes * 60000);

void main() {
  group('app usage', () {
    test('AppUse reads a native map and falls back to the package name', () {
      final a = AppUse.fromMap({'package': 'a.b', 'label': 'Chat', 'ms': 90000});
      expect(a.label, 'Chat');
      expect(a.ms, 90000);
      final b = AppUse.fromMap({'package': 'a.b', 'label': '', 'ms': 5});
      expect(b.label, 'a.b');
      final c = AppUse.fromMap({});
      expect(c.package, '');
      expect(c.ms, 0);
    });

    test('totalMs adds every app', () {
      expect(totalMs([app('a', 10), app('b', 5)]), 15 * 60000);
      expect(totalMs([]), 0);
    });

    test('topApps keeps the most used, in order', () {
      final top = topApps([app('a', 5), app('b', 30), app('c', 10)], 2);
      expect(top.map((e) => e.label), ['b', 'c']);
      expect(topApps([app('a', 5)], 5).length, 1);
    });

    test('averageMs ignores days with no data', () {
      expect(averageMs([0, 60000, 180000, 0]), 120000);
      expect(averageMs([0, 0]), 0);
    });

    test('percentChange compares with a minimum base', () {
      expect(percentChange(82 * 60000, 100 * 60000), -18);
      expect(percentChange(150 * 60000, 100 * 60000), 50);
      expect(percentChange(100 * 60000, 100 * 60000), 0);
      expect(percentChange(60000, 2 * 60000), isNull);
    });

    test('minutesOf rounds to whole minutes', () {
      expect(minutesOf(89999), 1);
      expect(minutesOf(90000), 2);
      expect(minutesOf(0), 0);
    });

    test('ScreenTimeReport derives its totals', () {
      final r = ScreenTimeReport(
        today: [app('a', 60), app('b', 30)],
        weekMs: const [0, 3600000, 7200000],
        yesterdaySoFarMs: 0,
      );
      expect(r.todayMs, 90 * 60000);
      expect(r.weekAverageMs, 5400000);
    });
  });
}
