import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repstar/theme/app_theme.dart';

/// Berechnet den Kontrast zwischen zwei undurchsichtigen Farben.
double contrastRatio(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;

  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    final name = theme.brightness.name;
    final colors = theme.colorScheme;
    final extra = theme.extension<RepStarColors>()!;

    group('Lesbarkeit im $name-Design', () {
      test('Text, Nebentext und Akzente sind auf Seiten und Karten lesbar', () {
        for (final background in [
          theme.scaffoldBackgroundColor,
          colors.surface,
        ]) {
          for (final foreground in [
            colors.onSurface,
            colors.onSurfaceVariant,
            colors.primary,
            extra.maintenance,
          ]) {
            expect(
              contrastRatio(foreground, background),
              greaterThanOrEqualTo(4.5),
              reason: 'Textfarben müssen auch bei kleinen Texten lesbar sein.',
            );
          }
        }
      });

      test('Text auf gefüllten Buttons bleibt lesbar', () {
        expect(
          contrastRatio(colors.onPrimary, colors.primary),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('Der leere Rangring ist sichtbar', () {
        expect(
          contrastRatio(extra.ringTrack, theme.scaffoldBackgroundColor),
          greaterThanOrEqualTo(3),
        );
      });

      test('Eingabehinweise und Listen-Nebentexte verwenden Theme-Farben', () {
        expect(
          theme.inputDecorationTheme.hintStyle?.color,
          colors.onSurfaceVariant,
        );
        expect(
          theme.inputDecorationTheme.labelStyle?.color,
          colors.onSurfaceVariant,
        );
        expect(
          theme.listTileTheme.subtitleTextStyle?.color,
          colors.onSurfaceVariant,
        );
      });
    });
  }

  test('Bildschirme und Widgets enthalten keine festen Designfarben', () {
    // Verhindert, dass später wieder Colors.white70 oder feste RGB-Farben
    // in die Oberfläche gelangen. Sonderfarben gehören nach app_theme.dart.
    final forbidden = RegExp(
      r'\bColors\.(?!transparent\b)\w+|\bColor\s*\(|'
      r'\bColor\.(?:fromARGB|fromRGBO|from)\s*\(',
    );

    for (final directory in ['lib/screens', 'lib/widgets']) {
      for (final file in Directory(directory)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))) {
        expect(
          forbidden.hasMatch(file.readAsStringSync()),
          isFalse,
          reason: '${file.path}: Verwende Theme-Farben statt fester Farben.',
        );
      }
    }
  });
}
