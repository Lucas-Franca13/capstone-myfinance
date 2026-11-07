// Integrante: Vitor de Oliveira Costa e Silva — favoritos e preferências locais.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myfinance/widgets/finance_components.dart';

import '../app_theme.dart';
import '../controllers/finance_controller.dart';
import '../controllers/market_controller.dart';
import '../money_format.dart';
import 'quote_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, this.onExploreMarket});
  final VoidCallback? onExploreMarket;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Future<void> _editBudget(FinanceController finance) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => _BudgetDialog(initialValue: finance.budget),
    );
    if (amount == null || !mounted) return;
    try {
      await finance.setBudget(amount);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível salvar o orçamento.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceController>();
    final market = context.watch<MarketController>();
    final selected = market.quotes
        .where((quote) => finance.favorites.contains(quote.code))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Preferências')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
        children: [
          Text('Seu espaço', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Organize seu plano e acompanhe as cotações que importam.',
            style: TextStyle(color: context.palette.muted),
          ),
          const SizedBox(height: 24),
          Text('Planejamento', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          AppCard(
            variant: AppCardVariant.outline,
            onTap: () => _editBudget(finance),
            child: Row(
              children: [
                Icon(Icons.tune, color: context.palette.forest),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Orçamento mensal',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        finance.budget == null
                            ? 'Toque para definir seu limite mensal'
                            : 'Limite de ${formatBrl(finance.budget!)} por mês',
                        style: TextStyle(
                          color: context.palette.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _PreferenceSwitch(
            title: 'Ocultar saldo',
            subtitle: 'Esconda os valores na tela inicial',
            value: finance.hideBalance,
            onChanged: finance.setHideBalance,
          ),
          const SizedBox(height: 12),
          _PreferenceSwitch(
            title: 'Tema escuro',
            subtitle: 'Cores escuras em todo o aplicativo',
            value: finance.darkMode,
            onChanged: finance.setDarkMode,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Moedas favoritas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (selected.isNotEmpty)
                AppStatusChip(label: '${selected.length} salvas'),
            ],
          ),
          const SizedBox(height: 12),
          if (market.status == MarketStatus.loading &&
              finance.favorites.isNotEmpty)
            const Center(child: CircularProgressIndicator())
          else if (market.status == MarketStatus.error &&
              finance.favorites.isNotEmpty)
            const AppCard(
              variant: AppCardVariant.outline,
              child: Text(
                'Favoritos salvos. Conecte-se para ver as cotações atuais.',
              ),
            )
          else if (selected.isEmpty)
            AppCard(
              variant: AppCardVariant.outline,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: context.palette.mint,
                    child: Icon(
                      Icons.favorite_border_rounded,
                      color: context.palette.forest,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sua lista está vazia',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Abra uma cotação e toque em “Favoritar moeda”.',
                    style: TextStyle(color: context.palette.muted),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed:
                        widget.onExploreMarket ??
                        () => Navigator.maybePop(context),
                    child: const Text('Explorar mercado'),
                  ),
                ],
              ),
            )
          else
            AppCard(
              variant: AppCardVariant.outline,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final quote in selected)
                    AppListRow(
                      headline: quote.code,
                      supportingText: quote.name,
                      leading: Icon(quote.icon, color: context.palette.forest),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => QuoteDetailScreen(
                              quote: quote,
                              onFavoritesRequested: () {},
                            ),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PreferenceSwitch extends StatelessWidget {
  const _PreferenceSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final Future<void> Function(bool value) onChanged;

  Future<void> _change(BuildContext context, bool value) async {
    try {
      await onChanged(value);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível salvar a preferência.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => AppCard(
    variant: AppCardVariant.outline,
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                subtitle,
                style: TextStyle(color: context.palette.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: (value) => _change(context, value),
        ),
      ],
    ),
  );
}

class _BudgetDialog extends StatefulWidget {
  const _BudgetDialog({this.initialValue});
  final double? initialValue;

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount = TextEditingController(
    text: widget.initialValue?.toStringAsFixed(2).replaceAll('.', ',') ?? '',
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  double? _parse(String? value) {
    final parsed = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    return parsed == null || !parsed.isFinite || parsed <= 0 ? null : parsed;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _parse(_amount.text));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Orçamento mensal'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _amount,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: 'Valor em R\$'),
          validator: (value) =>
              _parse(value) == null ? 'Informe um valor maior que zero' : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Salvar')),
      ],
    );
  }
}
