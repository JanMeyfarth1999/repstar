/// Beschreibt einen einzelnen Satz innerhalb einer Trainingseinheit.
class WorkoutSet {
  /// Gewicht in Kilogramm; null bedeutet noch keine Eingabe.
  double? weight;

  /// Anzahl der Wiederholungen; null bedeutet noch keine Eingabe.
  int? repetitions;

  /// Gibt an, ob der Nutzer diesen Satz abgehakt hat.
  bool isCompleted;

  /// Erstellt einen Satz, der zunächst nicht abgeschlossen ist.
  WorkoutSet({this.weight, this.repetitions, this.isCompleted = false});

  /// Wandelt den Satz in Daten um, die wir als JSON speichern können.
  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'repetitions': repetitions,
      'isCompleted': isCompleted,
    };
  }

  /// Erstellt den Satz aus zuvor gespeicherten Daten.
  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      weight: (json['weight'] as num?)?.toDouble(),
      repetitions: (json['repetitions'] as num?)?.toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
