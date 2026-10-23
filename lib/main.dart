import 'package:flutter/material.dart';
import 'package:repstar/screens/training_screen.dart';
import 'package:repstar/services/rest_notification_service.dart';
import 'package:repstar/services/theme_service.dart';
import 'package:repstar/theme/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'RepStar',
          debugShowCheckedModeBanner: false,

          // Flutter wählt abhängig von themeMode das passende Design.
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeService.instance.mode,

          home: child,
        );
      },

      // Die Trainingsseite wird beim Umschalten nicht neu angelegt.
      child: const TrainingScreen(),
    );
  }
}
