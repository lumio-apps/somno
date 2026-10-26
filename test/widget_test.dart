import 'package:flutter_test/flutter_test.dart';
import 'package:somno/core/sleep_logic.dart';
import 'package:somno/core/stats.dart';
import 'package:somno/core/version.dart';
import 'package:somno/data/update_service.dart';
import 'package:somno/data/models.dart';

int at(int day, int hour, [int minute = 0]) =>
    DateTime(2026, 10, day, hour, minute).millisecondsSinceEpoch;

List<SleepSession> run(
  List<NativeEvent> events, {
  SomnoSettings settings = const SomnoSettings(),
  int? lastOff,
}) {
  return detectSessions(
    events: events,
    lastOffMs: lastOff,
    settings: settings,
  ).sessions;
}

void main() {
  versionTests();
  insightTests();

  group('sleep detection', () {
    test('a night gap becomes one session', () {
      final sessions = run([
        NativeEvent(at(22, 23, 40), 'off'),
        NativeEvent(at(23, 7), 'unlock'),
      ]);
      expect(sessions.length, 1);
      expect(sessions.first.minutes, 440);
    });

    test('a gap shorter than the minimum is ignored', () {
      final sessions = run([
        NativeEvent(at(22, 23), 'off'),
        NativeEvent(at(23, 1), 'unlock'),
      ]);
      expect(sessions, isEmpty);
    });

    test('night mode ignores a gap that starts in the afternoon', () {
      final sessions = run([
        NativeEvent(at(22, 14), 'off'),
        NativeEvent(at(22, 18), 'unlock'),
      ]);
      expect(sessions, isEmpty);
    });

    test('day mode counts an afternoon gap inside the day window', () {
      final sessions = run(
        [
          NativeEvent(at(22, 14), 'off'),
          NativeEvent(at(22, 18), 'unlock'),
        ],
        settings: const SomnoSettings(mode: TrackingMode.day),
      );
      expect(sessions.length, 1);
    });

    test('any time mode counts every long gap', () {
      final sessions = run(
        [
          NativeEvent(at(22, 14), 'off'),
          NativeEvent(at(22, 18), 'unlock'),
        ],
        settings: const SomnoSettings(mode: TrackingMode.any),
      );
      expect(sessions.length, 1);
    });

    test('a reboot clears the pending screen-off', () {
      final sessions = run([
        NativeEvent(at(22, 23), 'off'),
        NativeEvent(at(23, 1), 'boot'),
        NativeEvent(at(23, 7), 'unlock'),
      ]);
      expect(sessions, isEmpty);
    });

    test('a glance at the lock screen does not split the night', () {
      final sessions = run([
        NativeEvent(at(22, 23), 'off'),
        NativeEvent(at(23, 2), 'off'),
        NativeEvent(at(23, 7), 'unlock'),
      ]);
      expect(sessions.length, 1);
      expect(sessions.first.startMs, at(22, 23));
    });

    test('a service restart keeps the pending screen-off', () {
      final sessions = run([
        NativeEvent(at(22, 23), 'off'),
        NativeEvent(at(23, 3), 'restart'),
        NativeEvent(at(23, 7), 'unlock'),
      ]);
      expect(sessions.length, 1);
    });

    test('a screen-off from an earlier sync is used', () {
      final sessions = run(
        [NativeEvent(at(23, 7), 'unlock')],
        lastOff: at(22, 23),
      );
      expect(sessions.length, 1);
    });

    test('a gap over 16 hours is not sleep', () {
      final sessions = run(
        [
          NativeEvent(at(22, 8), 'off'),
          NativeEvent(at(23, 8), 'unlock'),
        ],
        settings: const SomnoSettings(mode: TrackingMode.any),
      );
      expect(sessions, isEmpty);
    });

    test('invalid json gives no events', () {
      expect(NativeEvent.parse('not json'), isEmpty);
      expect(NativeEvent.parse('{}'), isEmpty);
    });
  });

  group('time windows', () {
    test('a window can wrap past midnight', () {
      expect(minuteInWindow(23 * 60, 21 * 60, 10 * 60), isTrue);
      expect(minuteInWindow(2 * 60, 21 * 60, 10 * 60), isTrue);
      expect(minuteInWindow(12 * 60, 21 * 60, 10 * 60), isFalse);
    });

    test('equal start and end means all day', () {
      expect(minuteInWindow(5 * 60, 8 * 60, 8 * 60), isTrue);
    });
  });

  group('age goals', () {
    test('goal is the middle of the recommended range', () {
      expect(goalMinutesForAge(30), 480);
      expect(goalMinutesForAge(16), 540);
      expect(goalMinutesForAge(70), 450);
    });

    test('range lookup', () {
      expect(rangeForAge(25).minHours, 7);
      expect(rangeForAge(25).maxHours, 9);
      expect(rangeForAge(70).maxHours, 8);
    });
  });

  group('stats', () {
    test('a session counts for the day you woke up', () {
      final s = SleepSession(startMs: at(22, 23), endMs: at(23, 7));
      final byDay = minutesByDay([s]);
      expect(byDay[DateTime(2026, 10, 23)], 480);
      expect(byDay[DateTime(2026, 10, 22)], isNull);
    });

    test('last days are listed oldest first and average skips empty days', () {
      final s = SleepSession(startMs: at(22, 23), endMs: at(23, 7));
      final days = lastNDays(minutesByDay([s]), DateTime(2026, 10, 23), 7);
      expect(days.length, 7);
      expect(days.last.minutes, 480);
      expect(days.first.day, DateTime(2026, 10, 17));
      expect(averageMinutes(days), 480);
    });
  });
}

