import 'package:flutter_test/flutter_test.dart';
import 'package:repstar/data/level_library.dart';
import 'package:repstar/models/exercise.dart';
import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_session.dart';
import 'package:repstar/models/workouts_set.dart';
import 'package:repstar/services/level_service.dart';
import 'package:repstar/services/training_reward_service.dart';

void main() {
  const rewardService = TrainingRewardService();
  final levelService = LevelService(levels: levelLibrary);

  final startedAt = DateTime.utc(2026, 10, 23, 10);

  final training = TrainingPlan(
    id: 'test_training',
    name: 'Testtraining',
    exercises: const [
      Exercise(
        id: 'test_exercise',
        name: 'Testübung',
        imagePath: 'assets/images/exercises/test.png',
        muscleGroup: 'Brust',
        equipment: 'Maschine',
        estimatedMet: 3.5,
        secondsPerRepetition: 3,
      ),
    ],
  );

  // Alle Tests verwenden denselben Aufbau und ändern nur die Dauer.
  TrainingSession createSession(Duration duration) {
    return TrainingSession(
      trainingPlanId: training.id,
      startedAt: startedAt,
      endedAt: startedAt.add(duration),
      bodyWeightKg: 80,
      setsByExercise: {
        'test_exercise': [
          WorkoutSet(weight: 40, repetitions: 10, isCompleted: true),
          WorkoutSet(weight: 40, repetitions: 100, isCompleted: false),
        ],
      },
    );
  }

  test('Knapp unter 30 Minuten gibt es keine XP', () {
    final session = createSession(
      const Duration(minutes: 29, seconds: 59, milliseconds: 999),
    );

    final reward = rewardService.calculate(
      training: training,
      session: session,
    );

    expect(reward.earnedXp, 0);

    // Satzdaten und Kalorienschätzung bleiben trotzdem vorhanden.
    expect(reward.completedSets, 1);
    expect(reward.completedRepetitions, 10);
    expect(reward.estimatedActiveKcal, closeTo(1.6667, 0.001));
  });

  test('Ab genau 30 Minuten zählen nur abgeschlossene Sätze', () {
    final session = createSession(const Duration(minutes: 30));

    final reward = rewardService.calculate(
      training: training,
      session: session,
    );

    expect(reward.earnedXp, 2);
    expect(reward.completedSets, 1);
    expect(reward.completedRepetitions, 10);
    expect(reward.estimatedActiveSeconds, 30.0);
  });

  test('Alte kurze Einheiten zählen nicht zur Monatswertung', () {
    final validSession = createSession(const Duration(minutes: 30));

    final reward = rewardService.calculate(
      training: training,
      session: validSession,
    );

    // Stellt eine ältere kurze Einheit mit gespeicherten Punkten nach.
    final oldShortSession = createSession(
      const Duration(minutes: 2),
    ).withReward(reward);

    final xp = levelService.monthlyXp(
      sessions: [oldShortSession, validSession.withReward(reward)],
      month: startedAt,
      now: DateTime.utc(2026, 10, 24),
    );

    // Nur die mindestens 30 Minuten lange Einheit zählt.
    expect(xp, reward.earnedXp);
  });
}
