import 'package:repstar/models/level_progress.dart';

/// Namen der 15 Prestige-Stufen und ihrer Trophäen.
const List<String> prestigeTitles = [
  'Eisenwolf',
  'Stahlkrieger',
  'Berserker',
  'Gladiator',
  'Vollstrecker',
  'Kriegsherr',
  'Dominator',
  'Koloss',
  'Titan',
  'Leviathan',
  'Behemoth',
  'Weltenbrecher',
  'Götterschlächter',
  'Thronbrecher',
  'Unsterblicher',
];

/// Jede innere Liste enthält genau zehn eigene Levelnamen.
/// Erste Liste: Prestige 1, zweite Liste: Prestige 2 usw.
const List<List<String>> prestigeLevelNames = [
  // Prestige 1 – Eisenwolf
  [
    'Lauch mit Lizenz',
    'Hantellehrling',
    'Pumpanwärter',
    'Eisenbeißer',
    'Rudelkämpfer',
    'Stahlklauen',
    'Hanteljäger',
    'Krafträuber',
    'Alphawolf',
    'Rudelkönig',
  ],

  // Prestige 2 – Stahlkrieger
  [
    'Blechrekrut',
    'Ambossknecht',
    'Schmiedesohn',
    'Eisensoldat',
    'Stahlfaust',
    'Panzerbrecher',
    'Frontkämpfer',
    'Eisenhauptmann',
    'Stahlkommandant',
    'Kriegerkönig',
  ],

  // Prestige 3 – Berserker
  [
    'Wutzwerg',
    'Zornfunke',
    'Wildling',
    'Axtträger',
    'Rasender',
    'Schlachtbeißer',
    'Kettenreißer',
    'Zornhammer',
    'Blutdonner',
    'Urberserker',
  ],

  // Prestige 4 – Gladiator
  [
    'Sandfresser',
    'Arenalehrling',
    'Schildträger',
    'Klingenarm',
    'Duellbrecher',
    'Löwenringer',
    'Arenavollstrecker',
    'Publikumsschreck',
    'Siegesfürst',
    'Arenakaiser',
  ],

  // Prestige 5 – Vollstrecker
  [
    'Großmaul auf Probe',
    'Faustpfand',
    'Brecheisen',
    'Betonknacker',
    'Stahlramme',
    'Abrisshammer',
    'Urteilsbringer',
    'Gnadenloser',
    'Letzte Instanz',
    'Endgegner',
  ],

  // Prestige 6 – Kriegsherr
  [
    'Kasernenprotz',
    'Sturmsoldat',
    'Frontbrecher',
    'Belagerer',
    'Schlachtführer',
    'Eisenmarschall',
    'Festungsbezwinger',
    'Heeresmeister',
    'Erobererkönig',
    'Kriegsimperator',
  ],

  // Prestige 7 – Dominator
  [
    'Möchtegern-Boss',
    'Revierprüfer',
    'Platzhirsch',
    'Rivalenbrecher',
    'Machtgreifer',
    'Respektforderer',
    'Konkurrenzvernichter',
    'Oberbefehlshaber',
    'Alleinherrscher',
    'Absolute Übermacht',
  ],

  // Prestige 8 – Koloss
  [
    'Kieselklopper',
    'Felsenschulter',
    'Granitfaust',
    'Steinbrecher',
    'Bergschieber',
    'Massivblock',
    'Felsentyrann',
    'Gebirgsramme',
    'Kontinentalriese',
    'Lebende Festung',
  ],

  // Prestige 9 – Titan
  [
    'Halbgott auf Probe',
    'Himmelsstürmer',
    'Donnerträger',
    'Blitzschmied',
    'Wolkenbrecher',
    'Olympbezwinger',
    'Himmelshammer',
    'Götterbezwinger',
    'Urtitan',
    'Titanenkönig',
  ],

  // Prestige 10 – Leviathan
  [
    'Pfützenhai',
    'Tiefenjäger',
    'Riffbrecher',
    'Sturmflosse',
    'Flutenbezwinger',
    'Abgrundrachen',
    'Gezeitenherr',
    'Ozeanverschlinger',
    'Tiefenkaiser',
    'Herr der Urflut',
  ],

  // Prestige 11 – Behemoth
  [
    'Käfigprotz',
    'Prankenbrecher',
    'Wildnisjäger',
    'Bestienbändiger',
    'Stampfgewalt',
    'Urzeitbrecher',
    'Monsterschlächter',
    'Bestienfürst',
    'Urgewalt',
    'König der Bestien',
  ],

  // Prestige 12 – Weltenbrecher
  [
    'Rissverursacher',
    'Bodenerschütterer',
    'Mauervernichter',
    'Festungszertrümmerer',
    'Erdbebenbringer',
    'Gebirgsspalter',
    'Kontinentalbrecher',
    'Weltenerschütterer',
    'Planetenschlächter',
    'Herr des Untergangs',
  ],

  // Prestige 13 – Götterschlächter
  [
    'Tempelprovokateur',
    'Götterforderer',
    'Reliquienbrecher',
    'Tempelstürmer',
    'Himmelsrebell',
    'Götterjäger',
    'Olympzerstörer',
    'Schicksalsbrecher',
    'Pantheonvernichter',
    'Götterdämmerer',
  ],

  // Prestige 14 – Thronbrecher
  [
    'Kronenräuber',
    'Thronforderer',
    'Zepterbrecher',
    'Fürstenbezwinger',
    'Königsstürzer',
    'Kaiserjäger',
    'Dynastienbrecher',
    'Imperienvernichter',
    'Herrscher aller Herrscher',
    'König ohne Grenzen',
  ],

  // Prestige 15 – Unsterblicher
  [
    'Todesverächter',
    'Grenzensprenger',
    'Zeitbezwinger',
    'Ewigkeitskrieger',
    'Schicksalsherrscher',
    'Unvergänglicher',
    'Unbezwingbarer',
    'Jenseits der Grenzen',
    'Letzter seiner Art',
    'Der Unsterbliche',
  ],
];

/// Liest den eigenen Namen für die gewünschte Kombination aus.
/// Normale Level ohne Prestige verwenden weiterhin levelLibrary.
String prestigeLevelName({required int prestige, required int level}) {
  if (prestige < 1 || prestige > LevelProgress.maxPrestige) {
    throw ArgumentError.value(
      prestige,
      'prestige',
      'Prestige muss zwischen 1 und 15 liegen.',
    );
  }

  if (level < 1 || level > LevelProgress.maxLevel) {
    throw ArgumentError.value(
      level,
      'level',
      'Level muss zwischen 1 und 10 liegen.',
    );
  }

  // Listen beginnen bei Index 0, sichtbare Level bei 1.
  return prestigeLevelNames[prestige - 1][level - 1];
}
