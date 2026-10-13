import 'package:flutter/material.dart';

import '../../models/contenido_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class SeccionContenidoSitio extends StatelessWidget {
  const SeccionContenidoSitio({
    super.key,
    required this.contenidos,
    this.onReproducirAudioguia,
  });

  final List<ContenidoModel> contenidos;

  /// Se conectará con el reproductor flotante.
  final ValueChanged<ContenidoModel>? onReproducirAudioguia;

  @override
  Widget build(BuildContext context) {
    final contenidosVisibles = contenidos
        .where((contenido) => contenido.activo)
        .toList();

    if (contenidosVisibles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historias y experiencias',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Descubre las historias que hacen especial este lugar.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          ...contenidosVisibles.map(
            (contenido) => _ContenidoCard(
              contenido: contenido,
              onReproducirAudioguia: onReproducirAudioguia,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContenidoCard extends StatelessWidget {
  const _ContenidoCard({
    required this.contenido,
    required this.onReproducirAudioguia,
  });

  final ContenidoModel contenido;
  final ValueChanged<ContenidoModel>? onReproducirAudioguia;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final imagenPrincipal = contenido.imagenPrincipal.trim();

    final tieneImagen = imagenPrincipal.isNotEmpty;

    final tieneAudioguia = contenido.audioGuias.any(
      (audio) => audio.url.trim().isNotEmpty,
    );

    final cantidadImagenes = contenido.imagenes
        .where((imagen) => imagen.trim().isNotEmpty)
        .length;

    return Container(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tieneImagen)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imagenPrincipal,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textSecondary,
                      size: 40,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 120,
              color: AppColors.surfaceVariant,
              child: const Center(
                child: Icon(
                  Icons.auto_stories_outlined,
                  color: AppColors.secondary,
                  size: 42,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(
              AppDimensions.spacingMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contenido.titulo,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                if (contenido.descripcion.trim().isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    contenido.descripcion,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],

                if (cantidadImagenes > 0) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  Row(
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(
                        width: AppDimensions.spacingXs,
                      ),
                      Text(
                        '$cantidadImagenes imágenes adicionales',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],

                if (tieneAudioguia) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  Container(
                    padding: const EdgeInsets.all(
                      AppDimensions.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.headphones,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        const SizedBox(
                          width: AppDimensions.spacingSm,
                        ),
                        Expanded(
                          child: Text(
                            'Escucha esta historia',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          tooltip: 'Escuchar historia',
                          onPressed: onReproducirAudioguia == null
                              ? null
                              : () => onReproducirAudioguia!(contenido),
                          icon: const Icon(Icons.play_arrow),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}