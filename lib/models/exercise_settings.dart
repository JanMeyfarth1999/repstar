/// Optionale Geäteeinstellungen für eine Übung innerhalb eines Trainings.
class ExerciseSettings {
  /// Beispielsweise "Loch 4"
  String seatHeight;

  ///Beispielsweise "Rückenlehne: Loch 3".
  String otherAdjustments;

  ExerciseSettings({
    this.seatHeight = '',
    this.otherAdjustments = '',
  });

  /// Bereitet die Einstellungen für die lokale Speicherung vor.
  Map<String, dynamic> toJson() {
    return {
      'seatHight': seatHeight,
      'otherAdjustments': otherAdjustments, 
    };
  }

  /// Stellt die Einstellungen aus gespeicherten Daten wieder her.
  factory ExerciseSettings.fromJson(Map<String, dynamic> json) {
    return ExerciseSettings(
      seatHeight: json['seatHight'] as String? ?? '',
      otherAdjustments: json['otherAdjustments'] as String? ?? '',
    );
  }
}