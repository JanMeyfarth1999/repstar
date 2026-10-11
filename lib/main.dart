import 'package:flutter/material.dart';

void main() {
  runApp(const RepStarApp());
}

/// Legt das Design fest und öffnet den Trainingsbereich.
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

/// Zeigt die gespeicherten Trainings an.
class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Training',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Training erstellen',
            icon: const Icon(Icons.add),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () {
              // Vorläufiger Hinweis, bis die Erstellung eingebaut ist.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hier erstellen wir gleich dein Training'),
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fitness_center, size: 64, color: Color(0xFF76Ff03)),
              SizedBox(height: 24),
              Text(
                'Dein Training. Deine Bühne.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Erstelle dein erstes Training über das + oben rechts',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
