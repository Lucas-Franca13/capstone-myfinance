import 'package:flutter/material.dart';

@immutable
class FinancePalette extends ThemeExtension<FinancePalette> {
  const FinancePalette({
    required this.canvas,
    required this.paper,
    required this.ink,
    required this.muted,
    required this.forest,
    required this.onForest,
    required this.mint,
    required this.onMint,
    required this.line,
    required this.red,
    required this.softRed,
    required this.inverse,
    required this.inverseAccent,
    required this.shadow,
  });

  static const light = FinancePalette(
    canvas: Color(0xFFF5F2EA),
    paper: Color(0xFFFFFEFA),
    ink: Color(0xFF182821),
    muted: Color(0xFF607068),
    forest: Color(0xFF236348),
    onForest: Colors.white,
    mint: Color(0xFFD9EBDD),
    onMint: Color(0xFF174A35),
    line: Color(0xFFDDE3D9),
    red: Color(0xFFAA4B45),
    softRed: Color(0xFFF7E9E5),
    inverse: Color(0xFF182821),
    inverseAccent: Color(0xFFD9EBDD),
    shadow: Color(0xFF182821),
  );

  static const dark = FinancePalette(
    canvas: Color(0xFF0F1512),
    paper: Color(0xFF18201C),
    ink: Color(0xFFE6EEE9),
    muted: Color(0xFF9AABA2),
    forest: Color(0xFF7CCFA2),
    onForest: Color(0xFF0F1512),
    mint: Color(0xFF1E3A2C),
    onMint: Color(0xFFB9E8CD),
    line: Color(0xFF2B3731),
    red: Color(0xFFEE8A80),
    softRed: Color(0xFF3D2421),
    inverse: Color(0xFF243229),
    inverseAccent: Color(0xFFA9DEC0),
    shadow: Colors.black,
  );

  final Color canvas;
  final Color paper;
  final Color ink;
  final Color muted;
  final Color forest;
  final Color onForest;
  final Color mint;
  final Color onMint;
  final Color line;
  final Color red;
  final Color softRed;
  final Color inverse;
  final Color inverseAccent;
  final Color shadow;

  @override
  FinancePalette copyWith({
    Color? canvas,
    Color? paper,
    Color? ink,
    Color? muted,
    Color? forest,
    Color? onForest,
    Color? mint,
    Color? onMint,
    Color? line,
    Color? red,
    Color? softRed,
    Color? inverse,
    Color? inverseAccent,
    Color? shadow,
  }) => FinancePalette(
    canvas: canvas ?? this.canvas,
    paper: paper ?? this.paper,
    ink: ink ?? this.ink,
    muted: muted ?? this.muted,
    forest: forest ?? this.forest,
    onForest: onForest ?? this.onForest,
    mint: mint ?? this.mint,
    onMint: onMint ?? this.onMint,
    line: line ?? this.line,
    red: red ?? this.red,
    softRed: softRed ?? this.softRed,
    inverse: inverse ?? this.inverse,
    inverseAccent: inverseAccent ?? this.inverseAccent,
    shadow: shadow ?? this.shadow,
  );

  @override
  FinancePalette lerp(FinancePalette? other, double t) {
    if (other == null) return this;
    return FinancePalette(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      forest: Color.lerp(forest, other.forest, t)!,
      onForest: Color.lerp(onForest, other.onForest, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      onMint: Color.lerp(onMint, other.onMint, t)!,
      line: Color.lerp(line, other.line, t)!,
      red: Color.lerp(red, other.red, t)!,
      softRed: Color.lerp(softRed, other.softRed, t)!,
      inverse: Color.lerp(inverse, other.inverse, t)!,
      inverseAccent: Color.lerp(inverseAccent, other.inverseAccent, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension FinancePaletteContext on BuildContext {
  FinancePalette get palette => Theme.of(this).extension<FinancePalette>()!;
}

ThemeData buildFinanceTheme(Brightness brightness) {
  final palette = brightness == Brightness.dark
      ? FinancePalette.dark
      : FinancePalette.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: FinancePalette.light.forest,
    surface: palette.paper,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    extensions: [palette],
    scaffoldBackgroundColor: palette.canvas,
    appBarTheme: AppBarTheme(
      backgroundColor: palette.canvas,
      foregroundColor: palette.ink,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: palette.ink,
        fontSize: 19,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: palette.ink,
        height: 1.1,
        letterSpacing: -0.8,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: palette.ink,
        letterSpacing: -0.4,
      ),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, color: palette.ink),
      bodyMedium: TextStyle(color: palette.ink),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.paper,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: palette.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: palette.forest, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.forest,
        foregroundColor: palette.onForest,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.forest,
        side: BorderSide(color: palette.forest),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
