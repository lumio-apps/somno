import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List;

import '../core/app_usage.dart';
import '../core/phone_format.dart';
import '../data/phone_info.dart';
import '../l10n/gen/app_localizations.dart';
import '../state/app_state.dart';
import '../ui/format.dart';
import '../ui/palette.dart';
import '../ui/widgets.dart';

/// Battery and device facts. Everything is read live from Android while this
/// tab is open, shown here, and never saved, shared or uploaded.
class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key, required this.active});

  /// True while this tab is the one on screen.
  final bool active;

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> with WidgetsBindingObserver {
  PhoneSnapshot? _snapshot;
  bool _failed = false;
  bool _foreground = true;
  Timer? _timer;
  int _ticks = 0;

  /// Screen time. [_usage] stays null until it is read; [_needAccess] is true
  /// when Usage access is off.
  ScreenTimeReport? _usage;
  bool _needAccess = false;
  bool _readingUsage = false;
  final Map<String, Uint8List?> _icons = <String, Uint8List?>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncTimer();
      }
    });
  }

  @override
  void didUpdateWidget(covariant PhoneScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      _syncTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  /// Reads now and then every few seconds, only while the tab is visible.
  void _syncTimer() {
    _timer?.cancel();
    _timer = null;
    if (widget.active && _foreground) {
      _ticks = 0;
      _load();
      _loadUsage();
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        _ticks++;
        _load();
        // Screen time changes slowly, so it is read about every 30 seconds.
        if (_ticks % 6 == 0) {
          _loadUsage();
        }
      });
    }
  }

  Future<void> _loadUsage() async {
    if (_readingUsage) {
      return;
    }
    _readingUsage = true;
    try {
      final app = AppScope.of(context);
      await app.refreshAccess();
      if (!mounted) {
        return;
      }
      if (app.usageAccess != true) {
        setState(() {
          _needAccess = true;
          _usage = null;
        });
        return;
      }
      final now = DateTime.now();
      final days = <Future<List<AppUse>>>[];
      for (var back = 6; back >= 0; back--) {
        final start = DateTime(now.year, now.month, now.day - back);
        final end = back == 0
            ? now
            : DateTime(now.year, now.month, now.day - back + 1);
        days.add(app.appUsage(start, end));
      }
      final yesterdayStart = DateTime(now.year, now.month, now.day - 1);
      final yesterdaySoFar = app.appUsage(
        yesterdayStart,
        DateTime(now.year, now.month, now.day - 1, now.hour, now.minute),
      );
      final results = await Future.wait(days);
      final soFar = await yesterdaySoFar;
      if (!mounted) {
        return;
      }
      final today = results.last;
      setState(() {
        _needAccess = false;
        _usage = ScreenTimeReport(
          today: topApps(today, 50),
          weekMs: [for (final r in results) totalMs(r)],
          yesterdaySoFarMs: totalMs(soFar),
        );
      });
      for (final a in topApps(today, 5)) {
        if (!_icons.containsKey(a.package)) {
          final icon = await app.appIcon(a.package);
          if (!mounted) {
            return;
          }
          setState(() => _icons[a.package] = icon);
        }
      }
    } finally {
      _readingUsage = false;
    }
  }

  Future<void> _load() async {
    final snap = await AppScope.of(context).phoneInfo();
    if (!mounted) {
      return;
    }
    setState(() {
      _snapshot = snap ?? _snapshot;
      _failed = snap == null && _snapshot == null;
    });
  }

  Future<void> _openBatteryUsage() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final exact = await AppScope.of(context).openBatteryUsage();
    if (!exact) {
      messenger.showSnackBar(SnackBar(content: Text(l.batteryUsageMissing)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = SomnoPalette.of(context);
    final snap = _snapshot;

    final children = <Widget>[
      Row(
        children: [
          Expanded(
            child: Text(
              l.phoneTitle,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
          ),
          _LockChip(label: l.onlyOnThisPhone),
        ],
      ),
      const SizedBox(height: 16),
    ];

    if (snap == null) {
      children.add(
        Panel(
          child: Text(
            _failed ? l.phoneUnavailable : l.phoneLoading,
            style: TextStyle(fontSize: 15, color: p.muted),
          ),
        ),
      );
    } else {
      children
        ..add(_BatteryCard(info: snap.battery))
        ..add(const SizedBox(height: 12))
        ..add(
          _ScreenTimeCard(
            report: _usage,
            needAccess: _needAccess,
            icons: _icons,
            onAllow: () => AppScope.of(context).openUsageAccess(),
          ),
        )
        ..add(const SizedBox(height: 12))
        ..add(_DeviceCard(info: snap.device))
        ..add(const SizedBox(height: 12))
        ..add(_LinkRow(
          title: l.batteryUsageTitle,
          hint: l.batteryUsageHint,
          onTap: _openBatteryUsage,
        ))
        ..add(
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              l.phoneNote,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, height: 1.5, color: p.muted),
            ),
          ),
        );
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        children: children,
      ),
    );
  }
}

