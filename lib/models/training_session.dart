import 'package:repstar/models/exercise_settings.dart';
import 'package:repstar/models/training_reward.dart';
import 'package:repstar/models/workouts_set.dart';

/// Eine absolvierte Trainingseinheit mit Zeiten, Satzwerten und Auswertung.
class TrainingSession {
  final String trainingPlanId;
  final DateTime startedAt;
  final DateTime endedAt;

  /// Körpergewicht, das beim Start dieser Einheit hinterlegt war.
  final double? bodyWeightKg;

  final Map<String, List<WorkoutSet>> setsByExercise;
  final Map<String, ExerciseSettings> settingsByExercise;

  /// Einmal berechnetes Ergebnis. Bei älteren Einheiten nicht vorhanden.
  final TrainingReward? reward;

  TrainingSession({
    required this.trainingPlanId,
    required this.startedAt,
    required this.endedAt,
    this.bodyWeightKg,
    required Map<String, List<WorkoutSet>> setsByExercise,
    Map<String, ExerciseSettings> settingsByExercise = const {},
    this.reward,
  }) : setsByExercise = Map<String, List<WorkoutSet>>.unmodifiable(
         setsByExercise.map(
           (exerciseId, sets) => MapEntry(
             exerciseId,
             List<WorkoutSet>.unmodifiable(
               sets.map(
                 (workoutSet) => WorkoutSet(
                   weight: workoutSet.weight,
                   repetitions: workoutSet.repetitions,
                   isCompleted: workoutSet.isCompleted,
                 ),
               ),
             ),
           ),
         ),
       ),
       settingsByExercise = Map<String, ExerciseSettings>.unmodifiable(
         settingsByExercise.map(
           (exerciseId, settings) => MapEntry(
             exerciseId,
             ExerciseSettings(
               seatHeight: settings.seatHeight,
               otherAdjustments: settings.otherAdjustments,
             ),
           ),
         ),
       );

  Duration get duration => endedAt.difference(startedAt);

  /// Summiert Gewicht × Wiederholungen aller gültigen erledigten Sätze.
  double get totalVolumeKg {
    var total = 0.0;

    for (final sets in setsByExercise.values) {
      for (final workoutSet in sets) {
        final weight = workoutSet.weight;
        final repetitions = workoutSet.repetitions;

        // Offene Sätze und ungültige Eingaben nicht berücksichtigen.
        if (!workoutSet.isCompleted ||
            weight == null ||
            !weight.isFinite ||
            weight < 0 ||
            repetitions == null ||
            repetitions <= 0) {
          continue;
        }

        total += weight * repetitions;
      }
    }

    return total;
  }

  /// Erstellt eine Kopie mit der berechneten Auswertung.
  TrainingSession withReward(TrainingReward calculatedReward) {
    return TrainingSession(
      trainingPlanId: trainingPlanId,
      startedAt: startedAt,
      endedAt: endedAt,
      bodyWeightKg: bodyWeightKg,
      setsByExercise: setsByExercise,
      settingsByExercise: settingsByExercise,
      reward: calculatedReward,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trainingPlanId': trainingPlanId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'bodyWeightKg': bodyWeightKg,
      'setsByExercise': setsByExercise.map(
        (exerciseId, sets) => MapEntry(
          exerciseId,
          sets.map((workoutSet) => workoutSet.toJson()).toList(),
        ),
      ),
      'settingsByExercise': settingsByExercise.map(
        (exerciseId, settings) => MapEntry(exerciseId, settings.toJson()),
      ),
      'reward': reward?.toJson(),
    };
  }

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    // Unterstützt auch die früher verwendeten Schreibweisen.
    final exerciseData =
        (json['setsByExercise'] ??
                json['setByExercise'] ??
                json['setByexercise'])
            as Map<String, dynamic>;

    final planId =
        (json['trainingPlanId'] ?? json['trainingsPlanId']) as String;

    final endTime = (json['endedAt'] ?? json['endeAt']) as String;

    final settingsData =
        json['settingsByExercise'] as Map<String, dynamic>? ?? {};

    final rewardData = json['reward'] as Map<String, dynamic>?;

    return TrainingSession(
      trainingPlanId: planId,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(endTime),
      bodyWeightKg: (json['bodyWeightKg'] as num?)?.toDouble(),

      // Alte Einheiten erhalten keine nachträglich erfundene Auswertung.
      reward: rewardData == null ? null : TrainingReward.fromJson(rewardData),

      settingsByExercise: settingsData.map(
        (exerciseId, value) => MapEntry(
          exerciseId,
          ExerciseSettings.fromJson(value as Map<String, dynamic>),
        ),
      ),
      setsByExercise: exerciseData.map((exerciseId, value) {
        final setData = value as List<dynamic>;

        return MapEntry(
          exerciseId,
          setData.map((item) {
            return WorkoutSet.fromJson(item as Map<String, dynamic>);
          }).toList(),
        );
      }),
    );
  }
}
