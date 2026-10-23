import 'package:repstar/models/level_definition.dart';

/// Ranganforderungen pro Kalendermonat.
/// Monatswechsel ist am ersten Tag des Monats um 00:00 Uhr UTC.
///
/// Der benötigte Anteil für den Klassenerhalt steigt von 50 auf 80 Prozent.
const List<LevelDefinition> levelLibrary = [
  LevelDefinition(
    number: 1,
    name: 'Sofakartoffel',
    description:
        'Die Couch kennt dich. Zeit, dass die Hanteln dich kennenlernen.',
    targetXp: 80,
    maintenancePercent: 50,
  ),
  LevelDefinition(
    number: 2,
    name: 'Ausreden-Azubi',
    description: 'Weniger „morgen“, mehr machen.',
    targetXp: 160,
    maintenancePercent: 53,
  ),
  LevelDefinition(
    number: 3,
    name: 'Gelegenheits-Pumper',
    description: 'Du tauchst auf. Jetzt wird daraus eine Gewohnheit.',
    targetXp: 240,
    maintenancePercent: 57,
  ),
  LevelDefinition(
    number: 4,
    name: 'Studio-Stammgast',
    description: 'Dein Training hat einen festen Platz im Alltag.',
    targetXp: 320,
    maintenancePercent: 60,
  ),
  LevelDefinition(
    number: 5,
    name: 'Eisenbeißer',
    description: 'Du bleibst dran, auch wenn die erste Motivation nachlässt.',
    targetXp: 400,
    maintenancePercent: 63,
  ),
  LevelDefinition(
    number: 6,
    name: 'Hantel-Rebell',
    description: 'Du ziehst dein Training konsequent durch.',
    targetXp: 480,
    maintenancePercent: 67,
  ),
  LevelDefinition(
    number: 7,
    name: 'Eisen-Rockstar',
    description: 'Regelmäßigkeit ist dein Markenzeichen.',
    targetXp: 560,
    maintenancePercent: 70,
  ),
  LevelDefinition(
    number: 8,
    name: 'Gym-Headliner',
    description: 'Du lieferst über den ganzen Monat ab.',
    targetXp: 640,
    maintenancePercent: 73,
  ),
  LevelDefinition(
    number: 9,
    name: 'Eisen-Legende',
    description: 'Ein starker Rang braucht dauerhaft starke Gewohnheiten.',
    targetXp: 720,
    maintenancePercent: 77,
  ),
  LevelDefinition(
    number: 10,
    name: 'RepStar-Legende',
    description: 'Ganz oben angekommen. Jetzt zählt, dass du dranbleibst.',
    targetXp: 900,
    maintenancePercent: 80,
  ),
];
