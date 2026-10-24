import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:repstar/data/exercise_library.dart';
import 'package:repstar/models/exercise.dart';
import 'package:repstar/models/training_plan.dart';
import 'package:repstar/models/training_session.dart';
import 'package:repstar/services/exercise_progress_service.dart';
import 'package:repstar/widgets/exercise_image.dart';

/// Listet Übungen mit bereits abgeschlossenen Sätzen auf.
class ExerciseProgressScreen extends StatelessWidget {
  final List<TrainingPlan> trainings;
  final List<TrainingSession> sessions;

  const ExerciseProgressScreen({
    super.key,
    required this.trainings,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final history = const ExerciseProgressService().buildHistory(sessions);

    final exercises = <String, Exercise>{
      for (final exercise in exerciseLibrary) exercise.id: exercise,
    };

    // Auch Übungen berücksichtigen, die in vorhandenen Vorlagen stehen.
    for (final training in trainings) {
      for (final exercise in training.exercises) {
        exercises[exercise.id] = exercise;
      }
    }

    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart, size: 64, color: colors.primary),
              const SizedBox(height: 20),
              const Text(
                'Dein Fortschritt beginnt hier',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Schließe ein Training mit abgehakten Sätzen ab. '
                'Danach kannst du deine Entwicklung pro Übung ansehen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    final exerciseIds = history.keys.toList()
      ..sort((first, second) {
        final firstName = exercises[first]?.name ?? first;
        final secondName = exercises[second]?.name ?? second;

        return firstName.toLowerCase().compareTo(secondName.toLowerCase());
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exerciseIds.length,
      itemBuilder: (context, index) {
        final id = exerciseIds[index];
        final exercise = exercises[id];
        final points = history[id]!;
        final latest = points.last;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ExerciseImage(
                imagePath: exercise?.imagePath ?? '',
                width: 56,
                height: 56,
              ),
            ),
            title: Text(
              exercise?.name ?? 'Übung: $id',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${points.length} erfasste Einheiten\n'
              'Zuletzt maximal '
              '${_ProgressFormat.number(latest.maxWeightKg)} kg',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) => _ExerciseProgressDetails(
                    name: exercise?.name ?? 'Übung: $id',
                    points: List<ExerciseProgressPoint>.unmodifiable(points),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Zeigt Kennzahlen und die Entwicklung einer einzelnen Übung.
class _ExerciseProgressDetails extends StatefulWidget {
  final String name;
  final List<ExerciseProgressPoint> points;

  const _ExerciseProgressDetails({required this.name, required this.points});

  @override
  State<_ExerciseProgressDetails> createState() =>
      _ExerciseProgressDetailsState();
}

class _ExerciseProgressDetailsState extends State<_ExerciseProgressDetails> {
  bool _showVolume = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final points = widget.points;
    final latest = points.last;

    final bestWeight = points
        .map((point) => point.maxWeightKg)
        .reduce((first, second) => math.max(first, second));

    final difference = latest.maxWeightKg - points.first.maxWeightKg;

    final differenceText =
        '${difference > 0 ? '+' : ''}'
        '${_ProgressFormat.number(difference)} kg seit erster Einheit';

    final values = points
        .map((point) => _showVolume ? point.volumeKg : point.maxWeightKg)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zuletzt maximal '
                    '${_ProgressFormat.number(latest.maxWeightKg)} kg',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    points.length > 1
                        ? differenceText
                        : 'Erste erfasste Einheit',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Höchstes Satzgewicht: '
                    '${_ProgressFormat.number(bestWeight)} kg',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Letztes Trainingsvolumen: '
                    '${_ProgressFormat.number(latest.volumeKg)} kg',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Beide Ansichten verwenden dieselben gespeicherten Datenpunkte.
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Satzgewicht'),
                selected: !_showVolume,
                onSelected: (_) {
                  setState(() => _showVolume = false);
                },
              ),
              ChoiceChip(
                label: const Text('Trainingsvolumen'),
                selected: _showVolume,
                onSelected: (_) {
                  setState(() => _showVolume = true);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _showVolume
                        ? 'Bewegtes Gewicht pro Einheit'
                        : 'Höchstes Satzgewicht pro Einheit',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (points.length < 2)
                    Text(
                      'Ab der zweiten erfassten Einheit erscheint '
                      'hier dein Diagramm.',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    )
                  else ...[
                    Text(
                      '${_ProgressFormat.number(values.reduce((first, second) => math.max(first, second)))} kg',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Semantics(
                        label: _showVolume
                            ? 'Verlauf des Trainingsvolumens. '
                                  'Werte stehen unten.'
                            : 'Verlauf des höchsten Satzgewichts. '
                                  'Werte stehen unten.',
                        child: CustomPaint(
                          painter: _ProgressChartPainter(
                            values: values,
                            dates: points
                                .map((point) => point.session.endedAt)
                                .toList(growable: false),
                            lineColor: colors.primary,
                            gridColor: colors.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '0 kg',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _ProgressFormat.date(points.first.session.endedAt),
                        ),
                        Text(_ProgressFormat.date(latest.session.endedAt)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    _showVolume
                        ? 'Summe aus Gewicht × Wiederholungen aller '
                              'gültigen abgehakten Sätze dieser Übung.'
                        : 'Das höchste eingetragene Gewicht eines '
                              'gültigen abgehakten Satzes, unabhängig '
                              'von dessen Wiederholungszahl.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Erfasste Einheiten',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Unter dem Diagramm stehen die genauen Ergebnisse.
          for (final point in points.reversed)
            Card(
              child: ListTile(
                title: Text(_ProgressFormat.date(point.session.endedAt)),
                subtitle: Text(
                  '${point.completedSets} Sätze · '
                  '${point.repetitions} Wiederholungen\n'
                  'Volumen: '
                  '${_ProgressFormat.number(point.volumeKg)} kg',
                ),
                trailing: Text(
                  'Max. ${_ProgressFormat.number(point.maxWeightKg)} kg',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isThreeLine: true,
              ),
            ),
        ],
      ),
    );
  }
}

/// Zeichnet das Diagramm ohne zusätzliches Paket.
class _ProgressChartPainter extends CustomPainter {
  final List<double> values;
  final List<DateTime> dates;
  final Color lineColor;
  final Color gridColor;

  const _ProgressChartPainter({
    required this.values,
    required this.dates,
    required this.lineColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }

    const padding = 8.0;
    final width = size.width - padding * 2;
    final height = size.height - padding * 2;

    if (width <= 0 || height <= 0) {
      return;
    }

    final highest = values.reduce((first, second) => math.max(first, second));

    // Verhindert eine Division durch null bei Übungen mit 0 kg.
    final scale = highest > 0 ? highest : 1.0;
    final start = dates.first.microsecondsSinceEpoch;
    final timeSpan = dates.last.microsecondsSinceEpoch - start;

    final path = Path();
    final positions = <Offset>[];

    for (var index = 0; index < values.length; index++) {
      // Die horizontalen Abstände entsprechen den tatsächlichen Zeitabständen.
      final xFraction = timeSpan > 0
          ? (dates[index].microsecondsSinceEpoch - start) / timeSpan
          : index / (values.length - 1);

      final point = Offset(
        padding + xFraction * width,
        padding + height * (1 - values[index] / scale),
      );

      positions.add(point);

      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var index = 0; index <= 3; index++) {
      final y = padding + height * index / 3;

      canvas.drawLine(
        Offset(padding, y),
        Offset(padding + width, y),
        gridPaint,
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );

    for (final point in positions) {
      canvas.drawCircle(point, 4, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressChartPainter oldDelegate) {
    return true;
  }
}

/// Gemeinsame Formatierung für Liste, Kennzahlen und Diagramm.
class _ProgressFormat {
  _ProgressFormat._();

  static String number(double value) {
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '')
        .replaceAll('.', ',');
  }

  static String date(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');

    return '$day.$month.${local.year}';
  }
}
