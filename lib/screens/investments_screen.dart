// Tela adicional: visão demonstrativa de metas.
import 'package:flutter/material.dart';
import 'package:myfinance/widgets/finance_components.dart';

import '../app_theme.dart';
import '../widgets/theme_mode_switch.dart';

class InvestmentsScreen extends StatelessWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Investimentos'),
      actions: const [ThemeModeSwitch()],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Construa seu futuro',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Metas ilustrativas, sem recomendação financeira.',
          style: TextStyle(color: context.palette.muted),
        ),
        const SizedBox(height: 20),
        const AppCard(
          variant: AppCardVariant.promoDark,
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PATRIMÔNIO INVESTIDO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'R\$ 12.400,00',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 12),
              AppStatusChip(
                label: 'Exemplo',
                variant: AppStatusChipVariant.dark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Suas metas', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const _GoalCard(
          title: 'Reserva de emergência',
          amount: 'R\$ 8.400 / R\$ 15.000',
          progress: 0.56,
          icon: Icons.shield_outlined,
        ),
        const SizedBox(height: 12),
        const _GoalCard(
          title: 'Viagem',
          amount: 'R\$ 4.000 / R\$ 10.000',
          progress: 0.4,
          icon: Icons.flight_outlined,
        ),
        const SizedBox(height: 18),
        Text(
          'Estes números são fictícios. O app não indica produtos nem executa aplicações.',
          style: TextStyle(color: context.palette.muted),
        ),
      ],
    ),
  );
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.amount,
    required this.progress,
    required this.icon,
  });
  final String title;
  final String amount;
  final double progress;
  final IconData icon;

  @override
  Widget build(BuildContext context) => AppCard(
    variant: AppCardVariant.outline,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: context.palette.forest),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(amount),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress,
          color: context.palette.forest,
          backgroundColor: context.palette.mint,
          minHeight: 8,
        ),
      ],
    ),
  );
}
