import 'package:flutter/material.dart';

/// Zeigt ein Übungsbild oder einen Platzhalter, wenn das Bild noch fehlt.
class ExerciseImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ExerciseImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  Widget _buildPlaceholder(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,

      // Große Bildbereiche erhalten auch ohne Bild eine sichtbare Höhe.
      height: height ?? 180,
      child: ColoredBox(
        color: colors.surface,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.fitness_center,
              size: 32,
              color: colors.primary,
              semanticLabel: 'Übungsbild noch nicht vorhanden',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return _buildPlaceholder(context);
    }

    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,

      // Fehlende oder nicht lesbare Bilder durch ein Übungssymbol ersetzen.
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder(context);
      },
    );
  }
}