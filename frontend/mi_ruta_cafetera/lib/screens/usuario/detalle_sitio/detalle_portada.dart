
import 'package:flutter/material.dart';

import '../../../../models/sitio_turistico_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';
import '../../../l10n/textos.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
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

            // Degradado para integrar la fotografía con el diseño.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.22),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.48),
                      ],
                      stops: const [0, 0.45, 1],
                    ),
                  ),
                ),
              ),
            ),

            // Identidad turística sobre la fotografía.
            Positioned(
              left: AppDimensions.pageHorizontal,
              bottom: AppDimensions.spacingLg,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_cafe_outlined,
                      size: 17,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 7),
                    Tr(
                      'EXPERIENCIA CAFETERA',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (onFavorito != null)
              Positioned(
                top: AppDimensions.spacingMd,
                right: AppDimensions.spacingMd,
                child: Material(
                  color: AppColors.cream.withValues(alpha: 0.96),
                  shape: const CircleBorder(),
                  elevation: 3,
                  child: IconButton(
                    tooltip: esFavorito
                        ? Textos.t('Quitar de favoritos')
                        : Textos.t('Agregar a favoritos'),
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
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: esFavorito
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                  ),
                ),
              ),
          ],
        ),

        // Presentación editorial del sitio.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pageHorizontal,
            AppDimensions.spacingXl,
            AppDimensions.pageHorizontal,
            AppDimensions.spacingLg,
          ),
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Flexible(
                    child: Text(
                      [
                        sitio.ciudad.trim(),
                        sitio.departamento.trim(),
                      ].where((texto) => texto.isNotEmpty).join(' · ')
                          .toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                sitio.nombre,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 27,
                      height: 1.16,
                    ),
              ),
              if (sitio.descripcion.trim().isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  sitio.descripcion.trim(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.65,
                      ),
                ),
              ],
              const SizedBox(height: AppDimensions.spacingLg),
              Container(
                height: 1,
                color: AppColors.divider,
              ),
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
        Icons.local_cafe_outlined,
        size: AppDimensions.featuredImageHeight * 0.25,
        color: AppColors.secondary,
      ),
    );
  }
}
