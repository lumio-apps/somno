import 'package:flutter/material.dart';

import 'l10n/gen/app_localizations.dart';
import 'screens/home_shell.dart';
import 'screens/setup_screen.dart';
import 'state/app_state.dart';
import 'ui/palette.dart';

class SomnoApp extends StatefulWidget {
  const SomnoApp({super.key, required this.state});

  final AppState state;

  @override
  State<SomnoApp> createState() => _SomnoAppState();
}

class _SomnoAppState extends State<SomnoApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.state.onResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: widget.state,
      child: ListenableBuilder(
        listenable: widget.state,
        builder: (context, _) {
          final settings = widget.state.settings;
          final code = settings.localeCode;
          return MaterialApp(
            title: 'Somno',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(Brightness.light),
            darkTheme: buildTheme(Brightness.dark),
            themeMode: settings.themeMode,
            locale: code.isEmpty ? null : Locale(code),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const _RootGate(),
          );
        },
      ),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (!app.loaded) {
      return const Scaffold();
    }
    if (!app.settings.onboarded) {
      return const SetupScreen();
    }
    return const HomeShell();
  }
}
