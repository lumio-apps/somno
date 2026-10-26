import 'package:flutter/material.dart';

import '../data/update_service.dart';
import '../l10n/gen/app_localizations.dart';
import '../state/app_state.dart';
import '../ui/palette.dart';
import '../ui/widgets.dart';

/// Tells the user a newer version exists, downloads it inside the app and
/// opens the Android installer.
Future<void> showUpdateDialog(
  BuildContext context,
  AppState app,
  UpdateInfo info,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _UpdateDialog(app: app, info: info),
  );
}

enum _Phase { idle, working, permission, failed }

class _UpdateDialog extends StatefulWidget {
  const _UpdateDialog({required this.app, required this.info});

  final AppState app;
  final UpdateInfo info;

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  _Phase _phase = _Phase.idle;
  double _progress = 0;

  Future<void> _start() async {
    setState(() {
      _phase = _Phase.working;
      _progress = 0;
    });
    final result = await widget.app.installUpdate(widget.info, (value) {
      if (mounted) {
        setState(() => _progress = value);
      }
    });
    if (!mounted) {
      return;
    }
    switch (result) {
      case InstallResult.started:
      case InstallResult.browser:
        Navigator.of(context).pop();
      case InstallResult.permission:
        setState(() => _phase = _Phase.permission);
      case InstallResult.failed:
        setState(() => _phase = _Phase.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = SomnoPalette.of(context);
    final info = widget.info;
    final working = _phase == _Phase.working;
    final percent = (_progress * 100).clamp(0, 100).round();

    String actionLabel = l.downloadInstall;
    if (_phase == _Phase.permission) {
      actionLabel = l.install;
    } else if (_phase == _Phase.failed) {
      actionLabel = l.tryAgain;
    }

    return PopScope(
      canPop: !working,
      child: AlertDialog(
        title: Text(l.updateAvailableTitle(info.version)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (info.notes.isNotEmpty) ...[
                Text(info.notes, style: TextStyle(color: p.text)),
                const SizedBox(height: 12),
              ],
              Text(
                l.updateNote,
                style: TextStyle(fontSize: 13, height: 1.45, color: p.muted),
              ),
              if (working) ...[
                const SizedBox(height: 16),
                ProgressBar(fraction: _progress),
                const SizedBox(height: 8),
                Text(
                  l.downloadingPercent(percent),
                  style: TextStyle(fontSize: 13, color: p.text),
                ),
              ],
              if (_phase == _Phase.permission) ...[
                const SizedBox(height: 16),
                Text(
                  l.installPermission,
                  style: TextStyle(fontSize: 13, height: 1.45, color: p.accent),
                ),
              ],
              if (_phase == _Phase.failed) ...[
                const SizedBox(height: 16),
                Text(
                  l.updateDownloadFailed,
                  style: TextStyle(fontSize: 13, height: 1.45, color: p.alert),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: working
                ? null
                : () {
                    widget.app.hideUpdateBanner();
                    Navigator.of(context).pop();
                  },
            child: Text(l.later),
          ),
          TextButton(
            onPressed: working ? null : _start,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
