import 'package:repstar/models/exercise_settings.dart';
import 'package:repstar/models/workouts_set.dart';

/// Eine absolvierte Trainingseinheit mit Zeiten und Satzwerten.
class TrainingSession {
  final String trainingPlanId;
  final DateTime startedAt;
  final DateTime endedAt;

  /// Körpergewicht, das für diese Einheit verwendet wurde.
  /// Bei älteren Einheiten oder fehlender Eingabe ist es unbekannt.
  final double? bodyWeightKg;

  /// Ordnet jeder Übungskennung die gespeicherten Sätze zu.
  final Map<String, List<WorkoutSet>> setsByExercise;

  /// Optionale Geräteeinstellungen, zugeordnet über die Übungskennung.
  final Map<String, ExerciseSettings> settingsByExercise;

  TrainingSession({
    required this.trainingPlanId,
    required this.startedAt,
    required this.endedAt,
    this.bodyWeightKg,
    required Map<String, List<WorkoutSet>> setsByExercise,
    Map<String, ExerciseSettings> settingsByExercise = const {},
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
       settingsByExercise =
           Map<String, ExerciseSettings>.unmodifiable(
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

  /// Berechnet die gesamte Trainingsdauer.
  Duration get duration => endedAt.difference(startedAt);

  /// Wandelt die abgeschlossene Einheit in speicherbare Daten um.
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
        (exerciseId, settings) => MapEntry(
          exerciseId,
          settings.toJson(),
        ),
      ),
    };
  }

  /// Liest das aktuelle Format und die früher verwendeten Feldnamen.
  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    // Unterstützt auch die früheren Schreibweisen.
    final exerciseData =
        (json['setsByExercise'] ??
                json['setByExercise'] ??
                json['setByexercise'])
            as Map<String, dynamic>;

    final planId =
        (json['trainingPlanId'] ?? json['trainingsPlanId']) as String;

    final endTime =
        (json['endedAt'] ?? json['endeAt']) as String;

    // Alte Einheiten enthalten noch keine Geräteeinstellungen.
    final settingsData =
        json['settingsByExercise'] as Map<String, dynamic>? ?? {};

    return TrainingSession(
      trainingPlanId: planId,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(endTime),

      // Für alte Einheiten wird kein Körpergewicht nachträglich erfunden.
      bodyWeightKg: (json['bodyWeightKg'] as num?)?.toDouble(),

      settingsByExercise: settingsData.map(
        (exerciseId, value) => MapEntry(
          exerciseId,
          ExerciseSettings.fromJson(
            value as Map<String, dynamic>,
          ),
        ),
      ),
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