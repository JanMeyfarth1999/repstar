import 'dart:math' as math;

import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_reward.dart';
import 'package:repstar/models/training_session.dart';

/// Berechnet Trainingspunkte und eine grobe Kalorienschätzung.
class TrainingRewardService {
  const TrainingRewardService();

  /// Version 3 schätzt Kalorien über die gesamte Trainingseinheit.
  static const int calculationVersion = 3;

  /// Gemeinsame Mindestdauer für Berechnung und Monatsauswertung.
  static const Duration minimumXpDuration = Duration(minutes: 30);

  /// Einheitliches Bezugsgewicht für körpergewichtsunabhängige Rangpunkte.
  static const double referenceBodyWeightKg = 80;

  /// Grober Durchschnitt für Krafttraining mit mehreren Übungen.
  /// Quelle: 2024 Adult Compendium, Aktivität 02054 (3,5 MET).
  /// Als Modell für eine Einheit mit üblichen Satzpausen verwendet.
  /// Längere Unterbrechungen oder tatsächliche Intensität erkennt es nicht.
  static const double sessionAverageMet = 3.5;

  /// Prüft ausschließlich die zeitliche Voraussetzung.
  ///
  /// Gültige abgeschlossene Sätze werden zusätzlich in calculate geprüft.
  static bool meetsMinimumXpDuration(TrainingSession session) {
    return session.duration >= minimumXpDuration;
  }

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
    var effortSeconds = 0.0;

    // Verhindert eine doppelte Wertung bei doppelten Übungskennungen.
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

    // Die geschätzte Ausführungszeit darf die Gesamtdauer nicht überschreiten.
    final timeScale = estimatedSeconds > 0
        ? math.min(1.0, elapsedSeconds / estimatedSeconds)
        : 0.0;

    final adjustedActiveSeconds = estimatedSeconds * timeScale;
    final adjustedEffortHours = effortSeconds * timeScale / 3600;

    // Erst ab 30 Minuten Gesamtdauer werden Punkte vergeben.
    // Längeres Warten erhöht die berechneten Satzpunkte nicht.
    final earnedXp = meetsMinimumXpDuration(session)
        ? (adjustedEffortHours * referenceBodyWeightKg).round()
        : 0;

    final bodyWeight = session.bodyWeightKg;

    final hasValidBodyWeight =
        bodyWeight != null && bodyWeight.isFinite && bodyWeight > 0;

    // Kalorien werden unabhängig von den XP über die gesamte Einheit
    // geschätzt. Der MET-Wert beschreibt den Durchschnitt der Einheit,
    // nicht nur die kurzen Ausführungszeiten der einzelnen Sätze.
    //
    // Näherung: aktive kcal = (MET - 1) × kg × Stunden.
    // Ein MET wird als Ruheanteil abgezogen. Übliche Satzpausen sind
    // Teil des angenommenen Einheitsdurchschnitts, kein Nachverbrauch.
    // Ohne gültigen abgeschlossenen Satz wird kein Training angenommen.
    final estimatedActiveKcal = hasValidBodyWeight
        ? completedSets == 0
              ? 0.0
              : (sessionAverageMet - 1) * bodyWeight * elapsedSeconds / 3600
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
