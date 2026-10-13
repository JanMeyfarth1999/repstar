/// Beschreibt einen einzelnen Satz innerhalb einer Trainingseinheit.
class WorkoutSet {
  /// Gewicht in Kilogramm; null bedeutet noch keine Eingabe.
  double? weight;

  /// Anzahl der Wiederholungen; null bedeutet noch keine Eingabe.
  int? repetitions;

  /// Gibt an, ob der Nutzer diesen Satz abgehakt hat.
  bool isCompleted;

  /// Erstellt einen Satz, der zunächst nicht abgeschlossen ist.
  WorkoutSet({
    this.weight,
    this.repetitions,
    this.isCompleted = false,
  });
}