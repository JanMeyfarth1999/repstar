# RepStar: Lightmode und Darkmode gemeinsam korrigiert

## Einspielen

1. In VS Code alle Dateien speichern und das laufende Training beenden.
2. Den bisherigen Projektstand sichern, zum Beispiel mit einem Git-Commit.
3. Die ZIP in einen separaten Ordner entpacken.
4. Den enthaltenen Ordner `lib` nach `E:\flutter\repstar` kopieren und vorhandene Dateien ersetzen. Das Ergebnis muss `E:\flutter\repstar\lib\main.dart` sein, nicht `lib\lib\main.dart`.
5. Den enthaltenen Test `test\theme_contrast_test.dart` in den vorhandenen Projektordner `test` kopieren. Bereits vorhandene Tests behalten.
6. Im Projektordner ausführen:

```powershell
flutter analyze
flutter test
```

7. App mit großem `R` neu starten oder `flutter run` erneut ausführen.
8. Zum Weitergeben die APK neu bauen: `flutter build apk --release`.

Keine neuen Pakete erforderlich. Die ZIP ist Quellcode und wird am PC eingespielt, nicht als App auf dem Handy installiert.

## Geänderte Dateien

- `lib/main.dart`: bindet beide zentralen Designs ein; Benachrichtigungs- und Theme-Initialisierung bleiben erhalten.
- `lib/theme/app_theme.dart` (neu): gemeinsame Text-, Nebentext-, Eingabe-, Listen-, Icon-, Button-Häkchen- und Rangfarben. Standardtexte erben das Theme.
- `lib/screens/training_screen.dart`: letzte Trainingsdauer, Abschlussdialog und leere Startseite verwenden Theme-Farben.
- `lib/screens/active_training_screen.dart`: XP-Countdown vor Erreichen der Mindestdauer ist in beiden Designs lesbar.
- `lib/widgets/training_exercise_card.dart`: Satznummern verwenden Theme-Farben.
- `lib/screens/rank_screen.dart`: Gold und Ringhintergrund kommen aus der zentralen Theme-Erweiterung; der leere Ring hat stärkeren Kontrast.
- `test/theme_contrast_test.dart` (neu): prüft Farbkontraste und verhindert feste Designfarben in Screens und Widgets.

Die Übungsdetails in `create_training_screen.dart` waren bereits korrekt an das Theme angebunden. Sie profitieren ebenso wie Filter, Menüs, Eingabefelder, Dialoge und Listen von den zentralen Theme-Regeln. Übungsbilder selbst werden nicht umgefärbt.

## Für neue Oberflächen

- Normaler Text: keine eigene Farbe setzen.
- Nebentext: `Theme.of(context).colorScheme.onSurfaceVariant`.
- Hervorhebungen: `Theme.of(context).colorScheme.primary`.
- Text auf primären gefüllten Flächen: `colorScheme.onPrimary`.
- Sonderfarben: zentral in `lib/theme/app_theme.dart` ergänzen.
- Kein `Colors.white70`, `Colors.black54` oder festes RGB in Screens und Widgets.

Der Test lässt `Colors.transparent` als farblose Rahmen-/Hintergrundangabe zu. Inhaltlich notwendige spätere Sonderfarben sollten über das Theme modelliert und mit geeigneten Kontrastpaaren getestet werden.

## Durchgeführte Prüfungen

- Alle 24 ursprünglichen Dart-Dateien aus der ZIP gelesen und auf Farbangaben geprüft.
- Syntaxprüfung aller gelieferten Dart-Dateien mit einem Dart-Parser bestanden.
- Keine festen Designfarben mehr unter `lib/screens` und `lib/widgets` gefunden.
- Die festgelegten normalen Texte, Nebentexte, grünen Akzente und goldenen Texte erreichen auf Seiten- und Kartenhintergrund mindestens 5,88:1 im Lightmode und 9,53:1 im Darkmode.
- Buttontext erreicht 6,58:1 (hell) bzw. 16,08:1 (dunkel).
- Leerer Ring erreicht 3,99:1 (hell) bzw. 5,83:1 (dunkel) zum Seitenhintergrund.
- Modelle, Übungsbibliothek, Speicherung, Punkte- und Monatsberechnung sind bytegleich zur hochgeladenen ZIP.

In dieser Umgebung ist kein Flutter SDK installiert. `flutter analyze`, die Flutter-Tests und eine visuelle Prüfung auf Android konnten hier nicht ausgeführt werden. Die mitgelieferten Tests sind deshalb zusätzlich im vollständigen Projekt auszuführen. Der Farbtest ersetzt keine Prüfung zukünftiger eigener Hintergrundflächen oder Bildinhalte.

## Kurze Sichtprüfung nach dem Einspielen

Jeweils in Hell und Dunkel prüfen:

- Leere Trainingsübersicht und Übersicht mit vorhandenen Trainings.
- Training erstellen/bearbeiten: Übungsdetails, Filter, ausgewählte Übungen.
- Laufendes Training: XP-Countdown, Satznummern, kg/Wdh-Eingaben und Geräteeinstellungen.
- Trainingsabschluss: Modellhinweis unter den Kalorien.
- Rangseite: Rangnummer, Beschreibung, Auswertungsdatum, leerer Ring und Klassenerhalt-Punkt.
- Designwechsel über System/Hell/Dunkel und gespeicherte Auswahl nach Neustart.
