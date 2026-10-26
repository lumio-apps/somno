import 'package:flutter/material.dart';

import '../core/stats.dart';
import '../data/models.dart';
import '../l10n/gen/app_localizations.dart';
import '../state/app_state.dart';
import '../ui/format.dart';
import '../ui/palette.dart';
import '../ui/widgets.dart';
import 'edit_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _week = true;

  void _openEditor(SleepSession? session) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EditScreen(session: session)),
    );
  }

  String _sourceText(AppLocalizations l, int source) {
    if (source == kSourceEdited) {
      return l.sourceEdited;
    }
    if (source == kSourceManual) {
      return l.sourceManual;
    }
    return l.sourceAuto;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final p = SomnoPalette.of(context);
    final goal = app.settings.goalMinutes;
    final today = dateOnly(DateTime.now());
    final count = _week ? 7 : 30;
    final totals = lastNDays(minutesByDay(app.sessions), today, count);
    final avg = averageMinutes(totals);
    final maxTotal = totals.fold<int>(0, (m, d) => d.minutes > m ? d.minutes : m);
    final scale = (maxTotal > goal ? maxTotal : goal).toDouble() * 1.1;
    final from = totals.first.day;
    final inPeriod =
        app.sessions.where((s) => !dateOnly(s.end).isBefore(from)).toList();

    final children = <Widget>[
      Text(
        l.navHistory,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: p.text,
        ),
      ),
      const SizedBox(height: 16),
      Pills<bool>(
        values: const [true, false],
        selected: _week,
        labelOf: (v) => v ? l.periodWeek : l.periodMonth,
        onChanged: (v) => setState(() => _week = v),
      ),
      const SizedBox(height: 24),
      Text(
        l.avgPerNight,
        style: TextStyle(fontSize: 14, color: p.muted),
      ),
      Text(
        avg == 0 ? l.noData : durationText(l, avg),
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          height: 1.15,
          color: p.text,
        ),
      ),
      const SizedBox(height: 20),
    ];

    if (_week) {
      for (var i = 0; i < totals.length; i++) {
        final t = totals[i];
        final isToday = i == totals.length - 1;
        children.add(
          SizedBox(
            height: 28,
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    weekdayShort(context, t.day),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                      color: isToday ? p.text : p.muted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final w = c.maxWidth;
                      final barW = t.minutes / scale * w;
                      final goalX = goal / scale * w;
                      return Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 4,
                            bottom: 4,
                            width: barW < 3 && t.minutes > 0 ? 3 : barW,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: t.minutes >= goal || isToday
                                    ? p.primary
                                    : p.bar,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          Positioned(
                            left: goalX,
                            top: 0,
                            bottom: 0,
                            width: 2,
                            child: DashLine(color: p.accent, vertical: true),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 72,
                  child: Text(
                    t.minutes == 0 ? '–' : durationText(l, t.minutes),
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
          ),
        );
        children.add(const SizedBox(height: 8));
      }
    } else {
      children.add(
        SizedBox(
          height: 170,
          child: LayoutBuilder(
            builder: (context, c) {
              final h = c.maxHeight;
              return Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: goal / scale * h,
                    height: 2,
                    child: DashLine(color: p.accent),
                  ),
                  Positioned.fill(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final t in totals)
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              child: FractionallySizedBox(
                                heightFactor: (t.minutes / scale)
                                    .clamp(0.02, 1.0)
                                    .toDouble(),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color:
                                        t.minutes >= goal ? p.primary : p.bar,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
      children.add(const SizedBox(height: 6));
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateShort(context, totals.first.day),
              style: TextStyle(fontSize: 12, color: p.muted),
            ),
            Text(
              dateShort(context, totals.last.day),
              style: TextStyle(fontSize: 12, color: p.muted),
            ),
          ],
        ),
      );
    }

    children.add(const SizedBox(height: 8));
    children.add(
      Row(
        children: [
          SizedBox(
            width: 18,
            height: 2,
            child: DashLine(color: p.accent),
          ),
          const SizedBox(width: 8),
          Text(
            l.goalLegend(durationText(l, goal)),
            style: TextStyle(fontSize: 13, color: p.muted),
          ),
        ],
      ),
    );

    children.add(const SizedBox(height: 24));
    children.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l.sessionsTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
          ),
          TextButton(
            onPressed: () => _openEditor(null),
            style: TextButton.styleFrom(
              minimumSize: const Size(64, 44),
              foregroundColor: p.primary,
            ),
            child: Text(
              l.addMissingSleep,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    children.add(const SizedBox(height: 4));

    if (inPeriod.isEmpty) {
      children.add(
        Text(
          l.noSessions,
          style: TextStyle(fontSize: 14, color: p.muted),
        ),
      );
    }
    for (final s in inPeriod) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: p.panel,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: p.line),
            ),
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onTap: () => _openEditor(s),
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weekdayShort(context, s.end)} · '
                            '${timeText(context, s.start)} – '
                            '${timeText(context, s.end)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: p.text,
                            ),
                          ),
                          Text(
                            _sourceText(l, s.source),
                            style: TextStyle(
                              fontSize: 12,
                              color: s.source == kSourceAuto
                                  ? p.muted
                                  : p.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      durationText(l, s.minutes),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: p.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: children,
      ),
    );
  }
}
