import 'package:repstar/models/level_definition.dart';
import 'package:repstar/models/level_progress.dart';
import 'package:repstar/models/training_session.dart';

/// Wertet monatliche Trainingspunkte und Rangänderungen aus.
class LevelService {
  final List<LevelDefinition> _levels;

  /// Die Rangdefinitionen werden zentral übergeben.
  /// Dadurch verwenden Berechnung und Oberfläche dieselben Anforderungen.
  LevelService({required List<LevelDefinition> levels})
    : _levels = List<LevelDefinition>.unmodifiable(levels) {
    if (_levels.length != 10) {
      throw ArgumentError('Es müssen genau zehn Ränge vorhanden sein.');
    }

    for (var index = 0; index < _levels.length; index++) {
      final definition = _levels[index];
      final promotionXp = definition.promotionXp;
      final isLast = index == _levels.length - 1;

      if (definition.number != index + 1) {
        throw ArgumentError('Die Ränge müssen von 1 bis 10 sortiert sein.');
      }

      if (definition.maintenanceXp < 0 ||
          (!isLast &&
              (promotionXp == null ||
                  promotionXp <= definition.maintenanceXp)) ||
          (isLast && promotionXp != null)) {
        throw ArgumentError(
          'Ungültige Anforderungen für Rang ${definition.number}.',
        );
      }
    }
  }

  /// Liefert die Anforderungen eines bestimmten Rangs.
  LevelDefinition definitionFor(int level) {
    if (level < 1 || level > _levels.length) {
      throw ArgumentError.value(level, 'level', 'Ungültiger Rang.');
    }

    return _levels[level - 1];
  }

  /// Summiert gespeicherte XP innerhalb des angegebenen Kalendermonats.
  ///
  /// Der Abschlusszeitpunkt bestimmt, zu welchem Monat eine Einheit gehört.
  /// Einheiten ohne Auswertung liefern keine XP.
  int monthlyXp({
    required Iterable<TrainingSession> sessions,
    required DateTime month,
    DateTime? now,
  }) {
    final start = LevelProgress.monthStart(month);
    final end = DateTime.utc(start.year, start.month + 1, 1);
    final currentTime = (now ?? DateTime.now()).toUtc();

    var total = 0;

    for (final session in sessions) {
      final finishedAt = session.endedAt.toUtc();

      // Monatsbeginn gehört dazu, der nächste Monatsbeginn nicht mehr.
      if (finishedAt.isBefore(start) ||
          !finishedAt.isBefore(end) ||
          finishedAt.isAfter(currentTime)) {
        continue;
      }

      final xp = session.reward?.earnedXp ?? 0;

      if (xp < 0) {
        throw const FormatException(
          'Eine Trainingseinheit enthält negative Rangpunkte.',
        );
      }

      total += xp;
    }

    return total;
  }

  /// Wertet alle seit der letzten Prüfung abgeschlossenen Monate aus.
  ///
  /// Innerhalb eines Monats bleibt der Rang unverändert.
  /// Pro abgeschlossenem Monat ist höchstens ein Rangwechsel möglich.
  LevelProgress evaluate({
    required LevelProgress progress,
    required Iterable<TrainingSession> sessions,
    DateTime? now,
  }) {
    final currentTime = (now ?? DateTime.now()).toUtc();
    final currentMonth = LevelProgress.monthStart(currentTime);

    var periodStart = LevelProgress.monthStart(progress.periodStartedAt);
    var level = progress.level;

    // Prüft auch den gespeicherten Rang auf Gültigkeit.
    definitionFor(level);

    // Bei zurückgestellter Geräteuhr keine Monate rückwärts auswerten.
    if (periodStart.isAfter(currentMonth)) {
      return progress;
    }

    // Dieselben Einheiten für mehrere Monatsauswertungen verwenden.
    final history = sessions.toList(growable: false);

    while (periodStart.isBefore(currentMonth)) {
      final definition = definitionFor(level);

      final xp = monthlyXp(
        sessions: history,
        month: periodStart,
        now: currentTime,
      );

      final promotionXp = definition.promotionXp;

      if (promotionXp != null && xp >= promotionXp) {
        level += 1;
      } else if (xp < definition.maintenanceXp && level > 1) {
        level -= 1;
      }

      // Automatischer Jahreswechsel bei Dezember.
      periodStart = DateTime.utc(periodStart.year, periodStart.month + 1, 1);
    }

    return LevelProgress(level: level, periodStartedAt: periodStart);
  }
}
