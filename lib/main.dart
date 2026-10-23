import 'package:flutter/material.dart';
import 'package:repstar/screens/training_screen.dart';
import 'package:repstar/services/rest_notification_service.dart';
import 'package:repstar/services/theme_service.dart';

Future<void> main() async {
  // Ermöglicht den Zugriff auf Gerätefunktionen vor runApp().
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await ThemeService.instance.load();
  } catch (error) {
    // Ohne lesbare Einstellung gilt die Systemeinstellung.
    debugPrint('Design konnte nicht geladen werden: $error');
  }

  try {
    await RestNotificationService.instance.initialize();
  } catch (error) {
    // Die App bleibt auch bei einem Einrichtungsfehler startbar.
    debugPrint('Benachrichtigungen konnten nicht eingerichtet werden: $error');
  }

  runApp(const RepStarApp());
}

/// Startet RepStar und stellt das helle und dunkle Design bereit.
class RepStarApp extends StatelessWidget {
  const RepStarApp({super.key});

  /// Gemeinsamer Aufbau für beide Designs.
  ThemeData _createTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF6F7F8);

    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // Das dunklere Grün ist auf hellen Flächen besser lesbar.
    final primaryColor = isDark
        ? const Color(0xFF76FF03)
        : const Color(0xFF286B00);

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF76FF03),
          brightness: brightness,
        ).copyWith(
          primary: primaryColor,
          onPrimary: isDark ? Colors.black : Colors.white,
          surface: surfaceColor,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: colorScheme.primaryContainer,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'RepStar',
          debugShowCheckedModeBanner: false,

          // Flutter wählt abhängig von themeMode das passende Design.
          theme: _createTheme(Brightness.light),
          darkTheme: _createTheme(Brightness.dark),
          themeMode: ThemeService.instance.mode,

          home: child,
        );
      },

      // Die Trainingsseite wird beim Umschalten nicht neu angelegt.
      child: const TrainingScreen(),
    );
  }
}
