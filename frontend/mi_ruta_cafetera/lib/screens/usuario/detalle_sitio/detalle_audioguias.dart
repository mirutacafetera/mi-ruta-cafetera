
import 'package:flutter/material.dart';

import '../../../../models/contenido_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class DetalleAudioguias extends StatelessWidget {
  const DetalleAudioguias({
    super.key,
    required this.audioguias,
    required this.onReproducir,
    this.cargando = false,
  });

  final List<AudioGuiaModel> audioguias;
  final ValueChanged<AudioGuiaModel> onReproducir;
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.spacingXl),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final audios = audioguias
        .where((audio) => audio.url.trim().isNotEmpty)
        .toList();

    if (audios.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
        vertical: AppDimensions.spacingLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audioguías',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Escucha las historias y descubre los detalles de este lugar.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          ...audios.map(
            (audio) => Card(
              margin: const EdgeInsets.only(
                bottom: AppDimensions.spacingMd,
              ),
              color: AppColors.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(
                  AppDimensions.spacingMd,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.headphones,
                      color: AppColors.primary,
                      size: 30,
                    ),
                    const SizedBox(
                      width: AppDimensions.spacingMd,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            audio.titulo,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (audio.descripcion.trim().isNotEmpty) ...[
                            const SizedBox(
                              height: AppDimensions.spacingXs,
                            ),
                            Text(
                              audio.descripcion,
                              style:
                                  Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Escuchar audioguía',
                      onPressed: () => onReproducir(audio),
                      icon: const Icon(
                        Icons.play_circle_fill,
                        color: AppColors.primary,
                        size: 38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
