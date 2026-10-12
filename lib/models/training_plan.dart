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
}