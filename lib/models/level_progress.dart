/// Speichert den persönlichen Rang und den ausgewerteten Kalendermonat.
class LevelProgress {
  final int level;

  /// Monatsbeginn in UTC, beispielsweise 2026-11-01 um 00:00 Uhr.
  final DateTime periodStartedAt;

  const LevelProgress({required this.level, required this.periodStartedAt});

  /// Liefert den Beginn des Kalendermonats eines Zeitpunkts.
  static DateTime monthStart(DateTime date) {
    final utcDate = date.toUtc();

    return DateTime.utc(utcDate.year, utcDate.month, 1);
  }

  /// Die Runde endet am ersten Tag des nächsten Monats um 00:00 Uhr UTC.
  DateTime get periodEndsAt {
    final start = periodStartedAt.toUtc();

    // DateTime behandelt Monat 13 automatisch als Januar des Folgejahres.
    return DateTime.utc(start.year, start.month + 1, 1);
  }

  /// Neue Nutzer beginnen mit Rang 1 im aktuellen Kalendermonat.
  factory LevelProgress.initial({DateTime? now}) {
    return LevelProgress(
      level: 1,
      periodStartedAt: monthStart(now ?? DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'periodStartedAt': monthStart(periodStartedAt).toIso8601String(),
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    final level = json['level'];
    final startedAt = json['periodStartedAt'];

    if (level is! int || level < 1 || level > 10) {
      throw const FormatException('Ungültiger Rang.');
    }

    if (startedAt is! String) {
      throw const FormatException('Der Beginn der Rangrunde fehlt.');
    }

    final parsedDate = DateTime.tryParse(startedAt);

    if (parsedDate == null) {
      throw const FormatException('Ungültiger Beginn der Rangrunde.');
    }

    return LevelProgress(
      level: level,

      // Normalisiert auch zuvor gespeicherte Startdaten auf den Monatsbeginn.
      periodStartedAt: monthStart(parsedDate),
    );
  }
}
