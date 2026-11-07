// Tela adicional: detalhe da movimentação selecionada.
import 'package:flutter/material.dart';
import 'package:myfinance/widgets/finance_components.dart';

import '../app_theme.dart';
import '../demo_data.dart';
import '../widgets/entry_removal.dart';
import '../widgets/theme_mode_switch.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.entry});
  final FinanceEntry entry;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Detalhe'),
      actions: [
        IconButton(
          tooltip: 'Excluir transação',
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: () {
            removeEntryWithUndo(context, entry);
            Navigator.pop(context);
          },
        ),
        const ThemeModeSwitch(),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppCard(
          variant: AppCardVariant.outline,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: context.palette.mint,
                child: Icon(entry.icon, color: context.palette.forest),
              ),
              const SizedBox(height: 20),
              Text(
                entry.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                entry.amount,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: context.palette.forest,
                ),
              ),
              const Divider(height: 36),
              Text(entry.subtitle),
              const SizedBox(height: 8),
              Text(entry.date, style: TextStyle(color: context.palette.muted)),
              const SizedBox(height: 20),
              Text(entry.note),
            ],
          ),
        ),
      ],
    ),
  );
}
