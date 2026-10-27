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
import 'status_screen.dart';
import 'update_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  TimeOfDay _tod(int minuteOfDay) =>
      TimeOfDay(hour: minuteOfDay ~/ 60, minute: minuteOfDay % 60);

  Future<void> _pickWindow(
    BuildContext context,
    AppState app,
    bool night,
  ) async {
    final l = AppLocalizations.of(context);
    final s = app.settings;
    final start = await showTimePicker(
      context: context,
      initialTime: _tod(night ? s.nightStart : s.dayStart),
      helpText: l.pickStart,
    );
    if (start == null || !context.mounted) {
      return;
    }
    final end = await showTimePicker(
      context: context,
      initialTime: _tod(night ? s.nightEnd : s.dayEnd),
      helpText: l.pickEnd,
    );
    if (end == null) {
      return;
    }
    final startMin = start.hour * 60 + start.minute;
    final endMin = end.hour * 60 + end.minute;
    await app.updateSettings(
      (cur) => night
          ? cur.copyWith(nightStart: startMin, nightEnd: endMin)
          : cur.copyWith(dayStart: startMin, dayEnd: endMin),
    );
  }

  Future<void> _pickBirthYear(BuildContext context, AppState app) async {
    final year = await showDialog<int>(
      context: context,
      builder: (_) => _BirthYearDialog(initial: app.settings.birthYear),
    );
    if (year != null) {
      await app.updateSettings((cur) => cur.copyWith(birthYear: year));
    }
  }

  Future<void> _checkUpdates(BuildContext context, AppState app) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await app.checkForUpdates();
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case UpdateResult.available:
        final info = app.availableUpdate;
        if (info != null) {
          await showUpdateDialog(context, app, info);
        }
      case UpdateResult.upToDate:
        messenger.showSnackBar(SnackBar(content: Text(l.upToDate)));
      case UpdateResult.failed:
        messenger.showSnackBar(SnackBar(content: Text(l.updateFailed)));
    }
  }

  String _accentName(AppLocalizations l, SomnoAccent a) {
    switch (a) {
      case SomnoAccent.teal:
        return l.accentTeal;
      case SomnoAccent.purple:
        return l.accentPurple;
      case SomnoAccent.amber:
        return l.accentAmber;
      case SomnoAccent.blue:
        return l.accentBlue;
    }
  }

  Future<void> _openWellbeing(BuildContext context, AppState app) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final found = await app.openWellbeing();
    if (!found) {
      messenger.showSnackBar(SnackBar(content: Text(l.wellbeingMissing)));
    }
  }

  Future<void> _pickReminder(BuildContext context, AppState app) async {
    final l = AppLocalizations.of(context);
    final picked = await showTimePicker(
      context: context,
      initialTime: _tod(app.settings.reminderMinute),
      helpText: l.reminderTime,
    );
    if (picked == null) {
      return;
    }
    await app.updateSettings(
      (cur) => cur.copyWith(reminderMinute: picked.hour * 60 + picked.minute),
    );
  }

  String _windowText(BuildContext context, int start, int end) {
    return '${minuteOfDayText(context, start)} – ${minuteOfDayText(context, end)}';
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final p = SomnoPalette.of(context);
    final s = app.settings;
    final year = s.birthYear;
    String? recommended;
    if (year != null) {
      final r = rangeForAge(DateTime.now().year - year);
      recommended = l.recommendedFor(l.hoursRange(r.minHours, r.maxHours));
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          Text(
            l.settingsTitle,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: p.text,
            ),
          ),
          SectionLabel(l.sectionTracking),
          Container(
            constraints: const BoxConstraints(minHeight: 56),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: p.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.trackSleep,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: p.text,
                    ),
                  ),
                ),
                Switch(
                  value: s.trackingEnabled,
                  onChanged: (v) => app.setTracking(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l.countSleepDuring,
            style: TextStyle(fontSize: 14, color: p.muted),
          ),
          const SizedBox(height: 8),
          Pills<TrackingMode>(
            values: TrackingMode.values,
            selected: s.mode,
            labelOf: (m) {
              switch (m) {
                case TrackingMode.night:
                  return l.modeNight;
                case TrackingMode.day:
                  return l.modeDay;
                case TrackingMode.any:
                  return l.modeAny;
              }
            },
            onChanged: (m) =>
                app.updateSettings((cur) => cur.copyWith(mode: m)),
          ),
          const SizedBox(height: 6),
          if (s.mode == TrackingMode.night)
            SettingRow(
              label: l.windowNight,
              value: _windowText(context, s.nightStart, s.nightEnd),
              onTap: () => _pickWindow(context, app, true),
            ),
          if (s.mode == TrackingMode.day)
            SettingRow(
              label: l.windowDay,
              value: _windowText(context, s.dayStart, s.dayEnd),
              onTap: () => _pickWindow(context, app, false),
            ),
          if (s.mode == TrackingMode.any)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l.anyTimeNote,
                style: TextStyle(fontSize: 14, height: 1.45, color: p.muted),
              ),
            ),
          StepperRow(
            label: l.minGap,
            valueText: l.gapValue(s.minGapHours),
            onMinus: s.minGapHours > 1
                ? () => app.updateSettings(
                      (cur) => cur.copyWith(minGapHours: cur.minGapHours - 1),
                    )
                : null,
            onPlus: s.minGapHours < 5
                ? () => app.updateSettings(
                      (cur) => cur.copyWith(minGapHours: cur.minGapHours + 1),
                    )
                : null,
          ),
          if (s.mode == TrackingMode.any && s.minGapHours < 4)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l.gapTip,
                style: TextStyle(fontSize: 13, color: p.accent),
              ),
            ),
          SectionLabel(l.sectionGoal),
          StepperRow(
            label: l.dailyGoal,
            valueText: durationText(l, s.goalMinutes),
            onMinus: s.goalMinutes > 240
                ? () => app.updateSettings(
                      (cur) => cur.copyWith(goalMinutes: cur.goalMinutes - 30),
                    )
                : null,
            onPlus: s.goalMinutes < 720
                ? () => app.updateSettings(
                      (cur) => cur.copyWith(goalMinutes: cur.goalMinutes + 30),
                    )
                : null,
          ),
          SettingRow(
            label: l.birthYear,
            value: year == null ? '–' : '$year',
            onTap: () => _pickBirthYear(context, app),
          ),
          if (recommended != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                recommended,
                style: TextStyle(fontSize: 13, color: p.muted),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l.guideline,
              style: TextStyle(fontSize: 12, height: 1.5, color: p.muted),
            ),
          ),
          SectionLabel(l.sectionReminder),
          Container(
            constraints: const BoxConstraints(minHeight: 56),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: p.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.bedtimeReminder,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: p.text,
                    ),
                  ),
                ),
                Switch(
                  value: s.reminderEnabled,
                  onChanged: (v) {
                    if (v) {
                      app.requestNotifications();
                    }
                    app.updateSettings(
                      (cur) => cur.copyWith(reminderEnabled: v),
                    );
                  },
                ),
              ],
            ),
          ),
          if (s.reminderEnabled)
            SettingRow(
              label: l.reminderTime,
              value: minuteOfDayText(context, s.reminderMinute),
              onTap: () => _pickReminder(context, app),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l.reminderNote,
              style: TextStyle(fontSize: 12, height: 1.5, color: p.muted),
            ),
          ),
          SectionLabel(l.sectionApp),
          Text(l.theme, style: TextStyle(fontSize: 14, color: p.muted)),
          const SizedBox(height: 8),
          Pills<ThemeMode>(
            values: const [ThemeMode.dark, ThemeMode.light, ThemeMode.system],
            selected: s.themeMode,
            labelOf: (m) {
              switch (m) {
                case ThemeMode.dark:
                  return l.themeDark;
                case ThemeMode.light:
                  return l.themeLight;
                case ThemeMode.system:
                  return l.themeSystem;
              }
            },
            onChanged: (m) =>
                app.updateSettings((cur) => cur.copyWith(themeMode: m)),
          ),
          const SizedBox(height: 14),
          Text(l.accentColor, style: TextStyle(fontSize: 14, color: p.muted)),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final a in SomnoAccent.values)
                _AccentDot(
                  accent: a,
                  label: _accentName(l, a),
                  selected: s.accentIndex == a.index,
                  onTap: () => app.updateSettings(
                    (cur) => cur.copyWith(accentIndex: a.index),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(l.language, style: TextStyle(fontSize: 14, color: p.muted)),
          const SizedBox(height: 8),
          Pills<String>(
            values: const ['', 'en', 'hi'],
            selected: s.localeCode,
            labelOf: (code) {
              if (code == 'en') {
                return l.langEnglish;
              }
              if (code == 'hi') {
                return l.langHindi;
              }
              return l.langSystem;
            },
            onChanged: (code) =>
                app.updateSettings((cur) => cur.copyWith(localeCode: code)),
          ),
          const SizedBox(height: 6),
          SettingRow(
            label: l.batteryGuide,
            value: l.open,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BatteryGuideScreen(),
                ),
              );
            },
          ),
          SettingRow(
            label: l.trackingStatus,
            value: l.open,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const StatusScreen()),
              );
            },
          ),
          SettingRow(
            label: l.wellbeing,
            value: l.open,
            onTap: () => _openWellbeing(context, app),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l.wellbeingNote,
              style: TextStyle(fontSize: 12, height: 1.5, color: p.muted),
            ),
          ),
          SectionLabel(l.sectionUpdates),
          SettingRow(
            label: l.checkUpdates,
            value: app.checkingUpdate
                ? l.checking
                : l.versionLabel(app.appVersion.isEmpty ? '–' : app.appVersion),
            onTap: app.checkingUpdate ? () {} : () => _checkUpdates(context, app),
          ),
          Container(
            constraints: const BoxConstraints(minHeight: 56),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: p.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.autoCheckUpdates,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: p.text,
                    ),
                  ),
                ),
                Switch(
                  value: s.autoUpdateCheck,
                  onChanged: (v) => app.updateSettings(
                    (cur) => cur.copyWith(autoUpdateCheck: v),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l.updatesNet,
              style: TextStyle(fontSize: 12, height: 1.5, color: p.muted),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              l.privacyNote,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, height: 1.5, color: p.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot({
    required this.accent,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final SomnoAccent accent;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = dark ? accent.dark : accent.light;
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        child: Container(
          width: 48,
          height: 48,
          margin: const EdgeInsets.only(right: 8),
          alignment: Alignment.center,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? p.text : Colors.transparent,
                width: 2,
              ),
            ),
            child: selected
                ? Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: dark ? SomnoPalette.dark.onPrimary : Colors.white,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _BirthYearDialog extends StatefulWidget {
  const _BirthYearDialog({this.initial});

  final int? initial;

  @override
  State<_BirthYearDialog> createState() => _BirthYearDialogState();
}

class _BirthYearDialogState extends State<_BirthYearDialog> {
  late final TextEditingController _controller;
  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initial ?? ''}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final year = int.tryParse(_controller.text);
    final now = DateTime.now().year;
    if (year == null || year < now - 120 || year > now) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.of(context).pop(year);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.birthYearLabel),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        decoration: InputDecoration(
          errorText: _invalid ? l.birthYearError : null,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(l.save)),
      ],
    );
  }
}
