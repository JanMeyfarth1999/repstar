import 'dart:math' as math;

import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_reward.dart';
import 'package:repstar/models/training_session.dart';

/// Berechnet Trainingspunkte und eine grobe Kalorienschätzung.
class TrainingRewardService {
  const TrainingRewardService();

  /// Änderungen an der Formel erhalten später eine neue Versionsnummer.
  static const int calculationVersion = 1;

  /// Einheitliches Bezugsgewicht für körpergewichtsunabhängige Rangpunkte.
  static const double referenceBodyWeightKg = 80;

  TrainingReward calculate({
    required TrainingPlan training,
    required TrainingSession session,
  }) {
    if (training.id != session.trainingPlanId) {
      throw ArgumentError(
        'Training und Trainingseinheit gehören nicht zusammen.',
      );
    }

    var completedSets = 0;
    var completedRepetitions = 0;
    var estimatedSeconds = 0.0;

    // Summe aus modellierter Ausführungszeit und zusätzlicher Belastung.
    var effortSeconds = 0.0;

    // Verhindert eine doppelte Wertung bei versehentlich doppelten IDs.
    final processedExerciseIds = <String>{};

    for (final exercise in training.exercises) {
      if (!processedExerciseIds.add(exercise.id)) {
        continue;
      }

      final sets = session.setsByExercise[exercise.id];

      if (sets == null) {
        continue;
      }

      final met = exercise.estimatedMet;
      final secondsPerRepetition = exercise.secondsPerRepetition;

      if (!met.isFinite ||
          met <= 1 ||
          !secondsPerRepetition.isFinite ||
          secondsPerRepetition <= 0) {
        throw ArgumentError(
          'Ungültige Berechnungswerte für "${exercise.name}".',
        );
      }

      for (final workoutSet in sets) {
        final repetitions = workoutSet.repetitions;
        final weight = workoutSet.weight;

        // Nur abgehakte Sätze mit gültigen Eingaben berücksichtigen.
        if (!workoutSet.isCompleted ||
            repetitions == null ||
            repetitions <= 0 ||
            weight == null ||
            !weight.isFinite ||
            weight < 0) {
          continue;
        }

        final setSeconds = repetitions * secondsPerRepetition;

        completedSets += 1;
        completedRepetitions += repetitions;
        estimatedSeconds += setSeconds;

        // Ein MET wird als Ruheanteil abgezogen.
        effortSeconds += setSeconds * (met - 1);
      }
    }

    final elapsedSeconds = math.max(
      0.0,
      session.duration.inMicroseconds / Duration.microsecondsPerSecond,
    );

    // Die geschätzte Ausführungszeit kann nicht länger als die Einheit sein.
    final timeScale = estimatedSeconds > 0
        ? math.min(1.0, elapsedSeconds / estimatedSeconds)
        : 0.0;

    final adjustedActiveSeconds = estimatedSeconds * timeScale;
    final adjustedEffortHours = effortSeconds * timeScale / 3600;

    // Punkte verwenden immer dasselbe Bezugsgewicht.
    final earnedXp = (adjustedEffortHours * referenceBodyWeightKg).round();

    final bodyWeight = session.bodyWeightKg;

    final hasValidBodyWeight =
        bodyWeight != null && bodyWeight.isFinite && bodyWeight > 0;

    final estimatedActiveKcal = hasValidBodyWeight
        ? adjustedEffortHours * bodyWeight
        : null;

    return TrainingReward(
      calculationVersion: calculationVersion,
      earnedXp: earnedXp,
      completedSets: completedSets,
      completedRepetitions: completedRepetitions,
      estimatedActiveSeconds: adjustedActiveSeconds,
      estimatedActiveKcal: estimatedActiveKcal,
    );
  }
}
