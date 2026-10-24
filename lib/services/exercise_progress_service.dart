import 'package:repstar/models/training_session.dart';

/// Ergebnisse einer Übung innerhalb einer abgeschlossenen Einheit.
class ExerciseProgressPoint {
  final TrainingSession session;
  final double maxWeightKg;
  final double volumeKg;
  final int completedSets;
  final int repetitions;

  const ExerciseProgressPoint({
    required this.session,
    required this.maxWeightKg,
    required this.volumeKg,
    required this.completedSets,
    required this.repetitions,
  });
}

/// Fasst gespeicherte Satzdaten pro Übung und Einheit zusammen.
class ExerciseProgressService {
  const ExerciseProgressService();

  Map<String, List<ExerciseProgressPoint>> buildHistory(
    Iterable<TrainingSession> sessions,
  ) {
    final history = <String, List<ExerciseProgressPoint>>{};

    for (final session in sessions) {
      for (final entry in session.setsByExercise.entries) {
        var completedSets = 0;
        var repetitions = 0;
        var maxWeight = 0.0;
        var volume = 0.0;

        for (final set in entry.value) {
          final weight = set.weight;
          final reps = set.repetitions;

          // Nur gültige abgehakte Sätze berücksichtigen.
          if (!set.isCompleted ||
              weight == null ||
              !weight.isFinite ||
              weight < 0 ||
              reps == null ||
              reps <= 0) {
            continue;
          }

          final setVolume = weight * reps;

          if (!setVolume.isFinite || !(volume + setVolume).isFinite) {
            continue;
          }

          completedSets += 1;
          repetitions += reps;
          volume += setVolume;

          if (weight > maxWeight) {
            maxWeight = weight;
          }
        }

        // Ohne gültigen erledigten Satz entsteht kein Datenpunkt.
        if (completedSets == 0) {
          continue;
        }

        history
            .putIfAbsent(entry.key, () => [])
            .add(
              ExerciseProgressPoint(
                session: session,
                maxWeightKg: maxWeight,
                volumeKg: volume,
                completedSets: completedSets,
                repetitions: repetitions,
              ),
            );
      }
    }

    // Nur die neuen Ergebnislisten sortieren.
    // Die gespeicherten Trainingseinheiten werden nicht verändert.
    for (final points in history.values) {
      points.sort((first, second) {
        return first.session.endedAt.compareTo(second.session.endedAt);
      });
    }

    return history;
  }
}
