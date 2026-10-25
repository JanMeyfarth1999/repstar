import 'package:repstar/models/exercise.dart';
import 'package:repstar/data/additional_exercises.dart';

/// Bestehende Übungen und Ergänzungen bilden die gemeinsame Bibliothek.
/// Jede der sechs Muskelgruppen enthält insgesamt 40 Übungen.
final List<Exercise> exerciseLibrary = List<Exercise>.unmodifiable([
  // --------------------------------------------------
  // Beine
  // --------------------------------------------------
  Exercise(
    id: 'leg_press',
    name: 'Beinpresse',
    imagePath: 'assets/images/exercises/beinpresse.png',
    muscleGroup: 'Beine',
    equipment: 'Maschine',
  ),
  Exercise(
    id: 'barbell_back_squat',
    name: 'Langhantel-Kniebeugen',
    imagePath: 'assets/images/exercises/langhantel_kniebeugen.png',
    muscleGroup: 'Beine',
    equipment: 'Langhantel',
  ),
  Exercise(
    id: 'hack_squat',
    name: 'Hackenschmidt-Kniebeugen',
    imagePath: 'assets/images/exercises/hackenschmidt_kniebeugen.png',
    muscleGroup: 'Beine',
    equipment: 'Maschine',
  ),
  Exercise(
    id: 'leg_extension',
    name: 'Beinstrecken an der Maschine',
    imagePath: 'assets/images/exercises/beinstrecken.png',
    muscleGroup: 'Beine',
    equipment: 'Maschine',
  ),
  Exercise(
    id: 'seated_leg_curl',
    name: 'Beinbeugen sitzend',
    imagePath: 'assets/images/exercises/beinbeugen_sitzend.png',
    muscleGroup: 'Beine',
    equipment: 'Maschine',
  ),
  Exercise(
    id: 'barbell_romanian_deadlift',
    name: 'Rumänisches Kreuzheben',
    imagePath: 'assets/images/exercises/rumaenisches_kreuzheben.png',
    muscleGroup: 'Beine',
    equipment: 'Langhantel',
  ),
  Exercise(
    id: 'dumbbell_bulgarian_split_squat',
    name: 'Bulgarian Split Squats',
    imagePath: 'assets/images/exercises/bulgarian_split_squats.png',
    muscleGroup: 'Beine',
    equipment: 'Kurzhanteln & Bank',
  ),
  Exercise(
    id: 'machine_hip_thrust',
    name: 'Hip Thrust an der Maschine',
    imagePath: 'assets/images/exercises/hip_thrust_maschine.png',
    muscleGroup: 'Beine',
    equipment: 'Maschine',
  ),
  Exercise(
    id: 'standing_calf_raise',
    name: 'Wadenheben stehend',
    imagePath: 'assets/images/exercises/wadenheben_stehend.png',
    muscleGroup: 'Beine',
    equipment: 'Maschine',
  ),
  Exercise(
    id: 'seated_calf_raise',
    name: 'Wadenheben sitzend',
    imagePath: 'assets/images/exercises/wadenheben_sitzend.png',
    muscleGroup: 'Beine',
    equipment: 'Maschine',
  ),

  // --------------------------------------------------
  // Brust
  // --------------------------------------------------
  Exercise(
    id: 'incline_dumbbell_press',
    name: 'Kurzhantel-Schrägbankdrücken',
    imagePath: 'assets/images/exercises/kurzhantel_schraegbankdruecken.png',
    muscleGroup: 'Brust',
    equipment: 'Kurzhantel',
  ),
  Exercise(
    id: 'barbell_bench_press',
    name: 'Langhantel-Bankdrücken',
    imagePath: 'assets/images/exercises/langhantel_bankdruecken.png',
    muscleGroup: 'Brust',
    equipment: 'Langhantel & Bank',
  ),
  Exercise(
    id: 'flat_dumbbell_press',
    name: 'Kurzhantel-Flachbankdrücken',
    imagePath: 'assets/images/exercises/kurzhantel_flachbankdruecken.png',
    muscleGroup: 'Brust',
    equipment: 'Kurzhanteln & Bank',
  ),
  Exercise(
    id: 'incline_barbell_press',
    name: 'Langhantel-Schrägbankdrücken',
    imagePath: 'assets/images/exercises/langhantel_schraegbankdruecken.png',
    muscleGroup: 'Brust',
    equipment: 'Langhantel & Schrägbank',
  ),
  Exercise(
    id: 'plate_loaded_chest_press',
    name: 'Plate-Loaded-Brustpresse',
    imagePath: 'assets/images/exercises/plate_loaded_brustpresse.png',
    muscleGroup: 'Brust',
    equipment: 'Maschine mit Gewichtsscheiben',
  ),
  Exercise(
    id: 'selectorized_chest_press',
    name: 'Brustpresse mit Steckgewichten',
    imagePath: 'assets/images/exercises/brustpresse_steckgewichte.png',
    muscleGroup: 'Brust',
    equipment: 'Maschine mit Steckgewichten',
  ),
  Exercise(
    id: 'pec_deck_fly',
    name: 'Butterfly an der Maschine',
    imagePath: 'assets/images/exercises/butterfly_maschine.png',
    muscleGroup: 'Brust',
    equipment: 'Maschine',
  ),
  Exercise(
    id: 'standing_cable_fly',
    name: 'Kabel-Flys stehend',
    imagePath: 'assets/images/exercises/kabel_flys_stehend.png',
    muscleGroup: 'Brust',
    equipment: 'Kabelzug',
  ),
  Exercise(
    id: 'flat_dumbbell_fly',
    name: 'Kurzhantel-Flys auf der Flachbank',
    imagePath: 'assets/images/exercises/kurzhantel_flys_flachbank.png',
    muscleGroup: 'Brust',
    equipment: 'Kurzhanteln & Bank',
  ),
  Exercise(
    id: 'push_up',
    name: 'Liegestütze',
    imagePath: 'assets/images/exercises/liegestuetze.png',
    muscleGroup: 'Brust',
    equipment: 'Körpergewicht',
  ),

  // --------------------------------------------------
  // Bizeps
  // --------------------------------------------------
  Exercise(
    id: 'dumbbell_curl',
    name: 'Kurzhantel-Bizepscurls',
    imagePath: 'assets/images/exercises/kurzhantel_bizepscurls.png',
    muscleGroup: 'Bizeps',
    equipment: 'Kurzhantel',
  ),
  Exercise(
    id: 'barbell_curl',
    name: 'Langhantel-Curls',
    imagePath: 'assets/images/exercises/langhantel_curls.png',
    muscleGroup: 'Bizeps',
    equipment: 'Langhantel',
  ),
  Exercise(
    id: 'ez_bar_curl',
    name: 'SZ-Stangen-Curls',
    imagePath: 'assets/images/exercises/sz_stangen_curls.png',
    muscleGroup: 'Bizeps',
    equipment: 'SZ-Stange',
  ),
  Exercise(
    id: 'dumbbell_hammer_curl',
    name: 'Hammer-Curls',
    imagePath: 'assets/images/exercises/hammer_curls.png',
    muscleGroup: 'Bizeps',
    equipment: 'Kurzhanteln',
  ),
  Exercise(
    id: 'incline_dumbbell_curl',
    name: 'Kurzhantel-Curls auf der Schrägbank',
    imagePath: 'assets/images/exercises/schraegbank_curls.png',
    muscleGroup: 'Bizeps',
    equipment: 'Kurzhanteln & Schrägbank',
  ),
  Exercise(
    id: 'concentration_curl',
    name: 'Konzentrationscurls',
    imagePath: 'assets/images/exercises/konzentrationscurls.png',
    muscleGroup: 'Bizeps',
    equipment: 'Kurzhantel',
  ),
  Exercise(
    id: 'ez_bar_preacher_curl',
    name: 'Scott-Curls mit SZ-Stange',
    imagePath: 'assets/images/exercises/scott_curls_sz_stange.png',
    muscleGroup: 'Bizeps',
    equipment: 'SZ-Stange & Scottbank',
  ),
  Exercise(
    id: 'straight_bar_cable_curl',
    name: 'Kabelcurls mit gerader Stange',
    imagePath: 'assets/images/exercises/kabelcurls_stange.png',
    muscleGroup: 'Bizeps',
    equipment: 'Kabelzug',
  ),
  Exercise(
    id: 'rope_cable_curl',
    name: 'Kabelcurls mit Seil',
    imagePath: 'assets/images/exercises/kabelcurls_seil.png',
    muscleGroup: 'Bizeps',
    equipment: 'Kabelzug',
  ),
  Exercise(
    id: 'machine_biceps_curl',
    name: 'Bizepscurls an der Maschine',
    imagePath: 'assets/images/exercises/bizepscurls_maschine.png',
    muscleGroup: 'Bizeps',
    equipment: 'Maschine',
  ),

  // --------------------------------------------------
  // Trizeps
  // --------------------------------------------------
  Exercise(
    id: 'cable_triceps_pushdown',
    name: 'Trizepsdrücken am Kabelzug',
    imagePath: 'assets/images/exercises/trizepsdruecken_kabelzug.png',
    muscleGroup: 'Trizeps',
    equipment: 'Kabelzug',
  ),
  Exercise(
    id: 'overhead_rope_triceps_extension',
    name: 'Überkopf-Trizepsstrecken am Kabelzug mit Seil',
    imagePath: 'assets/images/exercises/ueberkopf_trizepsstrecken_seil.png',
    muscleGroup: 'Trizeps',
    equipment: 'Kabelzug',
  ),
  Exercise(
    id: 'single_arm_overhead_cable_triceps_extension',
    name: 'Einarmiges Überkopf-Trizepsstrecken am Kabelzug',
    imagePath:
        'assets/images/exercises/einarmiges_ueberkopf_trizepsstrecken_kabel.png',
    muscleGroup: 'Trizeps',
    equipment: 'Kabelzug',
  ),
  Exercise(
    id: 'lying_ez_bar_triceps_extension',
    name: 'French Press mit SZ-Stange liegend',
    imagePath: 'assets/images/exercises/french_press_sz_stange.png',
    muscleGroup: 'Trizeps',
    equipment: 'SZ-Stange & Bank',
  ),
  Exercise(
    id: 'two_arm_overhead_dumbbell_triceps_extension',
    name: 'Beidarmiges Überkopf-Trizepsstrecken mit Kurzhantel',
    imagePath:
        'assets/images/exercises/beidarmiges_ueberkopf_trizepsstrecken.png',
    muscleGroup: 'Trizeps',
    equipment: 'Kurzhantel',
  ),
  Exercise(
    id: 'single_arm_overhead_dumbbell_triceps_extension',
    name: 'Einarmiges Überkopf-Trizepsstrecken mit Kurzhantel',
    imagePath:
        'assets/images/exercises/einarmiges_ueberkopf_trizepsstrecken.png',
    muscleGroup: 'Trizeps',
    equipment: 'Kurzhantel',
  ),
  Exercise(
    id: 'dumbbell_triceps_kickback',
    name: 'Kurzhantel-Kickbacks',
    imagePath: 'assets/images/exercises/kurzhantel_kickbacks.png',
    muscleGroup: 'Trizeps',
    equipment: 'Kurzhantel',
  ),
  Exercise(
    id: 'close_grip_barbell_bench_press',
    name: 'Enges Langhantel-Bankdrücken',
    imagePath: 'assets/images/exercises/enges_langhantel_bankdruecken.png',
    muscleGroup: 'Trizeps',
    equipment: 'Langhantel & Bank',
  ),
  Exercise(
    id: 'parallel_bar_dip',
    name: 'Dips am Parallelbarren',
    imagePath: 'assets/images/exercises/dips_parallelbarren.png',
    muscleGroup: 'Trizeps',
    equipment: 'Parallelbarren',
  ),
  Exercise(
    id: 'machine_triceps_extension',
    name: 'Trizepsstrecken an der Maschine',
    imagePath: 'assets/images/exercises/trizepsstrecken_maschine.png',
    muscleGroup: 'Trizeps',
    equipment: 'Maschine',
  ),

  // --------------------------------------------------
  // Rücken
  // --------------------------------------------------
  Exercise(
    id: 'lat_pulldown',
    name: 'Latzug zur Brust',
    imagePath: 'assets/images/exercises/latzug.png',
    muscleGroup: 'Rücken',
    equipment: 'Kabelzug',
  ),
  Exercise(
    id: 'pull_up',
    name: 'Klimmzüge',
    imagePath: 'assets/images/exercises/klimmzuege.png',
    muscleGroup: 'Rücken',
    equipment: 'Klimmzugstange',
  ),
  Exercise(
    id: 'assisted_machine_pull_up',
    name: 'Klimmzüge mit Maschinenunterstützung',
    imagePath: 'assets/images/exercises/klimmzuege_maschinenunterstuetzung.png',
    muscleGroup: 'Rücken',
    equipment: 'Assistierte Klimmzugmaschine',
  ),
  Exercise(
    id: 'bent_over_barbell_row',
    name: 'Langhantelrudern vorgebeugt',
    imagePath: 'assets/images/exercises/langhantelrudern_vorgebeugt.png',
    muscleGroup: 'Rücken',
    equipment: 'Langhantel',
  ),
  Exercise(
    id: 'single_arm_dumbbell_row',
    name: 'Kurzhantelrudern einarmig',
    imagePath: 'assets/images/exercises/kurzhantelrudern_einarmig.png',
    muscleGroup: 'Rücken',
    equipment: 'Kurzhantel & Bank',
  ),
  Exercise(
    id: 'seated_cable_row',
    name: 'Kabelrudern sitzend',
    imagePath: 'assets/images/exercises/kabelrudern_sitzend.png',
    muscleGroup: 'Rücken',
    equipment: 'Kabelzug',
  ),
  Exercise(
    id: 'machine_row',
    name: 'Rudern an der Maschine',
    imagePath: 'assets/images/exercises/rudern_maschine.png',
    muscleGroup: 'Rücken',
    equipment: 'Maschine',
  ),
  Exercise(
    id: 'chest_supported_dumbbell_row',
    name: 'Kurzhantelrudern mit Brustauflage',
    imagePath: 'assets/images/exercises/kurzhantelrudern_brustauflage.png',
    muscleGroup: 'Rücken',
    equipment: 'Kurzhanteln & Schrägbank',
  ),
  Exercise(
    id: 'straight_arm_cable_pulldown',
    name: 'Gestrecktes Armziehen am Kabelzug',
    imagePath: 'assets/images/exercises/gestrecktes_armziehen_kabelzug.png',
    muscleGroup: 'Rücken',
    equipment: 'Kabelzug',
  ),
  Exercise(
    id: 'back_extension',
    name: 'Rückenstrecken auf der Hyperextensionsbank',
    imagePath: 'assets/images/exercises/rueckenstrecken.png',
    muscleGroup: 'Rücken',
    equipment: 'Hyperextensionsbank',
  ),

  // --------------------------------------------------
  // Schultern
  // --------------------------------------------------
  Exercise(
    id: 'dumbbell_lateral_raise',
    name: 'Kurzhantel-Seitheben',
    imagePath: 'assets/images/exercises/kurzhantel_seitheben.png',
    muscleGroup: 'Schultern',
    equipment: 'Kurzhantel',
  ),
  Exercise(
    id: 'dumbbell_shoulder_press',
    name: 'Kurzhantel-Schulterdrücken',
    imagePath: 'assets/images/exercises/kurzhantel_schulterdruecken.png',
    muscleGroup: 'Schultern',
    equipment: 'Kurzhanteln',
  ),
  Exercise(
    id: 'barbell_shoulder_press',
    name: 'Langhantel-Schulterdrücken',
    imagePath: 'assets/images/exercises/langhantel_schulterdruecken.png',
    muscleGroup: 'Schultern',
    equipment: 'Langhantel',
  ),
  Exercise(
    id: 'machine_shoulder_press',
    name: 'Schulterdrücken an der Maschine',
    imagePath: 'assets/images/exercises/schulterdruecken_maschine.png',
    muscleGroup: 'Schultern',
    equipment: 'Maschine',
  ),
  Exercise(
    id: 'arnold_press',
    name: 'Arnold Press',
    imagePath: 'assets/images/exercises/arnold_press.png',
    muscleGroup: 'Schultern',
    equipment: 'Kurzhanteln',
  ),
  Exercise(
    id: 'dumbbell_front_raise',
    name: 'Kurzhantel-Frontheben',
    imagePath: 'assets/images/exercises/kurzhantel_frontheben.png',
    muscleGroup: 'Schultern',
    equipment: 'Kurzhanteln',
  ),
  Exercise(
    id: 'cable_lateral_raise',
    name: 'Seitheben am Kabelzug',
    imagePath: 'assets/images/exercises/seitheben_kabelzug.png',
    muscleGroup: 'Schultern',
    equipment: 'Kabelzug',
  ),
  Exercise(
    id: 'reverse_pec_deck',
    name: 'Reverse Butterfly an der Maschine',
    imagePath: 'assets/images/exercises/reverse_butterfly.png',
    muscleGroup: 'Schultern',
    equipment: 'Maschine',
  ),
  Exercise(
    id: 'dumbbell_reverse_fly',
    name: 'Kurzhantel-Reverse-Flys',
    imagePath: 'assets/images/exercises/kurzhantel_reverse_flys.png',
    muscleGroup: 'Schultern',
    equipment: 'Kurzhanteln',
  ),
  Exercise(
    id: 'cable_face_pull',
    name: 'Face Pulls am Kabelzug',
    imagePath: 'assets/images/exercises/face_pulls.png',
    muscleGroup: 'Schultern',
    equipment: 'Kabelzug',
  ),
  // Ergänzt die 180 neuen Übungen aus der separaten Datei.
  ...additionalExercises,
]);
