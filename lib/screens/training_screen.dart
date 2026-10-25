import 'package:repstar/models/active_training_draft.dart';
import 'package:repstar/services/active_training_storage_service.dart';
import 'package:repstar/screens/exercise_progress_screen.dart';
import 'dart:async';
import 'package:repstar/screens/training_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:repstar/data/level_library.dart';
import 'package:repstar/models/level_progress.dart';
import 'package:repstar/models/training_data.dart';
import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_session.dart';
import 'package:repstar/screens/active_training_screen.dart';
import 'package:repstar/screens/create_training_screen.dart';
import 'package:repstar/screens/rank_screen.dart';
import 'package:repstar/services/level_service.dart';
import 'package:repstar/services/storage_service.dart';
import 'package:repstar/services/training_reward_service.dart';
import 'package:repstar/widgets/theme_mode_button.dart';

/// Verwaltet Training, Rang und die gemeinsame lokale Speicherung.
class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with WidgetsBindingObserver {
  final StorageService _storageService = StorageService();

  final ActiveTrainingStorageService _draftStorage =
      ActiveTrainingStorageService();

  bool _checkingDraft = false;
  String? _draftProblem;

  final TrainingRewardService _rewardService = const TrainingRewardService();

  final LevelService _levelService = LevelService(levels: levelLibrary);

  final List<TrainingPlan> _trainings = [];
  final Map<String, List<TrainingSession>> _sessionsByTraining = {};

  LevelProgress _levelProgress = LevelProgress.initial();
  DateTime _now = DateTime.now();

  double? _bodyWeightKg;
  int _selectedPage = 0;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  String? _loadError;

  Timer? _calendarTimer;

  /// Eine laufende Speicherung wird von weiteren Aufrufen mitverwendet.
  Future<bool>? _saveFuture;

  /// Erkennt Änderungen, die während eines Schreibvorgangs entstehen.
  int _revision = 0;

  /// Gemeinsamer Zugriff auf sämtliche gespeicherten Einheiten.
  Iterable<TrainingSession> get _allSessions =>
      _sessionsByTraining.values.expand((sessions) => sessions);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    unawaited(_loadData());

