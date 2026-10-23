import 'package:repstar/models/level_progress.dart';
import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_session.dart';

/// Bündelt Trainings, Körpergewicht und den persönlichen Rang.
class TrainingData {
  final List<TrainingPlan> trainings;
  final Map<String, List<TrainingSession>> sessionsByTraining;

  /// Aktuelles Körpergewicht; null bedeutet „noch nicht angegeben“.
  final double? bodyWeightKg;

  /// Speichert den Rang und den dazugehörigen Kalendermonat.
  final LevelProgress levelProgress;

  TrainingData({
    required this.trainings,
    required this.sessionsByTraining,
    this.bodyWeightKg,
    LevelProgress? levelProgress,
  }) : levelProgress = levelProgress ?? LevelProgress.initial();

  /// Erstellt den Anfangszustand mit Rang 1 im aktuellen Monat.
  factory TrainingData.empty() {
    return TrainingData(trainings: [], sessionsByTraining: {});
  }

  /// Wandelt alle App-Daten in speicherbare Daten um.
  Map<String, dynamic> toJson() {
    return {
      'version': 3,
      'bodyWeightKg': bodyWeightKg,
      'levelProgress': levelProgress.toJson(),
      'trainings': trainings.map((training) => training.toJson()).toList(),
      'sessionsByTraining': sessionsByTraining.map(
        (trainingId, sessions) => MapEntry(
          trainingId,
          sessions.map((session) => session.toJson()).toList(),
        ),
      ),
    };
  }

  /// Liest das aktuelle Format und die bisherigen Versionen.
  factory TrainingData.fromJson(Map<String, dynamic> json) {
    final version = json['version'];

    if (version != 1 && version != 2 && version != 3) {
      throw const FormatException('Unbekanntes Speicherformat.');
    }

    final trainingData = json['trainings'] as List<dynamic>;
    final sessionData = json['sessionsByTraining'] as Map<String, dynamic>;

    // Version 3 muss einen Rangfortschritt enthalten.
    // Beschädigte neue Daten werden nicht still auf Rang 1 zurückgesetzt.
    final LevelProgress progress;

    if (version == 3) {
      final progressData = json['levelProgress'];

      if (progressData is! Map<String, dynamic>) {
        throw const FormatException('Der Rangfortschritt fehlt.');
      }

      progress = LevelProgress.fromJson(progressData);
    } else {
      // Bestehende Nutzer starten bei Einführung des Systems auf Rang 1.
      progress = LevelProgress.initial();
    }

    return TrainingData(
      bodyWeightKg: (json['bodyWeightKg'] as num?)?.toDouble(),
      levelProgress: progress,
      trainings: trainingData.map((item) {
        return TrainingPlan.fromJson(item as Map<String, dynamic>);
      }).toList(),
      sessionsByTraining: sessionData.map((trainingId, value) {
        final sessions = value as List<dynamic>;

        return MapEntry(
          trainingId,
          sessions.map((item) {
            return TrainingSession.fromJson(item as Map<String, dynamic>);
          }).toList(),
        );
      }),
    );
  }
}
