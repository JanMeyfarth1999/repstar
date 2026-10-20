import 'package:flutter/material.dart';
import 'package:repstar/models/training_data.dart';
import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_session.dart';
import 'package:repstar/screens/active_training_screen.dart';
import 'package:repstar/screens/create_training_screen.dart';
import 'package:repstar/services/storage_service.dart';

/// Zeigt Trainingsvorlagen und verwaltet ihre lokale Speicherung.
class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final StorageService _storageService = StorageService();

  final List<TrainingPlan> _trainings = [];
  final Map<String, List<TrainingSession>> _sessionsByTraining = {};

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();

    // Beim Öffnen des Bildschirms vorhandene Daten laden.
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final data = await _storageService.load();

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

        _isLoading = false;
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
      // Zeigt die Datei und Zeile, in der das Einlesen scheitert.
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Gemeinsame Speichermethode für Vorlagen und Trainingseinheiten.
  Future<bool> _saveData() async {
    if (_isSaving) {
      return false;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _storageService.save(
        TrainingData(
          trainings: _trainings,
          sessionsByTraining: _sessionsByTraining,
        ),
      );

      if (!mounted) {
        return false;
      }

      setState(() {
        _isSaving = false;
        _hasUnsavedChanges = false;
      });

      return true;
    } catch (error) {
      if (!mounted) {
        return false;
      }

      // Die Daten bleiben im Speicher und können erneut gesichert werden.
      setState(() {
        _isSaving = false;
        _hasUnsavedChanges = true;
      });

      debugPrint('Fehler beim Speichern: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speichern fehlgeschlagen. Bitte erneut versuchen.'),
        ),
      );

      return false;
    }
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
      _hasUnsavedChanges = true;
    });

    await _saveData();
  }

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
      final sessions = _sessionsByTraining.putIfAbsent(
        training.id,
        () => [],
      );

      sessions.add(session);
      _hasUnsavedChanges = true;
    });

    final saved = await _saveData();

    if (!mounted || !saved) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trainingseinheit gespeichert.'),
      ),
    );
  }

  /// Zeigt je nach Ladezustand den passenden Inhalt.
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _loadError!,
                textAlign: TextAlign.center,
              ),
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

    if (_trainings.isEmpty) {
      return const Center(
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
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trainings.length,
      itemBuilder: (context, index) {
        final training = _trainings[index];
        final history = _sessionsByTraining[training.id];
        final lastSession =
            history == null || history.isEmpty ? null : history.last;

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
                  onPressed: _isSaving
                      ? null
                      : () => _startTraining(training),
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
            onPressed: _isLoading || _isSaving || _loadError != null
                ? null
                : _createTraining,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSaving) const LinearProgressIndicator(),

          // Bleibt sichtbar, solange Änderungen nicht gesichert sind.
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

          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
}