import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_session.dart';

/// Bündelt die Daten, die wir gemeinsam speichern und laden.
class TrainingData {
  final List<TrainingPlan> trainings;
  final Map<String, List<TrainingSession>> sessionsByTraining;

  /// Aktuelles Körpergewicht; null bedeutet „noch nicht angegeben“.
  final double? bodyWeightKg;

  TrainingData({
    required this.trainings,
    required this.sessionsByTraining,
    this.bodyWeightKg,
  });

  /// Erstellt den Anfangszustand ohne gespeicherte Trainings.
  factory TrainingData.empty() {
    return TrainingData(
      trainings: [],
      sessionsByTraining: {},
    );
  }

  /// Wandelt Vorlagen, Verlauf und Körpergewicht in speicherbare Daten um.
  Map<String, dynamic> toJson() {
    return {
      'version': 2,
      'bodyWeightKg': bodyWeightKg,
      'trainings': trainings
          .map((training) => training.toJson())
          .toList(),
      'sessionsByTraining': sessionsByTraining.map(
        (trainingId, sessions) => MapEntry(
          trainingId,
          sessions.map((session) => session.toJson()).toList(),
        ),
      ),
    };
  }

  /// Stellt die App-Daten aus dem bisherigen oder neuen Format wieder her.
  factory TrainingData.fromJson(Map<String, dynamic> json) {
    final version = json['version'];

    // Bestehende Dateien der Version 1 bleiben lesbar.
    if (version != 1 && version != 2) {
      throw const FormatException('Unbekanntes Speicherformat.');
    }

    final trainingData = json['trainings'] as List<dynamic>;
    final sessionData =
        json['sessionsByTraining'] as Map<String, dynamic>;

    return TrainingData(
      // Akzeptiert ganze Zahlen und Kommazahlen. Fehlende Werte bleiben null.
      bodyWeightKg: (json['bodyWeightKg'] as num?)?.toDouble(),
      trainings: trainingData.map((item) {
        return TrainingPlan.fromJson(item as Map<String, dynamic>);
      }).toList(),
      sessionsByTraining: sessionData.map(
        (trainingId, value) {
          final sessions = value as List<dynamic>;

          return MapEntry(
            trainingId,
            sessions.map((item) {
              return TrainingSession.fromJson(
                item as Map<String, dynamic>,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}