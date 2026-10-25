import 'package:flutter_test/flutter_test.dart';
import 'package:repstar/data/exercise_library.dart';

void main() {
  test('Die Bibliothek enthält 240 unterschiedliche Übungs-IDs', () {
    final ids = exerciseLibrary.map((exercise) => exercise.id).toList();

    expect(ids.length, 240);

    // Doppelte IDs würden Trainings und Fortschrittsdaten vermischen.
    expect(ids.toSet().length, ids.length);
  });

  test('Jede vorhandene Muskelgruppe enthält genau 40 Übungen', () {
    const groups = [
      'Beine',
      'Brust',
      'Bizeps',
      'Trizeps',
      'Rücken',
      'Schultern',
    ];

    expect(
      exerciseLibrary.map((exercise) => exercise.muscleGroup).toSet(),
      unorderedEquals(groups),
    );

    for (final group in groups) {
      final exercises = exerciseLibrary.where(
        (exercise) => exercise.muscleGroup == group,
      );

      expect(
        exercises.length,
        40,
        reason: '$group soll genau 40 Übungen enthalten.',
      );
    }
  });
}
