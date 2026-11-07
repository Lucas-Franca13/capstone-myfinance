// Integrante: Bernardo Santos Magalhaes — tela inicial.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../controllers/finance_controller.dart';
import '../money_format.dart';
import '../widgets/finance_components.dart';
import '../widgets/pill_nav_bar.dart';
import '../widgets/theme_mode_switch.dart';
import 'documents_screen.dart';
import 'investments_screen.dart';
import 'new_expense_screen.dart';
import 'profile_screen.dart';
import 'transaction_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSelectTab});
  final ValueChanged<PillTab> onSelectTab;

  Future<void> _open(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceController>();
    final now = DateTime.now();
    final thisMonth = finance.entries.where(
      (entry) =>
          entry.createdAt.year == now.year &&
          entry.createdAt.month == now.month,
    );
    final income = thisMonth
        .where((entry) => entry.isIncome)
        .fold<double>(0, (sum, entry) => sum + entry.value);
    final expense = thisMonth
        .where((entry) => !entry.isIncome)
        .fold<double>(0, (sum, entry) => sum + entry.value);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'myfinance',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1),
        ),
        actions: [
          IconButton(
            tooltip: 'Abrir perfil',
            onPressed: () => _open(context, const ProfileScreen()),
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const ThemeModeSwitch(),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
          children: [
            Text(
              'Seu dinheiro, com clareza.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Registre, acompanhe e planeje em um só lugar.',
              style: TextStyle(color: context.palette.muted),
            ),
            const SizedBox(height: 22),
            AppCard(
              variant: AppCardVariant.promoDark,
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'SALDO REGISTRADO',
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: finance.hideBalance
                            ? 'Mostrar saldo'
                            : 'Ocultar saldo',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          finance.hideBalance
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white,
                        ),
                        onPressed: finance.loading
                            ? null
                            : () async {
                                try {
                                  await finance.setHideBalance(
                                    !finance.hideBalance,
                                  );
                                } catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Não foi possível salvar a preferência.',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      finance.loading
                          ? 'Carregando...'
                          : finance.hideBalance
                          ? '••••••••'
                          : formatBrl(finance.balance),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Receitas menos despesas que você registrou',
                    style: TextStyle(color: Color(0xFFD0E2D7), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              variant: AppCardVariant.outline,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MonthlyMetric(
                          label: 'Entradas no mês',
                          value: finance.hideBalance
                              ? '••••'
                              : formatBrl(income),
                          icon: Icons.south_west_rounded,
                          color: context.palette.forest,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MonthlyMetric(
                          label: 'Saídas no mês',
                          value: finance.hideBalance
                              ? '••••'
                              : formatBrl(expense),
                          icon: Icons.north_east_rounded,
                          color: context.palette.red,
                        ),
                      ),
                    ],
                  ),
                  if (finance.budget != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Orçamento usado neste mês',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${((expense / finance.budget!) * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (expense / finance.budget!).clamp(0, 1),
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(99),
                      color: expense > finance.budget!
                          ? context.palette.red
                          : context.palette.forest,
                      backgroundColor: context.palette.mint,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: finance.loading
                        ? null
                        : () => _open(context, const NewExpenseScreen()),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Nova transação'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => onSelectTab(PillTab.transactions),
                  child: const Text('Ver extrato'),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Últimas movimentações',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () => onSelectTab(PillTab.transactions),
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppCard(
              variant: AppCardVariant.outline,
              padding: EdgeInsets.zero,
              child: finance.entries.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            color: context.palette.forest,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Seu extrato começa aqui. Registre uma receita ou despesa.',
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        for (final entry in finance.entries.take(3))
                          AppListRow(
                            headline: entry.title,
                            supportingText: '${entry.date} · ${entry.category}',
                            leading: Icon(
                              entry.icon,
                              color: entry.isIncome
                                  ? context.palette.forest
                                  : context.palette.red,
                            ),
                            trailingSupportingText: entry.amount,
                            onTap: () => _open(
                              context,
                              TransactionDetailScreen(entry: entry),
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 26),
            Text('Explorar', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ExploreTile(
                    icon: Icons.folder_outlined,
                    label: 'Documentos',
                    onTap: () => _open(context, const DocumentsScreen()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ExploreTile(
                    icon: Icons.trending_up_rounded,
                    label: 'Investimentos',
                    onTap: () => _open(context, const InvestmentsScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyMetric extends StatelessWidget {
  const _MonthlyMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: context.palette.muted),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: context.palette.ink,
          ),
        ),
      ),
    ],
  );
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => AppCard(
    variant: AppCardVariant.outline,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    onTap: onTap,
    child: Row(
      children: [
        Icon(icon, size: 20, color: context.palette.forest),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        Icon(Icons.chevron_right, size: 17, color: context.palette.muted),
      ],
    ),
  );
}
