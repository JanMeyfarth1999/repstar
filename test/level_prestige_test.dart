import 'package:flutter_test/flutter_test.dart';
import 'package:repstar/data/level_library.dart';
import 'package:repstar/data/prestige_library.dart';
import 'package:repstar/models/level_progress.dart';
import 'package:repstar/services/level_service.dart';
import 'package:repstar/models/training_reward.dart';
import 'package:repstar/models/training_session.dart';

/// Erstellt eine abgeschlossene Testeinheit mit festgelegten XP.
/// Die Punkteberechnung selbst ist nicht Gegenstand dieser Tests.
TrainingSession createXpSession({
  required DateTime startedAt,
  required int xp,
}) {
  return TrainingSession(
    trainingPlanId: 'test-plan',
    startedAt: startedAt,
    endedAt: startedAt.add(const Duration(hours: 1)),
    setsByExercise: {},
    reward: TrainingReward(
      calculationVersion: 3,
      earnedXp: xp,
      completedSets: 3,
      completedRepetitions: 30,
      estimatedActiveSeconds: 90,
      estimatedActiveKcal: null,
    ),
  );
}

void main() {
  final service = LevelService(levels: levelLibrary);

  group('Prestige-System', () {
    test('Jedes Prestige besitzt zehn eigene Levelnamen', () {
      expect(prestigeTitles.length, LevelProgress.maxPrestige);
      expect(prestigeLevelNames.length, LevelProgress.maxPrestige);

      final allNames = <String>[];

      for (final names in prestigeLevelNames) {
        expect(names.length, LevelProgress.maxLevel);

        for (final name in names) {
          expect(name.trim(), isNotEmpty);
          allNames.add(name);
        }
      }

      // Kein Levelname soll in einem anderen Prestige erneut vorkommen.
      expect(allNames.toSet().length, 150);
    });

    test('Alte Speicherstände funktionieren ohne Prestige-Felder', () {
      final progress = LevelProgress.fromJson({
        'level': 4,
        'periodStartedAt': '2026-10-01T00:00:00.000Z',
      });

      expect(progress.level, 4);
      expect(progress.prestige, 0);
      expect(progress.highestPrestige, 0);
      expect(progress.hasPrestige, isFalse);
      expect(progress.unlockedTrophies, isEmpty);
    });

    test('Level 10 ermöglicht Prestige 1 und die erste Trophäe', () {
      final now = DateTime.utc(2026, 10, 15, 12);

      final updated = service.enterPrestige(
        progress: LevelProgress(
          level: 10,
          periodStartedAt: DateTime.utc(2026, 10, 1),
        ),
        sessions: [],
        now: now,
      );

      expect(updated.level, 1);
      expect(updated.prestige, 1);
      expect(updated.highestPrestige, 1);
      expect(updated.unlockedTrophies, [1]);

      // Der Wechsel setzt die XP-Grenze, verlängert aber nicht den Monat.
      expect(updated.xpStartedAt, now);
      expect(updated.periodEndsAt, DateTime.utc(2026, 11, 1));
    });

    test('Unter Level 10 ist kein Prestige-Wechsel möglich', () {
      final progress = LevelProgress(
        level: 9,
        periodStartedAt: DateTime.utc(2026, 10, 1),
      );

      expect(
        () => service.enterPrestige(
          progress: progress,
          sessions: [],
          now: DateTime.utc(2026, 10, 15),
        ),
        throwsStateError,
      );
    });

    test('Abstieg aus Prestige 1 behält die erreichte Trophäe', () {
      final updated = service.evaluate(
        progress: LevelProgress(
          level: 1,
          prestige: 1,
          highestPrestige: 1,
          periodStartedAt: DateTime.utc(2026, 10, 1),
        ),
        sessions: [],
        now: DateTime.utc(2026, 11, 1),
      );

      expect(updated.prestige, 0);
      expect(updated.level, 10);
      expect(updated.hasPrestige, isFalse);
      expect(updated.unlockedTrophies, [1]);
    });

    test('Mehrere versäumte Monate werden nacheinander ausgewertet', () {
      final updated = service.evaluate(
        progress: LevelProgress(
          level: 1,
          prestige: 2,
          highestPrestige: 3,
          periodStartedAt: DateTime.utc(2026, 1, 1),
        ),
        sessions: [],
        now: DateTime.utc(2026, 3, 1),
      );

      // Januar: Prestige 2, Level 1 → Prestige 1, Level 10.
      // Februar: Prestige 1, Level 10 → Prestige 1, Level 9.
      expect(updated.prestige, 1);
      expect(updated.level, 9);
      expect(updated.unlockedTrophies, [1, 2, 3]);
    });

    test('Erneutes Erreichen vergibt keine doppelte Trophäe', () {
      final updated = service.enterPrestige(
        progress: LevelProgress(
          level: 10,
          prestige: 1,
          highestPrestige: 3,
          periodStartedAt: DateTime.utc(2026, 10, 1),
        ),
        sessions: [],
        now: DateTime.utc(2026, 10, 15),
      );

      expect(updated.prestige, 2);
      expect(updated.highestPrestige, 3);
      expect(updated.unlockedTrophies, [1, 2, 3]);
    });

    test('Nach Prestige 15 ist kein weiterer Wechsel möglich', () {
      final progress = LevelProgress(
        level: 10,
        prestige: 15,
        highestPrestige: 15,
        periodStartedAt: DateTime.utc(2026, 10, 1),
      );

      expect(progress.canEnterPrestige, isFalse);

      expect(
        () => service.enterPrestige(
          progress: progress,
          sessions: [],
          now: DateTime.utc(2026, 10, 15),
        ),
        throwsStateError,
      );
    });

    test('Prestige, Trophäen und XP-Grenze überstehen JSON-Umwandlung', () {
      final original = LevelProgress(
        level: 4,
        prestige: 2,
        highestPrestige: 5,
        periodStartedAt: DateTime.utc(2026, 10, 1),
        xpStartedAt: DateTime.utc(2026, 10, 12, 14, 30),
      );

      final restored = LevelProgress.fromJson(original.toJson());

      expect(restored.level, original.level);
      expect(restored.prestige, original.prestige);
      expect(restored.highestPrestige, original.highestPrestige);
      expect(restored.periodStartedAt, original.periodStartedAt);
      expect(restored.xpStartedAt, original.xpStartedAt);
      expect(restored.unlockedTrophies, [1, 2, 3, 4, 5]);
    });

    test('Nach Prestige-Wechsel zählen nur danach gestartete Trainings', () {
      final cutoff = DateTime.utc(2026, 10, 15, 12);

      final xp = service.monthlyXp(
        sessions: [
          // Vor dem Wechsel abgeschlossen: zählt nicht.
          createXpSession(startedAt: DateTime.utc(2026, 10, 14, 10), xp: 200),

          // Vor dem Wechsel gestartet, danach beendet: zählt nicht.
          createXpSession(
            startedAt: DateTime.utc(2026, 10, 15, 11, 30),
            xp: 100,
          ),

          // Genau ab dem Wechsel gestartet: zählt.
          createXpSession(startedAt: cutoff, xp: 30),

          // Später gestartet: zählt ebenfalls.
          createXpSession(startedAt: DateTime.utc(2026, 10, 16, 10), xp: 50),
        ],
        month: DateTime.utc(2026, 10, 1),
        now: DateTime.utc(2026, 10, 20),
        xpStartedAt: cutoff,
      );

      expect(xp, 80);
    });

    test('Alte XP verhindern keinen Abstieg im neuen Prestige', () {
      final updated = service.evaluate(
        progress: LevelProgress(
          level: 1,
          prestige: 1,
          highestPrestige: 1,
          periodStartedAt: DateTime.utc(2026, 10, 1),
          xpStartedAt: DateTime.utc(2026, 10, 15, 12),
        ),
        sessions: [
          // Viele Punkte, aber vollständig vor dem Prestige-Wechsel.
          createXpSession(startedAt: DateTime.utc(2026, 10, 10, 10), xp: 1000),
        ],
        now: DateTime.utc(2026, 11, 1),
      );

      // Ohne neue XP wird der Klassenerhalt verfehlt.
      expect(updated.prestige, 0);
      expect(updated.level, 10);

      // Die Trophäe bleibt trotzdem erhalten.
      expect(updated.unlockedTrophies, [1]);
    });

    test('Neue XP ermöglichen Aufstieg und Folgemonat zählt normal', () {
      final novemberProgress = service.evaluate(
        progress: LevelProgress(
          level: 1,
          prestige: 1,
          highestPrestige: 1,
          periodStartedAt: DateTime.utc(2026, 10, 1),
          xpStartedAt: DateTime.utc(2026, 10, 15, 12),
        ),
        sessions: [
          createXpSession(
            startedAt: DateTime.utc(2026, 10, 20, 10),
            xp: levelLibrary[0].promotionXp!,
          ),
        ],
        now: DateTime.utc(2026, 11, 1),
      );

      expect(novemberProgress.prestige, 1);
      expect(novemberProgress.level, 2);

      // Nach dem Wechselmonat reicht wieder die normale Monatsgrenze.
      expect(novemberProgress.xpStartedAt, isNull);

      final novemberXp = service.monthlyXp(
        sessions: [
          createXpSession(startedAt: DateTime.utc(2026, 10, 20, 10), xp: 500),
          createXpSession(startedAt: DateTime.utc(2026, 11, 2, 10), xp: 60),
        ],
        month: novemberProgress.periodStartedAt,
        now: DateTime.utc(2026, 11, 3),
        xpStartedAt: novemberProgress.xpStartedAt,
      );

      // Oktober-Punkte werden im November nicht erneut gezählt.
      expect(novemberXp, 60);
    });
  });
}
