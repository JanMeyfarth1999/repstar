import 'dart:math' as math;
import 'package:repstar/data/prestige_library.dart';
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

  /// Der Trainingsbildschirm übernimmt Wechsel und Speicherung.
  final VoidCallback? onEnterPrestige;

  const RankScreen({
    super.key,
    required this.progress,
    required this.monthlyXp,
    required this.now,
    this.onEnterPrestige,
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
        title: const Text('Level, Prestige und Trophäen'),
        content: SingleChildScrollView(
          child: Text(
            'Jede Monatsrunde endet am 1. des nächsten Monats '
            'um 00:00 Uhr UTC.\n\n'
            'Der goldene Punkt markiert den Klassenerhalt. '
            'Die benötigte Quote steigt von Level 1 bis 10 '
            'von 50 auf 80 Prozent des Monatsziels.\n\n'
            'Unter der Grenze verlierst du ein Level. '
            'Ab der Grenze hältst du dein Level. '
            'Erreichst du das Aufstiegsziel, steigst du ein Level auf.\n\n'
            'Auf Level 10 kannst du freiwillig ins nächste Prestige '
            'wechseln. Dort beginnst du wieder auf Level 1, mit neuen '
            'Namen und denselben XP-Anforderungen.\n\n'
            'Beim Prestige-Wechsel beginnen deine gewerteten '
            'Monatspunkte bei null. Nur danach gestartete Trainings '
            'zählen. Das Monatsende bleibt unverändert.\n\n'
            'Verfehlst du auf Level 1 eines Prestiges den '
            'Klassenerhalt, fällst du auf Level 10 des vorherigen '
            'Prestiges zurück. Unter das normale Level 1 '
            'kannst du nicht fallen.\n\n'
            'Jedes erstmals erreichte Prestige schaltet eine '
            'dauerhafte Trophäe frei. Bei einem Abstieg behältst du '
            'sie. Erneutes Erreichen vergibt sie nicht doppelt.\n\n'
            'Prestige 15, Level 10 ist die höchste Kombination.\n\n'
            'Nur Einheiten ab $minimumMinutes Minuten zählen für XP. '
            'Levelaufstiege erfolgen sofort nach Erreichen der jeweiligen '
            'XP-Grenze. Du kannst mehrere Level im selben Monat erreichen. '
            'Die Monats-XP werden dabei nicht abgezogen.\n\n'
            'Abstiege erfolgen ausschließlich zum Monatswechsel, '
            'höchstens um ein Level je ausgewertetem Monat. '
            'Ein freiwilliger Prestige-Wechsel bleibt auf Level 10 möglich.\n\n'
            'Vergangene Monate werden beim Öffnen nacheinander '
            'ausgewertet. Deine Trainingshistorie bleibt erhalten.',
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
    // Ohne Prestige werden weiterhin die bisherigen Namen angezeigt.
    final displayedName = progress.hasPrestige
        ? prestigeLevelName(prestige: progress.prestige, level: progress.level)
        : definition.name;

    final displayedDescription = progress.hasPrestige
        ? 'Dein Durchlauf: ${prestigeTitles[progress.prestige - 1]}. '
              'Die Anforderungen bleiben dieselben wie bei den normalen Leveln.'
        : definition.description;
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
      status = progress.canEnterPrestige
          ? 'Level 10 gesichert. Du kannst ins nächste Prestige wechseln!'
          : 'Prestige 15, Level 10 gesichert. Ganz oben!';
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
          displayedName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          progress.hasPrestige
              ? 'Prestige ${progress.prestige} · '
                    'Level ${definition.number} von ${levelLibrary.length}'
              : 'Level ${definition.number} von ${levelLibrary.length}',
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
        if (definition.number == 1 && !progress.hasPrestige) ...[
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
                  displayedDescription,
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
        // Der Wechsel ist freiwillig und erst auf Level 10 verfügbar.
        if (progress.canEnterPrestige) ...[
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onEnterPrestige,
            icon: const Icon(Icons.workspace_premium),
            label: Text('In Prestige ${progress.prestige + 1} wechseln'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Neustart auf Level 1. Die Monatswertung beginnt für dich '
            'bei null, das Monatsende bleibt gleich.',
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 28),
        const Text(
          'Deine Prestige-Trophäen',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${progress.highestPrestige} von '
          '${LevelProgress.maxPrestige} dauerhaft freigeschaltet',
          style: TextStyle(color: secondaryTextColor),
        ),
        const SizedBox(height: 12),

        // Wrap verteilt die Trophäen auch auf schmalen Geräten auf mehrere Zeilen.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (
              var prestige = 1;
              prestige <= LevelProgress.maxPrestige;
              prestige++
            )
              Tooltip(
                message: prestige <= progress.highestPrestige
                    ? '${prestigeTitles[prestige - 1]}: dauerhaft erhalten'
                    : '${prestigeTitles[prestige - 1]}: noch nicht erreicht',
                child: Chip(
                  avatar: Icon(
                    prestige <= progress.highestPrestige
                        ? Icons.emoji_events
                        : Icons.lock_outline,
                    size: 20,
                    color: prestige <= progress.highestPrestige
                        ? maintenanceColor
                        : secondaryTextColor,
                  ),
                  label: Text('Prestige $prestige'),
                ),
              ),
          ],
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
              title: Text(
                progress.hasPrestige
                    ? prestigeLevelName(
                        prestige: progress.prestige,
                        level: level.number,
                      )
                    : level.name,
              ),
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
