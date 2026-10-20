
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

  /// Wandelt die Übungsdaten in eine speicherbare Map um.
  Map<String, dynamic> toJson() {
    return {
      id: 'id',
      name: 'name',
      imagePath: 'imagePath',
      muscleGroup: 'muscleGroup',
      equipment: 'equipment',
    };
  }

  /// Stellt eine Übung aus gespeicherten Daten wieder her.
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      imagePath: json['imagePath'] as String,
      muscleGroup: json['muscleGroup'] as String,
      equipment: json['equipment'] as String,
    );  
  } 
  
}