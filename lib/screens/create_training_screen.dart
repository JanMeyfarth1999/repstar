import 'package:flutter/material.dart';
import 'package:repstar/data/exercise_library.dart';
import 'package:repstar/models/exercise.dart';

/// Ermöglicht das Benennen eines Trainings und die Übungsauswahl.
class CreateTrainingScreen extends StatefulWidget {
  const CreateTrainingScreen({super.key});

  @override
  State<CreateTrainingScreen> createState() =>
      _CreateTrainingScreenState();
}

class _CreateTrainingScreenState extends State<CreateTrainingScreen> {
  /// Verwaltet den Text im Namensfeld.
  final TextEditingController _nameController = TextEditingController();

  /// Speichert die Kennungen der ausgewählten Übungen.
  final Set<String> _selectedExerciseIds = {};

  /// Fügt eine Übung hinzu oder entfernt sie aus der Auswahl.
  void _toggleExercise(Exercise exercise) {
    setState(() {
      if (_selectedExerciseIds.contains(exercise.id)) {
        _selectedExerciseIds.remove(exercise.id);
      } else {
        _selectedExerciseIds.add(exercise.id);
      }
    });
  }

  @override
  void dispose() {
    // Den Controller freigeben, wenn der Bildschirm geschlossen wird.
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
                '${_selectedExerciseIds.length} Übungen ausgewählt',
                style: TextStyle(color: accentColor),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Die Liste nutzt den verfügbaren Platz und ist scrollbar.
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: exerciseLibrary.length,
              itemBuilder: (context, index) {
                final exercise = exerciseLibrary[index];
                final isSelected =
                    _selectedExerciseIds.contains(exercise.id);

                // Dieselbe Darstellung wird für jede Übung verwendet.
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
    );
  }
}