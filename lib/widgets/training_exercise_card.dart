import 'package:flutter/material.dart';
import 'package:repstar/models/exercise.dart';
import 'package:repstar/models/exercise_settings.dart';
import 'package:repstar/models/workouts_set.dart';
import 'package:repstar/widgets/exercise_image.dart';

/// Zeigt eine Übung mit ihren bearbeitbaren Trainingssätzen.
class TrainingExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final List<WorkoutSet> sets;
  final ExerciseSettings? settings;

  /// Der Trainingsbildschirm bestimmt, welche Karte geöffnet ist.
  final bool isExpanded;

  final ValueChanged<bool> onExpansionChanged;
  final VoidCallback onExpansionAnimationEnd;
  final ValueChanged<ExerciseSettings?> onSettingsChanged;
  final VoidCallback onSetCompleted;

  const TrainingExerciseCard({
    super.key,
    required this.exercise,
    required this.sets,
    required this.settings,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.onExpansionAnimationEnd,
    required this.onSettingsChanged,
    required this.onSetCompleted,
  });

  @override
  State<TrainingExerciseCard> createState() =>
      _TrainingExerciseCardState();
}

class _TrainingExerciseCardState extends State<TrainingExerciseCard> {
  /// Ergänzt einen neuen, leeren Satz.
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
    });

    // Der Bildschirm prüft danach auch den Abschluss der ganzen Übung.
    if (workoutSet.isCompleted) {
      widget.onSetCompleted();
    }
  }

  /// Baut die gemeinsame Darstellung einer Satzzeile.
  Widget _buildSetRow(int index) {
    final workoutSet = widget.sets[index];
    final accentColor = Theme.of(context).colorScheme.primary;

    return Padding(
      key: ObjectKey(workoutSet),
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: workoutSet.isCompleted
                    ? accentColor
                    : Colors.white70,
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
            onPressed: widget.sets.length > 1
                ? () => _removeSet(index)
                : null,
          ),
        ],
      ),
    );
  }

  /// Zeigt die optionalen Geräteeinstellungen.
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
      key: ObjectKey(settings),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Geräteeinstellungen'),
            ),
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
            hintText: 'Loch …',
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
            hintText: 'Loch …',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            settings.otherAdjustments = value;
          },
        ),
      ],
    );
  }

  /// Inhalt der aufgeklappten Karte.
  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ExerciseImage(
              imagePath: widget.exercise.imagePath,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsFields(),
          const SizedBox(height: 16),
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

  @override
  Widget build(BuildContext context) {
    final completedSets = widget.sets
        .where((workoutSet) => workoutSet.isCompleted)
        .length;

    final allCompleted =
        widget.sets.isNotEmpty && completedSets == widget.sets.length;

    final accentColor = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ExerciseImage(
                imagePath: widget.exercise.imagePath,
                width: 56,
                height: 56,
              ),
            ),
            title: Text(
              widget.exercise.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '$completedSets von ${widget.sets.length} Sätzen erledigt.',
              style: TextStyle(
                color: allCompleted ? accentColor : null,
              ),
            ),
            trailing: Icon(
              widget.isExpanded
                  ? Icons.expand_less
                  : Icons.expand_more,
              color: allCompleted ? accentColor : null,
            ),
            onTap: () {
              widget.onExpansionChanged(!widget.isExpanded);
            },
          ),

          // Das Öffnen und Schließen wird vom Trainingsbildschirm gesteuert.
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            onEnd: widget.isExpanded
                ? widget.onExpansionAnimationEnd
                : null,
            child: widget.isExpanded
                ? _buildExpandedContent()
                : const SizedBox(
                    width: double.infinity,
                    height: 0,
                  ),
          ),
        ],
      ),
    );
  }
}