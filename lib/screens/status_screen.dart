import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../state/app_state.dart';
import '../ui/format.dart';
import '../ui/palette.dart';
import '../ui/widgets.dart';

/// Shows whether the tracker is alive and lets the user fix what stops it.
class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen>
    with WidgetsBindingObserver {
  Map<String, Object?> _status = <String, Object?>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  Future<void> _load() async {
    final app = AppScope.of(context);
    await app.refreshAccess();
    final status = await app.trackingStatus();
    if (mounted) {
      setState(() => _status = status);
    }
  }

  String _time(BuildContext context, AppLocalizations l, Object? value) {
    if (value is! num || value <= 0) {
      return l.statusNever;
    }
    final d = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return '${dateShort(context, d)} · ${timeText(context, d)}';
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final p = SomnoPalette.of(context);
    final running = _status['running'] == true;
    final phone = '${_status['manufacturer'] ?? ''} ${_status['model'] ?? ''}'
        .trim();
    final usage = app.usageAccess == true;
    final battery = app.batteryOk == true;

    Widget row(String label, String value, {Color? color}) {
      return Container(
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 15, color: p.text)),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color ?? p.text,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 24, 24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: p.text,
                ),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.trackingStatus,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: p.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  row(
                    l.statusUsage,
                    usage ? l.accessOn : l.accessOff,
                    color: usage ? p.primary : p.alert,
                  ),
                  row(
                    l.statusService,
                    usage
                        ? l.statusNotNeeded
                        : running
                            ? l.statusRunning
                            : l.statusStopped,
                    color: usage || running ? p.primary : p.accent,
                  ),
                  row(
                    l.statusBattery,
                    battery ? l.statusBatteryOk : l.statusBatteryBad,
                    color: battery ? p.primary : p.accent,
                  ),
                  row(l.statusLastOff, _time(context, l, _status['lastOff'])),
                  row(
                    l.statusLastUnlock,
                    _time(context, l, _status['lastUnlock']),
                  ),
                  if (phone.isNotEmpty) row(l.statusPhone, phone),
                  const SizedBox(height: 20),
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.usageExplain,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: p.text,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (usage)
                          Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: p.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l.usageIsOn,
                                  style: TextStyle(fontSize: 14, color: p.text),
                                ),
                              ),
                            ],
                          )
                        else
                          PrimaryButton(
                            label: l.allowUsage,
                            onTap: app.openUsageAccess,
                          ),
                      ],
                    ),
                  ),
                  if (!usage) ...[
                    const SizedBox(height: 12),
                    Text(
                      l.fallbackNote,
                      style: TextStyle(fontSize: 13, height: 1.5, color: p.muted),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    l.autostartNote,
                    style: TextStyle(fontSize: 13, height: 1.5, color: p.muted),
                  ),
                  const SizedBox(height: 4),
                  TextAction(
                    label: l.openAutostart,
                    onTap: app.openAutostart,
                  ),
                  TextAction(
                    label: l.openBatterySettings,
                    onTap: app.openBatterySettings,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
