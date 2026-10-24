import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:repstar/models/active_training_draft.dart';

/// Speichert genau einen laufenden Trainingszwischenstand.
class ActiveTrainingStorageService {
  final Future<Directory> Function() _directoryProvider;

  /// Alle Dateizugriffe laufen nacheinander.
  Future<void> _pendingOperation = Future<void>.value();

  ActiveTrainingStorageService({
    Future<Directory> Function()? directoryProvider,
  }) : _directoryProvider =
           directoryProvider ?? getApplicationDocumentsDirectory;

  Future<File> _getFile() async {
    final directory = await _directoryProvider();

    return File(
      '${directory.path}${Platform.pathSeparator}'
      'repstar_active_training.json',
    );
  }

  /// Reiht Lesen, Schreiben und Löschen in dieselbe Warteschlange ein.
  ///
  /// Ein fehlgeschlagener Zugriff darf spätere Versuche nicht blockieren.
  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = _pendingOperation.then<T>((_) => operation());

    _pendingOperation = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        // Der ursprüngliche Aufrufer erhält den Fehler über result.
        // Die Warteschlange bleibt für weitere Zugriffe benutzbar.
      },
    );

    return result;
  }

  /// Liest einen vorhandenen Zwischenstand.
  /// Ohne gespeichertes laufendes Training wird null zurückgegeben.
  Future<ActiveTrainingDraft?> load() {
    return _enqueue<ActiveTrainingDraft?>(() async {
      final file = await _getFile();

      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      final decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Der Trainingszwischenstand enthält ungültige Daten.',
        );
      }

      return ActiveTrainingDraft.fromJson(decoded);
    });
  }

  /// Speichert einen bereits erstellten Datenstand.
  Future<void> save(ActiveTrainingDraft draft) {
    // Sofort umwandeln, damit später geänderte Eingaben nicht
    // nachträglich in diesen Schreibauftrag hineinlaufen.
    final content = jsonEncode(draft.toJson());

    return _enqueue<void>(() async {
      final file = await _getFile();
      final temporaryFile = File('${file.path}.tmp');

      // Zunächst vollständig in eine temporäre Datei schreiben.
      await temporaryFile.writeAsString(content, flush: true);

      // Erst nach erfolgreichem Schreiben den bisherigen Stand ersetzen.
      await temporaryFile.rename(file.path);
    });
  }

  /// Entfernt den Zwischenstand nach Verwerfen oder sicherem Abschluss.
  Future<void> clear() {
    return _enqueue<void>(() async {
      final file = await _getFile();
      final temporaryFile = File('${file.path}.tmp');

      if (await file.exists()) {
        await file.delete();
      }

      if (await temporaryFile.exists()) {
        await temporaryFile.delete();
      }
    });
  }
}
