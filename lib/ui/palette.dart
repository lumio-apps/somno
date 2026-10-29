import 'package:flutter/material.dart';

/// The main colour of the app. The first one (blue) is the default.
enum SomnoAccent {
  blue(Color(0xFF7C93FF), Color(0xFF3B5BFF)),
  purple(Color(0xFFA78BFA), Color(0xFF6B47E8)),
  amber(Color(0xFFFBBF24), Color(0xFFB45309)),
  teal(Color(0xFF2DD4BF), Color(0xFF0B7A66));

  const SomnoAccent(this.dark, this.light);

  final Color dark;
  final Color light;

  static SomnoAccent fromIndex(int index) {
    if (index < 0 || index >= SomnoAccent.values.length) {
      return SomnoAccent.blue;
    }
    return SomnoAccent.values[index];
  }
}

/// Colors of the "Daylight" design. Light is the main look; dark is deep ink.
class SomnoPalette {
  const SomnoPalette({
    required this.bg,
    required this.panel,
    required this.line,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.text,
    required this.muted,
    required this.alert,
    required this.bar,
    required this.track,
    required this.raised,
  });

  final Color bg;
  final Color panel;
  final Color line;
  final Color primary;
  final Color onPrimary;
  final Color accent;
  final Color text;
  final Color muted;
  final Color alert;
  final Color bar;

  /// Background of a segmented control.
  final Color track;

  /// The selected segment inside [track].
  final Color raised;

  static const SomnoPalette dark = SomnoPalette(
    bg: Color(0xFF0A0F20),
    panel: Color(0xFF141B36),
    line: Color(0xFF232B4A),
    primary: Color(0xFF7C93FF),
    onPrimary: Color(0xFF0A0F20),
    accent: Color(0xFFFFC45C),
    text: Color(0xFFF2F4FF),
    muted: Color(0xFFA5AECB),
    alert: Color(0xFFFF8A8A),
    bar: Color(0xFF3A4378),
    track: Color(0xFF1B2342),
    raised: Color(0xFF2E3869),
  );

  static const SomnoPalette light = SomnoPalette(
    bg: Color(0xFFF4F6FB),
    panel: Color(0xFFFFFFFF),
    line: Color(0xFFE3E8F3),
    primary: Color(0xFF3B5BFF),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFB45309),
    text: Color(0xFF0C1226),
    muted: Color(0xFF4A556F),
    alert: Color(0xFFC62828),
    bar: Color(0xFFD5DCF3),
    track: Color(0xFFE6EAF5),
    raised: Color(0xFFFFFFFF),
  );

  SomnoPalette withPrimary(Color primary, Color onPrimary) {
    return SomnoPalette(
      bg: bg,
      panel: panel,
      line: line,
      primary: primary,
      onPrimary: onPrimary,
      accent: accent,
      text: text,
      muted: muted,
      alert: alert,
      bar: bar,
      track: track,
      raised: raised,
    );
  }

  /// The base colours with the main colour the user picked.
  static SomnoPalette of(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.brightness == Brightness.dark ? dark : light;
    return base.withPrimary(
      theme.colorScheme.primary,
      theme.colorScheme.onPrimary,
    );
  }
}

ThemeData buildTheme(
  Brightness brightness, [
  SomnoAccent accent = SomnoAccent.blue,
]) {
  final base =
      brightness == Brightness.dark ? SomnoPalette.dark : SomnoPalette.light;
  final p = base.withPrimary(
    brightness == Brightness.dark ? accent.dark : accent.light,
    base.onPrimary,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: p.bg,
    canvasColor: p.bg,
    dividerColor: p.line,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      secondary: p.accent,
      onSecondary: p.onPrimary,
      error: p.alert,
      onError: p.bg,
      surface: p.panel,
      onSurface: p.text,
    ),
  );
}
