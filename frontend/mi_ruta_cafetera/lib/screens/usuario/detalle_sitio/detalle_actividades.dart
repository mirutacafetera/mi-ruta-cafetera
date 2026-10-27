import 'package:flutter/material.dart';

import '../../../../models/sitio/sitio_actividad_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';
import '../../../widgets/usuario/detalle_sitio/componentes_detalle.dart';
import '../../../l10n/textos.dart';

class DetalleActividades extends StatelessWidget {
  final List<SitioActividadModel> actividades;
  final bool cargando;
  final ValueChanged<SitioActividadModel> onSeleccionar;

  /// Cuando la pantalla que lo contiene ya dibuja el encabezado
  /// de la sección, se envía `false` para no repetirlo.
  final bool mostrarEncabezado;

  const DetalleActividades({
    super.key,
    required this.actividades,
    this.cargando = false,
    required this.onSeleccionar,
    this.mostrarEncabezado = true,
  });

  static const double _anchoTarjeta = 230;
  static const double _altoLista = 258;

  @override
  Widget build(BuildContext context) {
    final visibles = actividades.where((a) => a.activo).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mostrarEncabezado) ...[
            EncabezadoSeccionDetalle(
              icono: Icons.coffee_rounded,
              titulo: Textos.t('Actividades para disfrutar'),
              descripcion: Textos.t(
                'Explora las experiencias de este lugar.',
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
          ],
          if (cargando)
            const Padding(
              padding: EdgeInsets.all(AppDimensions.spacingXxl),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.sitioPrimary,
                ),
              ),
            )
          else if (visibles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pageHorizontal,
              ),
              child: TarjetaEstadoDetalle(
                icono: Icons.local_activity_outlined,
                titulo: Textos.t('Próximamente nuevas experiencias'),
                descripcion: Textos.t(
                  'Estamos preparando actividades para tu visita.',
                ),
              ),
            )
          else
            SizedBox(
              height: _altoLista,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontal,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: visibles.length,
                separatorBuilder: (_, _) => const SizedBox(
                  width: AppDimensions.spacingMd + 2,
                ),
                itemBuilder: (context, index) {
                  return _TarjetaActividad(
                    actividad: visibles[index],
                    ancho: _anchoTarjeta,
                    onTap: () => onSeleccionar(visibles[index]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _TarjetaActividad extends StatelessWidget {
  const _TarjetaActividad({
    required this.actividad,
    required this.ancho,
    required this.onTap,
  });

  final SitioActividadModel actividad;
  final double ancho;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imagenes = unirImagenesDetalle(
      actividad.imagenPrincipal,
      actividad.imagenes,
    );
    final imagen = actividad.imagenPrincipal.trim();
    final descripcion = actividad.descripcion.trim();

    return SizedBox(
      width: ancho,
      child: Container(
        decoration: decoracionTarjetaDetalle(),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imagen.isNotEmpty)
                        Image.network(
                          imagen,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const _FondoActividad(),
                        )
                      else
                        const _FondoActividad(),
                      if (imagenes.length > 1)
                        Positioned(
                          right: AppDimensions.spacingMd,
                          top: AppDimensions.spacingMd,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingSm + 1,
                              vertical: AppDimensions.spacingSm - 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.chipRadius,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.photo_library_outlined,
                                  color: AppColors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${imagenes.length}',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(
                    AppDimensions.sitioContentPadding - 1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actividad.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.sitioTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        descripcion.isEmpty
                            ? Textos.t('Descubre esta experiencia.')
                            : descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.sitioTextSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      const Row(
                        children: [
                          Tr(
                            'Ver experiencia',
                            style: TextStyle(
                              color: AppColors.sitioPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: AppColors.sitioPrimary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FondoActividad extends StatelessWidget {
  const _FondoActividad();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sitioSurfaceGreen,
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_cafe_rounded,
        size: 44,
        color: AppColors.sitioPrimary,
      ),
    );
  }
}
