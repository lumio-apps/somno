import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import 'palette.dart';

/// The Somno "Z" mark.
class SomnoLogo extends StatelessWidget {
  const SomnoLogo({super.key, this.size = 28, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? SomnoPalette.of(context).primary;
    return SizedBox.square(
      dimension: size,
      child: ExcludeSemantics(
        child: CustomPaint(painter: _LogoPainter(c)),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 72;
    canvas.scale(scale);
    canvas.translate(-16, -12);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(30, 34)
      ..lineTo(68, 34)
      ..lineTo(30, 68)
      ..lineTo(70, 68);
    canvas.drawPath(path, stroke);
    canvas.drawCircle(const Offset(78, 24), 5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.color != color;
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: child,
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
          color: p.muted,
        ),
      ),
    );
  }
}

/// A row of equal pills where one value is selected.
class Pills<T> extends StatelessWidget {
  const Pills({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    final children = <Widget>[];
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      final on = value == selected;
      if (i > 0) {
        children.add(const SizedBox(width: 8));
      }
      children.add(
        Expanded(
          child: Semantics(
            selected: on,
            button: true,
            child: Material(
              color: on ? p.primary : Colors.transparent,
              shape: StadiumBorder(
                side: on ? BorderSide.none : BorderSide(color: p.line),
              ),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => onChanged(value),
                child: SizedBox(
                  height: 44,
                  child: Center(
                    child: Text(
                      labelOf(value),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                        color: on ? p.onPrimary : p.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Row(children: children);
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    final enabled = onTap != null;
    return Material(
      color: enabled ? p.primary : p.line,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: enabled ? p.onPrimary : p.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TextAction extends StatelessWidget {
  const TextAction({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color ?? p.muted,
            ),
          ),
        ),
      ),
    );
  }
}

/// A settings line: label on the left, value on the right.
class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.label,
    this.value,
    this.valueColor,
    this.onTap,
  });

  final String label;
  final String? value;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    final v = value;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: p.text,
                ),
              ),
            ),
            if (v != null)
              Text(
                v,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? p.muted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Label with a minus button, a value and a plus button.
class StepperRow extends StatelessWidget {
  const StepperRow({
    super.key,
    required this.label,
    required this.valueText,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final String valueText;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    final l = AppLocalizations.of(context);
    final style = IconButton.styleFrom(
      minimumSize: const Size(44, 44),
      side: BorderSide(color: p.line),
      foregroundColor: p.text,
    );
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: p.text,
              ),
            ),
          ),
          IconButton(
            onPressed: onMinus,
            tooltip: l.decrease,
            style: style,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 76,
            child: Text(
              valueText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: p.primary,
              ),
            ),
          ),
          IconButton(
            onPressed: onPlus,
            tooltip: l.increase,
            style: style,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.fraction, this.height = 10});

  final double fraction;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: p.line,
        borderRadius: BorderRadius.circular(999),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fraction.clamp(0.0, 1.0).toDouble(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: p.primary,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

/// A dashed straight line, vertical or horizontal.
class DashLine extends StatelessWidget {
  const DashLine({super.key, required this.color, this.vertical = false});

  final Color color;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashPainter(color, vertical),
      child: const SizedBox.expand(),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color, this.vertical);

  final Color color;
  final bool vertical;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    final length = vertical ? size.height : size.width;
    var pos = 0.0;
    while (pos < length) {
      final end = pos + 5 > length ? length : pos + 5;
      if (vertical) {
        canvas.drawLine(Offset(1, pos), Offset(1, end), paint);
      } else {
        canvas.drawLine(Offset(pos, 1), Offset(end, 1), paint);
      }
      pos += 9;
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.vertical != vertical;
}

/// A line of text with an action button, shown above the content.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.text,
    required this.action,
    required this.onTap,
  });

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    return Panel(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: p.text),
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              minimumSize: const Size(64, 44),
              foregroundColor: p.primary,
            ),
            child: Text(
              action,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
