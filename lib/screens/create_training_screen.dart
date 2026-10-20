import 'package:flutter/material.dart';
import 'package:repstar/data/exercise_library.dart';
import 'package:repstar/models/exercise.dart';
import 'package:repstar/models/training_plan.dart';

/// Ermöglicht das Benennen eines Trainings und die Übungsauswahl.
class CreateTrainingScreen extends StatefulWidget {
  /// Beim Bearbeiten wird die vorhandene Vorlage übergeben.
  final TrainingPlan? initialTraining;

  const CreateTrainingScreen({super.key, this.initialTraining});

  @override
  State<CreateTrainingScreen> createState() => _CreateTrainingScreenState();
}

class _CreateTrainingScreenState extends State<CreateTrainingScreen> {
  final TextEditingController _nameController = TextEditingController();

  /// Die Reihenfolge der Auswahl wird für das Training übernommen.
  final List<Exercise> _selectedExercises = [];

  /// Ohne ausgewählte Muskelgruppe werden alle Übungen angezeigt.
  String? _selectedMuscleGroup;

  @override
  void initState() {
    super.initState();

    final training = widget.initialTraining;

    if (training != null) {
      // Vorhandenen Namen und Übungen zum bearbeiten übernehemen.
      _nameController.text = training.name;

      // Die Auswahl erhält eine eigene Liste.
      _selectedExercises.addAll(training.exercises);
    }
  }

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

  /// Verschiebt eine Übung innerhalb der Trainingsreihenfolge.
  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      // Beim verschieben nach unten verschiebt das Entfernen den Zielindex.
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final exercise = _selectedExercises.removeAt(oldIndex);
      _selectedExercises.insert(newIndex, exercise);
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
      // Beib bearbeiten bleibt die Kennung samt Trainingshistorie erhalten.
      id:
          widget.initialTraining?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
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

  /// Zeigt die ausgewählten Ünungen in ihrer Trainingsreihenfolge.
  Widget _buildSelectedExercises() {
    if (_selectedExercises.isEmpty) {
      return const SizedBox.shrink();
    }

    // Maximal drei Zeilen gleichzeitig anzeigen; weitere sind scrollbar.
    final visibleRows = _selectedExercises.length > 3
        ? 3
        : _selectedExercises.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: const Text('Ausgewählte Übungen'),
        subtitle: const Text('Zum Sortieren den Griff rechts ziehen'),
        children: [
          SizedBox(
            height: visibleRows * 72.0,
            child: ReorderableListView.builder(
              padding: EdgeInsets.zero,
              primary: false,
              itemExtent: 72,
              buildDefaultDragHandles: false,
              itemCount: _selectedExercises.length,
              onReorder: _reorderExercises,
              itemBuilder: (context, index) {
                final exercise = _selectedExercises[index];

                return ListTile(
                  // Die Kennung bleibt beim Verschieben gleich.
                  key: ValueKey(exercise.id),
                  leading: SizedBox(
                    width: 28,
                    child: Center(child: Text('${index + 1}')),
                  ),
                  title: Text(
                    exercise.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Übung entfernen',
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _toggleExercise(exercise),
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Tooltip(
                          message: 'Übung verschieben',
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.drag_handle),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;
    // Jede vorhandene Muskelgruppe einmal anzeigen und alphabetisch sortieren.
    final muscleGroups =
        exerciseLibrary.map((exercise) => exercise.muscleGroup).toSet().toList()
          ..sort();

    // Der Filter ändert nur die Anzeige, nicht die ausgewählten Übungen.
    final filteredExercises = exerciseLibrary.where((exerise) {
      return _selectedMuscleGroup == null ||
          exerise.muscleGroup == _selectedMuscleGroup;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialTraining == null
              ? 'Training erstellen'
              : 'Training bearbeiten',
        ),
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

          // Die Filterleiste lässt sich bei wenig Platz seitlich scrollen.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Alle'),
                  selected: _selectedMuscleGroup == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedMuscleGroup = null;
                    });
                  },
                ),
                for (final muscleGroup in muscleGroups)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(muscleGroup),
                      selected: _selectedMuscleGroup == muscleGroup,
                      onSelected: (selected) {
                        setState(() {
                          // Erneutes Antippen hebt den Filter auf.
                          _selectedMuscleGroup = selected ? muscleGroup : null;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              // Der erste Eintrag enthält die sortierbare Auswahl.
              itemCount: filteredExercises.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildSelectedExercises();
                }
                // Die Übungsbibliothek beginnt hinter dem zusätlichen ersten Eintrag.
                final exercise = filteredExercises[index - 1];
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
                                style: const TextStyle(color: Colors.white70),
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
