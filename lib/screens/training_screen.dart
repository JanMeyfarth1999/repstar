import 'package:flutter/material.dart';
import 'package:repstar/models/training_plan.dart';
import 'package:repstar/screens/create_training_screen.dart';

/// Zeigt die während der laufenden App angelegten Trainings.
class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final List<TrainingPlan> _trainings = [];

  /// Öffnet die Erstellung und wartet auf das Ergebnis.
  Future<void> _createTraining() async {
    final training = await Navigation.of(context).push<TrainingPlan>(
      MaterialPageRoute<TrainingPlan>(
        builder: (context) => const CreateTrainingScreen(),
        
      ),
    );
    // Beim Zurückgehen ohne Speichern ist das Ergebnis null.
    // mounted prüft, ob dieser Bildschirm noch existiert.
    if (!mounted || training == null) {
      return;
    }

    setState(() {
      _trainings.add(training);
    });
  }
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
            onPressed: _createTraining,
          )
        ],
      ),
      body: _trainings.isEmpty
      ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center,
                size: 64,
                color: Color(0xFF76FF03),
              ),
              SizedBox()
            ],
          ),
          ),
      )

    )
  }
}