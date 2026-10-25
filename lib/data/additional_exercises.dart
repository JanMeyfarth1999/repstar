import 'package:repstar/models/exercise.dart';

/// Ein Datensatz besteht aus ID, Anzeigename und Ausstattung.
/// Die Muskelgruppe wird einmal für die ganze Gruppe angegeben.
typedef ExerciseEntry = (String, String, String);

/// Je 30 Ergänzungen zu den vorhandenen zehn Übungen.
/// Die IDs bleiben nach Veröffentlichung dauerhaft unverändert.
const Map<String, List<ExerciseEntry>> _entriesByMuscleGroup = {
  'Beine': [
    ('lying_leg_curl', 'Beinbeugen liegend', 'Maschine'),
    ('hip_abduction_machine', 'Abduktoren an der Maschine', 'Maschine'),
    ('hip_adduction_machine', 'Adduktoren an der Maschine', 'Maschine'),
    ('barbell_hip_thrust', 'Hip Thrust mit Langhantel', 'Langhantel & Bank'),
    ('smith_machine_squat', 'Kniebeugen an der Multipresse', 'Multipresse'),
    ('barbell_front_squat', 'Frontkniebeugen mit Langhantel', 'Langhantel'),
    ('dumbbell_goblet_squat', 'Goblet Squats', 'Kurzhantel'),
    (
      'dumbbell_walking_lunge',
      'Gehende Ausfallschritte mit Kurzhanteln',
      'Kurzhanteln',
    ),
    (
      'dumbbell_reverse_lunge',
      'Rückwärts-Ausfallschritte mit Kurzhanteln',
      'Kurzhanteln',
    ),
    (
      'dumbbell_romanian_deadlift',
      'Rumänisches Kreuzheben mit Kurzhanteln',
      'Kurzhanteln',
    ),
    ('horizontal_leg_press', 'Horizontale Beinpresse', 'Maschine'),
    ('single_leg_press', 'Einbeinige Beinpresse', 'Maschine'),
    ('single_leg_extension', 'Einbeiniges Beinstrecken', 'Maschine'),
    ('standing_single_leg_curl', 'Beinbeugen stehend, einbeinig', 'Maschine'),
    ('single_leg_seated_curl', 'Beinbeugen sitzend, einbeinig', 'Maschine'),
    ('pendulum_squat', 'Pendulum Squats', 'Pendel-Kniebeugenmaschine'),
    ('belt_squat', 'Belt Squats', 'Belt-Squat-Maschine'),
    (
      'smith_bulgarian_split_squat',
      'Bulgarian Split Squats an der Multipresse',
      'Multipresse & Bank',
    ),
    ('smith_hip_thrust', 'Hip Thrust an der Multipresse', 'Multipresse & Bank'),
    ('dumbbell_step_up', 'Step-ups mit Kurzhanteln', 'Kurzhanteln & Box'),
    ('barbell_lunge', 'Ausfallschritte mit Langhantel', 'Langhantel'),
    ('barbell_good_morning', 'Good Mornings', 'Langhantel'),
    (
      'cable_glute_kickback',
      'Glute-Kickbacks am Kabelzug',
      'Kabelzug & Fußschlaufe',
    ),
    ('cable_pull_through', 'Pull-throughs am Kabelzug', 'Kabelzug & Seil'),
    ('glute_kickback_machine', 'Glute-Kickbacks an der Maschine', 'Maschine'),
    ('calf_raise_leg_press', 'Wadenheben an der Beinpresse', 'Beinpresse'),
    (
      'smith_standing_calf_raise',
      'Wadenheben an der Multipresse',
      'Multipresse',
    ),
    (
      'dumbbell_single_leg_calf_raise',
      'Einbeiniges Wadenheben mit Kurzhantel',
      'Kurzhantel & Stufe',
    ),
    ('dumbbell_sumo_squat', 'Sumo-Kniebeugen mit Kurzhantel', 'Kurzhantel'),
    (
      'single_leg_dumbbell_rdl',
      'Einbeiniges rumänisches Kreuzheben',
      'Kurzhantel',
    ),
  ],

  'Brust': [
    (
      'smith_flat_bench_press',
      'Flachbankdrücken an der Multipresse',
      'Multipresse & Bank',
    ),
    (
      'smith_incline_bench_press',
      'Schrägbankdrücken an der Multipresse',
      'Multipresse & Schrägbank',
    ),
    (
      'incline_plate_loaded_chest_press',
      'Schräge Plate-Loaded-Brustpresse',
      'Maschine mit Gewichtsscheiben',
    ),
    (
      'incline_selectorized_chest_press',
      'Schräge Brustpresse mit Steckgewichten',
      'Maschine mit Steckgewichten',
    ),
    ('high_to_low_cable_fly', 'Kabel-Flys von oben nach unten', 'Kabelzug'),
    ('low_to_high_cable_fly', 'Kabel-Flys von unten nach oben', 'Kabelzug'),
    (
      'incline_dumbbell_fly',
      'Kurzhantel-Flys auf der Schrägbank',
      'Kurzhanteln & Schrägbank',
    ),
    (
      'decline_barbell_bench_press',
      'Langhantel-Negativbankdrücken',
      'Langhantel & Negativbank',
    ),
    (
      'decline_dumbbell_bench_press',
      'Kurzhantel-Negativbankdrücken',
      'Kurzhanteln & Negativbank',
    ),
    (
      'smith_decline_bench_press',
      'Negativbankdrücken an der Multipresse',
      'Multipresse & Negativbank',
    ),
    (
      'decline_plate_loaded_chest_press',
      'Negative Plate-Loaded-Brustpresse',
      'Maschine mit Gewichtsscheiben',
    ),
    ('single_arm_machine_chest_press', 'Einarmige Brustpresse', 'Maschine'),
    (
      'standing_cable_chest_press',
      'Brustdrücken am Kabelzug stehend',
      'Kabelzug',
    ),
    (
      'seated_cable_chest_press',
      'Brustdrücken am Kabelzug sitzend',
      'Kabelzug & Bank',
    ),
    (
      'single_arm_cable_chest_press',
      'Einarmiges Brustdrücken am Kabelzug',
      'Kabelzug',
    ),
    ('flat_bench_cable_fly', 'Kabel-Flys auf der Flachbank', 'Kabelzug & Bank'),
    (
      'incline_bench_cable_fly',
      'Kabel-Flys auf der Schrägbank',
      'Kabelzug & Schrägbank',
    ),
    ('single_arm_cable_fly', 'Einarmige Kabel-Flys', 'Kabelzug'),
    (
      'decline_dumbbell_fly',
      'Kurzhantel-Flys auf der Negativbank',
      'Kurzhanteln & Negativbank',
    ),
    ('dumbbell_floor_press', 'Kurzhantel-Floor-Press', 'Kurzhanteln'),
    ('barbell_floor_press', 'Langhantel-Floor-Press', 'Langhantel & Rack'),
    (
      'neutral_grip_dumbbell_bench_press',
      'Kurzhantel-Bankdrücken mit neutralem Griff',
      'Kurzhanteln & Bank',
    ),
    (
      'dumbbell_squeeze_press',
      'Squeeze Press mit Kurzhanteln',
      'Kurzhanteln & Bank',
    ),
    (
      'single_arm_dumbbell_bench_press',
      'Einarmiges Kurzhantel-Bankdrücken',
      'Kurzhantel & Bank',
    ),
    (
      'chest_focused_dip',
      'Brustbetonte Dips mit vorgebeugtem Oberkörper',
      'Parallelbarren',
    ),
    (
      'incline_push_up',
      'Liegestütze mit erhöhten Händen',
      'Bank oder stabile Erhöhung',
    ),
    (
      'decline_push_up',
      'Liegestütze mit erhöhten Füßen',
      'Bank & Körpergewicht',
    ),
    ('kneeling_push_up', 'Liegestütze auf den Knien', 'Körpergewicht'),
    (
      'suspension_chest_press',
      'Brustdrücken am Schlingentrainer',
      'Schlingentrainer',
    ),
    (
      'resistance_band_chest_press',
      'Brustdrücken mit Widerstandsband',
      'Widerstandsband',
    ),
  ],

  'Bizeps': [
    ('single_arm_cable_curl', 'Einarmige Kabelcurls', 'Kabelzug'),
    ('bayesian_cable_curl', 'Bayesian Curls am Kabelzug', 'Kabelzug'),
    (
      'dumbbell_preacher_curl',
      'Einarmige Scott-Curls mit Kurzhantel',
      'Kurzhantel & Scottbank',
    ),
    ('cable_preacher_curl', 'Scott-Curls am Kabelzug', 'Kabelzug & Scottbank'),
    (
      'ez_bar_spider_curl',
      'Spider-Curls mit SZ-Stange',
      'SZ-Stange & Schrägbank',
    ),
    (
      'dumbbell_spider_curl',
      'Spider-Curls mit Kurzhanteln',
      'Kurzhanteln & Schrägbank',
    ),
    ('cross_body_hammer_curl', 'Cross-Body-Hammer-Curls', 'Kurzhanteln'),
    (
      'incline_hammer_curl',
      'Hammer-Curls auf der Schrägbank',
      'Kurzhanteln & Schrägbank',
    ),
    ('seated_dumbbell_curl', 'Kurzhantel-Curls sitzend', 'Kurzhanteln & Bank'),
    ('seated_hammer_curl', 'Hammer-Curls sitzend', 'Kurzhanteln & Bank'),
    (
      'alternating_dumbbell_curl',
      'Alternierende Kurzhantel-Curls',
      'Kurzhanteln',
    ),
    ('zottman_curl', 'Zottman-Curls', 'Kurzhanteln'),
    ('reverse_ez_bar_curl', 'Reverse-Curls mit SZ-Stange', 'SZ-Stange'),
    ('reverse_barbell_curl', 'Reverse-Curls mit Langhantel', 'Langhantel'),
    ('reverse_dumbbell_curl', 'Reverse-Curls mit Kurzhanteln', 'Kurzhanteln'),
    ('reverse_cable_curl', 'Reverse-Curls am Kabelzug', 'Kabelzug'),
    ('ez_bar_cable_curl', 'Kabelcurls mit SZ-Griff', 'Kabelzug & SZ-Griff'),
    (
      'high_cable_double_biceps_curl',
      'Doppelbizeps-Curls am hohen Kabelzug',
      'Kabelzug',
    ),
    (
      'lying_cable_curl',
      'Kabelcurls auf der Flachbank liegend',
      'Kabelzug & Bank',
    ),
    (
      'incline_cable_curl',
      'Kabelcurls auf der Schrägbank',
      'Kabelzug & Schrägbank',
    ),
    ('cable_concentration_curl', 'Konzentrationscurls am Kabelzug', 'Kabelzug'),
    ('barbell_drag_curl', 'Drag-Curls mit Langhantel', 'Langhantel'),
    ('dumbbell_drag_curl', 'Drag-Curls mit Kurzhanteln', 'Kurzhanteln'),
    ('wide_grip_ez_bar_curl', 'SZ-Curls mit breitem Griff', 'SZ-Stange'),
    ('close_grip_ez_bar_curl', 'SZ-Curls mit engem Griff', 'SZ-Stange'),
    (
      'barbell_preacher_curl',
      'Scott-Curls mit gerader Langhantel',
      'Langhantel & Scottbank',
    ),
    (
      'hammer_preacher_curl',
      'Hammer-Curls an der Scottbank',
      'Kurzhantel & Scottbank',
    ),
    (
      'single_arm_machine_curl',
      'Einarmige Bizepscurls an der Maschine',
      'Maschine',
    ),
    (
      'behind_body_incline_curl',
      'Schrägbank-Curls mit nach außen gedrehten Armen',
      'Kurzhanteln & Schrägbank',
    ),
    (
      'resistance_band_biceps_curl',
      'Bizepscurls mit Widerstandsband',
      'Widerstandsband',
    ),
  ],

  'Trizeps': [
    ('rope_triceps_pushdown', 'Trizepsdrücken mit Seil', 'Kabelzug & Seil'),
    (
      'v_bar_triceps_pushdown',
      'Trizepsdrücken mit V-Griff',
      'Kabelzug & V-Griff',
    ),
    (
      'reverse_grip_triceps_pushdown',
      'Trizepsdrücken im Untergriff',
      'Kabelzug',
    ),
    (
      'single_arm_cable_pushdown',
      'Einarmiges Trizepsdrücken am Kabelzug',
      'Kabelzug',
    ),
    (
      'single_arm_reverse_pushdown',
      'Einarmiges Trizepsdrücken im Untergriff',
      'Kabelzug',
    ),
    (
      'cross_body_cable_extension',
      'Cross-Body-Trizepsstrecken am Kabelzug',
      'Kabelzug',
    ),
    (
      'dual_cable_triceps_pushdown',
      'Trizepsdrücken mit zwei Einzelgriffen',
      'Kabelzug & Einzelgriffe',
    ),
    (
      'overhead_bar_cable_extension',
      'Überkopf-Trizepsstrecken mit Kabelstange',
      'Kabelzug & Stange',
    ),
    (
      'high_pulley_overhead_extension',
      'Überkopf-Trizepsstrecken vom hohen Kabelzug',
      'Kabelzug & Seil',
    ),
    (
      'seated_ez_bar_french_press',
      'French Press mit SZ-Stange sitzend',
      'SZ-Stange & Bank',
    ),
    (
      'standing_ez_bar_french_press',
      'French Press mit SZ-Stange stehend',
      'SZ-Stange',
    ),
    (
      'lying_barbell_triceps_extension',
      'Trizepsstrecken mit Langhantel liegend',
      'Langhantel & Bank',
    ),
    (
      'lying_dumbbell_triceps_extension',
      'Trizepsstrecken mit zwei Kurzhanteln liegend',
      'Kurzhanteln & Bank',
    ),
    (
      'single_arm_lying_dumbbell_extension',
      'Einarmiges Trizepsstrecken liegend',
      'Kurzhantel & Bank',
    ),
    (
      'incline_ez_bar_triceps_extension',
      'French Press mit SZ-Stange auf der Schrägbank',
      'SZ-Stange & Schrägbank',
    ),
    (
      'incline_dumbbell_triceps_extension',
      'Trizepsstrecken mit Kurzhanteln auf der Schrägbank',
      'Kurzhanteln & Schrägbank',
    ),
    (
      'decline_ez_bar_triceps_extension',
      'French Press mit SZ-Stange auf der Negativbank',
      'SZ-Stange & Negativbank',
    ),
    (
      'lying_cable_triceps_extension',
      'Trizepsstrecken am Kabelzug liegend',
      'Kabelzug & Bank',
    ),
    (
      'incline_cable_triceps_extension',
      'Trizepsstrecken am Kabelzug auf der Schrägbank',
      'Kabelzug & Schrägbank',
    ),
    (
      'single_arm_cable_kickback',
      'Einarmige Kickbacks am Kabelzug',
      'Kabelzug',
    ),
    ('two_arm_cable_kickback', 'Beidarmige Kickbacks am Kabelzug', 'Kabelzug'),
    (
      'two_arm_dumbbell_kickback',
      'Beidarmige Kurzhantel-Kickbacks',
      'Kurzhanteln',
    ),
    (
      'smith_close_grip_bench_press',
      'Enges Bankdrücken an der Multipresse',
      'Multipresse & Bank',
    ),
    (
      'close_grip_dumbbell_press',
      'Enges Bankdrücken mit Kurzhanteln',
      'Kurzhanteln & Bank',
    ),
    ('close_grip_push_up', 'Enge Liegestütze', 'Körpergewicht'),
    ('diamond_push_up', 'Diamant-Liegestütze', 'Körpergewicht'),
    (
      'assisted_triceps_dip',
      'Trizeps-Dips mit Maschinenunterstützung',
      'Assistierte Dipmaschine',
    ),
    ('seated_dip_machine', 'Dips an der sitzenden Dipmaschine', 'Maschine'),
    (
      'suspension_triceps_extension',
      'Trizepsstrecken am Schlingentrainer',
      'Schlingentrainer',
    ),
    (
      'resistance_band_triceps_pushdown',
      'Trizepsdrücken mit Widerstandsband',
      'Widerstandsband',
    ),
  ],

  'Rücken': [
    ('neutral_grip_lat_pulldown', 'Latzug mit neutralem Griff', 'Kabelzug'),
    ('underhand_lat_pulldown', 'Latzug im Untergriff', 'Kabelzug'),
    ('single_arm_lat_pulldown', 'Einarmiger Latzug', 'Kabelzug'),
    (
      'plate_loaded_lat_pulldown',
      'Latzug an der Plate-Loaded-Maschine',
      'Maschine mit Gewichtsscheiben',
    ),
    ('machine_high_row', 'High Row an der Maschine', 'Maschine'),
    (
      'plate_loaded_low_row',
      'Low Row an der Plate-Loaded-Maschine',
      'Maschine mit Gewichtsscheiben',
    ),
    ('t_bar_row', 'T-Bar-Rudern', 'T-Bar-Station'),
    (
      'chest_supported_t_bar_row',
      'T-Bar-Rudern mit Brustauflage',
      'T-Bar-Maschine mit Brustauflage',
    ),
    ('single_arm_cable_row', 'Einarmiges Kabelrudern', 'Kabelzug'),
    (
      'wide_grip_seated_cable_row',
      'Kabelrudern mit breitem Obergriff',
      'Kabelzug',
    ),
    ('underhand_seated_cable_row', 'Kabelrudern im Untergriff', 'Kabelzug'),
    ('single_arm_machine_row', 'Einarmiges Rudern an der Maschine', 'Maschine'),
    ('underhand_barbell_row', 'Langhantelrudern im Untergriff', 'Langhantel'),
    ('pendlay_row', 'Pendlay Rows', 'Langhantel'),
    (
      'smith_bent_over_row',
      'Vorgebeugtes Rudern an der Multipresse',
      'Multipresse',
    ),
    (
      'seal_barbell_row',
      'Seal Rows mit Langhantel',
      'Langhantel & hohe Flachbank',
    ),
    (
      'bent_over_dumbbell_row',
      'Vorgebeugtes Rudern mit zwei Kurzhanteln',
      'Kurzhanteln',
    ),
    ('meadows_row', 'Meadows Rows', 'Langhantel & Landmine'),
    ('chin_up', 'Klimmzüge im Untergriff', 'Klimmzugstange'),
    (
      'neutral_grip_pull_up',
      'Klimmzüge mit neutralem Griff',
      'Klimmzugstation',
    ),
    (
      'inverted_row',
      'Umgekehrtes Rudern an der Stange',
      'Stange & Körpergewicht',
    ),
    ('suspension_row', 'Rudern am Schlingentrainer', 'Schlingentrainer'),
    ('machine_pullover', 'Überzüge an der Maschine', 'Pullover-Maschine'),
    (
      'rope_straight_arm_pulldown',
      'Gestrecktes Armziehen mit Seil',
      'Kabelzug & Seil',
    ),
    (
      'single_arm_straight_arm_pulldown',
      'Einarmiges gestrecktes Armziehen',
      'Kabelzug',
    ),
    ('machine_back_extension', 'Rückenstrecken an der Maschine', 'Maschine'),
    ('barbell_deadlift', 'Klassisches Kreuzheben', 'Langhantel'),
    ('trap_bar_deadlift', 'Kreuzheben mit Trap Bar', 'Trap Bar'),
    ('barbell_shrug', 'Schulterheben mit Langhantel', 'Langhantel'),
    ('dumbbell_shrug', 'Schulterheben mit Kurzhanteln', 'Kurzhanteln'),
  ],

  'Schultern': [
    ('machine_lateral_raise', 'Seitheben an der Maschine', 'Maschine'),
    (
      'smith_seated_shoulder_press',
      'Schulterdrücken an der Multipresse sitzend',
      'Multipresse & Bank',
    ),
    (
      'plate_loaded_shoulder_press',
      'Plate-Loaded-Schulterpresse',
      'Maschine mit Gewichtsscheiben',
    ),
    (
      'seated_barbell_shoulder_press',
      'Langhantel-Schulterdrücken sitzend',
      'Langhantel & Bank',
    ),
    (
      'standing_dumbbell_shoulder_press',
      'Kurzhantel-Schulterdrücken stehend',
      'Kurzhanteln',
    ),
    (
      'neutral_grip_dumbbell_shoulder_press',
      'Kurzhantel-Schulterdrücken mit neutralem Griff',
      'Kurzhanteln',
    ),
    (
      'single_arm_dumbbell_shoulder_press',
      'Einarmiges Kurzhantel-Schulterdrücken',
      'Kurzhantel',
    ),
    (
      'single_arm_landmine_press',
      'Einarmige Landmine Press',
      'Langhantel & Landmine',
    ),
    (
      'seated_dumbbell_lateral_raise',
      'Kurzhantel-Seitheben sitzend',
      'Kurzhanteln & Bank',
    ),
    (
      'lean_away_dumbbell_lateral_raise',
      'Einarmiges Seitheben mit seitlicher Neigung',
      'Kurzhantel & Haltemöglichkeit',
    ),
    (
      'incline_side_lying_lateral_raise',
      'Seitheben seitlich auf der Schrägbank',
      'Kurzhantel & Schrägbank',
    ),
    (
      'bilateral_cable_lateral_raise',
      'Beidarmiges Seitheben am Kabelzug',
      'Kabelzug',
    ),
    (
      'behind_body_cable_lateral_raise',
      'Seitheben am Kabelzug hinter dem Körper',
      'Kabelzug',
    ),
    (
      'lean_away_cable_lateral_raise',
      'Seitheben am Kabelzug mit seitlicher Neigung',
      'Kabelzug',
    ),
    (
      'cuffed_cable_lateral_raise',
      'Seitheben am Kabelzug mit Manschette',
      'Kabelzug & Armmanschette',
    ),
    ('barbell_front_raise', 'Frontheben mit Langhantel', 'Langhantel'),
    ('plate_front_raise', 'Frontheben mit Gewichtsscheibe', 'Gewichtsscheibe'),
    ('cable_front_raise', 'Frontheben am Kabelzug', 'Kabelzug'),
    (
      'rope_cable_front_raise',
      'Frontheben am Kabelzug mit Seil',
      'Kabelzug & Seil',
    ),
    (
      'seated_dumbbell_front_raise',
      'Kurzhantel-Frontheben sitzend',
      'Kurzhanteln & Bank',
    ),
    ('cable_reverse_fly', 'Reverse-Flys am Kabelzug', 'Kabelzug'),
    (
      'single_arm_cable_reverse_fly',
      'Einarmige Reverse-Flys am Kabelzug',
      'Kabelzug',
    ),
    (
      'chest_supported_dumbbell_reverse_fly',
      'Reverse-Flys mit Brustauflage',
      'Kurzhanteln & Schrägbank',
    ),
    (
      'seated_bent_over_reverse_fly',
      'Reverse-Flys sitzend und vorgebeugt',
      'Kurzhanteln & Bank',
    ),
    (
      'chest_supported_rear_delt_row',
      'Rudern für hintere Schultern mit Brustauflage',
      'Kurzhanteln & Schrägbank',
    ),
    (
      'cable_rear_delt_row',
      'Rudern für hintere Schultern am Kabelzug',
      'Kabelzug',
    ),
    ('cable_y_raise', 'Y-Raises am Kabelzug', 'Kabelzug'),
    (
      'incline_dumbbell_y_raise',
      'Y-Raises auf der Schrägbank',
      'Kurzhanteln & Schrägbank',
    ),
    ('barbell_upright_row', 'Aufrechtes Rudern mit Langhantel', 'Langhantel'),
    ('cable_upright_row', 'Aufrechtes Rudern am Kabelzug', 'Kabelzug'),
  ],
};

/// Baut aus allen kompakten Datensätzen vollständige Exercise-Objekte.
/// Diese Umwandlung wird einmal beim ersten Zugriff ausgeführt.
final List<Exercise> additionalExercises = List<Exercise>.unmodifiable([
  for (final group in _entriesByMuscleGroup.entries)
    for (final entry in group.value)
      Exercise(
        id: entry.$1,
        name: entry.$2,

        // Neue Bilder erhalten den Dateinamen der stabilen Übungs-ID.
        // Bis das Bild vorhanden ist, greift ExerciseImage als Ersatz.
        imagePath: 'assets/images/exercises/${entry.$1}.png',
        muscleGroup: group.key,
        equipment: entry.$3,
      ),
]);
