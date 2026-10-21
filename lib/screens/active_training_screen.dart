import 'package:vibration/vibration.dart';
import 'package:repstar/models/exercise_settings.dart';
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
  State<ActiveTrainingScreen> createState() => _ActiveTrainingScreenState();
}

class _ActiveTrainingScreenState extends State<ActiveTrainingScreen> {
  final DateTime _startedAt = DateTime.now();

  /// Veränderbare Satzlisten für die aktuelle Einheit.
  final Map<String, List<WorkoutSet>> _setsByExercise = {};

  /// Speichert optionale Geräteeinstellungen je Übung.
  final Map<String, ExerciseSettings> _settingsByExercise = {};

  Timer? _timer;
  Duration _elapsed = Duration.zero;

  /// Gewählte Pausenlänge; gilt für die nächste gestartete Pause.
  int _restDurationSeconds = 90;

  /// Die Endzeit verhindert, dass verzögerte Updates den Countdown verlängern.
  DateTime? _restEndsAt;
  int _restRemainingSeconds = 0;
  bool _canLeave = false;
  bool _exitDialogOpen = false;

  @override
  void initState() {
    super.initState();

    for (final exercise in widget.training.exercises) {
      final previousSets = widget.previousSession?.setsByExercise[exercise.id];

      // Liest die bisherigen Geräteeinstellungen dieser Übung.
      final previousSettings =
          widget.previousSession?.settingsByExercise[exercise.id];

      // Geräteeinstellungen der letzten Einheit übernehmen.
      if (previousSettings != null) {
        // Eine eigene Kopie verhindert Änderungen an der alten Einheit.
        _settingsByExercise[exercise.id] = ExerciseSettings(
          seatHeight: previousSettings.seatHeight,
          otherAdjustments: previousSettings.otherAdjustments,
        );
      }

      if (previousSets == null || previousSets.isEmpty) {
        // Drei voneinander unabhängige Sätze für eine neue Übung.
        _setsByExercise[exercise.id] = List.generate(3, (_) => WorkoutSet());
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

    // Ein gemeinsamer Tmer aktualisiert Trainingsdauer und Pausenanzeige.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTimers());
  }

  /// Aktualisiert beide Anzeigen und erkennt das Ende einer Pause.
  void _updateTimers() {
    if (!mounted || _canLeave) {
      return;
    }

    final now = DateTime.now();
    final restEndsAt = _restEndsAt;
    var restFinished = false;

    setState(() {
      _elapsed = now.difference(_startedAt);

      if (restEndsAt != null) {
        final remaining = restEndsAt.difference(now);

        if (remaining <= Duration.zero) {
          // Die Endzeit löschen, damit das Signal nur einmal ausgelöst wird.
          _restEndsAt = null;
          _restRemainingSeconds = 0;
          restFinished = true;
        } else {
          // Aufrunden: Eine noch laufende Pause zeigt mindestens 1 Sekunde.
          _restRemainingSeconds =
              (remaining.inMicroseconds / Duration.microsecondsPerSecond)
                  .ceil();
        }
      }
    });

    if (restFinished) {
      unawaited(_vibrateRestEnd());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pause vorbei – weiter geht’s!')),
      );
    }
  }

  /// Startet nach einem Satz eine neue Pause mit der gewählten Länge.
  void _startRest() {
    if (_canLeave) {
      return;
    }

    setState(() {
      _restEndsAt = DateTime.now().add(Duration(seconds: _restDurationSeconds));
      _restRemainingSeconds = _restDurationSeconds;
    });
  }

  /// Verlängert eine laufende Pause um 30 Sekunden.
  void _extendRest() {
    final restEndsAt = _restEndsAt;

    if (restEndsAt == null) {
      return;
    }

    final now = DateTime.now();
    final baseTime = restEndsAt.isAfter(now) ? restEndsAt : now;
    final newEnd = baseTime.add(const Duration(seconds: 30));

    setState(() {
      _restEndsAt = newEnd;
      _restRemainingSeconds =
          (newEnd.difference(now).inMicroseconds /
                  Duration.microsecondsPerSecond)
              .ceil();
    });
  }

  /// Überspringt die Pause ohne Vibrationssignal.
  void _skipRest() {
    setState(() {
      _restEndsAt = null;
      _restRemainingSeconds = 0;
    });
  }

  /// Löst ein kurzes Vibrationssignal aus, sofern das Gerät es unterstützt.
  Future<void> _vibrateRestEnd() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();

      // Nach dem Verlassen oder einem neuen Pausenstart kein altes Signal senden.
      if (!mounted || _canLeave || _restEndsAt != null) {
        return;
      }

      if (hasVibrator) {
        await Vibration.vibrate(duration: 500);
      }
    } catch (error) {
      // Ein Vibrationsfehler unterbricht das Training nicht.
      debugPrint('Vibration fehlgeschlagen: $error');
    }
  }

  /// Formatiert die Dauer beispielsweise als 00:12:35.
  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

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
      settingsByExercise: _settingsByExercise,
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

  /// Zeigt Pausenlänge, Countdown und Steuerung.
  Widget _buildRestTimer() {
    final isResting = _restEndsAt != null;
    final minutes = (_restRemainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_restRemainingSeconds % 60).toString().padLeft(2, '0');

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isResting ? 'Satzpause: $minutes:$seconds' : 'Pausentimer bereit',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Text('Pausenlänge: '),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _restDurationSeconds,
                  items: [
                    for (final seconds in [30, 60, 90, 120, 180])
                      DropdownMenuItem<int>(
                        value: seconds,
                        child: Text('$seconds Sekunden'),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        // Eine laufende Pause behält ihre bisherige Endzeit.
                        _restDurationSeconds = value;
                      });
                    }
                  },
                ),
              ],
            ),
            if (isResting)
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: _extendRest,
                    icon: const Icon(Icons.more_time),
                    label: const Text('+30 Sekunden'),
                  ),
                  TextButton(
                    onPressed: _skipRest,
                    child: const Text('Überspringen'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
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
        appBar: AppBar(title: Text(widget.training.name)),
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
            // Die Pause bleibt oberhalb der Übungsliste sichtbar.
            _buildRestTimer(),
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
                    onSetCompleted: _startRest,
                    settings: _settingsByExercise[exercise.id],
                    onSettingsChanged: (settings) {
                      setState(() {
                        if (settings == null) {
                          //Entfernt beide Notizfelder samt ihren werten.
                          _settingsByExercise.remove(exercise.id);
                        } else {
                          // Hinterlegt die Einstellungen für diese Übung.
                          _settingsByExercise[exercise.id] = settings;
                        }
                      });
                    },
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
