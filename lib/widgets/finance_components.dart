import 'package:flutter/material.dart';

import '../app_theme.dart';

enum AppCardVariant { elevated, outline, promoDark }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = variant == AppCardVariant.promoDark;
    return Material(
      color: dark ? context.palette.inverse : context.palette.paper,
      elevation: variant == AppCardVariant.elevated ? 3 : 0,
      shadowColor: context.palette.shadow.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: variant == AppCardVariant.outline
            ? BorderSide(color: context.palette.line)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: dark ? Colors.white : context.palette.ink),
            child: IconTheme.merge(
              data: IconThemeData(
                color: dark ? Colors.white : context.palette.ink,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    required this.headline,
    this.supportingText,
    this.leading,
    this.trailing,
    this.trailingSupportingText,
    this.onTap,
  });

  final String headline;
  final String? supportingText;
  final Widget? leading;
  final Widget? trailing;
  final String? trailingSupportingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 68),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (leading != null) ...[
              IconTheme(
                data: IconThemeData(color: context.palette.forest, size: 23),
                child: leading!,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (supportingText != null)
                    Text(
                      supportingText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.palette.muted,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (trailingSupportingText != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 108),
                child: Text(
                  trailingSupportingText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            if (trailing != null) ...[const SizedBox(width: 4), trailing!],
          ],
        ),
      ),
    ),
  );
}

enum AppButtonAppearance { solid, outline }

enum AppButtonSize { medium, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.icon,
    this.appearance = AppButtonAppearance.solid,
    this.size = AppButtonSize.medium,
    this.fullWidth = false,
    this.onPressed,
  });

  final String text;
  final Widget? icon;
  final AppButtonAppearance appearance;
  final AppButtonSize size;
  final bool fullWidth;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          IconTheme(data: const IconThemeData(size: 18), child: icon!),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(0, size == AppButtonSize.large ? 48 : 42),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: appearance == AppButtonAppearance.outline
          ? OutlinedButton(onPressed: onPressed, style: style, child: child)
          : FilledButton(onPressed: onPressed, style: style, child: child),
    );
  }
}

enum AppStatusChipVariant { tint, dark }

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    this.variant = AppStatusChipVariant.tint,
  });

  final String label;
  final AppStatusChipVariant variant;

  @override
  Widget build(BuildContext context) {
    final dark = variant == AppStatusChipVariant.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? context.palette.forest : context.palette.mint,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: dark ? context.palette.onForest : context.palette.onMint,
          ),
        ),
      ),
    );
  }
}
