// Integrante: João Victor Amaro de Araújo — formulário de nova transação.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myfinance/widgets/finance_components.dart';

import '../app_theme.dart';
import '../controllers/finance_controller.dart';
import '../demo_data.dart';
import 'market_screen.dart';
import 'favorites_screen.dart';
import '../widgets/pill_nav_bar.dart';
import '../widgets/theme_mode_switch.dart';

class NewExpenseScreen extends StatefulWidget {
  const NewExpenseScreen({super.key});

  @override
  State<NewExpenseScreen> createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _category = TextEditingController();
  String _type = 'Despesa';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _category.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Preencha este campo' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<FinanceController>().addEntry(
        FinanceEntry(
          title: _name.text.trim(),
          category: _category.text.trim(),
          value: double.parse(_amount.text.trim().replaceAll(',', '.')),
          isIncome: _type == 'Receita',
          createdAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transação salva com sucesso!')),
      );
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível salvar. Tente novamente.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Nova transação'),
      actions: const [ThemeModeSwitch()],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'O que aconteceu?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Registre uma entrada ou saída. Você poderá vê-la no extrato.',
          style: TextStyle(color: context.palette.muted),
        ),
        const SizedBox(height: 20),
        AppCard(
          variant: AppCardVariant.outline,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Ex.: mercado',
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tipo de transação',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'Despesa',
                        label: Text('Despesa'),
                        icon: Icon(Icons.north_east_rounded),
                      ),
                      ButtonSegment(
                        value: 'Receita',
                        label: Text('Receita'),
                        icon: Icon(Icons.south_west_rounded),
                      ),
                    ],
                    selected: {_type},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) =>
                        setState(() => _type = selection.first),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amount,
                  decoration: const InputDecoration(
                    labelText: 'Valor (R\$)',
                    hintText: 'Ex.: 120,50',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final amount = double.tryParse(
                      (value ?? '').replaceAll(',', '.'),
                    );
                    return amount == null || !amount.isFinite || amount <= 0
                        ? 'Informe um valor maior que zero'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _category,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    hintText: 'Ex.: alimentação',
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: _saving ? 'Salvando...' : 'Salvar transação',
                  fullWidth: true,
                  size: AppButtonSize.large,
                  onPressed: _saving ? null : _submit,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        AppButton(
          text: 'Ir para Mercado & Cotações',
          appearance: AppButtonAppearance.outline,
          fullWidth: true,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => MarketScreen(
                  onSelectTab: (tab) {
                    if (tab == PillTab.favorites) {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const FavoritesScreen(),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        Text(
          'Dados financeiros ficam salvos somente neste dispositivo.',
          style: TextStyle(color: context.palette.muted),
        ),
      ],
    ),
  );
}
