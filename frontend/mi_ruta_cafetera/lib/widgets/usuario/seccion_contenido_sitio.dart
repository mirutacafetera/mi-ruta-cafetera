import 'package:flutter/material.dart';

import '../../models/contenido_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class SeccionContenidoSitio extends StatelessWidget {
  const SeccionContenidoSitio({
    super.key,
    required this.contenidos,
  });

  final List<ContenidoModel> contenidos;

  @override
  Widget build(BuildContext context) {
    if (contenidos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experiencias del sitio',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),

        const SizedBox(
          height: AppDimensions.spacingMd,
        ),

        ...contenidos.map(
          (contenido) => _ContenidoCard(
            contenido: contenido,
          ),
        ),
      ],
    );
  }
}

class _ContenidoCard extends StatelessWidget {
  const _ContenidoCard({
    required this.contenido,
  });

  final ContenidoModel contenido;

  @override
  Widget build(BuildContext context) {
    final tieneImagen =
        contenido.imagenPrincipal.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
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
                contenido.imagenPrincipal,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Container(
                    color: AppColors.surfaceVariant,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textSecondary,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(
              AppDimensions.spacingMd,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  contenido.titulo,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),

                if (contenido.descripcion
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: AppDimensions.spacingSm,
                  ),

                  Text(
                    contenido.descripcion,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                  ),
                ],

                if (contenido.imagenes.isNotEmpty) ...[
                  const SizedBox(
                    height: AppDimensions.spacingSm,
                  ),

                  Text(
                    '${contenido.imagenes.length} imágenes en la galería',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],

                if (contenido.audioGuias.isNotEmpty) ...[
                  const SizedBox(
                    height: AppDimensions.spacingSm,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.headphones_outlined,
                        size: 18,
                        color: AppColors.secondary,
                      ),

                      const SizedBox(
                        width: AppDimensions.spacingXs,
                      ),

                      Text(
                        '${contenido.audioGuias.length} audioguía(s)',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
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
