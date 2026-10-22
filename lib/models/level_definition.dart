/// Beschreibt einen Rang und seine benötigten Punkte pro 30-Tage-Runde.
class LevelDefinition {
  final int number;
  final String name;
  final String description;

  /// Mindestpunktzahl, um den Rang zu halten.
  final int maintenanceXp;

  /// Punktzahl für den Aufstieg; beim höchsten Rang gibt es keinen Aufstieg.
  final int? promotionXp;

  const LevelDefinition({
    required this.number,
    required this.name,
    required this.description,
    required this.maintenanceXp,
    required this.promotionXp,
  });

  bool get isHighestLevel => promotionXp == null;
}