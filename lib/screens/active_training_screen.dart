import 'dart:async';

import 'package:flutter/material.dart';
import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_session.dart';
import 'package:repstar/models/workouts_set.dart';
import 'package:repstar/widgets/training_exercise_card.dart';

/// Zeigt das laufende Training mit Timer und Übungskarten.
class ActiveTrainingScreen extends StatefulWidget {
  final TrainingPlan training;
  final TrainingSession? previousSession;

  const ActiveTrainingScreen({
    super.key,
    required this.training,
    this.previousSession,
  });

  @override
  State<ActiveTrainingScreen> createState() =>
      _ActiveTrainingScreenState();
}

class _ActiveTrainingScreenState extends State<ActiveTrainingScreen> {
  final DateTime _startedAt = DateTime.now();

  /// Veränderbare Satzlisten für die aktuelle Einheit.
  final Map<String, List<WorkoutSet>> _setsByExercise = {};

  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _canLeave = false;
  bool _exitDialogOpen = false;

  @override
  void initState() {
    super.initState();

    for (final exercise in widget.training.exercises) {
      final previousSets =
          widget.previousSession?.setsByExercise[exercise.id];

      if (previousSets == null || previousSets.isEmpty) {
        // Drei voneinander unabhängige Sätze für eine neue Übung.
        _setsByExercise[exercise.id] = List.generate(
          3,
          (_) => WorkoutSet(),
        );
      } else {
        // Letzte Werte übernehmen; Häkchen starten wieder leer.
        _setsByExercise[exercise.id] = previousSets
            .map(
              (workoutSet) => WorkoutSet(
                weight: workoutSet.weight,
                repetitions: workoutSet.repetitions,
              ),
            )
            .toList();
      }
    }

    // Die Startzeit bleibt die Grundlage, auch bei verzögerten Updates.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(_startedAt);
      });
    });
  }

  /// Formatiert die Dauer beispielsweise als 00:12:35.
  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes =
        (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds =
        (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  /// Erlaubt das Schließen und liefert optional eine fertige Einheit.
  void _leaveScreen([TrainingSession? session]) {
    if (_canLeave) {
      return;
    }

    _timer?.cancel();

    setState(() {
      _canLeave = true;
    });

    // Erst die Zurück-Sperre aktualisieren, dann den Bildschirm schließen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop<TrainingSession>(session);
      }
    });
  }

  /// Beendet den Timer und erstellt die abgeschlossene Einheit.
  void _finishTraining() {
    final session = TrainingSession(
      trainingPlanId: widget.training.id,
      startedAt: _startedAt,
      endedAt: DateTime.now(),
      setsByExercise: _setsByExercise,
    );

    _leaveScreen(session);
  }

  /// Verhindert versehentliches Verwerfen über den Zurück-Button.
  Future<void> _confirmDiscard() async {
    if (_exitDialogOpen || _canLeave) {
      return;
    }

    _exitDialogOpen = true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Training verwerfen?'),
        content: const Text(
          'Die Eingaben dieser Einheit werden nicht gespeichert.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Weiter trainieren'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Verwerfen'),
          ),
        ],
      ),
    );

    _exitDialogOpen = false;

    if (mounted && discard == true) {
      _leaveScreen();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<TrainingSession>(
      canPop: _canLeave,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmDiscard();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.training.name),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_elapsed),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: widget.training.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = widget.training.exercises[index];

                  return TrainingExerciseCard(
                    key: ValueKey(exercise.id),
                    exercise: exercise,
                    sets: _setsByExercise[exercise.id]!,
                    initiallyExpanded: index == 0,
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _finishTraining,
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Training beenden'),
            ),
          ),
        ),
      ),
    );
  }
}