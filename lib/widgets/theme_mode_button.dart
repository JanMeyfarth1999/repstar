import 'package:flutter/material.dart';
import 'package:repstar/services/theme_service.dart';

/// Wiederverwendbarer Menübutton zur Auswahl des Designs.
class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ThemeService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, child) {
        final icon = switch (service.mode) {
          ThemeMode.light => Icons.light_mode_outlined,
          ThemeMode.dark => Icons.dark_mode_outlined,
          ThemeMode.system => Icons.brightness_auto_outlined,
        };

        return PopupMenuButton<ThemeMode>(
          tooltip: 'Design auswählen',
          icon: Icon(icon),
          initialValue: service.mode,
          onSelected: (mode) async {
            final saved = await service.setMode(mode);

            if (!context.mounted || saved) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Design wurde geändert, konnte aber nicht '
                  'dauerhaft gespeichert werden.',
                ),
              ),
            );
          },
          itemBuilder: (context) => [
            CheckedPopupMenuItem<ThemeMode>(
              value: ThemeMode.light,
              checked: service.mode == ThemeMode.light,
              child: const Text('Hell'),
            ),
            CheckedPopupMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              checked: service.mode == ThemeMode.dark,
              child: const Text('Dunkel'),
            ),
            CheckedPopupMenuItem<ThemeMode>(
              value: ThemeMode.system,
              checked: service.mode == ThemeMode.system,
              child: const Text('System'),
            ),
          ],
        );
      },
    );
  }
}
