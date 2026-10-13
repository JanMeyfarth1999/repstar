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
}