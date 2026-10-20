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

  /// Wandelt die Trainigseinheit in speicherbare Daten um.
  Map<String, dynamic> toJson() {
    return {
      'trainingsPlanId': trainingPlanId,

      // Zeitpunte als Text speichern.
      'startedAt': startedAt.toIso8601String(),
      'endeAt': startedAt.toIso8601String(),

      // Jeder Satz verwendet seine eigene toJson-Methode.
      'setByExercise': setsByExercise.map(
        (exerciseId, sets) => MapEntry(
          exerciseId,
          sets.map((workoutSet) => workoutSet.toJson()).toList(),
        ),
      ),
    };
  }

  /// Stellt die Trainingseinheit aus gespeicherten Daten wieder her
  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    final exerciseData = json['setByexercise'] as Map<String, dynamic>;

    return TrainingSession(
      trainingPlanId: json['trainingPlanId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
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
