import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_session.dart';

/// Wiederherstellbarer Zwischenstand eines laufenden Trainings.
class ActiveTrainingDraft {
  /// Eigene Trainingsvorlage für die Wiederherstellung.
  final TrainingPlan training;

  /// Enthält Startzeit, Körpergewicht, Sätze und Geräteeinstellungen.
  ///
  /// endedAt entspricht hier dem Zeitpunkt der letzten Sicherung.
  /// Der Zwischenstand wird dadurch noch nicht zum Trainingsverlauf.
  final TrainingSession snapshot;

  /// Ausgewählte Pausenlänge.
  final int restDurationSeconds;

  /// Endzeit einer laufenden Satzpause.
  final DateTime? restEndsAt;

  /// Kennung der aktuell geöffneten Übung.
  final String? expandedExerciseId;

  /// Kennzeichnet einen fertigen, noch nicht sicher übernommenen Abschluss.
  ///
  /// Damit können wir später verhindern, dass eine Einheit bei einem
  /// Absturz zwischen Abschluss und Speicherung verloren geht.
  final bool isFinished;

  ActiveTrainingDraft({
    required this.training,
    required this.snapshot,
    this.restDurationSeconds = 90,
    this.restEndsAt,
    this.expandedExerciseId,
    this.isFinished = false,
  }) {
    if (training.id != snapshot.trainingPlanId) {
      throw ArgumentError(
        'Zwischenstand und Trainingsvorlage gehören nicht zusammen.',
      );
    }

    if (restDurationSeconds <= 0) {
      throw ArgumentError('Die Pausenlänge muss größer als null sein.');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'training': training.toJson(),
      'snapshot': snapshot.toJson(),
      'restDurationSeconds': restDurationSeconds,
      'restEndsAt': restEndsAt?.toIso8601String(),
      'expandedExerciseId': expandedExerciseId,
      'isFinished': isFinished,
    };
  }

  factory ActiveTrainingDraft.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1) {
      throw const FormatException(
        'Unbekanntes Format für den Trainingszwischenstand.',
      );
    }

    final trainingData = json['training'];
    final snapshotData = json['snapshot'];

    if (trainingData is! Map<String, dynamic> ||
        snapshotData is! Map<String, dynamic>) {
      throw const FormatException(
        'Der Trainingszwischenstand ist unvollständig.',
      );
    }

    final restEndText = json['restEndsAt'] as String?;
    DateTime? restEndsAt;

    if (restEndText != null) {
      restEndsAt = DateTime.tryParse(restEndText);

      if (restEndsAt == null) {
        throw const FormatException('Ungültige Endzeit der Satzpause.');
      }
    }

    return ActiveTrainingDraft(
      training: TrainingPlan.fromJson(trainingData),
      snapshot: TrainingSession.fromJson(snapshotData),
      restDurationSeconds: json['restDurationSeconds'] as int? ?? 90,
      restEndsAt: restEndsAt,
      expandedExerciseId: json['expandedExerciseId'] as String?,
      isFinished: json['isFinished'] as bool? ?? false,
    );
  }
}
