import 'package:flutter/material.dart';

import '../core/stats.dart';
import '../data/models.dart';
import '../l10n/gen/app_localizations.dart';
import '../state/app_state.dart';
import '../ui/format.dart';
import '../ui/palette.dart';
import '../ui/widgets.dart';
import 'battery_guide.dart';
import 'update_dialog.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  String _title(
    BuildContext context,
    AppLocalizations l,
    DateTime? day,
    DateTime today,
  ) {
    if (day == null) {
      return l.titleNone;
    }
    if (day == today) {
      return l.titleToday;
    }
    if (day == DateTime(today.year, today.month, today.day - 1)) {
      return l.titleYesterday;
    }
    return l.titleOnDate(dateFull(context, day));
  }

  String _status(AppLocalizations l, SomnoSettings s) {
    if (!s.trackingEnabled) {
      return l.statusOff;
    }
    switch (s.mode) {
      case TrackingMode.night:
        return l.statusNight;
      case TrackingMode.day:
        return l.statusDay;
      case TrackingMode.any:
        return l.statusAny;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final p = SomnoPalette.of(context);
    final settings = app.settings;
    final today = dateOnly(DateTime.now());
    final night = app.nightSessions;
    final byDay = minutesByDay(night);
    final day = latestSleepDay(night);
    final daySessions =
        day == null ? const <SleepSession>[] : sessionsOnDay(night, day);
    final naps = sessionsOnDay(app.napSessions, today);
    final napMinutes = naps.fold<int>(0, (sum, s) => sum + s.minutes);
    final streak = goalStreak(byDay, today, settings.goalMinutes);
    final consistency = consistencyScore(night, today);
    final debt = sleepDebt(byDay, today, settings.goalMinutes);
    final total = daySessions.fold<int>(0, (sum, s) => sum + s.minutes);
    final main = longestSession(daySessions);
    final goal = settings.goalMinutes;
    final week = lastNDays(byDay, today, 7);
    final weekMax = week.fold<int>(0, (m, d) => d.minutes > m ? d.minutes : m);
    final scale = (weekMax > goal ? weekMax : goal).toDouble();
    final percent = goal == 0 ? 0 : (total * 100 / goal).round();
    final remaining = goal - total;

    final children = <Widget>[
      Row(
        children: [
          const SomnoLogo(size: 28),
          const SizedBox(width: 10),
          Text(
            l.appName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: p.text,
            ),
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: settings.trackingEnabled ? p.primary : p.muted,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _status(l, settings),
            style: TextStyle(fontSize: 13, color: p.muted),
          ),
        ],
      ),
      const SizedBox(height: 16),
    ];

    final update = app.updateToOffer;
    if (update != null) {
      children.add(
        InfoBanner(
          text: l.updateBanner(update.version),
          action: l.view,
          onTap: () => showUpdateDialog(context, app, update),
        ),
      );
      children.add(const SizedBox(height: 12));
    }

    if (!settings.trackingEnabled) {
      children.add(
        InfoBanner(
          text: l.bannerTrackingOff,
          action: l.turnOn,
          onTap: () => app.setTracking(true),
        ),
      );
      children.add(const SizedBox(height: 12));
    } else if (app.batteryOk == false) {
      children.add(
        InfoBanner(
          text: l.bannerBattery,
          action: l.fix,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const BatteryGuideScreen(),
              ),
            );
          },
        ),
      );
      children.add(const SizedBox(height: 12));
    }

    children.add(const SizedBox(height: 12));
    children.add(
      Text(
        _title(context, l, day, today),
        style: TextStyle(fontSize: 15, color: p.muted),
      ),
    );
    children.add(const SizedBox(height: 4));

    if (total == 0) {
      children.add(
        Text(
          l.noSleepYet,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: p.text,
          ),
        ),
      );
      children.add(const SizedBox(height: 8));
      children.add(
        Text(
          l.noSleepHint(settings.minGapHours),
          style: TextStyle(fontSize: 15, height: 1.45, color: p.muted),
        ),
      );
    } else {
      children.add(_BigDuration(minutes: total));
      children.add(const SizedBox(height: 20));
      children.add(ProgressBar(fraction: total / goal));
      children.add(const SizedBox(height: 8));
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.goalPercent(percent, durationText(l, goal)),
              style: TextStyle(fontSize: 14, color: p.text),
            ),
            Text(
              remaining > 0
                  ? l.goalToGo(durationText(l, remaining))
                  : l.goalReached,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: remaining > 0 ? p.accent : p.primary,
              ),
            ),
          ],
        ),
      );
      children.add(const SizedBox(height: 20));
      children.add(
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Timeline(sessions: daySessions, day: day!),
              if (main != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _TimeBlock(
                        label: l.asleepLabel,
                        value: timeText(context, main.start),
                      ),
                    ),
                    Expanded(
                      child: _TimeBlock(
                        label: l.awakeLabel,
                        value: timeText(context, main.end),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }

    children.add(const SizedBox(height: 16));
    children.add(
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.last7,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: p.text,
                  ),
                ),
                Text(
                  l.avgShort(durationText(l, averageMinutes(week))),
                  style: TextStyle(fontSize: 13, color: p.muted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < week.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: scale == 0
                            ? 0.04
                            : (week[i].minutes / scale)
                                .clamp(0.04, 1.0)
                                .toDouble(),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: i == week.length - 1 ? p.primary : p.bar,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (naps.isNotEmpty) {
      children.add(const SizedBox(height: 12));
      children.add(
        Panel(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.napsToday,
                style: TextStyle(fontSize: 15, color: p.text),
              ),
              Text(
                '${naps.length} · ${durationText(l, napMinutes)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: p.text,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final debtMinutes = debt?.minutes ?? 0;
    final debtEven = debtMinutes.abs() < 15;
    children.add(const SizedBox(height: 16));
    children.add(
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.insightsTitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: p.text,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Stat(
                    label: l.streakLabel,
                    value: l.daysCount(streak),
                    valueColor: streak > 0 ? p.primary : p.text,
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: l.consistencyLabel,
                    value: consistency == null ? '–' : '$consistency%',
                    caption: consistency == null ? l.needMoreDays : null,
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: l.debtLabel,
                    value: debt == null
                        ? '–'
                        : durationText(l, debtEven ? 0 : debtMinutes.abs()),
                    caption: debt == null
                        ? l.needMoreDays
                        : debtEven
                            ? l.debtEven
                            : debtMinutes > 0
                                ? l.debtShort
                                : l.debtAhead,
                    valueColor: debt == null || debtEven
                        ? p.text
                        : debtMinutes > 0
                            ? p.accent
                            : p.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l.insightsNote,
              style: TextStyle(fontSize: 12, height: 1.45, color: p.muted),
            ),
          ],
        ),
      ),
    );

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: children,
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.caption,
    this.valueColor,
  });

  final String label;
  final String value;
  final String? caption;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    final note = caption;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: p.muted)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valueColor ?? p.text,
            ),
          ),
        ),
        if (note != null)
          Text(note, style: TextStyle(fontSize: 12, color: p.muted)),
      ],
    );
  }
}

