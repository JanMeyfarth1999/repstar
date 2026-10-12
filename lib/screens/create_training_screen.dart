import 'package:flutter/material.dart';
import 'package:repstar/data/exercise_library.dart';
import 'package:repstar/models/exercise.dart';
import 'package:repstar/models/training_plan.dart';

/// Ermöglicht das Benennen eines Trainings und die Übungsauswahl.
class CreateTrainingScreen extends StatefulWidget {
  const CreateTrainingScreen({super.key});

  @override
  State<CreateTrainingScreen> createState() =>
      _CreateTrainingScreenState();
}

class _CreateTrainingScreenState extends State<CreateTrainingScreen> {
  final TextEditingController _nameController = TextEditingController();

  /// Die Reihenfolge der Auswahl wird für das Training übernommen.
  final List<Exercise> _selectedExercises = [];

  /// Prüft anhand der Kennung, ob eine Übung ausgewählt ist.
  bool _isSelected(Exercise exercise) {
    return _selectedExercises.any((item) => item.id == exercise.id);
  }

  /// Fügt eine Übung hinzu oder entfernt sie aus der Auswahl.
  void _toggleExercise(Exercise exercise) {
    setState(() {
      if (_isSelected(exercise)) {
        _selectedExercises.removeWhere((item) => item.id == exercise.id);
      } else {
        _selectedExercises.add(exercise);
      }
    });
  }

  /// Prüft die Eingaben und gibt das Training an die Startseite zurück.
  void _saveTraining() {
    final name = _nameController.text.trim();

    if (name.isEmpty || _selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bitte benenne dein Training und wähle mindestens eine Übung.',
          ),
        ),
      );
      return;
    }

    final training = TrainingPlan(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      exercises: _selectedExercises,
    );

    // Schließt den Bildschirm und liefert das erstellte Training zurück.
    Navigator.of(context).pop<TrainingPlan>(training);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training erstellen'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Trainingsname',
                hintText: 'Zum Beispiel Brust & Bizeps',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_selectedExercises.length} Übungen ausgewählt',
                style: TextStyle(color: accentColor),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: exerciseLibrary.length,
              itemBuilder: (context, index) {
                final exercise = exerciseLibrary[index];
                final isSelected = _isSelected(exercise);

                // Dieselbe Karte stellt jede Übung aus der Liste dar.
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 80,
                            height: 80,
                            color: Colors.white,
                            child: Image.asset(
                              exercise.imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${exercise.muscleGroup} · '
                                '${exercise.equipment}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: isSelected
                              ? 'Übung entfernen'
                              : 'Übung hinzufügen',
                          color: accentColor,
                          icon: Icon(
                            isSelected
                                ? Icons.remove_circle_outline
                                : Icons.add_circle_outline,
                          ),
                          onPressed: () => _toggleExercise(exercise),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Bleibt unterhalb der scrollbaren Übungsliste erreichbar.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _saveTraining,
            icon: const Icon(Icons.check),
            label: const Text('Training speichern'),
          ),
        ),
      ),
    );
  }
}