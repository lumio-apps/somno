import 'dart:async';

import 'package:flutter/material.dart';

import '../core/phone_format.dart';
import '../data/phone_info.dart';
import '../l10n/gen/app_localizations.dart';
import '../state/app_state.dart';
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
      _load();
      _timer = Timer.periodic(const Duration(seconds: 5), (_) => _load());
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
