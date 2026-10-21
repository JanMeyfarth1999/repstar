import 'package:repstar/models/exercise_settings.dart';
import 'package:flutter/material.dart';
import 'package:repstar/models/exercise.dart';
import 'package:repstar/models/workouts_set.dart';

/// Zeigt eine Übung mit ihren bearbeitbaren Trainingssätzen.
class TrainingExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final List<WorkoutSet> sets;

  /// Bestimmt, ob die Karte beim Öffnen bereits aufgeklappt ist.
  final bool initiallyExpanded;

  /// Optionale Geräteeinstellungen für diese Übung.
  final ExerciseSettings? settings;

  /// Meldet hinzugefügte oder entfernte Einstellungen an den Trainingsbildschirm.
  final ValueChanged<ExerciseSettings?> onSettingsChanged;

  /// Meldet erfolgreichen abgehakten Satz an den Trainingsbildschirm.
  final VoidCallback onSetCompleted;

  const TrainingExerciseCard({
    super.key,
    required this.exercise,
    required this.sets,
    required this.settings,
    required this.onSettingsChanged,
    required this.onSetCompleted,
    this.initiallyExpanded = false,
  });

  @override
  State<TrainingExerciseCard> createState() => _TrainingExerciseCardState();
}

class _TrainingExerciseCardState extends State<TrainingExerciseCard> {
  /// Ergänz einen neuen, leeren Satz.

  void _addSet() {
    setState(() {
      widget.sets.add(WorkoutSet());
    });
  }

  /// Entfernt einen Satz. Mindestens ein Satz bleibt erhalten.
  void _removeSet(int index) {
    if (widget.sets.length <= 1) {
      return;
    }

    setState(() {
      widget.sets.removeAt(index);
    });
  }

  /// Hakt einen Satz nach Prüfung der Eingaben ab.
  void _toggleCompleted(WorkoutSet workoutSet) {
    if (!workoutSet.isCompleted) {
      final weight = workoutSet.weight;
      final repetitions = workoutSet.repetitions;

      if (weight == null ||
          !weight.isFinite ||
          weight < 0 ||
          repetitions == null ||
          repetitions <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bitte ein gültiges Gewicht und Wiederholungen eintragen.',
            ),
          ),
        );
        return;
      }
    }
    setState(() {
      workoutSet.isCompleted = !workoutSet.isCompleted;

      // Nur beim Setzen des Häkchens eine neue Pause starten.
      if (workoutSet.isCompleted) {
        widget.onSetCompleted();
      }
    });
  }

  /// Baut eine Satzzeile. Diese Darstellung verwenden alle Sätze.
  Widget _buildSetRow(int index) {
    final workoutSet = widget.sets[index];
    final accentColor = Theme.of(context).colorScheme.primary;

    return Padding(
      // Die Kennung hält Eingabefelder beim Entfernen beim richtigen Satz.
      key: ObjectKey(workoutSet),
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: workoutSet.isCompleted ? accentColor : Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              initialValue: workoutSet.repetitions?.toString() ?? '',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Wdh',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  workoutSet.repetitions = int.tryParse(value.trim());

                  // Geänderte werte müssen erneut bestätigt werden.
                  workoutSet.isCompleted = false;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: workoutSet.weight?.toString() ?? '',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'kg',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  // Unterstützt beispielsweise 35,5 und 35.5.
                  workoutSet.weight = double.tryParse(
                    value.trim().replaceAll(',', '.'),
                  );
                  workoutSet.isCompleted = false;
                });
              },
            ),
          ),
          Checkbox(
            value: workoutSet.isCompleted,
            activeColor: accentColor,
            onChanged: (_) => _toggleCompleted(workoutSet),
          ),
          IconButton(
            tooltip: 'Satz entfernen',
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: widget.sets.length > 1 ? () => _removeSet(index) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsFields() {
    final settings = widget.settings;

    if (settings == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () {
            widget.onSettingsChanged(ExerciseSettings());
          },
          icon: const Icon(Icons.add),
          label: const Text('Geräteeinstellungen hinzufügen'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: Text('Geräteeinstellungen')),
            IconButton(
              tooltip: 'Geräteeinstellungen entfernen',
              onPressed: () {
                widget.onSettingsChanged(null);
              },
              icon: const Icon(Icons.remove_circle_outline),
            ),
          ],
        ),
        TextFormField(
          initialValue: settings.seatHeight,
          decoration: const InputDecoration(
            labelText: 'Sitzhöhe',
            hintText: 'Loch...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            settings.seatHeight = value;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: settings.otherAdjustments,
          decoration: const InputDecoration(
            labelText: 'Sonstige Verstellmöglichkeiten',
            hintText: 'Loch...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            settings.otherAdjustments = value;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedSets = widget.sets
        .where((workoutSet) => workoutSet.isCompleted)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: widget.initiallyExpanded,
        tilePadding: const EdgeInsets.all(12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),

        // Auch bei geschlossener Karte bleibt ein kleines Bild sichtbar.
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 56,
            height: 56,
            color: Colors.white,
            child: Image.asset(widget.exercise.imagePath, fit: BoxFit.contain),
          ),
        ),
        title: Text(
          widget.exercise.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$completedSets von ${widget.sets.length} Sätzen erledigt.',
        ),
        children: [
          // Das große Bild erscheint beim Aufklappen
          // Die Höhe passt sich dem Bildformat an, ohne seitliche Freiflächen.
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              widget.exercise.imagePath,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),

          // Zeigt die optionalen Geräteeinstellungen oberhalb der Sätze.
          _buildSettingsFields(),
          const SizedBox(height: 16),

          // Für jeden Satz wird dieselbe Zeilen-Methode aufgerufen.
          for (int index = 0; index < widget.sets.length; index++)
            _buildSetRow(index),

          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _addSet,
              icon: const Icon(Icons.add),
              label: const Text('Satz hinzufügen'),
            ),
          ),
        ],
      ),
    );
  }
}
