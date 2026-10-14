
import 'package:flutter/material.dart';

import '../../../../models/sitio_turistico_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class DetallePortada extends StatelessWidget {
  const DetallePortada({
    super.key,
    required this.sitio,
    this.imagenPrincipal,
    this.onFavorito,
    this.esFavorito = false,
    this.procesandoFavorito = false,
  });

  final SitioTuristicoModel sitio;
  final String? imagenPrincipal;
  final VoidCallback? onFavorito;
  final bool esFavorito;
  final bool procesandoFavorito;

  @override
  Widget build(BuildContext context) {
    final imagen = (imagenPrincipal ?? '').trim();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 8.5,
              child: SizedBox(
                width: double.infinity,
                child: imagen.isNotEmpty
                    ? Image.network(
                        imagen,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (_, _, _) => _imagenAlternativa(),
                      )
                    : _imagenAlternativa(),
              ),
            ),
            if (onFavorito != null)
              Positioned(
                top: AppDimensions.spacingMd,
                right: AppDimensions.spacingMd,
                child: Material(
                  color: AppColors.surface.withValues(alpha: 0.94),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: esFavorito
                        ? 'Quitar de favoritos'
                        : 'Agregar a favoritos',
                    onPressed: procesandoFavorito ? null : onFavorito,
                    icon: procesandoFavorito
                        ? const SizedBox(
                            width: AppDimensions.iconMd,
                            height: AppDimensions.iconMd,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            esFavorito
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: esFavorito
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pageHorizontal,
            AppDimensions.spacingLg,
            AppDimensions.pageHorizontal,
            AppDimensions.spacingMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sitio.nombre,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              if (sitio.descripcion.trim().isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  sitio.descripcion.trim(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _imagenAlternativa() {
    return Container(
      width: double.infinity,
      color: AppColors.cream,
      alignment: Alignment.center,
      child: Icon(
        Icons.local_cafe,
        size: AppDimensions.featuredImageHeight * 0.25,
        color: AppColors.secondary,
      ),
    );
  }
}