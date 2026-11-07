// Tela adicional: perfil demonstrativo.
import 'package:flutter/material.dart';
import 'package:myfinance/widgets/finance_components.dart';

import '../app_theme.dart';
import '../widgets/theme_mode_switch.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Perfil'),
      actions: const [ThemeModeSwitch()],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: context.palette.mint,
          child: Icon(
            Icons.person_outline,
            size: 36,
            color: context.palette.forest,
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            'Meu perfil',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 5),
        Center(
          child: Text(
            'Perfil demonstrativo',
            style: TextStyle(color: context.palette.muted),
          ),
        ),
        const SizedBox(height: 24),
        const AppCard(
          variant: AppCardVariant.outline,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppListRow(
                headline: 'Objetivo',
                supportingText: 'Organizar finanças e investir melhor',
                leading: Icon(Icons.flag_outlined),
              ),
              AppListRow(
                headline: 'Privacidade',
                supportingText:
                    'Dados financeiros salvos apenas neste aparelho',
                leading: Icon(Icons.lock_outline),
              ),
              AppListRow(
                headline: 'Versão',
                supportingText: 'Capstone A3',
                leading: Icon(Icons.info_outline),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
