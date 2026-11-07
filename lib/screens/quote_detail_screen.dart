// Integrante: Lucas Henrique Albergaria — detalhe da moeda/ativo selecionado.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myfinance/widgets/finance_components.dart';

import '../app_theme.dart';
import '../controllers/finance_controller.dart';
import '../market_data.dart';
import '../services/quote_repository.dart';
import '../widgets/theme_mode_switch.dart';

class QuoteDetailScreen extends StatefulWidget {
  const QuoteDetailScreen({
    super.key,
    required this.quote,
    required this.onFavoritesRequested,
  });
  final MarketQuote quote;
  final VoidCallback onFavoritesRequested;

  @override
  State<QuoteDetailScreen> createState() => _QuoteDetailScreenState();
}

class _QuoteDetailScreenState extends State<QuoteDetailScreen> {
  Future<void> _openDocumentation() async {
    bool opened;
    try {
      opened = await launchUrl(
        QuoteRepository.documentation,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.quote;
    final favorite = context.watch<FinanceController>().favorites.contains(
      quote.code,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhe · ${quote.code}'),
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
                CircleAvatar(
                  radius: 30,
                  backgroundColor: context.palette.mint,
                  child: Icon(
                    quote.icon,
                    color: context.palette.forest,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  quote.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  quote.price,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: context.palette.forest,
                  ),
                ),
                const SizedBox(height: 10),
                AppStatusChip(
                  label: 'Variação: ${quote.change}',
                  variant: AppStatusChipVariant.tint,
                ),
                const Divider(height: 36),
                Text(quote.description),
                const SizedBox(height: 8),
                Text(
                  'Atualizado em ${quote.updatedAt.day.toString().padLeft(2, '0')}/${quote.updatedAt.month.toString().padLeft(2, '0')} às ${quote.updatedAt.hour.toString().padLeft(2, '0')}:${quote.updatedAt.minute.toString().padLeft(2, '0')}.',
                  style: TextStyle(color: context.palette.muted),
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: favorite ? 'Remover dos favoritos' : 'Favoritar moeda',
                  icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
                  fullWidth: true,
                  onPressed: () async {
                    try {
                      await context.read<FinanceController>().toggleFavorite(
                        quote.code,
                      );
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Não foi possível salvar o favorito.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Configurações e favoritos',
                  appearance: AppButtonAppearance.outline,
                  fullWidth: true,
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onFavoritesRequested();
                  },
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton.icon(
                    onPressed: _openDocumentation,
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Documentação da AwesomeAPI'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
