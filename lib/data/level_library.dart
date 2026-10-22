import 'package:repstar/models/level_definition.dart';

/// Ranggrenzen pro 30-Tage-Runde.
/// Die XP-Werte sind erste Spielregeln und werden anhand der
/// anschließenden Trainingsberechnung überprüft und abgestimmt.
const List<LevelDefinition> levelLibrary = [
  LevelDefinition(
    number: 1,
    name: 'Sofakartoffel',
    description: 'Die Couch kennt dich. Zeit, dass die Hanteln dich kennenlernen.',
    maintenanceXp: 0,
    promotionXp: 80,
  ),
  LevelDefinition(
    number: 2,
    name: 'Ausreden-Azubi',
    description: 'Weniger „morgen“, mehr machen.',
    maintenanceXp: 80,
    promotionXp: 160,
  ),
  LevelDefinition(
    number: 3,
    name: 'Gelegenheits-Pumper',
    description: 'Du tauchst auf. Jetzt wird daraus eine Gewohnheit.',
    maintenanceXp: 120,
    promotionXp: 240,
  ),
  LevelDefinition(
    number: 4,
    name: 'Studio-Stammgast',
    description: 'Dein Training hat einen festen Platz im Alltag.',
    maintenanceXp: 160,
    promotionXp: 320,
  ),
  LevelDefinition(
    number: 5,
    name: 'Eisenbeißer',
    description: 'Du bleibst dran, auch wenn die erste Motivation nachlässt.',
    maintenanceXp: 240,
    promotionXp: 400,
  ),
  LevelDefinition(
    number: 6,
    name: 'Hantel-Rebell',
    description: 'Du ziehst dein Training konsequent durch.',
    maintenanceXp: 320,
    promotionXp: 480,
  ),
  LevelDefinition(
    number: 7,
    name: 'Eisen-Rockstar',
    description: 'Regelmäßigkeit ist dein Markenzeichen.',
    maintenanceXp: 400,
    promotionXp: 560,
  ),
  LevelDefinition(
    number: 8,
    name: 'Gym-Headliner',
    description: 'Du lieferst über die ganze Runde ab.',
    maintenanceXp: 480,
    promotionXp: 640,
  ),
  LevelDefinition(
    number: 9,
    name: 'Eisen-Legende',
    description: 'Ein starker Rang braucht dauerhaft starke Gewohnheiten.',
    maintenanceXp: 560,
    promotionXp: 720,
  ),
  LevelDefinition(
    number: 10,
    name: 'RepStar-Legende',
    description: 'Ganz oben angekommen. Jetzt zählt, dass du dranbleibst.',
    maintenanceXp: 720,
    promotionXp: null,
  ),
];