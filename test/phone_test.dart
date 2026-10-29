import 'package:flutter_test/flutter_test.dart';
import 'package:somno/core/phone_format.dart';
import 'package:somno/data/phone_info.dart';

const gb = 1024 * 1024 * 1024;

void main() {
  group('phone format', () {
    test('bytesText uses GB and MB', () {
      expect(bytesText(0), '0 MB');
      expect(bytesText(512 * 1024 * 1024), '512 MB');
      expect(bytesText(gb), '1 GB');
      expect(bytesText((2.5 * gb).round()), '2.5 GB');
      expect(bytesText(120 * gb), '120 GB');
    });

    test('marketingSize rounds up to the size the phone is sold as', () {
      expect(marketingSize((5.5 * gb).round()), '6 GB');
      expect(marketingSize((7.4 * gb).round()), '8 GB');
      expect(marketingSize(112 * gb), '128 GB');
      expect(marketingSize((11.2 * gb).round()), '12 GB');
      expect(marketingSize(0), '0 GB');
    });

    test('usedFraction is clamped between 0 and 1', () {
      expect(usedFraction(25 * gb, 100 * gb), closeTo(0.75, 0.0001));
      expect(usedFraction(0, 0), 0);
      expect(usedFraction(200 * gb, 100 * gb), 0);
      expect(usedFraction(-5, 100), 1);
    });

    test('uptimeText', () {
      expect(uptimeText(45 * 60000), '45m');
      expect(uptimeText(3 * 3600000 + 5 * 60000), '3h 5m');
      expect(uptimeText(2 * 86400000 + 7 * 3600000), '2d 7h');
    });
  });

  group('phone info', () {
    test('battery reads a full map', () {
      final b = BatteryInfo.fromMap({
        'level': 78,
        'status': 2,
        'plugged': 2,
        'health': 2,
        'tempTenths': 314,
        'millivolts': 4210,
        'cycles': 212,
        'saver': true,
      });
      expect(b.known, isTrue);
      expect(b.charging, isTrue);
      expect(b.celsius, closeTo(31.4, 0.0001));
      expect(b.volts, closeTo(4.21, 0.0001));
      expect(b.cycles, 212);
      expect(b.saver, isTrue);
    });

    test('battery copes with missing values', () {
      final b = BatteryInfo.fromMap({});
      expect(b.known, isFalse);
      expect(b.celsius, isNull);
      expect(b.volts, isNull);
      expect(b.cycles, -1);
    });

    test('device name does not repeat the brand', () {
      expect(
        DeviceInfo.fromMap({'manufacturer': 'Xiaomi', 'model': 'Redmi Note 12'})
            .name,
        'Xiaomi Redmi Note 12',
      );
      expect(
        DeviceInfo.fromMap({'manufacturer': 'samsung', 'model': 'Samsung S23'})
            .name,
        'Samsung S23',
      );
      expect(
        DeviceInfo.fromMap({'manufacturer': '', 'model': 'Pixel 8'}).name,
        'Pixel 8',
      );
    });

    test('snapshot accepts doubles for the refresh rate', () {
      final s = PhoneSnapshot.fromMap({
        'battery': {'level': 50},
        'device': {'hz': 119.9, 'ramTotal': 6 * gb, 'ramFree': 2 * gb},
      });
      expect(s.device.hz, 120);
      expect(s.device.ramUsed, 4 * gb);
      expect(s.battery.level, 50);
    });
  });
}
