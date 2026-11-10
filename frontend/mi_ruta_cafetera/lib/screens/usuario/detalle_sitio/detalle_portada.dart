
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

    final ubicacion = [
      sitio.ciudad.trim(),
      sitio.departamento.trim(),
    ].where((texto) => texto.isNotEmpty).join(' · ');

    final nombreCategoria = sitio.categoriaNombre.trim().isNotEmpty
        ? sitio.categoriaNombre.trim()
        : 'Sitio turístico';

    // Reutiliza el mapa de iconos de AppColors.
    final iconoCategoria =
        AppColors.getIconForCategory(sitio.categoriaNombre);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PORTADA PRINCIPAL
        Stack(
          children: [
            LayoutBuilder(
              builder: (context, restricciones) {
                final alto = (restricciones.maxWidth / (16 / 10))
                    .clamp(0.0, AppDimensions.heroHeight)
                    .toDouble();

                return SizedBox(
                  width: double.infinity,
                  height: alto,
                  child: imagen.isNotEmpty
                      ? Image.network(
                          imagen,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (_, _, _) => _imagenAlternativa(),
                        )
                      : _imagenAlternativa(),
                );
              },
            ),

            // DEGRADADO DE LA PORTADA
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.black.withValues(alpha: 0.18),
                        Colors.transparent,
                        AppColors.black.withValues(alpha: 0.42),
                      ],
                      stops: const [0, 0.48, 1],
                    ),
                  ),
                ),
              ),
            ),

            // DISTINTIVO DINÁMICO DE CATEGORÍA
            Positioned(
              left: AppDimensions.pageHorizontal,
              bottom: AppDimensions.spacingLg,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sitioPrimaryDark.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: AppColors.sitioAccent.withValues(alpha: 0.65),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.16),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      iconoCategoria,
                      size: 15,
                      color: AppColors.sitioAccent,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      nombreCategoria.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.sitioTextOnPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BOTÓN FAVORITOS
            if (onFavorito != null)
              Positioned(
                top: AppDimensions.spacingLg,
                right: AppDimensions.pageHorizontal,
                child: Material(
                  color: AppColors.sitioSurface,
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
                              color: AppColors.sitioPrimary,
                            ),
                          )
                        : Icon(
                            esFavorito
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: esFavorito
                                ? AppColors.sitioError
                                : AppColors.sitioPrimary,
                          ),
                  ),
                ),
              ),
          ],
        ),

        // INFORMACIÓN DEL SITIO
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pageHorizontal,
            AppDimensions.spacingXl,
            AppDimensions.pageHorizontal,
            AppDimensions.spacingXl,
          ),
          color: AppColors.sitioBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // UBICACIÓN
              if (ubicacion.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 17,
                      color: AppColors.sitioAccent,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        ubicacion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.sitioAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: AppDimensions.spacingMd),

              // NOMBRE DEL SITIO
              Text(
                sitio.nombre,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.sitioTextPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 29,
                      height: 1.20,
                      letterSpacing: -0.5,
                    ),
              ),

              // DETALLE DECORATIVO
              const SizedBox(height: AppDimensions.spacingMd),
              Container(
                width: 45,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.sitioAccent,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              // DESCRIPCIÓN
              if (sitio.descripcion.trim().isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingLg),
                Text(
                  sitio.descripcion.trim(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.sitioTextSecondary,
                        fontSize: 15,
                        height: 1.7,
                        letterSpacing: 0.1,
                      ),
                ),
              ],

              const SizedBox(height: AppDimensions.spacingXl),

              // SEPARADOR
              Container(
                height: 1,
                color: AppColors.sitioDivider,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // IMAGEN ALTERNATIVA
  Widget _imagenAlternativa() {
    return Container(
      width: double.infinity,
      color: AppColors.sitioSurfaceGreen,
      alignment: Alignment.center,
      child: Icon(
        Icons.local_cafe_outlined,
        size: AppDimensions.featuredImageHeight * 0.25,
        color: AppColors.sitioPrimary,
      ),
    );
  }
}
