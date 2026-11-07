import 'package:flutter/material.dart';

import '../app_theme.dart';

enum PillTab {
  home('Início', Icons.space_dashboard_rounded),
  market('Mercado', Icons.currency_exchange_rounded),
  transactions('Extrato', Icons.receipt_long_rounded),
  favorites('Favoritos', Icons.favorite_rounded);

  const PillTab(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Instância única que permanece sobre o conteúdo enquanto a aba muda.
class PillNavBar extends StatelessWidget {
  const PillNavBar({super.key, required this.selected, required this.onSelect});

  final PillTab selected;
  final ValueChanged<PillTab> onSelect;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    minimum: const EdgeInsets.fromLTRB(16, 4, 16, 10),
    child: Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Material(
          color: context.palette.inverse,
          elevation: 14,
          shadowColor: context.palette.shadow.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: SizedBox(
              height: 58,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final slotWidth =
                      constraints.maxWidth / PillTab.values.length;
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        left: slotWidth * selected.index,
                        top: 0,
                        bottom: 0,
                        width: slotWidth,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.palette.inverseAccent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (final tab in PillTab.values)
                            Expanded(
                              child: Semantics(
                                button: true,
                                selected: tab == selected,
                                label: tab.label,
                                child: InkWell(
                                  onTap: () => onSelect(tab),
                                  borderRadius: BorderRadius.circular(999),
                                  child: SizedBox(
                                    height: 58,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          tab.icon,
                                          size: 21,
                                          color: tab == selected
                                              ? context.palette.inverse
                                              : Colors.white,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          tab.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: tab == selected
                                                ? context.palette.inverse
                                                : Colors.white,
                                            fontSize: 10.5,
                                            fontWeight: tab == selected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
