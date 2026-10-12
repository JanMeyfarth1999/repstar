import 'package:repstar/models/exercise.dart';

/// Übungsbibliothek mit den passenden lokalen Bildern.
const List<Exercise> exerciseLibrary = [
  Exercise(
    id: 'leg_press',
    name: 'Beinpresse',
    imagePath: 'assets/images/exercises/beinpresse.png',
    muscleGroup: 'Beine',
    equipment: 'Maschine',
  ),
  Exercise(
    id: 'incline_dumbbell_press',
    name: 'Kurzhantel-Schrägbankdrücken',
    imagePath: 'assets/images/exercises/kurzhantel_schraegbankdruecken.png',
    muscleGroup: 'Brust',
    equipment: 'Kurzhantel',
  ),
  Exercise(
    id: 'dumbbell_curl',
    name: 'Kurzhantel-Bizepscurls',
    imagePath: 'assets/images/exercises/kurzhantel_bizepscurls.png',
    muscleGroup: 'Bizeps',
    equipment: 'Kurzhantel',
  ),
  Exercise(
    id: 'cable_triceps_pushdown',
    name: 'Trizepsdrücken am Kabelzug',
    imagePath: 'assets/images/exercises/trizepsdruecken_kabelzug.png',
    muscleGroup: 'Trizeps',
    equipment: 'Kabelzug',
  ),
  Exercise(
    id: 'lat_pulldown',
    name: 'Latzug zur Brust',
    imagePath: 'assets/images/exercises/latzug.png',
    muscleGroup: 'Rücken',
    equipment: 'Kabelzug',
  ),
  Exercise(
    id: 'dumbbell_lateral_raise',
    name: 'Kurzhantel-Seitheben',
    imagePath: 'assets/images/exercises/kurzhantel_seitheben.png',
    muscleGroup: 'Schultern',
    equipment: 'Kurzhantel',
  ),
];
