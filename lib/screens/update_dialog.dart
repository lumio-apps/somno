import 'package:flutter/material.dart';

import '../data/update_service.dart';
import '../l10n/gen/app_localizations.dart';
import '../state/app_state.dart';
import '../ui/palette.dart';

/// Tells the user a newer version exists and opens its download.
Future<void> showUpdateDialog(
  BuildContext context,
  AppState app,
  UpdateInfo info,
) {
  final l = AppLocalizations.of(context);
  final p = SomnoPalette.of(context);
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              app.hideUpdateBanner();
              Navigator.of(dialogContext).pop();
            },
            child: Text(l.later),
          ),
          TextButton(
            onPressed: () {
              app.openUrl(info.downloadUrl);
              Navigator.of(dialogContext).pop();
            },
            child: Text(l.download),
          ),
        ],
      );
    },
  );
}
