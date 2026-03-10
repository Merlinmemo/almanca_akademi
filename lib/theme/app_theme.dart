import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0E2A47);
  static const Color accent = Color(0xFFD4AF37);
  static const Color accentDeep = Color(0xFF8E6C17);
  static const Color accentLight = Color(0xFFFFE27A);
  static const Color success = Color(0xFF2ECC71);
  static const Color danger = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);

  static const Color backgroundDark = Color(0xFF0B1E33);
  static const Color cardDark = Color(0xFF132B45);
  static const Color surfaceAlt = Color(0xFF173553);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFD6E1EC);
  static const Color lineSoft = Color(0x80FFFFFF);
  static const Color disabledFill = Color(0x1FFFFFFF);
  static const Color disabledStroke = Color(0x33FFFFFF);
  static const Color disabledText = Color(0x99FFFFFF);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundDark,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: cardDark,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textPrimary,
      error: danger,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textPrimary),
      bodySmall: TextStyle(color: textSecondary),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
      titleSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
      labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
      labelMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
      labelSmall: TextStyle(color: textSecondary, fontWeight: FontWeight.w700),
    ),
    iconTheme: const IconThemeData(color: textPrimary),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w900,
      ),
    ),
    cardTheme: const CardThemeData(
      color: cardDark,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return accent.withOpacity(0.45);
          return accent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return Colors.black.withOpacity(0.55);
          return Colors.black;
        }),
        iconColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return Colors.black.withOpacity(0.55);
          return Colors.black;
        }),
        overlayColor: WidgetStateProperty.all(Colors.black.withOpacity(0.06)),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return disabledFill;
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return disabledText;
          return textPrimary;
        }),
        iconColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return disabledText;
          return textPrimary;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const BorderSide(color: disabledStroke, width: 1.4);
          }
          return const BorderSide(color: lineSoft, width: 1.8);
        }),
        overlayColor: WidgetStateProperty.all(accent.withOpacity(0.08)),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return disabledText;
          return accent;
        }),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
        ),
        overlayColor: WidgetStateProperty.all(accent.withOpacity(0.10)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceAlt,
      selectedColor: accent.withOpacity(0.18),
      disabledColor: disabledFill,
      labelStyle: const TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
      secondaryLabelStyle: const TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
      side: const BorderSide(color: lineSoft),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      brightness: Brightness.dark,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return accent;
        return Colors.white70;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return accent.withOpacity(0.45);
        return Colors.white24;
      }),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: cardDark,
      titleTextStyle: TextStyle(color: textPrimary, fontWeight: FontWeight.w900, fontSize: 22),
      contentTextStyle: TextStyle(color: textPrimary, fontSize: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accent,
      linearTrackColor: Colors.white24,
    ),
    dividerColor: Colors.white12,
  );
}
