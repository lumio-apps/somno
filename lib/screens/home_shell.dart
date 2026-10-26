import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../ui/palette.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          TodayScreen(),
          HistoryScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: _NavPill(
            index: _index,
            labels: [l.navToday, l.navHistory, l.navSettings],
            icons: const [
              Icons.nightlight_round,
              Icons.bar_chart_rounded,
              Icons.tune_rounded,
            ],
            onChanged: (i) => setState(() => _index = i),
          ),
        ),
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.index,
    required this.labels,
    required this.icons,
    required this.onChanged,
  });

  final int index;
  final List<String> labels;
  final List<IconData> icons;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    final items = <Widget>[];
    for (var i = 0; i < labels.length; i++) {
      final on = i == index;
      final color = on ? p.onPrimary : p.muted;
      items.add(
        Expanded(
          child: Semantics(
            selected: on,
            button: true,
            child: Material(
              color: on ? p.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => onChanged(i),
                child: SizedBox(
                  height: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icons[i], size: 22, color: color),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: p.line),
      ),
      child: Row(children: items),
    );
  }
}
