// Tela adicional: documentos demonstrativos.
import 'package:flutter/material.dart';
import 'package:myfinance/widgets/finance_components.dart';

import '../app_theme.dart';
import '../demo_data.dart';
import '../widgets/theme_mode_switch.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Documentos'),
      actions: const [ThemeModeSwitch()],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Seu arquivo financeiro',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Exemplos de folha, horas e imposto.',
          style: TextStyle(color: context.palette.muted),
        ),
        const SizedBox(height: 20),
        AppCard(
          variant: AppCardVariant.outline,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final document in documents)
                AppListRow(
                  headline: document.title,
                  supportingText: document.subtitle,
                  leading: Icon(document.icon, color: context.palette.forest),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => _DocumentDetailScreen(document: document),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DocumentDetailScreen extends StatelessWidget {
  const _DocumentDetailScreen({required this.document});
  final FinanceDocument document;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Documento'),
      actions: const [ThemeModeSwitch()],
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
              Icon(document.icon, size: 48, color: context.palette.forest),
              const SizedBox(height: 18),
              Text(
                document.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                document.subtitle,
                style: TextStyle(color: context.palette.muted),
              ),
              const Divider(height: 32),
              Text(document.detail),
            ],
          ),
        ),
      ],
    ),
  );
}
