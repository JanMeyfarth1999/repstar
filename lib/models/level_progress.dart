/// Speichert Rang, Prestige und den ausgewerteten Kalendermonat.
class LevelProgress {
  static const int maxLevel = 10;
  static const int maxPrestige = 15;

  final int level;

  /// 0 bedeutet: normale Level ohne sichtbare Prestige-Bezeichnung.
  final int prestige;

  /// Bleibt auch bei einem Abstieg erhalten.
  /// Daraus ergibt sich, welche Trophäen dauerhaft freigeschaltet sind.
  final int highestPrestige;

  /// Beginn des aktuell ausgewerteten Kalendermonats in UTC.
  final DateTime periodStartedAt;

  /// Nach einem Prestige-Wechsel zählen nur neue Trainingseinheiten.
  /// null bedeutet: Es gilt der normale Monatsbeginn.
  final DateTime? xpStartedAt;

  const LevelProgress({
    required this.level,
    required this.periodStartedAt,
    this.prestige = 0,
    this.highestPrestige = 0,
    this.xpStartedAt,
  }) : assert(level >= 1 && level <= maxLevel),
       assert(prestige >= 0 && prestige <= maxPrestige),
       assert(highestPrestige >= prestige),
       assert(highestPrestige <= maxPrestige);

  /// Gibt an, ob aktuell ein Prestige aktiv ist.
  bool get hasPrestige => prestige > 0;

  /// Auf Level 10 kann freiwillig das nächste Prestige gewählt werden.
  bool get canEnterPrestige => level == maxLevel && prestige < maxPrestige;

  /// Liefert die Nummern aller dauerhaft freigeschalteten Trophäen.
  List<int> get unlockedTrophies => List<int>.unmodifiable(
    List<int>.generate(highestPrestige, (index) => index + 1),
  );

  /// Liefert den Beginn des Kalendermonats eines Zeitpunkts.
  static DateTime monthStart(DateTime date) {
    final utcDate = date.toUtc();

    return DateTime.utc(utcDate.year, utcDate.month, 1);
  }

  /// Die Runde endet am ersten Tag des nächsten Monats um 00:00 Uhr UTC.
  DateTime get periodEndsAt {
    final start = periodStartedAt.toUtc();

    // Monat 13 wird automatisch zum Januar des Folgejahres.
    return DateTime.utc(start.year, start.month + 1, 1);
  }

  /// Neue Nutzer beginnen mit dem bisherigen Level 1 ohne Prestige.
  factory LevelProgress.initial({DateTime? now}) {
    return LevelProgress(
      level: 1,
      periodStartedAt: monthStart(now ?? DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'prestige': prestige,
      'highestPrestige': highestPrestige,
      'periodStartedAt': monthStart(periodStartedAt).toIso8601String(),
      'xpStartedAt': xpStartedAt?.toUtc().toIso8601String(),
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    final level = json['level'];
    final startedAt = json['periodStartedAt'];

    // Alte Speicherstände besitzen noch keine Prestige-Felder.
    final prestige = json['prestige'] ?? 0;
    final highestPrestige = json['highestPrestige'] ?? prestige;

    if (level is! int || level < 1 || level > maxLevel) {
      throw const FormatException('Ungültiger Rang.');
    }

    if (prestige is! int || prestige < 0 || prestige > maxPrestige) {
      throw const FormatException('Ungültiges Prestige.');
    }

    if (highestPrestige is! int ||
        highestPrestige < prestige ||
        highestPrestige > maxPrestige) {
      throw const FormatException('Ungültiger Trophäenfortschritt.');
    }

    if (startedAt is! String) {
      throw const FormatException('Der Beginn der Rangrunde fehlt.');
    }

    final parsedDate = DateTime.tryParse(startedAt);

    if (parsedDate == null) {
      throw const FormatException('Ungültiger Beginn der Rangrunde.');
    }

    final xpStartedAtText = json['xpStartedAt'];
    DateTime? xpStartedAt;

    if (xpStartedAtText != null) {
      if (xpStartedAtText is! String) {
        throw const FormatException('Ungültiger Beginn der XP-Wertung.');
      }

      xpStartedAt = DateTime.tryParse(xpStartedAtText);

      if (xpStartedAt == null) {
        throw const FormatException('Ungültiger Beginn der XP-Wertung.');
      }
    }

    return LevelProgress(
      level: level,
      prestige: prestige,
      highestPrestige: highestPrestige,
      periodStartedAt: monthStart(parsedDate),
      xpStartedAt: xpStartedAt?.toUtc(),
    );
  }
}
