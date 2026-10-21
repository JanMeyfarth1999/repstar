import 'package:repstar/services/rest_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:repstar/screens/training_screen.dart';

Future<void> main() async {
  // Ermöglicht den Zugriff auf Gerätefunktionen vor runApp().
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await RestNotificationService.instance.initialize();
  } catch (error) {
    // Die App bleibt auch bei einem Einrichtungsfehler startbar.
    debugPrint('Benachrichtigungen konnten nicht eingerichtet werden: $error');
  }

  runApp(const RepStarApp());
}

/// Startet RepStar und legt das gemeinsame Design fest.
class RepStarApp extends StatelessWidget {
  const RepStarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RepStar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF76FF03),
          brightness: Brightness.dark,
          primary: const Color(0xFF76FF03),
          surface: const Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
        ),
      ),
      home: const TrainingScreen(),
    );
  }
}
