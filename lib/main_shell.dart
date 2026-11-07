import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/market_screen.dart';
import 'screens/transactions_screen.dart';
import 'widgets/pill_nav_bar.dart';

/// Mantém as quatro áreas montadas e a barra em pílula fixa sobre o conteúdo.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  PillTab _selected = PillTab.home;

  void _selectTab(PillTab tab) {
    if (_selected == tab) return;
    setState(() => _selected = tab);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onSelectTab: _selectTab),
      MarketScreen(onSelectTab: _selectTab),
      const TransactionsScreen(),
      FavoritesScreen(onExploreMarket: () => _selectTab(PillTab.market)),
    ];
    return Scaffold(
      backgroundColor: context.palette.canvas,
      body: Stack(
        children: [
          for (var index = 0; index < pages.length; index++)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: index != _selected.index,
                child: ExcludeSemantics(
                  excluding: index != _selected.index,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    offset: index == _selected.index
                        ? Offset.zero
                        : Offset(index < _selected.index ? -0.07 : 0.07, 0),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      opacity: index == _selected.index ? 1 : 0,
                      child: TickerMode(
                        enabled: index == _selected.index,
                        child: pages[index],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: PillNavBar(selected: _selected, onSelect: _selectTab),
          ),
        ],
      ),
    );
  }
}
