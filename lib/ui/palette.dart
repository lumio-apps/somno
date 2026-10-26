import 'package:flutter/material.dart';

/// Colors of design B. Dark is true black for OLED screens.
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

  static const SomnoPalette dark = SomnoPalette(
    bg: Color(0xFF05080F),
    panel: Color(0xFF0F1522),
    line: Color(0xFF1C2536),
    primary: Color(0xFF2DD4BF),
    onPrimary: Color(0xFF05080F),
    accent: Color(0xFFF5A524),
    text: Color(0xFFF4F7FB),
    muted: Color(0xFF9AA6BC),
    alert: Color(0xFFFF8A8A),
    bar: Color(0xFF3A4A63),
  );

  static const SomnoPalette light = SomnoPalette(
    bg: Color(0xFFF4F7FB),
    panel: Color(0xFFFFFFFF),
    line: Color(0xFFDCE3EC),
    primary: Color(0xFF087F72),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF9A5B00),
    text: Color(0xFF0A1220),
    muted: Color(0xFF566377),
    alert: Color(0xFFC62828),
    bar: Color(0xFFC5CFDC),
  );

  static SomnoPalette of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}

ThemeData buildTheme(Brightness brightness) {
  final p =
      brightness == Brightness.dark ? SomnoPalette.dark : SomnoPalette.light;
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