class _LockChip extends StatelessWidget {
  const _LockChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: p.track,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline_rounded, size: 14, color: p.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: p.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BatteryCard extends StatelessWidget {
  const _BatteryCard({required this.info});

  final BatteryInfo info;

  String _state(AppLocalizations l) {
    if (info.full) {
      return l.batteryFull;
    }
    if (info.charging) {
      final src = _source(l);
      return src.isEmpty ? l.batteryCharging : '${l.batteryCharging} · $src';
    }
    if (info.status == 4) {
      return l.batteryNotCharging;
    }
    if (info.status == 3) {
      return l.batteryDischarging;
    }
    return '';
  }

  String _source(AppLocalizations l) {
    if (info.plugged & 4 != 0) {
      return l.powerWireless;
    }
    if (info.plugged & 2 != 0) {
      return l.powerUsb;
    }
    if (info.plugged & 1 != 0) {
      return l.powerAc;
    }
    if (info.plugged & 8 != 0) {
      return l.powerDock;
    }
    return '';
  }

  String _health(AppLocalizations l) {
    switch (info.health) {
      case 2:
        return l.healthGood;
      case 3:
        return l.healthOverheat;
      case 4:
        return l.healthDead;
      case 5:
        return l.healthOverVoltage;
      case 6:
        return l.healthFailure;
      case 7:
        return l.healthCold;
      default:
        return l.valueUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = SomnoPalette.of(context);
    if (!info.known) {
      return Panel(
        child: Text(
          l.phoneUnavailable,
          style: TextStyle(fontSize: 15, color: p.muted),
        ),
      );
    }
    final low = info.level <= 15 && !info.charging && !info.full;
    final barColor = low ? p.alert : p.primary;
    final state = _state(l);
    final temp = info.celsius;
    final volts = info.volts;
    return Panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.batteryTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: p.muted,
                  ),
                ),
              ),
              if (state.isNotEmpty)
                Flexible(
                  child: Text(
                    state,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: low ? p.alert : p.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Semantics(
            label: l.batteryPercent(info.level),
            excludeSemantics: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${info.level}',
                  style: TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2,
                    color: p.text,
                  ),
                ),
                Text(
                  '%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: p.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          _Bar(fraction: info.level / 100, color: barColor, height: 14),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Fact(
                  label: l.batteryTemp,
                  value: temp == null
                      ? l.valueUnknown
                      : '${temp.toStringAsFixed(1)} °C',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Fact(label: l.batteryHealth, value: _health(l)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Fact(
                  label: l.batteryVoltage,
                  value: volts == null
                      ? l.valueUnknown
                      : '${volts.toStringAsFixed(2)} V',
                ),
              ),
            ],
          ),
          if (info.cycles >= 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                l.batteryCycles(info.cycles),
                style: TextStyle(fontSize: 13, color: p.muted),
              ),
            ),
          if (info.saver)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l.batterySaverOn,
                style: TextStyle(fontSize: 13, color: p.accent),
              ),
            ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.track,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: p.muted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.fraction, required this.color, this.height = 8});

  final double fraction;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: p.track,
        borderRadius: BorderRadius.circular(999),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fraction.clamp(0.0, 1.0).toDouble(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.info});

  final DeviceInfo info;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = SomnoPalette.of(context);
    final ramTotal = marketingBytes(info.ramTotal);
    final storageTotal = marketingBytes(info.storageTotal);
    final rows = <Widget>[
      _Line(label: l.deviceModel, value: info.name),
      _Line(
        label: l.deviceAndroid,
        value: info.patch.isEmpty
            ? info.release
            : l.androidWithPatch(info.release, info.patch),
      ),
      if (info.cores > 0)
        _Line(
          label: l.deviceProcessor,
          value: info.abi.isEmpty
              ? l.coresCount(info.cores)
              : '${l.coresCount(info.cores)} · ${info.abi}',
        ),
    ];
    return Panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.deviceTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
          ),
          const SizedBox(height: 4),
          ...rows,
          if (info.ramTotal > 0) ...[
            const SizedBox(height: 10),
            _UsageLine(
              label: l.deviceMemory,
              value: l.freeOf(
                bytesText(info.ramFree),
                marketingSize(info.ramTotal),
              ),
              fraction: usedFraction(info.ramFree, ramTotal),
            ),
          ],
          if (info.storageTotal > 0) ...[
            const SizedBox(height: 12),
            _UsageLine(
              label: l.deviceStorage,
              value: l.freeOf(
                bytesText(info.storageFree),
                marketingSize(info.storageTotal),
              ),
              fraction: usedFraction(info.storageFree, storageTotal),
            ),
          ],
          const SizedBox(height: 6),
          if (info.width > 0)
            _Line(
              label: l.deviceScreen,
              value: info.hz > 0
                  ? '${info.width} × ${info.height} · ${info.hz} Hz'
                  : '${info.width} × ${info.height}',
            ),
          _Line(label: l.deviceUptime, value: uptimeText(info.uptimeMs)),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: p.muted)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: p.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageLine extends StatelessWidget {
  const _UsageLine({
    required this.label,
    required this.value,
    required this.fraction,
  });

  final String label;
  final String value;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: p.muted)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: p.text,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _Bar(fraction: fraction, color: p.primary),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    return Semantics(
      button: true,
      child: Material(
        color: p.panel,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: p.text,
                        ),
                      ),
                      Text(
                        hint,
                        style: TextStyle(fontSize: 12, color: p.muted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: p.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScreenTimeCard extends StatelessWidget {
  const _ScreenTimeCard({
    required this.report,
    required this.needAccess,
    required this.icons,
    required this.onAllow,
  });

  final ScreenTimeReport? report;
  final bool needAccess;
  final Map<String, Uint8List?> icons;
  final VoidCallback onAllow;

  String _compare(AppLocalizations l, ScreenTimeReport r) {
    final change = percentChange(r.todayMs, r.yesterdaySoFarMs);
    if (change == null) {
      return '';
    }
    if (change == 0) {
      return l.screenTimeSame;
    }
    return change < 0
        ? l.screenTimeLess(-change)
        : l.screenTimeMore(change);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = SomnoPalette.of(context);
    final r = report;

    final head = Text(
      l.screenTimeTitle,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: p.text,
      ),
    );

    if (needAccess) {
      return Panel(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            head,
            const SizedBox(height: 8),
            Text(
              l.screenTimeNeedAccess,
              style: TextStyle(fontSize: 14, height: 1.45, color: p.muted),
            ),
            const SizedBox(height: 8),
            TextAction(label: l.allowUsage, onTap: onAllow, color: p.primary),
          ],
        ),
      );
    }
    if (r == null) {
      return Panel(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            head,
            const SizedBox(height: 8),
            Text(
              l.phoneLoading,
              style: TextStyle(fontSize: 14, color: p.muted),
            ),
          ],
        ),
      );
    }

    final compare = _compare(l, r);
    final top = topApps(r.today, 5);
    final topMax = top.isEmpty ? 1 : top.first.ms;
    final now = DateTime.now();
    final weekMax = r.weekMs.fold<int>(0, (m, v) => v > m ? v : m);

    return Panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          head,
          const SizedBox(height: 2),
          Text(
            durationText(l, minutesOf(r.todayMs)),
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
              color: p.text,
            ),
          ),
          if (compare.isNotEmpty)
            Text(
              compare,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: p.muted,
              ),
            ),
          const SizedBox(height: 14),
          if (top.isEmpty)
            Text(
              l.screenTimeNone,
              style: TextStyle(fontSize: 14, color: p.muted),
            )
          else ...[
            Text(
              l.mostUsedToday,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: p.muted,
              ),
            ),
            const SizedBox(height: 8),
            for (final a in top)
              _AppRow(
                app: a,
                icon: icons[a.package],
                fraction: a.ms / topMax,
                time: durationText(l, minutesOf(a.ms)),
              ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.screenTimeWeek,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: p.muted,
                  ),
                ),
              ),
              Text(
                l.screenTimeAvg(durationText(l, minutesOf(r.weekAverageMs))),
                style: TextStyle(fontSize: 13, color: p.muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < r.weekMs.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: weekMax == 0
                            ? 4
                            : (4 + 60 * r.weekMs[i] / weekMax),
                        decoration: BoxDecoration(
                          color: i == r.weekMs.length - 1 ? p.primary : p.bar,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < r.weekMs.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    weekdayShort(
                      context,
                      DateTime(
                        now.year,
                        now.month,
                        now.day - (r.weekMs.length - 1 - i),
                      ),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: i == r.weekMs.length - 1
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: i == r.weekMs.length - 1 ? p.text : p.muted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  const _AppRow({
    required this.app,
    required this.icon,
    required this.fraction,
    required this.time,
  });

  final AppUse app;
  final Uint8List? icon;
  final double fraction;
  final String time;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    final bytes = icon;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: bytes == null
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: p.track,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        app.label.isEmpty
                            ? '?'
                            : app.label.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: p.primary,
                        ),
                      ),
                    ),
                  )
                : ExcludeSemantics(
                    child: Image.memory(
                      bytes,
                      width: 36,
                      height: 36,
                      gaplessPlayback: true,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        app.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: p.text,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: p.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _Bar(fraction: fraction, color: p.primary, height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