void versionTests() {
  group('versions', () {
    test('newer and older', () {
      expect(isNewerVersion('v1.0.1', '1.0.0'), isTrue);
      expect(isNewerVersion('v1.10.0', '1.9.9'), isTrue);
      expect(isNewerVersion('v2.0', '1.9.9'), isTrue);
      expect(isNewerVersion('v1.0.0', '1.0.0'), isFalse);
      expect(isNewerVersion('v1.0.0', '1.0.1'), isFalse);
      expect(isNewerVersion('1.0.1+3', '1.0.1'), isFalse);
    });

    test('release json', () {
      final info = UpdateService.parse(
        '{"tag_name":"v1.0.1","html_url":"https://github.com/lumio-apps/somno/releases/tag/v1.0.1","body":"Fixes","assets":[{"name":"Somno-v1.0.1.apk","browser_download_url":"https://github.com/x/Somno-v1.0.1.apk"}]}',
      );
      expect(info.version, '1.0.1');
      expect(info.apkUrl, 'https://github.com/x/Somno-v1.0.1.apk');
      expect(info.notes, 'Fixes');
    });
  });
}

SleepSession night(int wakeDay, {int bedHour = 23, int wakeHour = 7}) {
  return SleepSession(
    startMs: at(wakeDay - 1, bedHour),
    endMs: at(wakeDay, wakeHour),
  );
}

void insightTests() {
  final today = DateTime(2026, 10, 10);
  group('insights', () {
    test('nap range', () {
      SleepSession of(int minutes) =>
          SleepSession(startMs: 0, endMs: minutes * 60000);
      expect(isNap(of(19)), isFalse);
      expect(isNap(of(20)), isTrue);
      expect(isNap(of(90)), isTrue);
      expect(isNap(of(91)), isFalse);
    });

    test('streak counts back from today', () {
      final byDay = minutesByDay([night(8), night(9), night(10)]);
      expect(goalStreak(byDay, today, 480), 3);
    });

    test('streak starts yesterday when today is empty', () {
      final byDay = minutesByDay([night(8), night(9)]);
      expect(goalStreak(byDay, today, 480), 2);
    });

    test('streak breaks on a short night', () {
      final byDay = minutesByDay([
        night(7),
        night(8, wakeHour: 3),
        night(9),
        night(10),
      ]);
      expect(goalStreak(byDay, today, 480), 2);
    });

    test('sleep debt', () {
      final byDay = minutesByDay([night(9, wakeHour: 6), night(10, wakeHour: 6)]);
      final debt = sleepDebt(byDay, today, 480);
      expect(debt?.minutes, 120);
      expect(debt?.days, 2);
      expect(sleepDebt(minutesByDay([night(10)]), today, 480), isNull);
    });

    test('consistency', () {
      final steady = [night(8), night(9), night(10)];
      expect(consistencyScore(steady, today), 100);
      expect(consistencyScore([night(9), night(10)], today), isNull);
      final messy = [
        night(8, bedHour: 21, wakeHour: 5),
        night(9, bedHour: 23, wakeHour: 7),
        night(10, wakeHour: 10),
      ];
      expect(consistencyScore(messy, today)!, lessThan(100));
    });
  });
}
