import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/finance_controller.dart';

class ThemeModeSwitch extends StatelessWidget {
  const ThemeModeSwitch({super.key});

  Future<void> _change(BuildContext context, bool value) async {
    try {
      await context.read<FinanceController>().setDarkMode(value);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível salvar o tema.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = context.select<FinanceController, bool>(
      (finance) => finance.darkMode,
    );
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 8),
      child: Tooltip(
        message: darkMode ? 'Usar tema claro' : 'Usar tema escuro',
        child: Switch(
          value: darkMode,
          thumbIcon: WidgetStateProperty.resolveWith(
            (states) => Icon(
              states.contains(WidgetState.selected)
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
            ),
          ),
          onChanged: (value) => _change(context, value),
        ),
      ),
    );
  }
}
