import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Verwaltet das gewählte Design und speichert es auf dem Gerät.
class ThemeService extends ChangeNotifier {
  ThemeService._();

  static final ThemeService instance = ThemeService._();

  /// Ohne gespeicherte Auswahl folgt die App dem Handy-Design.
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  /// Schreibvorgänge laufen nacheinander, auch bei schnellem Umschalten.
  Future<bool> _saveQueue = Future<bool>.value(true);

  Future<File> _settingsFile() async {
    final directory = await getApplicationDocumentsDirectory();

    // Getrennt von den Trainingsdaten speichern.
    return File('${directory.path}${Platform.pathSeparator}repstar_theme.txt');
  }

  /// Wird vor dem Start der Oberfläche aufgerufen.
  Future<void> load() async {
    final file = await _settingsFile();

    if (!await file.exists()) {
      return;
    }

    final savedMode = (await file.readAsString()).trim();

    _mode = switch (savedMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => throw const FormatException('Unbekannte Design-Auswahl.'),
    };
  }

  /// Aktualisiert die Oberfläche sofort und speichert danach die Auswahl.
  Future<bool> setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();

    _saveQueue = _saveQueue.then((_) => _writeMode(mode));

    return _saveQueue;
  }

  Future<bool> _writeMode(ThemeMode mode) async {
    try {
      final file = await _settingsFile();

      await file.writeAsString(mode.name, flush: true);
      return true;
    } catch (error) {
      debugPrint('Design konnte nicht gespeichert werden: $error');
      return false;
    }
  }
}
