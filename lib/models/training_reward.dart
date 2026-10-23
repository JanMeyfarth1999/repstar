/// Hält das einmal berechnete Ergebnis einer Trainingseinheit fest.
class TrainingReward {
  final int calculationVersion;
  final int earnedXp;
  final int completedSets;
  final int completedRepetitions;

  /// Geschätzte reine Ausführungszeit der gewerteten Sätze.
  final double estimatedActiveSeconds;

  /// Modellschätzung für den zusätzlichen Verbrauch während der Sätze.
  /// Ohne bekanntes Körpergewicht bleibt dieser Wert null.
  final double? estimatedActiveKcal;

  const TrainingReward({
    required this.calculationVersion,
    required this.earnedXp,
    required this.completedSets,
    required this.completedRepetitions,
    required this.estimatedActiveSeconds,
    required this.estimatedActiveKcal,
  });

  Map<String, dynamic> toJson() {
    return {
      'calculationVersion': calculationVersion,
      'earnedXp': earnedXp,
      'completedSets': completedSets,
      'completedRepetitions': completedRepetitions,
      'estimatedActiveSeconds': estimatedActiveSeconds,
      'estimatedActiveKcal': estimatedActiveKcal,
    };
  }

  factory TrainingReward.fromJson(Map<String, dynamic> json) {
    return TrainingReward(
      calculationVersion: json['calculationVersion'] as int,
      earnedXp: json['earnedXp'] as int,
      completedSets: json['completedSets'] as int,
      completedRepetitions: json['completedRepetitions'] as int,
      estimatedActiveSeconds: (json['estimatedActiveSeconds'] as num)
          .toDouble(),
      estimatedActiveKcal: (json['estimatedActiveKcal'] as num?)?.toDouble(),
    );
  }
}
