
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
  final bool mostrarEncabezado;

  const DetalleActividades({
    super.key,
    required this.actividades,
    this.cargando = false,
    required this.onSeleccionar,
    this.mostrarEncabezado = true,
  });

  static const double _anchoTarjeta = 175;
  static const double _altoLista = 215;

  @override
  Widget build(BuildContext context) {
    final visibles = actividades.where((a) => a.activo).toList();

    return Padding(
      padding: const EdgeInsets.only(
        top: 0,
        bottom: 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mostrarEncabezado) ...[
            const _SeparadorExperiencias(),
            const SizedBox(height: AppDimensions.spacingLg),
            EncabezadoSeccionDetalle(
              icono: Icons.explore_rounded,
              titulo: Textos.t('Experiencias para disfrutar'),
              descripcion: Textos.t(
                'Conoce las actividades que puedes vivir durante tu visita.',
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
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
                  width: AppDimensions.spacingMd,
                ),
                itemBuilder: (context, index) {
                  final actividad = visibles[index];

                  return _TarjetaActividad(
                    actividad: actividad,
                    ancho: _anchoTarjeta,
                    onTap: () => onSeleccionar(actividad),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// =====================================================
// SEPARADOR DE LA SECCIÓN
// =====================================================

class _SeparadorExperiencias extends StatelessWidget {
  const _SeparadorExperiencias();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1.3,
              color: AppColors.sitioPrimary.withValues(alpha: 0.65),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.sitioSurfaceGreen,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.sitioBorder,
                width: 0.8,
              ),
            ),
            child: const Icon(
              Icons.hiking_rounded,
              color: AppColors.sitioPrimary,
              size: 21,
            ),
          ),
          Expanded(
            child: Container(
              height: 1.3,
              color: AppColors.sitioPrimary.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// TARJETA DE ACTIVIDAD
// =====================================================

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
    final nombre = actividad.nombre.trim();
    final duracion = actividad.duracion.trim();

    final precio = actividad.precio > 0
        ? 'Precio: ${formatearPrecioCop(actividad.precio)}'
        : 'Precio: por consultar';

    return SizedBox(
      width: ancho,
      child: Container(
        // MARCO EXTERIOR CAFÉ
        decoration: decoracionTarjetaDetalle().copyWith(
          border: Border.all(
            color: AppColors.adminBorder.withValues(alpha: 0.60),
            width: 0.5,
          ),
        ),

        // ESPACIO PARA CONSERVAR VISIBLE EL BORDE
        padding: const EdgeInsets.all(1),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius - 1,
          ),
          child: Material(
            color: AppColors.sitioSurface,
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IMAGEN
                  SizedBox(
                    height: 96,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imagen.isNotEmpty)
                          Image.network(
                            imagen,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const _FondoActividad(),
                          )
                        else
                          const _FondoActividad(),

                        if (imagenes.length > 1)
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.black.withValues(
                                  alpha: 0.65,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.photo_library_outlined,
                                    color: AppColors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${imagenes.length}',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 10,
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

                  // INFORMACIÓN DE LA ACTIVIDAD
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        9,
                        8,
                        9,
                        8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre.isNotEmpty
                                ? nombre
                                : Textos.t('Experiencia turística'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.sitioTextPrimary,
                              fontSize: 12,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 9),

                          // VALOR Y BOTÓN
                          Row(
                            children: [
                              const Icon(
                                Icons.confirmation_number_outlined,
                                color: AppColors.sitioPrimary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  precio,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.sitioPrimaryDark,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Material(
                                color: AppColors.sitioPrimary,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  onTap: onTap,
                                  customBorder: const CircleBorder(),
                                  child: const SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: AppColors.sitioTextOnPrimary,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // DURACIÓN
                          if (duracion.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  color: AppColors.sitioAccent,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Duración: $duracion',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.sitioTextSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// IMAGEN ALTERNATIVA
// =====================================================

class _FondoActividad extends StatelessWidget {
  const _FondoActividad();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sitioSurfaceGreen,
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_cafe_rounded,
        size: 40,
        color: AppColors.sitioPrimary,
      ),
    );
  }
}
