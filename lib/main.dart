import 'package:flutter/material.dart';
import 'package:repstar/screens/training_screen.dart';

void main() {
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