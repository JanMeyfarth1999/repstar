import 'package:repstar/models/workouts_set.dart';

/// Eine absolvierte Trainingseinheit mit Zeiten und Satzwerten.
class TrainingSession {
  final String trainingPlanId;
  final DateTime startedAt;
  final DateTime endedAt;

  /// Ordnet jeder Übungskennung die gespeicherten Sätze zu.
  final Map<String, List<WorkoutSet>> setsByExercise;

  TrainingSession({
    required this.trainingPlanId,
    required this.startedAt,
    required this.endedAt,
    required Map<String, List<WorkoutSet>> setsByExercise,
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
       );

  /// Berechnet die gesamte Trainingsdauer.
  Duration get duration => endedAt.difference(startedAt);

  /// Verwendet beim Speichern einheitliche Feldnamen.
  Map<String, dynamic> toJson() {
    return {
      'trainingPlanId': trainingPlanId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'setsByExercise': setsByExercise.map(
        (exerciseId, sets) => MapEntry(
          exerciseId,
          sets.map((workoutSet) => workoutSet.toJson()).toList(),
        ),
      ),
    };
  }

  /// Liest das korrigierte Format und die bisherigen Feldnamen.
  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    final exerciseData = (
      json['setsByExercise'] ??
      json['setByExercise'] ??
      json['setByexercise']
    ) as Map<String, dynamic>;

    final planId =
        (json['trainingPlanId'] ?? json['trainingsPlanId']) as String;

    final endTime =
        (json['endedAt'] ?? json['endeAt']) as String;

    return TrainingSession(
      trainingPlanId: planId,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(endTime),
      setsByExercise: exerciseData.map((exerciseId, value) {
        final setData = value as List<dynamic>;

        return MapEntry(
          exerciseId,
          setData.map((item) {
            return WorkoutSet.fromJson(
              item as Map<String, dynamic>,
            );
          }).toList(),
        );
      }),
    );
  }
}