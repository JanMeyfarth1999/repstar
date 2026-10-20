import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_session.dart';

/// Bündelt die Daten, die wir gemeinsam speichern und laden.
class TrainingData {
  final List<TrainingPlan> trainings;
  final Map<String, List<TrainingSession>> sessionsByTraining;

  TrainingData({
    required this.trainings,
    required this.sessionsByTraining,
  });

  /// Erstellt den Anfangszustand ohne gespeicherte Trainings.
  factory TrainingData.empty() {
    return TrainingData(
      trainings: [],
      sessionsByTraining: {},
    );
  }

  /// Wandelt Vorlagen und Verlauf in speicherbare Daten um.
  Map<String, dynamic> toJson() {
    return {
      'version': 1,
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

  /// Stellt Vorlagen und Verlauf aus gespeicherten Daten wieder her.
  factory TrainingData.fromJson(Map<String, dynamic> json) {
    // Verhindert, dass ein unbekanntes Dateiformat falsch geladen wird.
    if (json['version'] != 1) {
      throw const FormatException('Unbekanntes Speicherformat.');
    }

    final trainingData = json['trainings'] as List<dynamic>;
    final sessionData =
        json['sessionsByTraining'] as Map<String, dynamic>;

    return TrainingData(
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