import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:repstar/data/level_library.dart';
import 'package:repstar/models/level_progress.dart';
import 'package:repstar/services/training_reward_service.dart';
import 'package:repstar/theme/app_theme.dart';

/// Zeigt Rang und Monatsfortschritt im hellen und dunklen Design.
class RankScreen extends StatelessWidget {
  final LevelProgress progress;
  final int monthlyXp;
  final DateTime now;

  const RankScreen({
    super.key,
    required this.progress,
    required this.monthlyXp,
    required this.now,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}';
  }

  void _showRules(BuildContext context) {
    final minimumMinutes = TrainingRewardService.minimumXpDuration.inMinutes;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('So funktioniert dein Rang'),
        content: SingleChildScrollView(
          child: Text(
            'Jede Runde dauert einen Kalendermonat und endet am '
            '1. des nächsten Monats um 00:00 Uhr UTC.\n\n'
            'Der goldene Punkt am Ring markiert die benötigten '
            'Punkte für den Klassenerhalt.\n\n'
            'Unter dieser Grenze sinkst du um einen Rang. '
            'Erreichst du sie, hältst du deinen Rang. '
            'Beim Aufstiegsziel steigst du um einen Rang.\n\n'
            'Die Grenze für den Klassenerhalt steigt mit dem Rang '
            'von 50 auf 80 Prozent des Monatsziels.\n\n'
            'Rang 1 kann nicht unterschritten werden, auch wenn '
            'sein Erhaltungsziel verfehlt wird.\n\n'
            'Im höchsten Rang liegt der Klassenerhalt bei '
            '80 Prozent des vollständigen Rings. '
            'Ein weiterer Aufstieg ist dort nicht möglich.\n\n'
            'Rangwechsel erfolgen zum Monatswechsel. '
            'Danach beginnen die Monatspunkte wieder bei null. '
            'Deine Trainingseinheiten bleiben gespeichert.\n\n'
            'Nur Trainingseinheiten mit mindestens $minimumMinutes Minuten '
            'Gesamtdauer zählen zur Punktewertung.\n\n'
            'Pro Monat ist höchstens ein Rangwechsel möglich. '
            'Vergangene Monate werden beim nächsten Öffnen '
            'der App nacheinander ausgewertet.',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Verstanden'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final accentColor = colors.primary;
    final secondaryTextColor = colors.onSurfaceVariant;

    // Sonderfarben kommen wie die Standardfarben aus dem aktiven Theme.
    final rankColors = theme.extension<RepStarColors>()!;
    final maintenanceColor = rankColors.maintenance;

    final definition = levelLibrary[progress.level - 1];
    final promotionXp = definition.promotionXp;
    final targetXp = definition.targetXp;

    final fraction = (monthlyXp / targetXp).clamp(0.0, 1.0).toDouble();

    final maintenanceFraction = (definition.maintenanceXp / targetXp)
        .clamp(0.0, 1.0)
        .toDouble();

    final maintenanceReached = monthlyXp >= definition.maintenanceXp;

    final remainingSeconds = progress.periodEndsAt
        .difference(now.toUtc())
        .inSeconds;

    final remainingDays = remainingSeconds > 0
        ? (remainingSeconds / Duration.secondsPerDay).ceil()
        : 0;

    final String status;
    final IconData statusIcon;

    if (promotionXp != null && monthlyXp >= promotionXp) {
      status = 'Aufstieg zum Monatswechsel gesichert!';
      statusIcon = Icons.trending_up;
    } else if (!maintenanceReached) {
      final missingXp = definition.maintenanceXp - monthlyXp;
      status = 'Noch $missingXp XP zum Klassenerhalt.';
      statusIcon = Icons.shield_outlined;
    } else if (promotionXp != null) {
      final missingXp = promotionXp - monthlyXp;
      status = 'Rang gesichert. Noch $missingXp XP zum Aufstieg.';
      statusIcon = Icons.verified_outlined;
    } else {
      status = 'Höchster Rang gesichert. Du bleibst eine RepStar-Legende!';
      statusIcon = Icons.emoji_events_outlined;
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'DEINE MONATSRUNDE',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            IconButton(
              tooltip: 'Rangregeln anzeigen',
              onPressed: () => _showRules(context),
              icon: const Icon(Icons.info_outline),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.12),
              border: Border.all(color: accentColor.withValues(alpha: 0.5)),
            ),
            child: Icon(
              definition.isHighestLevel
                  ? Icons.workspace_premium
                  : Icons.emoji_events_outlined,
              size: 44,
              color: accentColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          definition.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rang ${definition.number} von ${levelLibrary.length}',
          textAlign: TextAlign.center,
          style: TextStyle(color: secondaryTextColor),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final size = math.min(constraints.maxWidth, 360.0);

            return Center(
              child: Semantics(
                label:
                    '$monthlyXp Monatspunkte. '
                    'Klassenerhalt bei ${definition.maintenanceXp} XP. '
                    '${promotionXp == null ? 'Höchster Rang.' : 'Aufstieg bei $promotionXp XP.'}',
                child: SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: _RankRingPainter(
                      progress: fraction,
                      maintenanceFraction: maintenanceFraction,
                      color: accentColor,

                      // Dunkler Ring auf hellem Hintergrund,
                      // heller Ring auf dunklem Hintergrund.
                      trackColor: rankColors.ringTrack,
                      maintenanceColor: maintenanceColor,
                      backgroundColor: theme.scaffoldBackgroundColor,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(size * 0.16),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'MONATSPUNKTE',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '$monthlyXp',
                                style: TextStyle(
                                  fontSize: 58,
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Klassenerhalt: '
                                '${definition.maintenanceXp} XP',
                                style: TextStyle(
                                  color: maintenanceColor,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                promotionXp == null
                                    ? 'Monatsziel: $targetXp XP'
                                    : 'Aufstieg: $promotionXp XP',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                remainingDays == 0
                                    ? 'Monatswechsel'
                                    : 'Noch $remainingDays '
                                          '${remainingDays == 1 ? 'Tag' : 'Tage'}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.circle, size: 12, color: maintenanceColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Klassenerhalt bei ${definition.maintenanceXp} XP',
                style: TextStyle(color: maintenanceColor),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              maintenanceReached
                  ? Icons.check_circle_outline
                  : Icons.lock_outline,
              size: 18,
              color: maintenanceReached ? accentColor : secondaryTextColor,
            ),
          ],
        ),
        if (definition.number == 1) ...[
          const SizedBox(height: 8),
          Text(
            'Im ersten Rang ist kein Abstieg möglich.',
            textAlign: TextAlign.center,
            style: TextStyle(color: secondaryTextColor, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(statusIcon, color: accentColor, size: 28),
                const SizedBox(height: 10),
                Text(
                  status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  definition.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryTextColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Nächste Auswertung: '
          '${_formatDate(progress.periodEndsAt)} um 00:00 UTC',
          textAlign: TextAlign.center,
          style: TextStyle(color: secondaryTextColor, fontSize: 12),
        ),
        const SizedBox(height: 28),
        const Text(
          'Dein Weg zur Legende',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        for (final level in levelLibrary)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: level.number == progress.level
                    ? accentColor
                    : Colors.transparent,
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: level.number == progress.level
                    ? accentColor
                    : colors.surfaceContainerHighest,
                foregroundColor: level.number == progress.level
                    ? colors.onPrimary
                    : colors.onSurfaceVariant,
                child: Text('${level.number}'),
              ),
              title: Text(level.name),
              subtitle: Text(
                'Halten: ${level.maintenanceXp} XP '
                '(${level.maintenancePercent} %)\n'
                '${level.promotionXp == null ? 'Höchster Rang' : 'Aufstieg: ${level.promotionXp} XP'}',
              ),
              isThreeLine: true,
              trailing: level.number == progress.level
                  ? Icon(Icons.location_on, color: accentColor)
                  : null,
            ),
          ),
      ],
    );
  }
}

/// Zeichnet Fortschrittsring und Klassenerhalt-Markierung.
class _RankRingPainter extends CustomPainter {
  final double progress;
  final double maintenanceFraction;
  final Color color;
  final Color trackColor;
  final Color maintenanceColor;
  final Color backgroundColor;

  const _RankRingPainter({
    required this.progress,
    required this.maintenanceFraction,
    required this.color,
    required this.trackColor,
    required this.maintenanceColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 18.0;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - strokeWidth;
    final circle = Rect.fromCircle(center: center, radius: radius);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, ringPaint..color = trackColor);

    if (progress > 0) {
      canvas.drawArc(
        circle,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        ringPaint..color = color,
      );
    }

    final angle = -math.pi / 2 + math.pi * 2 * maintenanceFraction;

    final markerPosition =
        center + Offset(math.cos(angle), math.sin(angle)) * radius;

    canvas.drawCircle(markerPosition, 12, Paint()..color = backgroundColor);

    canvas.drawCircle(markerPosition, 8, Paint()..color = maintenanceColor);
  }

  @override
  bool shouldRepaint(covariant _RankRingPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        maintenanceFraction != oldDelegate.maintenanceFraction ||
        color != oldDelegate.color ||
        trackColor != oldDelegate.trackColor ||
        maintenanceColor != oldDelegate.maintenanceColor ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
