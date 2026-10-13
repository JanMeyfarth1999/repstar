import 'package:flutter/material.dart';
import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_session.dart';
import 'package:repstar/screens/active_training_screen.dart';
import 'package:repstar/screens/create_training_screen.dart';

/// Zeigt Trainingsvorlagen und startet neue Trainingseinheiten.
class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final List<TrainingPlan> _trainings = [];

  /// Verlauf je Training; bisher nur während der laufenden App.
  final Map<String, List<TrainingSession>> _sessionsByTraining = {};

  Future<void> _createTraining() async {
    final training = await Navigator.of(context).push<TrainingPlan>(
      MaterialPageRoute<TrainingPlan>(
        builder: (context) => const CreateTrainingScreen(),
      ),
    );

    if (!mounted || training == null) {
      return;
    }

    setState(() {
      _trainings.add(training);
    });
  }

  /// Startet eine neue Einheit mit den Werten vom letzten Mal.
  Future<void> _startTraining(TrainingPlan training) async {
    final history = _sessionsByTraining[training.id];
    final previousSession =
        history == null || history.isEmpty ? null : history.last;

    final session = await Navigator.of(context).push<TrainingSession>(
      MaterialPageRoute<TrainingSession>(
        builder: (context) => ActiveTrainingScreen(
          training: training,
          previousSession: previousSession,
        ),
      ),
    );

    if (!mounted || session == null) {
      return;
    }

    setState(() {
      // Eine neue Liste anlegen, falls dies die erste Einheit ist.
      final sessions = _sessionsByTraining.putIfAbsent(
        training.id,
        () => [],
      );
      sessions.add(session);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trainingseinheit gespeichert.'),
      ),
    );
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
          ),
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
                    SizedBox(height: 24),
                    Text(
                      'Dein Training. Deine Bühne.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Erstelle dein erstes Training über das + oben rechts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _trainings.length,
              itemBuilder: (context, index) {
                final training = _trainings[index];
                final history = _sessionsByTraining[training.id];
                final lastSession =
                    history == null || history.isEmpty
                        ? null
                        : history.last;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          training.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${training.exercises.length} Übungen',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          training.exercises
                              .map((exercise) => exercise.name)
                              .join(' · '),
                        ),
                        if (lastSession != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Letzte Trainingsdauer: '
                            '${lastSession.duration.inMinutes} Minuten',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _startTraining(training),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Training starten'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}