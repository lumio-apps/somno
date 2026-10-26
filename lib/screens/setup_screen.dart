import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/sleep_logic.dart';
import '../data/models.dart';
import '../l10n/gen/app_localizations.dart';
import '../state/app_state.dart';
import '../ui/format.dart';
import '../ui/palette.dart';
import '../ui/widgets.dart';
import 'battery_guide.dart';

/// First launch: birth year and goal, tracking mode, battery step.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _year = TextEditingController();
  int _step = 0;
  TrackingMode _mode = TrackingMode.night;

  @override
  void dispose() {
    _year.dispose();
    super.dispose();
  }

  /// The age for the typed birth year, or null when it is not valid.
  int? get _age {
    final year = int.tryParse(_year.text);
    final now = DateTime.now().year;
    if (year == null || year < now - 120 || year > now) {
      return null;
    }
    return now - year;
  }

  Future<void> _finish() async {
    final age = _age;
    if (age == null) {
      return;
    }
    final app = AppScope.of(context);
    final year = DateTime.now().year - age;
    app.requestNotifications();
    await app.completeOnboarding(
      birthYear: year,
      goalMinutes: goalMinutesForAge(age),
      mode: _mode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = SomnoPalette.of(context);

    Widget body;
    if (_step == 0) {
      body = _buildBirthYear(context, l, p);
    } else if (_step == 1) {
      body = _buildMode(context, l, p);
    } else {
      body = BatteryGuideView(
        finishLabel: l.startTracking,
        skipLabel: l.skipForNow,
        onFinish: _finish,
      );
    }

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          setState(() => _step--);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            children: [
              Semantics(
                label: l.stepOf(_step + 1, 3),
                child: Row(
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: i <= _step ? p.primary : p.line,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              body,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBirthYear(BuildContext context, AppLocalizations l, SomnoPalette p) {
    final age = _age;
    final typed = _year.text.length == 4;
    final range = age == null ? null : rangeForAge(age);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SomnoLogo(size: 64),
        const SizedBox(height: 20),
        Text(
          l.welcomeTitle,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: p.text,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l.welcomeBody,
          style: TextStyle(fontSize: 16, height: 1.5, color: p.muted),
        ),
        const SizedBox(height: 24),
        Text(
          l.birthYearLabel,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: p.muted,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _year,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          onChanged: (_) => setState(() {}),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: p.text,
          ),
          decoration: InputDecoration(
            hintText: '${DateTime.now().year - 25}',
            errorText: typed && age == null ? l.birthYearError : null,
            filled: true,
            fillColor: p.panel,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: p.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: p.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: p.alert),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: p.alert, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (age != null && range != null) ...[
          Panel(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l.recommendedAge,
                        style: TextStyle(fontSize: 14, color: p.muted),
                      ),
                    ),
                    Text(
                      l.hoursRange(range.minHours, range.maxHours),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: p.text,
                      ),
                    ),
                  ],
                ),
                Divider(height: 24, color: p.line),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l.yourGoal,
                        style: TextStyle(fontSize: 14, color: p.muted),
                      ),
                    ),
                    Text(
                      durationText(l, goalMinutesForAge(age)),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: p.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l.changeLater,
            style: TextStyle(fontSize: 13, color: p.muted),
          ),
          if (age < 14) ...[
            const SizedBox(height: 6),
            Text(
              l.youngNote,
              style: TextStyle(fontSize: 13, color: p.accent),
            ),
          ],
        ],
        const SizedBox(height: 8),
        Text(
          l.guideline,
          style: TextStyle(fontSize: 12, height: 1.5, color: p.muted),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: l.continueLabel,
          onTap: age == null ? null : () => setState(() => _step = 1),
        ),
      ],
    );
  }

  Widget _buildMode(BuildContext context, AppLocalizations l, SomnoPalette p) {
    const defaults = SomnoSettings();
    final options = <TrackingMode, String>{
      TrackingMode.night: l.modeNightDesc(
        minuteOfDayText(context, defaults.nightStart),
        minuteOfDayText(context, defaults.nightEnd),
      ),
      TrackingMode.day: l.modeDayDesc(
        minuteOfDayText(context, defaults.dayStart),
        minuteOfDayText(context, defaults.dayEnd),
      ),
      TrackingMode.any: l.modeAnyDesc,
    };
    final titles = <TrackingMode, String>{
      TrackingMode.night: l.modeNight,
      TrackingMode.day: l.modeDay,
      TrackingMode.any: l.modeAny,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.modeStepTitle,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: p.text,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l.modeStepBody,
          style: TextStyle(fontSize: 16, height: 1.5, color: p.muted),
        ),
        const SizedBox(height: 24),
        for (final mode in TrackingMode.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Semantics(
              selected: _mode == mode,
              button: true,
              child: Material(
                color: p.panel,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: _mode == mode ? p.primary : p.line,
                    width: _mode == mode ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onTap: () => setState(() => _mode = mode),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titles[mode]!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _mode == mode ? p.primary : p.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          options[mode]!,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: p.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: l.continueLabel,
          onTap: () => setState(() => _step = 2),
        ),
      ],
    );
  }
}
