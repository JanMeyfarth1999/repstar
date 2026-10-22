import 'dart:async';

import 'package:flutter/material.dart';
import 'package:repstar/models/exercise_settings.dart';
import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_session.dart';
import 'package:repstar/models/workouts_set.dart';
import 'package:repstar/widgets/training_exercise_card.dart';
import 'package:vibration/vibration.dart';

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

  /// Optionale Geräteeinstellungen je Übung.
  final Map<String, ExerciseSettings> _settingsByExercise = {};

  /// Ordnet jeder Karte eine Kennung für das automatische Scrollen zu.
  final Map<String, GlobalKey> _exerciseKeys = {};

  /// Es ist jeweils höchstens eine Übung aufgeklappt.
  String? _expandedExerciseId;

  /// Nach dem Aufklappen soll diese Übung sichtbar gemacht werden.
  String? _pendingScrollExerciseId;

  Timer? _timer;
  Duration _elapsed = Duration.zero;

  /// Gewählte Pausenlänge für die nächste gestartete Pause.
  int _restDurationSeconds = 90;

  DateTime? _restEndsAt;
  int _restRemainingSeconds = 0;

  bool _canLeave = false;
  bool _exitDialogOpen = false;

  @override
  void initState() {
    super.initState();

    for (final exercise in widget.training.exercises) {
      _exerciseKeys[exercise.id] = GlobalKey();

      final previousSets =
          widget.previousSession?.setsByExercise[exercise.id];

      final previousSettings =
          widget.previousSession?.settingsByExercise[exercise.id];

      if (previousSettings != null) {
        // Eine eigene Kopie verhindert Änderungen an der alten Einheit.
        _settingsByExercise[exercise.id] = ExerciseSettings(
          seatHeight: previousSettings.seatHeight,
          otherAdjustments: previousSettings.otherAdjustments,
        );
      }

      if (previousSets == null || previousSets.isEmpty) {
        _setsByExercise[exercise.id] = List.generate(
          3,
          (_) => WorkoutSet(),
        );
      } else {
        // Letzte Werte übernehmen; die Häkchen starten wieder leer.
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

    if (widget.training.exercises.isNotEmpty) {
      _expandedExerciseId = widget.training.exercises.first.id;
    }

    // Ein gemeinsamer Timer aktualisiert Trainingsdauer und Pausenanzeige.
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateTimers(),
    );
  }

  /// Prüft, ob wirklich alle vorhandenen Sätze einer Übung abgehakt sind.
  bool _isExerciseCompleted(String exerciseId) {
    final sets = _setsByExercise[exerciseId];

    return sets != null &&
        sets.isNotEmpty &&
        sets.every((workoutSet) => workoutSet.isCompleted);
  }

  /// Sucht die nächste offene Übung in der Trainingsreihenfolge.
  String? _findNextIncompleteExercise(String currentExerciseId) {
    final exercises = widget.training.exercises;
    final currentIndex = exercises.indexWhere(
      (exercise) => exercise.id == currentExerciseId,
    );

    if (currentIndex == -1) {
      return null;
    }

    // Am Listenende auch zuvor übersprungene Übungen berücksichtigen.
    for (int offset = 1; offset < exercises.length; offset++) {
      final index = (currentIndex + offset) % exercises.length;
      final exerciseId = exercises[index].id;

      if (!_isExerciseCompleted(exerciseId)) {
        return exerciseId;
      }
    }

    return null;
  }

  /// Startet die Pause und wechselt bei abgeschlossener Übung weiter.
  void _onSetCompleted(String exerciseId) {
    if (!mounted || _canLeave) {
      return;
    }

    _startRest();

    // Solange noch Sätze fehlen, bleibt die aktuelle Karte geöffnet.
    if (!_isExerciseCompleted(exerciseId)) {
      return;
    }

    final nextExerciseId = _findNextIncompleteExercise(exerciseId);

    // Beim Wechsel die Bildschirmtastatur schließen.
    FocusScope.of(context).unfocus();

    setState(() {
      _expandedExerciseId = nextExerciseId;
      _pendingScrollExerciseId = nextExerciseId;
    });

    if (nextExerciseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Alle Übungen erledigt! Du kannst dein Training jetzt beenden.',
          ),
        ),
      );
    }
  }

  /// Ermöglicht weiterhin das manuelle Öffnen und Schließen einer Karte.
  void _onExpansionChanged(String exerciseId, bool expanded) {
    if (_canLeave) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      if (expanded) {
        _expandedExerciseId = exerciseId;
        _pendingScrollExerciseId = exerciseId;
      } else if (_expandedExerciseId == exerciseId) {
        _expandedExerciseId = null;
        _pendingScrollExerciseId = null;
      }
    });
  }

  /// Scrollt nach der Aufklappanimation einmal zur ausgewählten Karte.
  void _onExpansionAnimationEnd(String exerciseId) {
    if (!mounted ||
        _canLeave ||
        _expandedExerciseId != exerciseId ||
        _pendingScrollExerciseId != exerciseId) {
      return;
    }

    // Spätere Größenänderungen, etwa durch ein geladenes Bild,
    // sollen kein erneutes automatisches Scrollen auslösen.
    _pendingScrollExerciseId = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _canLeave ||
          _expandedExerciseId != exerciseId) {
        return;
      }

      final cardContext = _exerciseKeys[exerciseId]?.currentContext;

      if (cardContext == null) {
        return;
      }

      unawaited(
        Scrollable.ensureVisible(
          cardContext,
          alignment: 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
      );
    });
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
          _restEndsAt = null;
          _restRemainingSeconds = 0;
          restFinished = true;
        } else {
          _restRemainingSeconds =
              (remaining.inMicroseconds /
                      Duration.microsecondsPerSecond)
                  .ceil();
        }
      }
    });

    if (restFinished) {
      unawaited(_vibrateRestEnd());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pause vorbei – weiter geht’s!'),
        ),
      );
    }
  }

  /// Startet nach einem Satz eine neue Pause.
  void _startRest() {
    if (_canLeave) {
      return;
    }

    setState(() {
      _restEndsAt = DateTime.now().add(
        Duration(seconds: _restDurationSeconds),
      );
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

  /// Löst ein kurzes Vibrationssignal aus.
  Future<void> _vibrateRestEnd() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();

      if (!mounted || _canLeave || _restEndsAt != null) {
        return;
      }

      if (hasVibrator) {
        await Vibration.vibrate(duration: 500);
      }
    } catch (error) {
      debugPrint('Vibration fehlgeschlagen: $error');
    }
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
      _pendingScrollExerciseId = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop<TrainingSession>(session);
      }
    });
  }

  /// Erstellt die abgeschlossene Einheit.
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
    final minutes =
        (_restRemainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds =
        (_restRemainingSeconds % 60).toString().padLeft(2, '0');

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isResting
                  ? 'Satzpause: $minutes:$seconds'
                  : 'Pausentimer bereit',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
                        // Gilt für die nächste gestartete Pause.
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

  /// Baut alle Karten, damit auch entfernte Scrollziele erreichbar sind.
  Widget _buildExerciseList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          for (final exercise in widget.training.exercises)
            TrainingExerciseCard(
              key: _exerciseKeys[exercise.id],
              exercise: exercise,
              sets: _setsByExercise[exercise.id]!,
              settings: _settingsByExercise[exercise.id],
              isExpanded: _expandedExerciseId == exercise.id,
              onExpansionChanged: (expanded) {
                _onExpansionChanged(exercise.id, expanded);
              },
              onExpansionAnimationEnd: () {
                _onExpansionAnimationEnd(exercise.id);
              },
              onSetCompleted: () {
                _onSetCompleted(exercise.id);
              },
              onSettingsChanged: (settings) {
                setState(() {
                  if (settings == null) {
                    _settingsByExercise.remove(exercise.id);
                  } else {
                    _settingsByExercise[exercise.id] = settings;
                  }
                });
              },
            ),
        ],
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
            _buildRestTimer(),
            Expanded(
              child: _buildExerciseList(),
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