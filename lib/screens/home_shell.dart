import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../ui/palette.dart';
import 'history_screen.dart';
import 'phone_screen.dart';
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
        children: [
          const TodayScreen(),
          const HistoryScreen(),
          PhoneScreen(active: _index == 2),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _TabBar(
        index: _index,
        labels: [l.navToday, l.navHistory, l.navPhone, l.navSettings],
        icons: const [
          Icons.nightlight_round,
          Icons.bar_chart_rounded,
          Icons.smartphone_rounded,
          Icons.tune_rounded,
        ],
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// A flat full-width tab bar with a small dot above the selected tab.
class _TabBar extends StatelessWidget {
  const _TabBar({
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
      final color = on ? p.primary : p.muted;
      items.add(
        Expanded(
          child: Semantics(
            selected: on,
            button: true,
            label: labels[i],
            excludeSemantics: true,
            child: InkWell(
              onTap: () => onChanged(i),
              child: SizedBox(
                height: 64,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: on ? p.primary : Colors.transparent,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Icon(icons[i], size: 24, color: color),
                    const SizedBox(height: 2),
                    Text(
                      labels[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                        color: color,
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
    return Container(
      decoration: BoxDecoration(
        color: p.panel,
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: SafeArea(top: false, child: Row(children: items)),
    );
  }
}
