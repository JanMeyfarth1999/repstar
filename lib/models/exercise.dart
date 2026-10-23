/// Beschreibt eine Übung aus der Übungsbibliothek.
class Exercise {
  final String id;
  final String name;
  final String imagePath;
  final String muscleGroup;
  final String equipment;

  /// Modellwert für die Belastung, keine individuelle Messung.
  final double estimatedMet;

  /// Angenommene Ausführungszeit je Wiederholung.
  final double secondsPerRepetition;

  const Exercise({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.muscleGroup,
    required this.equipment,
    this.estimatedMet = 3.5,
    this.secondsPerRepetition = 3,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
      'estimatedMet': estimatedMet,
      'secondsPerRepetition': secondsPerRepetition,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: _readText(json, 'id'),
      name: _readText(json, 'name'),
      imagePath: _readText(json, 'imagePath'),
      muscleGroup: _readText(json, 'muscleGroup'),
      equipment: _readText(json, 'equipment'),

      // Ältere gespeicherte Übungen verwenden die Standardannahmen.
      estimatedMet: (json['estimatedMet'] as num?)?.toDouble() ?? 3.5,
      secondsPerRepetition:
          (json['secondsPerRepetition'] as num?)?.toDouble() ?? 3,
    );
  }

  /// Unterstützt auch die früher vertauschten Schlüssel und Werte.
  static String _readText(Map<String, dynamic> json, String fieldName) {
    final value = json[fieldName];

    if (value is String) {
      return value;
    }

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
