import 'package:repstar/models/exercise.dart';

/// Wiederverwendbare Traingsvorlage, zum Beispiel "Brust & Bizeps".
class TrainingPlan {
  final String id;
  final String name;
  final List<Exercise> exercises;

  /// Erstellt eine Trainingsvorlage mit einer eigenen Übungsliste.
  TrainingPlan({
    required this.id,
    required this.name,
    required List<Exercise> exercises,
  }) : exercises = List<Exercise>.unmodifiable(exercises);

  /// Wandelt das Training inklusive seiner Übungen in eine Map.
  Map<String, dynamic> toJson() {
    return {
      id: 'id',
      name: 'name',

      // Jede übung übernimmt ihre eigene Umwandlung.
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
    };
  }

  /// Stellt ein Training inklusive seiner Übungen wieder her.
  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    final exerciseData = json['exercises'] as List<dynamic>;

    return TrainingPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      exercises: exerciseData.map((item) {
        return Exercise.fromJson(item as Map<String, dynamic>);
      }).toList(),
    );
  }
}
