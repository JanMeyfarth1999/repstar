import 'package:flutter/material.dart';

/// Zentrale Farben und Komponentenregeln für beide Designs.
///
/// Normaler Text erbt die Theme-Farbe. Für Nebentext wird
/// colorScheme.onSurfaceVariant verwendet, niemals ein festes Weiß/Grau.
class AppTheme {
  AppTheme._();

  static final ThemeData light = _create(Brightness.light);
  static final ThemeData dark = _create(Brightness.dark);

  static ThemeData _create(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final background = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF6F7F8);
    final surface = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFFFFFF);
    final primary = isDark
        ? const Color(0xFF76FF03)
        : const Color(0xFF286B00);

    final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xFF76FF03),
      brightness: brightness,
    ).copyWith(
      primary: primary,
      onPrimary: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFFFFFFF),
      surface: surface,
      onSurface: isDark
          ? const Color(0xFFF2F2F2)
          : const Color(0xFF1B1D20),
      onSurfaceVariant: isDark
          ? const Color(0xFFC0C4CC)
          : const Color(0xFF505760),
      outline: isDark
          ? const Color(0xFF8A9099)
          : const Color(0xFF747B84),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: base.textTheme.apply(
        bodyColor: colors.onSurface,
        displayColor: colors.onSurface,
      ),
      iconTheme: IconThemeData(color: colors.onSurfaceVariant),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      listTileTheme: ListTileThemeData(
        textColor: colors.onSurface,
        iconColor: colors.onSurfaceVariant,
        subtitleTextStyle: base.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: colors.primaryContainer,
      ),
      inputDecorationTheme: InputDecorationTheme(
        // Hinweise, Einheiten und Beschriftungen bleiben in beiden Modi lesbar.
        hintStyle: TextStyle(color: colors.onSurfaceVariant),
        labelStyle: TextStyle(color: colors.onSurfaceVariant),
        helperStyle: TextStyle(color: colors.onSurfaceVariant),
        prefixStyle: TextStyle(color: colors.onSurfaceVariant),
        suffixStyle: TextStyle(color: colors.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStatePropertyAll<Color>(colors.onPrimary),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primary,
        selectionColor: colors.primary.withValues(alpha: 0.25),
        selectionHandleColor: colors.primary,
      ),
      extensions: <ThemeExtension<dynamic>>[
        RepStarColors(
          maintenance: isDark
              ? const Color(0xFFFFC857)
              : const Color(0xFF855600),
          // Der leere Ring soll sich sichtbar vom Hintergrund abheben.
          ringTrack: colors.outline,
        ),
      ],
    );
  }
}

/// Ergänzt Material-Farben um die Sonderfarben des Rangrings.
/// ThemeExtension ermöglicht auch weiche Übergänge beim Designwechsel.
@immutable
class RepStarColors extends ThemeExtension<RepStarColors> {
  final Color maintenance;
  final Color ringTrack;

  const RepStarColors({
    required this.maintenance,
    required this.ringTrack,
  });

  @override
  RepStarColors copyWith({Color? maintenance, Color? ringTrack}) {
    return RepStarColors(
      maintenance: maintenance ?? this.maintenance,
      ringTrack: ringTrack ?? this.ringTrack,
    );
  }

  @override
  RepStarColors lerp(covariant RepStarColors? other, double t) {
    if (other == null) {
      return this;
    }

    return RepStarColors(
      maintenance: Color.lerp(maintenance, other.maintenance, t)!,
      ringTrack: Color.lerp(ringTrack, other.ringTrack, t)!,
    );
  }
}