    // Prüft den Monatswechsel auch, während die App geöffnet bleibt.
    _calendarTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(_refreshRank()),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Nach Rückkehr aus dem Hintergrund vergangene Monate auswerten.
      unawaited(_refreshRank());
    }
  }

  /// Innerhalb von setState aufrufen, wenn Speicherdaten geändert werden.
  void _markChanged() {
    _revision += 1;
    _hasUnsavedChanges = true;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final data = await _storageService.load();
      final now = DateTime.now();

      final progress = _levelService.evaluate(
        progress: data.levelProgress,
        sessions: data.sessionsByTraining.values.expand((sessions) => sessions),
        now: now,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _trainings
          ..clear()
          ..addAll(data.trainings);

        _sessionsByTraining
          ..clear()
          ..addAll(data.sessionsByTraining);

        _bodyWeightKg = data.bodyWeightKg;
        _levelProgress = progress;
        _now = now;
        _isLoading = false;
        _markChanged();
      });
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }

      // Bei einem Ladefehler keine leeren Daten darüber speichern.
      setState(() {
        _isLoading = false;
        _loadError = 'Die Trainingsdaten konnten nicht geladen werden.';
      });

      debugPrint('Fehler beim Laden: $error');
      debugPrintStack(stackTrace: stackTrace);
      return;
    }

    // Sichert auch die Umstellung älterer Dateien auf das neue Format.
    await _saveData();
    await _checkPendingDraft();
  }

  /// Aktualisiert Uhrzeit und gegebenenfalls den gespeicherten Rang.
  Future<void> _refreshRank() async {
    if (!mounted || _isLoading || _loadError != null) {
      return;
    }

    final now = DateTime.now();

    final updated = _levelService.evaluate(
      progress: _levelProgress,
      sessions: _allSessions,
      now: now,
    );

    final changed =
        updated.level != _levelProgress.level ||
        !updated.periodStartedAt.isAtSameMomentAs(
          _levelProgress.periodStartedAt,
        );

    setState(() {
      _now = now;

      if (changed) {
        _levelProgress = updated;
        _markChanged();
      }
    });

    if (changed) {
      await _saveData();
    }
  }

  /// Verhindert gleichzeitig laufende Schreibvorgänge.
  Future<bool> _saveData() async {
    final runningSave = _saveFuture;

    if (runningSave != null) {
      return runningSave;
    }

    final save = _performSave();
    _saveFuture = save;

    try {
      return await save;
    } finally {
      _saveFuture = null;
    }
  }

  Future<bool> _performSave() async {
    if (!mounted || _isLoading || _loadError != null) {
      return false;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      int savedRevision;

      do {
        savedRevision = _revision;

        // Eigene Listen bilden einen festen Stand für diesen Schreibvorgang.
        final snapshot = TrainingData(
          trainings: List<TrainingPlan>.of(_trainings),
          sessionsByTraining: _sessionsByTraining.map(
            (id, sessions) => MapEntry(id, List<TrainingSession>.of(sessions)),
          ),
          bodyWeightKg: _bodyWeightKg,
          levelProgress: _levelProgress,
        );

        await _storageService.save(snapshot);

        if (!mounted) {
          return false;
        }

        // Falls während des Speicherns etwas geändert wurde,
        // den aktuellen Stand anschließend ebenfalls sichern.
      } while (savedRevision != _revision);

      setState(() {
        _isSaving = false;
        _hasUnsavedChanges = false;
      });

      return true;
    } catch (error, stackTrace) {
      if (!mounted) {
        return false;
      }

      setState(() {
        _isSaving = false;
        _hasUnsavedChanges = true;
      });

      debugPrint('Fehler beim Speichern: $error');
      debugPrintStack(stackTrace: stackTrace);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speichern fehlgeschlagen. Bitte erneut versuchen.'),
        ),
      );

      return false;
    }
  }

  Future<void> _editBodyWeight() async {
    if (_isLoading || _isSaving || _loadError != null) {
      return;
    }

    var input = _bodyWeightKg?.toString().replaceAll('.', ',') ?? '';
    String? errorText;

    final weight = await showDialog<double>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Tastatur und Speichern-Button verwenden dieselbe Prüfung.
          void submitWeight() {
            final parsedWeight = double.tryParse(
              input.trim().replaceAll(',', '.'),
            );

            if (parsedWeight == null ||
                !parsedWeight.isFinite ||
                parsedWeight <= 0) {
              setDialogState(() {
                errorText = 'Bitte ein gültiges Gewicht über 0 eingeben.';
              });
              return;
            }

            Navigator.of(dialogContext).pop(parsedWeight);
          }

          return AlertDialog(
            title: const Text('Körpergewicht'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Dein Gewicht wird für die grobe '
                    'Kalorienschätzung verwendet.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: input,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Körpergewicht',
                      hintText: 'Zum Beispiel 85,5',
                      suffixText: 'kg',
                      border: const OutlineInputBorder(),
                      errorText: errorText,
                    ),
                    onChanged: (value) {
                      input = value;

                      if (errorText != null) {
                        setDialogState(() {
                          errorText = null;
                        });
                      }
                    },
                    onFieldSubmitted: (_) => submitWeight(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Abbrechen'),
              ),
              FilledButton(
                onPressed: submitWeight,
                child: const Text('Speichern'),
              ),
            ],
          );
        },
      ),
    );

    if (!mounted || weight == null) {
      return;
    }

    setState(() {
      _bodyWeightKg = weight;
      _markChanged();
    });

    await _saveData();
  }

  Widget _buildBodyWeightCard() {
    final weight = _bodyWeightKg;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ListTile(
        leading: Icon(
          Icons.monitor_weight_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Körpergewicht'),
        subtitle: Text(
          weight == null
              ? 'Noch nicht angegeben'
              : '${weight.toString().replaceAll('.', ',')} kg',
        ),
        trailing: const Icon(Icons.edit_outlined),
        onTap: _isSaving ? null : _editBodyWeight,
      ),
    );
  }

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
      _markChanged();
    });

    await _saveData();
  }

  Future<void> _editTraining(TrainingPlan training) async {
    final updated = await Navigator.of(context).push<TrainingPlan>(
      MaterialPageRoute<TrainingPlan>(
        builder: (context) => CreateTrainingScreen(initialTraining: training),
      ),
    );

    if (!mounted || updated == null) {
      return;
    }

    final index = _trainings.indexWhere((item) => item.id == training.id);

    if (index == -1) {
      return;
    }

    setState(() {
      _trainings[index] = updated;
      _markChanged();
    });

    await _saveData();
  }

  /// Erkennt dieselbe Einheit anhand von Vorlage und ursprünglicher Startzeit.
  TrainingSession? _findSavedSession(TrainingSession session) {
    for (final saved in _allSessions) {
      if (saved.trainingPlanId == session.trainingPlanId &&
          saved.startedAt.isAtSameMomentAs(session.startedAt)) {
        return saved;
      }
    }

    return null;
  }

  Future<void> _startTraining(TrainingPlan training) async {
    if (_isSaving || _checkingDraft || _draftProblem != null) {
      return;
    }

    // Ein vorhandenes Training niemals durch ein neues überschreiben.
    if (await _checkPendingDraft()) {
      return;
    }

    if (!mounted) {
      return;
    }

    await _runTraining(training);
  }

  /// Öffnet entweder eine neue Einheit oder einen Zwischenstand.
  Future<void> _runTraining(
    TrainingPlan training, {
    ActiveTrainingDraft? draft,
  }) async {
    final history = _sessionsByTraining[training.id];

    final previousSession = history == null || history.isEmpty
        ? null
        : history.last;

    final session = await Navigator.of(context).push<TrainingSession>(
      MaterialPageRoute<TrainingSession>(
        builder: (context) => ActiveTrainingScreen(
          training: training,
          previousSession: previousSession,
          bodyWeightKg: _bodyWeightKg,
          draft: draft,
          draftStorage: _draftStorage,
        ),
      ),
    );

    if (!mounted || session == null) {
      return;
    }

    await _acceptFinishedSession(training, session);
  }

  /// Erst in den Verlauf schreiben, dann den Zwischenstand entfernen.
  Future<void> _acceptFinishedSession(
    TrainingPlan training,
    TrainingSession session,
  ) async {
    final existingSession = _findSavedSession(session);

    // Verwendet die bereits gespeicherte Einheit oder die gerade beendete.
    // Dadurch enthält completed immer eine Trainingseinheit.
    TrainingSession completed = existingSession ?? session;

    if (existingSession == null) {
      try {
        final reward = _rewardService.calculate(
          training: training,
          session: session,
        );

        completed = session.withReward(reward);
      } catch (error, stackTrace) {
        debugPrint('Trainingsauswertung fehlgeschlagen: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      final entry = completed;

      setState(() {
        _sessionsByTraining.putIfAbsent(training.id, () => []).add(entry);

        _now = DateTime.now();

        _levelProgress = _levelService.evaluate(
          progress: _levelProgress,
          sessions: _allSessions,
          now: _now,
        );

        _markChanged();
      });
    }

    final saved = await _saveData();

    if (!mounted) {
      return;
    }

    if (saved) {
      try {
        await _draftStorage.clear();
      } catch (error) {
        if (mounted) {
          setState(() {
            _draftProblem =
                'Training gespeichert, aber der Zwischenstand '
                'konnte nicht entfernt werden.';
          });
        }
      }
    }

    if (mounted) {
      await _showTrainingSummary(completed, saved: saved);
    }
  }

  /// Prüft, ob ein unterbrochenes oder noch nicht übernommenes Training vorliegt.
  ///
  /// true bedeutet: Ein Zwischenstand wurde behandelt oder ein Fehler
  /// verhindert vorerst den Start einer neuen Einheit.
  Future<bool> _checkPendingDraft() async {
    if (!mounted || _isLoading || _loadError != null || _checkingDraft) {
      return true;
    }

    setState(() {
      _checkingDraft = true;
      _draftProblem = null;
    });

    try {
      final draft = await _draftStorage.load();

      if (!mounted) {
        return true;
      }

      if (draft == null) {
        return false;
      }

      // Der Verlauf kann schon gespeichert sein, während der alte
      // Zwischenstand wegen eines Absturzes noch vorhanden ist.
      if (_findSavedSession(draft.snapshot) != null) {
        if (!await _saveData()) {
          return true;
        }

        await _draftStorage.clear();
        return false;
      }

      // Ein bereits beendetes Training übernehmen, ohne es neu zu starten.
      if (draft.isFinished) {
        await _acceptFinishedSession(draft.training, draft.snapshot);

        return true;
      }

      final resume = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Training fortsetzen?'),
          content: Text(
            'Für „${draft.training.name}“ liegt ein Zwischenstand vor. '
            'Sätze und Geräteeinstellungen können wiederhergestellt werden. '
            'Der Timer zählt seit der ursprünglichen Startzeit weiter.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Verwerfen'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Fortsetzen'),
            ),
          ],
        ),
      );

      if (!mounted) {
        return true;
      }

      if (resume == true) {
        await _runTraining(draft.training, draft: draft);
      } else if (resume == false) {
        await _draftStorage.clear();
      }

      // Wird der Dialog über Zurück geschlossen, bleibt der Stand erhalten.
      return true;
    } catch (error, stackTrace) {
      debugPrint('Zwischenstand konnte nicht verarbeitet werden: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        setState(() {
          _draftProblem =
              'Der Trainingszwischenstand konnte nicht verarbeitet '
              'werden. Bitte erneut versuchen.';
        });
      }

      return true;
    } finally {
      if (mounted) {
        setState(() {
          _checkingDraft = false;
        });
      }
    }
  }

  Future<void> _showTrainingSummary(
    TrainingSession session, {
    required bool saved,
  }) async {
    final reward = session.reward;
    final totalSeconds = session.duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Training abgeschlossen'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trainingsdauer: $minutes:$seconds min'),
              const SizedBox(height: 16),
              if (reward != null) ...[
                Text(
                  '+${reward.earnedXp} XP',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text('${reward.completedSets} Sätze abgeschlossen'),
                const SizedBox(height: 6),
                Text('${reward.completedRepetitions} Wiederholungen'),
                const SizedBox(height: 6),
                Text(
                  'Bewegtes Gewicht: '
                  '${session.totalVolumeKg.toStringAsFixed(1).replaceAll('.', ',')} kg',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  reward.estimatedActiveKcal == null
                      ? 'Kalorienschätzung: Körpergewicht fehlt.'
                      : 'Geschätzte aktive Kalorien: '
                            'ca. ${reward.estimatedActiveKcal!.round()} kcal',
                ),
                const SizedBox(height: 8),
                Text(
                  reward.calculationVersion >= 3
                      ? 'Grobe Schätzung für die gesamte Einheit mit üblichen '
                            'Satzpausen, abzüglich Ruheanteil. Längere '
                            'Unterbrechungen werden nicht erkannt.'
                      : 'Ältere Schätzung nur für die Satz-Ausführung. '
                            'Pausen und Nachverbrauch sind nicht enthalten.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else
                const Text('Die Auswertung konnte nicht berechnet werden.'),
              const SizedBox(height: 16),
              Text(
                saved
                    ? 'Auf dem Gerät gespeichert.'
                    : 'Noch nicht gespeichert. Schließe diese Ansicht '
                          'und tippe auf „Erneut speichern“.',
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Weiter'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainings() {
    if (_trainings.isEmpty) {
      final colors = Theme.of(context).colorScheme;

      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fitness_center, size: 64, color: colors.primary),
              const SizedBox(height: 24),
              const Text(
                'Dein Training. Deine Bühne.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Erstelle dein erstes Training über das + oben rechts.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trainings.length,
      itemBuilder: (context, index) {
        final training = _trainings[index];
        final history = _sessionsByTraining[training.id];
        final lastSession = history == null || history.isEmpty
            ? null
            : history.last;
        final reward = lastSession?.reward;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        training.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Training bearbeiten',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed:
                          _isSaving || _checkingDraft || _draftProblem != null
                          ? null
                          : () => _startTraining(training),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${training.exercises.length} Übungen',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (reward != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Letzte Einheit: +${reward.earnedXp} XP',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isSaving ? null : () => _startTraining(training),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Training starten'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Zeigt Ladezustand, Fehler oder die drei Hauptseiten.
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadData,
                child: const Text('Erneut laden'),
              ),
            ],
          ),
        ),
      );
    }

    // Alle Seiten greifen auf denselben geladenen Datenstand zu.
    return IndexedStack(
      index: _selectedPage,
      children: [
        Column(
          children: [
            _buildBodyWeightCard(),
            Expanded(child: _buildTrainings()),
          ],
        ),
        RankScreen(
          progress: _levelProgress,
          monthlyXp: _levelService.monthlyXp(
            sessions: _allSessions,
            month: _levelProgress.periodStartedAt,
            now: _now,
          ),
          now: _now,
        ),
        TrainingHistoryScreen(
          trainings: _trainings,
          sessions: _allSessions.toList(growable: false),
        ),
        ExerciseProgressScreen(
          trainings: _trainings,
          sessions: _allSessions.toList(growable: false),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _calendarTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(switch (_selectedPage) {
          0 => 'Training',
          1 => 'Dein Rang',
          2 => 'Trainingsverlauf',
          _ => 'Fortschritt',
        }, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          const ThemeModeButton(),

          if (_selectedPage == 0)
            IconButton(
              tooltip: 'Training erstellen',
              icon: const Icon(Icons.add),
              color: Theme.of(context).colorScheme.primary,
              onPressed: _isLoading || _isSaving || _loadError != null
                  ? null
                  : _createTraining,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isSaving) const LinearProgressIndicator(),
          if (_draftProblem != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(_draftProblem!, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: _checkingDraft
                        ? null
                        : () async {
                            await _checkPendingDraft();
                          },
                    child: const Text('Zwischenstand erneut prüfen'),
                  ),
                ],
              ),
            ),
          if (_hasUnsavedChanges && !_isSaving)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Änderungen sind noch nicht auf dem Gerät gespeichert.',
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () async {
                      await _saveData();
                    },
                    child: const Text('Erneut speichern'),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildContent()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedPage,
        onDestinationSelected: (index) {
          setState(() {
            _selectedPage = index;
          });

          unawaited(_refreshRank());
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Training',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Dein Rang',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Verlauf',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Fortschritt',
          ),
        ],
      ),
    );
  }
}
