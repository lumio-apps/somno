/// Facts about this phone, read from Android when the Phone tab is open.
/// Nothing here is saved, shared or uploaded.
class BatteryInfo {
  const BatteryInfo({
    this.level = -1,
    this.status = 1,
    this.plugged = 0,
    this.health = 1,
    this.tempTenths,
    this.millivolts = -1,
    this.cycles = -1,
    this.saver = false,
  });

  factory BatteryInfo.fromMap(Map<Object?, Object?> m) {
    final temp = _int(m['tempTenths'], -1 << 31);
    return BatteryInfo(
      level: _int(m['level'], -1),
      status: _int(m['status'], 1),
      plugged: _int(m['plugged'], 0),
      health: _int(m['health'], 1),
      tempTenths: temp == -1 << 31 ? null : temp,
      millivolts: _int(m['millivolts'], -1),
      cycles: _int(m['cycles'], -1),
      saver: m['saver'] == true,
    );
  }

  /// 0 to 100, or -1 when unknown.
  final int level;

  /// Android BatteryManager status: 2 charging, 3 discharging,
  /// 4 not charging, 5 full, anything else unknown.
  final int status;

  /// Bit mask: 1 AC, 2 USB, 4 wireless, 8 dock. 0 means unplugged.
  final int plugged;

  /// Android BatteryManager health: 2 good, 3 overheat, 4 dead,
  /// 5 over voltage, 6 failure, 7 cold, anything else unknown.
  final int health;

  /// Temperature in tenths of a degree Celsius, or null when unknown.
  final int? tempTenths;
  final int millivolts;

  /// Charge cycles, or -1 when this phone does not report it.
  final int cycles;
  final bool saver;

  bool get known => level >= 0;
  bool get charging => status == 2;
  bool get full => status == 5;
  double? get celsius => tempTenths == null ? null : tempTenths! / 10;
  double? get volts => millivolts > 0 ? millivolts / 1000 : null;
}

class DeviceInfo {
  const DeviceInfo({
    this.manufacturer = '',
    this.model = '',
    this.release = '',
    this.sdk = 0,
    this.patch = '',
    this.abi = '',
    this.cores = 0,
    this.uptimeMs = 0,
    this.ramTotal = 0,
    this.ramFree = 0,
    this.storageTotal = 0,
    this.storageFree = 0,
    this.width = 0,
    this.height = 0,
    this.dpi = 0,
    this.hz = 0,
  });

  factory DeviceInfo.fromMap(Map<Object?, Object?> m) {
    return DeviceInfo(
      manufacturer: _str(m['manufacturer']),
      model: _str(m['model']),
      release: _str(m['release']),
      sdk: _int(m['sdk'], 0),
      patch: _str(m['patch']),
      abi: _str(m['abi']),
      cores: _int(m['cores'], 0),
      uptimeMs: _int(m['uptimeMs'], 0),
      ramTotal: _int(m['ramTotal'], 0),
      ramFree: _int(m['ramFree'], 0),
      storageTotal: _int(m['storageTotal'], 0),
      storageFree: _int(m['storageFree'], 0),
      width: _int(m['width'], 0),
      height: _int(m['height'], 0),
      dpi: _int(m['dpi'], 0),
      hz: _num(m['hz']).round(),
    );
  }

  final String manufacturer;
  final String model;
  final String release;
  final int sdk;
  final String patch;
  final String abi;
  final int cores;
  final int uptimeMs;
  final int ramTotal;
  final int ramFree;
  final int storageTotal;
  final int storageFree;
  final int width;
  final int height;
  final int dpi;
  final int hz;

  /// "Xiaomi Redmi Note 12", without repeating the brand when the model
  /// already starts with it.
  String get name {
    final make = manufacturer.trim();
    final mod = model.trim();
    if (mod.isEmpty) {
      return make;
    }
    if (make.isEmpty || mod.toLowerCase().startsWith(make.toLowerCase())) {
      return mod;
    }
    final cap = make[0].toUpperCase() + make.substring(1);
    return '$cap $mod';
  }

  int get ramUsed => ramTotal - ramFree;
  int get storageUsed => storageTotal - storageFree;
}

class PhoneSnapshot {
  const PhoneSnapshot({required this.battery, required this.device});

  factory PhoneSnapshot.fromMap(Map<Object?, Object?> m) {
    final b = m['battery'];
    final d = m['device'];
    return PhoneSnapshot(
      battery: b is Map ? BatteryInfo.fromMap(b) : const BatteryInfo(),
      device: d is Map ? DeviceInfo.fromMap(d) : const DeviceInfo(),
    );
  }

  final BatteryInfo battery;
  final DeviceInfo device;
}

int _int(Object? v, int fallback) => v is num ? v.toInt() : fallback;

double _num(Object? v) => v is num ? v.toDouble() : 0;

String _str(Object? v) => v is String ? v : '';
