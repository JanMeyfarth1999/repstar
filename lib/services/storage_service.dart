import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:repstar/models/training_data.dart';

/// Speichert und lädt die Trainingsdaten auf dem Gerät.
class StorageService {
  /// Reiht Schreibvorgänge aneinander, damit sie sich nicht überholen.
  Future<void> _pendingWrite = Future<void>.value();

  /// Ermittelt die Datei im Dokumentenordner der App.
  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();

    await directory.create(recursive: true);

    return File(
      '${directory.path}${Platform.pathSeparator}repstar_data.json',
    );
  }

  /// Lädt die gespeicherten Trainingsdaten.
  Future<TrainingData> load() async {
    await _pendingWrite;

    final file = await _getFile();

    // Beim ersten App-Start gibt es noch keine Speicherdatei.
    if (!await file.exists()) {
      return TrainingData.empty();
    }

    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;

    return TrainingData.fromJson(json);
  }

  /// Speichert eine Momentaufnahme der übergebenen Daten.
  Future<void> save(TrainingData data) {
    // Sofort umwandeln, bevor die Daten erneut verändert werden können.
    final content = jsonEncode(data.toJson());

    final operation = _pendingWrite.then((_) async {
      final file = await _getFile();

      // Zunächst eine separate Datei vollständig schreiben.
      final temporaryFile = File('${file.path}.tmp');
      await temporaryFile.writeAsString(content, flush: true);

      // Erst nach erfolgreichem Schreiben die Speicherdatei ersetzen.
      await temporaryFile.rename(file.path);
    });

    // Ein fehlgeschlagener Vorgang soll spätere Versuche nicht blockieren.
    // Der Aufrufer erhält den Fehler weiterhin über „operation“.
    _pendingWrite = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );

    return operation;
  }
}