import 'package:flutter_test/flutter_test.dart';
import 'package:repstar/models/exercise.dart';
import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_session.dart';
import 'package:repstar/models/workouts_set.dart';
import 'package:repstar/services/training_reward_service.dart';

void main() {
  test('Die Auswertung zählt nur abgeschlossene Sätze', () {
    const exercise = Exercise(
      id: 'test_exercise',
      name: 'Testübung',
      imagePath: 'assets/images/exercises/test.png',
      muscleGroup: 'Brust',
      equipment: 'Maschine',
      estimatedMet: 3.5,
      secondsPerRepetition: 3,
    );

    final training = TrainingPlan(
      id: 'test_training',
      name: 'Testtraining',
      exercises: [exercise],
    );

    final startedAt = DateTime.utc(2026, 10, 23, 10);

    final session = TrainingSession(
      trainingPlanId: training.id,
      startedAt: startedAt,
      endedAt: startedAt.add(const Duration(minutes: 1)),
      bodyWeightKg: 80,
      setsByExercise: {
        exercise.id: [
          // Dieser Satz zählt zur Auswertung.
          WorkoutSet(weight: 40, repetitions: 10, isCompleted: true),

          // Dieser Satz darf weder Punkte noch Kalorien liefern.
          WorkoutSet(weight: 40, repetitions: 100, isCompleted: false),
        ],
      },
    );

    final reward = const TrainingRewardService().calculate(
      training: training,
      session: session,
    );

    expect(reward.completedSets, 1);
    expect(reward.completedRepetitions, 10);

    // Zehn Wiederholungen mit je drei Sekunden ergeben 30 Sekunden.
    expect(reward.estimatedActiveSeconds, 30.0);
    expect(reward.earnedXp, 2);
    expect(reward.estimatedActiveKcal, closeTo(1.6667, 0.001));
  });
}
