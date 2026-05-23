import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

Future<bool> showConfirmDeleteDialog({
  required BuildContext context,
  required String title,
}) async {
  final l10n = AppLocalizations.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(l10n.t('hide_completed_confirm')),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.t('cancel_action')),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.t('hide_action')),
        ),
      ],
    ),
  );

  return confirmed == true;
}
