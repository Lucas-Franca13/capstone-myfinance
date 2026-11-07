import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/finance_controller.dart';
import '../demo_data.dart';

Future<void> removeEntryWithUndo(
  BuildContext context,
  FinanceEntry entry,
) async {
  final finance = context.read<FinanceController>();
  final messenger = ScaffoldMessenger.of(context);
  final int index;
  try {
    index = await finance.removeEntry(entry);
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Não foi possível excluir a transação.')),
    );
    return;
  }
  if (index < 0) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('“${entry.title}” foi excluída.'),
        persist: false,
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () async {
            try {
              await finance.restoreEntry(entry, index);
            } catch (_) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Não foi possível restaurar a transação.'),
                ),
              );
            }
          },
        ),
      ),
    );
}
