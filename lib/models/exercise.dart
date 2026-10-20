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
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
    };
  }

  /// Stellt eine Übung aus gespeicherten Daten wieder her.
factory Exercise.fromJson(Map<String, dynamic> json) {
  return Exercise(
    id: _readText(json, 'id'),
    name: _readText(json, 'name'),
    imagePath: _readText(json, 'imagePath'),
    muscleGroup: _readText(json, 'muscleGroup'),
    equipment: _readText(json, 'equipment'),
  );
}

  /// Unterstützt auch die zuvor vertauschten Schlüssel und Werte.
  static String _readText(Map<String, dynamic> json, String fieldName) {
    final value = json[fieldName];

    if (value is String) {
      return value;
    }

    // Bei den alten Daten steckt der tatsächliche Wert im Schlüssel.
    final matches = json.entries
        .where((entry) => entry.value == fieldName)
        .toList();

    if (matches.length == 1) {
      return matches.single.key;
    }

    throw FormatException(
      'Das Übungsfeld "$fieldName" konnte nicht wiederhergestellt werden.',
    );
  }
}
