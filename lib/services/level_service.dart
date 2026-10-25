import 'package:repstar/models/level_definition.dart';
import 'package:repstar/models/level_progress.dart';
import 'package:repstar/models/training_session.dart';
import 'package:repstar/services/training_reward_service.dart';

/// Wertet monatliche Trainingspunkte, Level und Prestige aus.
class LevelService {
  final List<LevelDefinition> _levels;

  LevelService({required List<LevelDefinition> levels})
    : _levels = List<LevelDefinition>.unmodifiable(levels) {
    if (_levels.length != LevelProgress.maxLevel) {
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

  /// Anforderungen bleiben in jedem Prestige gleich.
  LevelDefinition definitionFor(int level) {
    if (level < 1 || level > _levels.length) {
      throw ArgumentError.value(level, 'level', 'Ungültiger Rang.');
    }

    return _levels[level - 1];
  }

  /// Summiert gültige Punkte innerhalb eines Kalendermonats.
  ///
  /// Nach einem Prestige-Wechsel werden nur Einheiten berücksichtigt,
  /// die ab xpStartedAt begonnen wurden.
  int monthlyXp({
    required Iterable<TrainingSession> sessions,
    required DateTime month,
    DateTime? now,
    DateTime? xpStartedAt,
  }) {
    final start = LevelProgress.monthStart(month);
    final end = DateTime.utc(start.year, start.month + 1, 1);
    final currentTime = (now ?? DateTime.now()).toUtc();
    final countingStart = xpStartedAt?.toUtc();

    var total = 0;

    for (final session in sessions) {
      final finishedAt = session.endedAt.toUtc();

      if (finishedAt.isBefore(start) ||
          !finishedAt.isBefore(end) ||
          finishedAt.isAfter(currentTime)) {
        continue;
      }

      // Bereits vor dem Prestige-Wechsel gestartete Einheiten
      // dürfen nicht im neuen Durchlauf zählen.
      if (countingStart != null &&
          session.startedAt.toUtc().isBefore(countingStart)) {
        continue;
      }

      // Die Mindestdauer gilt auch für ältere Trainingseinheiten.
      if (!TrainingRewardService.meetsMinimumXpDuration(session)) {
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

  /// Wertet alle abgeschlossenen, noch offenen Kalendermonate aus.
  LevelProgress evaluate({
    required LevelProgress progress,
    required Iterable<TrainingSession> sessions,
    DateTime? now,
  }) {
    final currentTime = (now ?? DateTime.now()).toUtc();
    final currentMonth = LevelProgress.monthStart(currentTime);

    var periodStart = LevelProgress.monthStart(progress.periodStartedAt);
    var level = progress.level;
    var prestige = progress.prestige;
    var xpStartedAt = progress.xpStartedAt?.toUtc();

    definitionFor(level);

    // Bei zurückgestellter Geräteuhr keine Monate rückwärts auswerten.
    if (periodStart.isAfter(currentMonth)) {
      return progress;
    }

    // Dieselbe Historie wird für alle offenen Monate wiederverwendet.
    final history = sessions.toList(growable: false);

    while (periodStart.isBefore(currentMonth)) {
      final definition = definitionFor(level);

      final xp = monthlyXp(
        sessions: history,
        month: periodStart,
        now: currentTime,
        xpStartedAt: xpStartedAt,
      );

      final promotionXp = definition.promotionXp;

      if (promotionXp != null && xp >= promotionXp) {
        // Pro abgeschlossenem Monat höchstens ein Level aufsteigen.
        level += 1;
      } else if (xp < definition.maintenanceXp) {
        if (level > 1) {
          level -= 1;
        } else if (prestige > 0) {
          // Unter Level 1 geht es ins vorherige Prestige, Level 10.
          prestige -= 1;
          level = LevelProgress.maxLevel;
        }

        // Ohne Prestige bleibt Level 1 die Untergrenze.
      }

      periodStart = DateTime.utc(periodStart.year, periodStart.month + 1, 1);

      // Nach dem Wechselmonat genügt wieder die normale Monatsgrenze.
      if (xpStartedAt != null && !xpStartedAt.isAfter(periodStart)) {
        xpStartedAt = null;
      }
    }

    return LevelProgress(
      level: level,
      prestige: prestige,

      // Trophäen bleiben bei jedem Abstieg erhalten.
      highestPrestige: progress.highestPrestige,
      periodStartedAt: periodStart,
      xpStartedAt: xpStartedAt,
    );
  }

  /// Wechselt freiwillig von Level 10 ins nächste Prestige, Level 1.
  LevelProgress enterPrestige({
    required LevelProgress progress,
    required Iterable<TrainingSession> sessions,
    DateTime? now,
  }) {
    final currentTime = (now ?? DateTime.now()).toUtc();

    // Vor dem Wechsel zuerst eventuell vergangene Monate auswerten.
    final evaluated = evaluate(
      progress: progress,
      sessions: sessions,
      now: currentTime,
    );

    if (evaluated.periodStartedAt.isAfter(
      LevelProgress.monthStart(currentTime),
    )) {
      throw StateError('Die Gerätezeit liegt vor der gespeicherten Rangrunde.');
    }

    if (!evaluated.canEnterPrestige) {
      throw StateError(
        'Ein Prestige-Wechsel ist nur auf Level 10 '
        'und bis Prestige 15 möglich.',
      );
    }

    final nextPrestige = evaluated.prestige + 1;

    // Bereits erhaltene Trophäen werden nicht doppelt vergeben.
    final highestPrestige = nextPrestige > evaluated.highestPrestige
        ? nextPrestige
        : evaluated.highestPrestige;

    return LevelProgress(
      level: 1,
      prestige: nextPrestige,
      highestPrestige: highestPrestige,

      // Der nächste Monatswechsel bleibt am bisherigen festen Datum.
      periodStartedAt: evaluated.periodStartedAt,

      // Vorherige Trainings bleiben im Verlauf, zählen aber nicht
      // erneut für den neuen Prestige-Durchlauf.
      xpStartedAt: currentTime,
    );
  }
}
