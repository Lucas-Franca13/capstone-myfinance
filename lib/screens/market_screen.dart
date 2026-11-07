// Integrante: Lucas Filipe França Nunes — lista de cotações.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myfinance/widgets/finance_components.dart';

import '../app_theme.dart';
import '../controllers/market_controller.dart';
import 'quote_detail_screen.dart';
import '../widgets/pill_nav_bar.dart';
import '../widgets/theme_mode_switch.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key, required this.onSelectTab});

  final ValueChanged<PillTab> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mercado'),
        actions: [
          IconButton(
            tooltip: 'Atualizar cotações',
            onPressed: market.status == MarketStatus.loading
                ? null
                : market.load,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Configurações e favoritos',
            icon: const Icon(Icons.favorite_outline),
            onPressed: () => onSelectTab(PillTab.favorites),
          ),
          const ThemeModeSwitch(),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cotações em reais',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Dólar, euro e bitcoin · dados da AwesomeAPI',
                  style: TextStyle(color: context.palette.muted),
                ),
              ],
            ),
          ),
          Expanded(
            child: market.status == MarketStatus.loading
                ? const Center(
                    child: CircularProgressIndicator(
                      key: Key('market-loading'),
                    ),
                  )
                : market.status == MarketStatus.error
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_outlined, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            market.message ?? 'Erro ao carregar cotações.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: market.load,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: market.load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                      itemCount: market.quotes.length + 1,
                      itemBuilder: (context, index) {
                        if (index == market.quotes.length) {
                          final updated = market.quotes.first.updatedAt;
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                            child: Text(
                              'Atualizado em ${updated.day.toString().padLeft(2, '0')}/${updated.month.toString().padLeft(2, '0')} às ${updated.hour.toString().padLeft(2, '0')}:${updated.minute.toString().padLeft(2, '0')} · puxe para atualizar',
                              style: TextStyle(
                                color: context.palette.muted,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        final quote = market.quotes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            variant: AppCardVariant.outline,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => QuoteDetailScreen(
                                  quote: quote,
                                  onFavoritesRequested: () =>
                                      onSelectTab(PillTab.favorites),
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 17,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: context.palette.mint,
                                  child: Icon(
                                    quote.icon,
                                    color: context.palette.forest,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        quote.code,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        quote.name,
                                        style: TextStyle(
                                          color: context.palette.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 144,
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          quote.price,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: quote.isNegative
                                            ? context.palette.softRed
                                            : quote.isNeutral
                                            ? context.palette.canvas
                                            : context.palette.mint,
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          quote.change,
                                          style: TextStyle(
                                            color: quote.isNegative
                                                ? context.palette.red
                                                : quote.isNeutral
                                                ? context.palette.muted
                                                : context.palette.onMint,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
