/// Beschreibt einen Rang und seine Anforderungen pro Kalendermonat.
class LevelDefinition {
  final int number;
  final String name;
  final String description;

  /// Punktzahl, die einem vollständig gefüllten Fortschrittsring entspricht.
  final int targetXp;

  /// Benötigter Anteil des Monatsziels für den Klassenerhalt.
  final int maintenancePercent;

  const LevelDefinition({
    required this.number,
    required this.name,
    required this.description,
    required this.targetXp,
    required this.maintenancePercent,
  }) : assert(number >= 1 && number <= 10),
       assert(targetXp > 0),
       assert(maintenancePercent > 0 && maintenancePercent < 100);

  bool get isHighestLevel => number == 10;

  /// Berechnet die Erhaltungsgrenze und rundet auf ganze Punkte auf.
  ///
  /// Beispiel: 160 × 53 % = 84,8, also werden 85 XP benötigt.
  int get maintenanceXp {
    return (targetXp * maintenancePercent + 99) ~/ 100;
  }

  /// Das volle Monatsziel ermöglicht einen Aufstieg.
  /// Im höchsten Rang ist kein weiterer Aufstieg möglich.
  int? get promotionXp => isHighestLevel ? null : targetXp;
}