class _BigDuration extends StatelessWidget {
  const _BigDuration({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final l = AppLocalizations.of(context);
    final big = TextStyle(
      fontSize: 96,
      fontWeight: FontWeight.w700,
      letterSpacing: -3,
      height: 1,
      color: p.text,
    );
    final unit = TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w500,
      color: p.muted,
    );
    return Semantics(
      label: durationText(l, minutes),
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('$h', style: big),
            Text(' h ', style: unit),
            Text(m.toString().padLeft(2, '0'), style: big),
            Text(' m', style: unit),
          ],
        ),
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: p.muted)),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: p.text,
          ),
        ),
      ],
    );
  }
}

/// A 24 hour strip from 6 PM the evening before to 6 PM on [day].
class _Timeline extends StatelessWidget {
  const _Timeline({required this.sessions, required this.day});

  final List<SleepSession> sessions;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    final windowStart = DateTime(day.year, day.month, day.day - 1, 18);
    final startMs = windowStart.millisecondsSinceEpoch;
    final spanMs = const Duration(hours: 24).inMilliseconds;
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final segments = <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: p.line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ];
            for (final s in sessions) {
              final from = s.startMs < startMs ? startMs : s.startMs;
              final to = s.endMs > startMs + spanMs ? startMs + spanMs : s.endMs;
              if (to <= from) {
                continue;
              }
              final left = (from - startMs) / spanMs * w;
              var width = (to - from) / spanMs * w;
              if (width < 4) {
                width = 4;
              }
              segments.add(
                Positioned(
                  left: left,
                  top: 0,
                  bottom: 0,
                  width: width,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: p.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              );
            }
            return SizedBox(height: 12, child: Stack(children: segments));
          },
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final hour in const [18, 0, 6, 12, 18])
              Text(
                minuteOfDayText(context, hour * 60),
                style: TextStyle(fontSize: 12, color: p.muted),
              ),
          ],
        ),
      ],
    );
  }
}
