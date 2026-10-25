import 'dart:async';
import 'package:repstar/models/active_training_draft.dart';
import 'package:repstar/services/active_training_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:repstar/models/exercise_settings.dart';
import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_session.dart';
import 'package:repstar/models/workouts_set.dart';
import 'package:repstar/services/training_reward_service.dart';
import 'package:repstar/widgets/training_exercise_card.dart';
import 'package:vibration/vibration.dart';

/// Zeigt ein neues oder wiederhergestelltes Training.
class ActiveTrainingScreen extends StatefulWidget {
  final TrainingPlan training;
  final TrainingSession? previousSession;

  /// Körpergewicht für eine neu gestartete Einheit.
  final double? bodyWeightKg;

  /// Vorhandener Zwischenstand beim Fortsetzen.
  final ActiveTrainingDraft? draft;

  /// Gemeinsame Instanz verhindert konkurrierende Dateizugriffe.
  final ActiveTrainingStorageService? draftStorage;

  const ActiveTrainingScreen({
    super.key,
    required this.training,
    this.previousSession,
    this.bodyWeightKg,
    this.draft,
    this.draftStorage,
  });

  @override
  State<ActiveTrainingScreen> createState() => _ActiveTrainingScreenState();
}

class _ActiveTrainingScreenState extends State<ActiveTrainingScreen>
    with WidgetsBindingObserver {
  late final DateTime _startedAt;
  late final double? _bodyWeightAtStart;
  late final ActiveTrainingStorageService _draftStorage;

  Timer? _draftSaveTimer;
  String? _draftSaveError;
  bool _isClosing = false;

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
    WidgetsBinding.instance.addObserver(this);

    final draft = widget.draft;
    final source = draft?.snapshot ?? widget.previousSession;

    _draftStorage = widget.draftStorage ?? ActiveTrainingStorageService();

    _startedAt = draft?.snapshot.startedAt ?? DateTime.now();

    // Beim Fortsetzen das damalige Körpergewicht erhalten.
    _bodyWeightAtStart = draft != null
        ? draft.snapshot.bodyWeightKg
        : widget.bodyWeightKg;

    final elapsed = DateTime.now().difference(_startedAt);
    _elapsed = elapsed.isNegative ? Duration.zero : elapsed;

    for (final exercise in widget.training.exercises) {
      _exerciseKeys[exercise.id] = GlobalKey();

      final savedSets = source?.setsByExercise[exercise.id];
      final settings = source?.settingsByExercise[exercise.id];

      if (settings != null) {
        _settingsByExercise[exercise.id] = ExerciseSettings(
          seatHeight: settings.seatHeight,
          otherAdjustments: settings.otherAdjustments,
        );
      }

      _setsByExercise[exercise.id] = savedSets == null || savedSets.isEmpty
          ? List.generate(3, (_) => WorkoutSet())
          : savedSets
                .map(
                  (set) => WorkoutSet(
                    weight: set.weight,
                    repetitions: set.repetitions,

                    // Beim Fortsetzen bleiben vorhandene Häkchen erhalten.
                    // Bei einem neuen Training beginnen sie wieder leer.
                    isCompleted: draft != null && set.isCompleted,
                  ),
                )
                .toList();
    }

    if (draft == null) {
      if (widget.training.exercises.isNotEmpty) {
        _expandedExerciseId = widget.training.exercises.first.id;
      }
    } else {
      final expandedId = draft.expandedExerciseId;

      _expandedExerciseId = _exerciseKeys.containsKey(expandedId)
          ? expandedId
          : null;

      _restDurationSeconds = draft.restDurationSeconds;

      final end = draft.restEndsAt;

      // Eine bereits abgelaufene Pause nicht erneut starten.
      if (end != null && end.isAfter(DateTime.now())) {
        _restEndsAt = end;
        _restRemainingSeconds =
            (end.difference(DateTime.now()).inMicroseconds /
                    Duration.microsecondsPerSecond)
                .ceil();
      }
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTimers());

    // Bereits der Start des Trainings wird abgesichert.
    unawaited(_saveDraft());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && !_isClosing && !_canLeave) {
      _draftSaveTimer?.cancel();

      // Beim Wechsel in den Hintergrund sofort eine Sicherung anstoßen.
      unawaited(_saveDraft());
    }
  }

  /// Bündelt schnelle Tastatureingaben zu einer Sicherung.
  void _scheduleDraftSave() {
    if (!mounted || _isClosing || _canLeave) {
      return;
    }

    _draftSaveTimer?.cancel();

    _draftSaveTimer = Timer(
      const Duration(milliseconds: 350),
      () => unawaited(_saveDraft()),
    );
  }

  /// Erstellt eine eigene Kopie des aktuellen Trainingsstands.
  TrainingSession _captureSession(DateTime end) {
    return TrainingSession(
      trainingPlanId: widget.training.id,
      startedAt: _startedAt,
      endedAt: end,
      bodyWeightKg: _bodyWeightAtStart,
      setsByExercise: _setsByExercise,
      settingsByExercise: _settingsByExercise,
    );
  }

  /// Speichert entweder einen laufenden oder einen fertigen Zwischenstand.
  Future<bool> _saveDraft({TrainingSession? finishedSession}) async {
    if (_canLeave || (_isClosing && finishedSession == null)) {
      return false;
    }

    final draft = ActiveTrainingDraft(
      training: widget.training,
      snapshot: finishedSession ?? _captureSession(DateTime.now()),
      restDurationSeconds: _restDurationSeconds,
      restEndsAt: _restEndsAt,
      expandedExerciseId: _expandedExerciseId,
      isFinished: finishedSession != null,
    );

    try {
      await _draftStorage.save(draft);

      if (mounted && _draftSaveError != null) {
        setState(() {
          _draftSaveError = null;
        });
      }

      return true;
    } catch (error) {
      debugPrint('Zwischenspeichern fehlgeschlagen: $error');

      if (mounted) {
        setState(() {
          _draftSaveError = 'Zwischenstand konnte nicht gespeichert werden.';
        });
      }

      return false;
    }
  }

  /// Prüft, ob alle vorhandenen Sätze einer Übung abgehakt sind.
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

  /// Ermöglicht das manuelle Öffnen und Schließen einer Karte.
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
    _scheduleDraftSave();
  }

  /// Scrollt nach der Aufklappanimation zur ausgewählten Karte.
  void _onExpansionAnimationEnd(String exerciseId) {
    if (!mounted ||
        _canLeave ||
        _expandedExerciseId != exerciseId ||
        _pendingScrollExerciseId != exerciseId) {
      return;
    }

    // Spätere Größenänderungen sollen kein weiteres Scrollen auslösen.
    _pendingScrollExerciseId = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _canLeave || _expandedExerciseId != exerciseId) {
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

  /// Aktualisiert die Zeitanzeigen und erkennt das Ende einer Pause.
  void _updateTimers() {
    if (!mounted || _canLeave) {
      return;
    }

    final now = DateTime.now();
    final restEndsAt = _restEndsAt;
    var restFinished = false;

    setState(() {
      // Die Startzeit ist die Grundlage, nicht die Anzahl der Timer-Aufrufe.
      _elapsed = now.difference(_startedAt);

      if (restEndsAt != null) {
        final remaining = restEndsAt.difference(now);

        if (remaining <= Duration.zero) {
          _restEndsAt = null;
          _restRemainingSeconds = 0;
          restFinished = true;
        } else {
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

  /// Startet nach einem Satz eine neue Pause.
  void _startRest() {
    if (_canLeave) {
      return;
    }

    setState(() {
      _restEndsAt = DateTime.now().add(Duration(seconds: _restDurationSeconds));
      _restRemainingSeconds = _restDurationSeconds;
    });
    _scheduleDraftSave();
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
    _scheduleDraftSave();
  }

  /// Überspringt die Pause ohne Vibrationssignal.
  void _skipRest() {
    setState(() {
      _restEndsAt = null;
      _restRemainingSeconds = 0;
    });
    _scheduleDraftSave();
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

  /// Formatiert die gesamte Trainingsdauer als Stunden:Minuten:Sekunden.
  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  /// Gemeinsame Formatierung für Pausen- und XP-Countdown.
  String _formatCountdown(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  /// Zeigt die verbleibende Zeit bis zur zeitlichen XP-Freigabe.
  Widget _buildXpStatus() {
    // Verwendet dieselbe Grenze wie die tatsächliche Punkteberechnung.
    final minimumDuration = TrainingRewardService.minimumXpDuration;
    final minimumReached = _elapsed >= minimumDuration;

    final String label;

    if (minimumReached) {
      label = 'XP-Mindestdauer erreicht';
    } else {
      final remaining = minimumDuration - _elapsed;

      // Aufrunden verhindert eine vorzeitige Anzeige von 00:00.
      final remainingSeconds =
          (remaining.inMicroseconds / Duration.microsecondsPerSecond).ceil();

      label = 'XP-Freigabe in ${_formatCountdown(remainingSeconds)}';
    }

    final color = minimumReached
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          minimumReached
              ? Icons.check_circle_outline
              : Icons.lock_clock_outlined,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: minimumReached ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  /// Zeigt den Trainingstimer und direkt darunter den XP-Status.
  Widget _buildTrainingTimer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
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
          const SizedBox(height: 8),
          _buildXpStatus(),
        ],
      ),
    );
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

  /// Erst den Abschluss absichern, dann zum Trainingsbildschirm zurück.
  Future<void> _finishTraining() async {
    if (_isClosing || _canLeave) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isClosing = true;
    });

    _draftSaveTimer?.cancel();

    final session = _captureSession(DateTime.now());
    final saved = await _saveDraft(finishedSession: session);

    if (!mounted) {
      return;
    }

    if (saved) {
      _leaveScreen(session);
    } else {
      setState(() {
        _isClosing = false;
      });
    }
  }

  Future<void> _confirmDiscard() async {
    if (_exitDialogOpen || _canLeave || _isClosing) {
      return;
    }

    _exitDialogOpen = true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Training verwerfen?'),
        content: const Text('Die Eingaben dieser Einheit werden verworfen.'),
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

    if (!mounted || discard != true) {
      return;
    }

    setState(() {
      _isClosing = true;
    });

    _draftSaveTimer?.cancel();

    try {
      await _draftStorage.clear();

      if (mounted) {
        _leaveScreen();
      }
    } catch (error) {
      debugPrint('Verwerfen fehlgeschlagen: $error');

      if (mounted) {
        setState(() {
          _isClosing = false;
          _draftSaveError = 'Zwischenstand konnte nicht gelöscht werden.';
        });
      }
    }
  }

  /// Zeigt Pausenlänge, Countdown und Steuerung.
  Widget _buildRestTimer() {
    final isResting = _restEndsAt != null;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isResting
                  ? 'Satzpause: ${_formatCountdown(_restRemainingSeconds)}'
                  : 'Pausentimer bereit',
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
                        _restDurationSeconds = value;
                      });

                      _scheduleDraftSave();
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
              onChanged: _scheduleDraftSave,
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

                _scheduleDraftSave();
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _draftSaveTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
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
        appBar: AppBar(title: Text(widget.training.name)),
        body: Column(
          children: [
            _buildTrainingTimer(),
            if (_draftSaveError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(_draftSaveError!, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: _isClosing
                          ? null
                          : () async {
                              await _saveDraft();
                            },
                      child: const Text('Erneut sichern'),
                    ),
                  ],
                ),
              ),
            _buildRestTimer(),
            Expanded(
              child: AbsorbPointer(
                absorbing: _isClosing,
                child: _buildExerciseList(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _isClosing ? null : _finishTraining,
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Training beenden'),
            ),
          ),
        ),
      ),
    );
  }
}
