import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../ui/format.dart';
import '../ui/palette.dart';
import '../ui/widgets.dart';

/// Add a new sleep session, or edit / delete an existing one.
class EditScreen extends StatefulWidget {
  const EditScreen({super.key, this.session});

  final SleepSession? session;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late DateTime _start;
  late DateTime _end;
  SaveResult _result = SaveResult.ok;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    if (s != null) {
      _start = s.start;
      _end = s.end;
    } else {
      final now = DateTime.now();
      var end = DateTime(now.year, now.month, now.day, 7);
      if (end.isAfter(now)) {
        end = DateTime(now.year, now.month, now.day - 1, 7);
      }
      _end = end;
      _start = end.subtract(const Duration(hours: 8));
    }
  }

  Future<DateTime?> _pick(DateTime initial) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 5);
    var initialDate = initial;
    if (initialDate.isAfter(now)) {
      initialDate = now;
    }
    if (initialDate.isBefore(first)) {
      initialDate = first;
    }
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: first,
      lastDate: now,
    );
    if (date == null || !mounted) {
      return null;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickStart() async {
    final picked = await _pick(_start);
    if (picked != null) {
      setState(() {
        _start = picked;
        _result = SaveResult.ok;
      });
    }
  }

  Future<void> _pickEnd() async {
    final picked = await _pick(_end);
    if (picked != null) {
      setState(() {
        _end = picked;
        _result = SaveResult.ok;
      });
    }
  }

  Future<void> _save() async {
    final app = AppScope.of(context);
    final result = await app.saveSession(
      existing: widget.session,
      start: _start,
      end: _end,
    );
    if (!mounted) {
      return;
    }
    if (result == SaveResult.ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _result = result);
    }
  }

  Future<void> _delete() async {
    final session = widget.session;
    if (session == null) {
      return;
    }
    final app = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l.deleteConfirmTitle),
          content: Text(l.deleteConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l.delete),
            ),
          ],
        );
      },
    );
    if (ok != true) {
      return;
    }
    await app.deleteSession(session);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  String? _errorText(AppLocalizations l) {
    switch (_result) {
      case SaveResult.ok:
        return null;
      case SaveResult.endBeforeStart:
        return l.errEndBeforeStart;
      case SaveResult.tooLong:
        return l.errTooLong;
      case SaveResult.overlap:
        return l.errOverlap;
      case SaveResult.future:
        return l.errFuture;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = SomnoPalette.of(context);
    final minutes = ((_end.millisecondsSinceEpoch -
                _start.millisecondsSinceEpoch) /
            60000)
        .round();
    final error = _errorText(l);
    final editing = widget.session != null;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 24, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    foregroundColor: p.text,
                  ),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 4),
                Text(
                  editing ? l.editSleep : l.addSleep,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.totalSleep,
                          style: TextStyle(fontSize: 13, color: p.muted),
                        ),
                        Text(
                          durationText(l, minutes),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: minutes > 0 ? p.text : p.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PickerField(
                    label: l.fellAsleep,
                    value:
                        '${dateShort(context, _start)} · ${timeText(context, _start)}',
                    onTap: _pickStart,
                  ),
                  const SizedBox(height: 12),
                  _PickerField(
                    label: l.wokeUp,
                    value:
                        '${dateShort(context, _end)} · ${timeText(context, _end)}',
                    onTap: _pickEnd,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: p.alert,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    l.editNote,
                    style: TextStyle(fontSize: 13, height: 1.45, color: p.muted),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(label: l.save, onTap: _save),
                  if (editing) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _delete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: p.alert,
                          side: BorderSide(color: p.alert),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          l.deleteSession,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = SomnoPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: p.muted,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: p.panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: p.line),
          ),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onTap: onTap,
            child: Container(
              height: 56,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: p.text,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
