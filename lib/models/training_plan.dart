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
      'id': id,
      'name': name,

      // Jede übung übernimmt ihre eigene Umwandlung.
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
    };
  }

  /// Stellt ein Training inklusive seiner Übungen wieder her.
  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    final exerciseData = json['exercises'] as List<dynamic>;

    return TrainingPlan(
      id: _readText(json, 'id'),
      name: _readText(json, 'name'),
      exercises: exerciseData.map((item) {
        return Exercise.fromJson(item as Map<String, dynamic>);
      }).toList(),
    );
  }

  /// Liest korrekte Felder und unterstützt die zuvor vertauschten Daten.
  static String _readText(Map<String, dynamic> json, String fieldName) {
    final value = json[fieldName];

    if (value is String) {
      return value;
    }

    // Alte Schreibweise beispielweise "Brust & Bizeps": "name".
    // In diesem Fall ist der gesuchte Text im Schlüssel gespeichert.

    final matches = json.entries
        .where((entry) => entry.value == fieldName)
        .toList();

    if (matches.length == 1) {
      return matches.single.key;
    }

    throw FormatException(
      'Das Feld "$fieldName" konnte nicht wiederhergestellt werden.',
    );
  }
}
