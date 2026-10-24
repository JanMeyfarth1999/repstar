import 'package:flutter/material.dart';
import 'package:repstar/data/exercise_library.dart';
import 'package:repstar/models/exercise.dart';
import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_session.dart';
import 'package:repstar/services/training_reward_service.dart';
import 'package:repstar/widgets/exercise_image.dart';

/// Zeigt alle abgeschlossenen Trainingseinheiten, neueste zuerst.
class TrainingHistoryScreen extends StatelessWidget {
  final List<TrainingPlan> trainings;
  final List<TrainingSession> sessions;

  const TrainingHistoryScreen({
    super.key,
    required this.trainings,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 64, color: colors.primary),
              const SizedBox(height: 20),
              const Text(
                'Dein Trainingsverlauf',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Nach deinem ersten abgeschlossenen Training '
                'findest du hier deine Ergebnisse.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    final trainingsById = {
      for (final training in trainings) training.id: training,
    };

    // Eine Kopie sortieren, damit die gespeicherte Reihenfolge erhalten bleibt.
    final sortedSessions = List<TrainingSession>.of(sessions)
      ..sort((first, second) {
        return second.endedAt.compareTo(first.endedAt);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedSessions.length,
      itemBuilder: (context, index) {
        final session = sortedSessions[index];
        final training = trainingsById[session.trainingPlanId];

        final completedSets = session.setsByExercise.values
            .expand((sets) => sets)
            .where((set) => set.isCompleted)
            .length;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Icon(Icons.fitness_center, color: colors.primary),
            title: Text(
              training?.name ?? 'Training ohne vorhandene Vorlage',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${_HistoryFormat.dateTime(session.startedAt)}\n'
                '${_HistoryFormat.duration(session.duration)}'
                ' · $completedSets Sätze\n'
                '${session.reward == null ? 'Keine Punkteauswertung' : '+${_HistoryFormat.rankXp(session)} XP'}',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) => _TrainingSessionDetailsScreen(
                    session: session,
                    training: training,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Zeigt die gespeicherten Werte genau einer Trainingseinheit.
class _TrainingSessionDetailsScreen extends StatelessWidget {
  final TrainingSession session;
  final TrainingPlan? training;

  const _TrainingSessionDetailsScreen({
    required this.session,
    required this.training,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final reward = session.reward;
    final calories = reward?.estimatedActiveKcal;

    // Auch aus einer Vorlage entfernte Übungen über die Bibliothek finden.
    final exercisesById = <String, Exercise>{
      for (final exercise in exerciseLibrary) exercise.id: exercise,
    };

    final currentTraining = training;

    if (currentTraining != null) {
      for (final exercise in currentTraining.exercises) {
        exercisesById[exercise.id] = exercise;
      }
    }

    final completedSets = session.setsByExercise.values
        .expand((sets) => sets)
        .where((set) => set.isCompleted)
        .length;

    return Scaffold(
      appBar: AppBar(title: Text(training?.name ?? 'Trainingseinheit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Zusammenfassung',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _DetailLine(
                    label: 'Beginn',
                    value: _HistoryFormat.dateTime(session.startedAt),
                  ),
                  _DetailLine(
                    label: 'Ende',
                    value: _HistoryFormat.dateTime(session.endedAt),
                  ),
                  _DetailLine(
                    label: 'Dauer',
                    value: _HistoryFormat.duration(session.duration),
                  ),
                  _DetailLine(
                    label: 'Abgeschlossene Sätze',
                    value: '$completedSets',
                  ),
                  _DetailLine(
                    label: 'Bewegtes Gewicht',
                    value: '${_HistoryFormat.weight(session.totalVolumeKg)} kg',
                  ),
                  _DetailLine(
                    label: 'Körpergewicht beim Start',
                    value: session.bodyWeightKg == null
                        ? 'Nicht angegeben'
                        : '${_HistoryFormat.weight(session.bodyWeightKg)} kg',
                  ),
                  _DetailLine(
                    label: 'Rangpunkte',
                    value: reward == null
                        ? 'Keine Auswertung'
                        : '${_HistoryFormat.rankXp(session)} XP',
                  ),
                  if (!TrainingRewardService.meetsMinimumXpDuration(session))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Keine Rangpunkte: Die Mindestdauer von '
                        '${TrainingRewardService.minimumXpDuration.inMinutes} '
                        'Minuten wurde nicht erreicht.',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ),
                  _DetailLine(
                    label: 'Geschätzte aktive Kalorien',
                    value: calories == null
                        ? 'Nicht verfügbar'
                        : 'ca. ${calories.round()} kcal',
                  ),
                  if (calories != null)
                    Text(
                      reward!.calculationVersion >= 3
                          ? 'Grobe Schätzung für die gesamte Einheit '
                                'mit üblichen Satzpausen, abzüglich Ruheanteil.'
                          : 'Ältere Berechnung: berücksichtigt nur die '
                                'geschätzte Satz-Ausführungszeit.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Übungen und Sätze',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Die Satzwerte stammen aus der abgeschlossenen Einheit.
          for (final entry in session.setsByExercise.entries)
            _buildExerciseCard(context, entry.key, exercisesById[entry.key]),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    String exerciseId,
    Exercise? exercise,
  ) {
    final colors = Theme.of(context).colorScheme;
    final sets = session.setsByExercise[exerciseId]!;
    final settings = session.settingsByExercise[exerciseId];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ExerciseImage(
                    imagePath: exercise?.imagePath ?? '',
                    width: 56,
                    height: 56,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exercise?.name ?? 'Übung: $exerciseId',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Optionale Geräteeinstellungen dieser damaligen Einheit.
            if (settings != null) ...[
              if (settings.seatHeight.trim().isNotEmpty)
                _DetailLine(label: 'Sitzhöhe', value: settings.seatHeight),
              if (settings.otherAdjustments.trim().isNotEmpty)
                _DetailLine(
                  label: 'Weitere Einstellungen',
                  value: settings.otherAdjustments,
                ),
            ],

            for (var index = 0; index < sets.length; index++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 58,
                      child: Text(
                        'Satz ${index + 1}',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${sets[index].repetitions ?? '—'} Wdh.'
                        ' · ${_HistoryFormat.weight(sets[index].weight)} kg',
                      ),
                    ),
                    Icon(
                      sets[index].isCompleted
                          ? Icons.check_circle_outline
                          : Icons.radio_button_unchecked,
                      color: sets[index].isCompleted
                          ? colors.primary
                          : colors.onSurfaceVariant,
                      semanticLabel: sets[index].isCompleted
                          ? 'Satz abgeschlossen'
                          : 'Satz nicht abgeschlossen',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Gemeinsame Darstellung für Angaben in der Detailansicht.
class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(value),
        ],
      ),
    );
  }
}

/// Gemeinsame Formatierung für Übersicht und Detailansicht.
class _HistoryFormat {
  _HistoryFormat._();

  static String dateTime(DateTime date) {
    final local = date.toLocal();

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${twoDigits(local.day)}.${twoDigits(local.month)}.'
        '${local.year} · ${twoDigits(local.hour)}:'
        '${twoDigits(local.minute)}';
  }

  static String duration(Duration duration) {
    final totalSeconds = duration.isNegative ? 0 : duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours Std. $minutes Min. $seconds Sek.';
    }

    return '$minutes Min. $seconds Sek.';
  }

  static String weight(double? value) {
    if (value == null) {
      return '—';
    }

    // Ganze Gewichte ohne .0 anzeigen, Nachkommastellen erhalten.
    return value
        .toString()
        .replaceFirst(RegExp(r'\.0$'), '')
        .replaceAll('.', ',');
  }

  static int rankXp(TrainingSession session) {
    // Alte kurze Testeinheiten liefern auch im Verlauf keine Rangpunkte.
    if (!TrainingRewardService.meetsMinimumXpDuration(session)) {
      return 0;
    }

    return session.reward?.earnedXp ?? 0;
  }
}
