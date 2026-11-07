// Tela adicional: extrato das movimentações.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../controllers/finance_controller.dart';
import '../demo_data.dart';
import '../widgets/entry_removal.dart';
import '../widgets/finance_components.dart';
import '../widgets/theme_mode_switch.dart';
import 'new_expense_screen.dart';
import 'transaction_detail_screen.dart';

enum _EntryFilter {
  all('Todas', ''),
  income('Receitas', 'Nenhuma receita registrada.'),
  expense('Despesas', 'Nenhuma despesa registrada.');

  const _EntryFilter(this.label, this.emptyMessage);

  final String label;
  final String emptyMessage;

  bool matches(FinanceEntry entry) => switch (this) {
    _EntryFilter.all => true,
    _EntryFilter.income => entry.isIncome,
    _EntryFilter.expense => !entry.isIncome,
  };
}

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  _EntryFilter _filter = _EntryFilter.all;

  void _newEntry() => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => const NewExpenseScreen()),
  );

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceController>();
    final entries = finance.entries;
    final visible = entries.where(_filter.matches).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extrato'),
        actions: [
          IconButton(
            tooltip: 'Nova transação',
            onPressed: finance.loading ? null : _newEntry,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          const ThemeModeSwitch(),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suas movimentações',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entries.isEmpty
                          ? 'Seu histórico começa com o primeiro registro.'
                          : '${entries.length} ${entries.length == 1 ? 'lançamento salvo' : 'lançamentos salvos'} neste dispositivo · deslize para excluir',
                      style: TextStyle(color: context.palette.muted),
                    ),
                    if (entries.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final filter in _EntryFilter.values)
                            ChoiceChip(
                              label: Text(filter.label),
                              selected: _filter == filter,
                              onSelected: (_) =>
                                  setState(() => _filter = filter),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (entries.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: AppCard(
                    variant: AppCardVariant.outline,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: context.palette.mint,
                          child: Icon(
                            Icons.receipt_long_outlined,
                            color: context.palette.forest,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ainda não há transações',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Adicione uma receita ou despesa para acompanhar seu dinheiro.',
                          style: TextStyle(color: context.palette.muted),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: finance.loading ? null : _newEntry,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Nova transação'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (visible.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: AppCard(
                    variant: AppCardVariant.outline,
                    child: Text(
                      _filter.emptyMessage,
                      style: TextStyle(color: context.palette.muted),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.builder(
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final entry = visible[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Dismissible(
                        key: ObjectKey(entry),
                        direction: DismissDirection.endToStart,
                        background: const _DeleteBackground(),
                        onDismissed: (_) => removeEntryWithUndo(context, entry),
                        child: AppCard(
                          variant: AppCardVariant.outline,
                          padding: EdgeInsets.zero,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  TransactionDetailScreen(entry: entry),
                            ),
                          ),
                          child: AppListRow(
                            headline: entry.title,
                            supportingText: '${entry.date} · ${entry.category}',
                            leading: Icon(
                              entry.icon,
                              color: entry.isIncome
                                  ? context.palette.forest
                                  : context.palette.red,
                            ),
                            trailingSupportingText: entry.amount,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 130)),
          ],
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.palette.softRed,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Excluir',
              style: TextStyle(
                color: context.palette.red,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.delete_outline_rounded, color: context.palette.red),
          ],
        ),
      ),
    ),
  );
}
