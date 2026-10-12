
/// Beschreibt eine Übung aus der Übungsbibliothek
class Exercise {
  final String id;
  final String name;
  final String imagePath;
  final String muscleGroup;
  final String equipment;

  /// Erstellt eine Übung mit allen benötigten Angaben.
  const Exercise({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.muscleGroup,
    required this.equipment,
  });
  
}