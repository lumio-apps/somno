import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../state/app_state.dart';
import '../ui/palette.dart';
import '../ui/widgets.dart';

/// Explains the one-time battery step. Used inside setup and as its own page.
class BatteryGuideView extends StatelessWidget {
  const BatteryGuideView({
    super.key,
    required this.finishLabel,
    required this.skipLabel,
    required this.onFinish,
  });

  /// Label of the button that leaves this guide once battery saving is off.
  final String finishLabel;

  /// Label of the quiet button that leaves it without fixing battery saving.
  final String skipLabel;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final p = SomnoPalette.of(context);
    final ok = app.batteryOk == true;
    final steps = [l.batteryStep1, l.batteryStep2, l.batteryStep3];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.battery_charging_full_rounded, size: 56, color: p.primary),
        const SizedBox(height: 16),
        Text(
          l.batteryTitle,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: p.text,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l.batteryBody,
          style: TextStyle(fontSize: 16, height: 1.5, color: p.muted),
        ),
        const SizedBox(height: 20),
        if (ok)
          Panel(
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: p.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.batteryAlreadyOk,
                    style: TextStyle(fontSize: 15, color: p.text),
                  ),
                ),
              ],
            ),
          )
        else
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Panel(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: p.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: p.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 6),
        Text(
          l.notifHint,
          style: TextStyle(fontSize: 13, height: 1.5, color: p.muted),
        ),
        const SizedBox(height: 10),
        Text(
          l.batteryFoot,
          style: TextStyle(fontSize: 13, height: 1.5, color: p.muted),
        ),
        const SizedBox(height: 24),
        if (ok)
          PrimaryButton(label: finishLabel, onTap: onFinish)
        else ...[
          PrimaryButton(
            label: l.openBatterySettings,
            onTap: app.openBatterySettings,
          ),
          const SizedBox(height: 4),
          TextAction(
            label: skipLabel,
            onTap: onFinish,
          ),
        ],
      ],
    );
  }
}

/// The guide as a page of its own, opened from Settings or the Today banner.
class BatteryGuideScreen extends StatelessWidget {
  const BatteryGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = SomnoPalette.of(context);
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
              child: BatteryGuideView(
                finishLabel: l.done,
                skipLabel: l.done,
                onFinish: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
