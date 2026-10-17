
import 'package:flutter/material.dart';

import '../../models/sitio/sitio_actividad_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class TarjetaActividadSitio extends StatelessWidget {
  final SitioActividadModel actividad;
  final VoidCallback onEditar;
  final VoidCallback onEnviarRevision;
  final VoidCallback onEliminar;
  final bool guardando;

  const TarjetaActividadSitio({
    super.key,
    required this.actividad,
    required this.onEditar,
    required this.onEnviarRevision,
    required this.onEliminar,
    required this.guardando,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.sitioPanelCardPadding),
      decoration: BoxDecoration(
        color: AppColors.sitioSurface,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        border: Border.all(color: AppColors.sitioBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compacto = constraints.maxWidth < 360;

              if (compacto) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _imagenActividad(),
                    const SizedBox(height: 16),
                    _informacionActividad(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _imagenActividad(),
                  const SizedBox(width: 14),
                  Expanded(child: _informacionActividad()),
                ],
              );
            },
          ),
          if (actividad.motivoRechazo.isNotEmpty &&
              actividad.estadoPublicacion == 'rechazado') ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.sitioErrorSoft,
                borderRadius: BorderRadius.circular(
                  AppDimensions.sitioFormRadius,
                ),
                border: Border.all(
                  color: AppColors.sitioError.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.sitioError,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Motivo del rechazo:\n${actividad.motivoRechazo}',
                      style: const TextStyle(
                        color: AppColors.sitioError,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (guardando) ...[
            const LinearProgressIndicator(
              color: AppColors.sitioPrimary,
              backgroundColor: AppColors.sitioSurfaceGreen,
              minHeight: 3,
            ),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: guardando ? null : onEditar,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.sitioPrimary,
                  side: const BorderSide(color: AppColors.sitioBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 11,
                  ),
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar'),
              ),
              if (actividad.estadoPublicacion == 'borrador')
                ElevatedButton.icon(
                  onPressed: guardando ? null : onEnviarRevision,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sitioPrimary,
                    foregroundColor: AppColors.sitioTextOnPrimary,
                    disabledBackgroundColor:
                        AppColors.sitioPrimary.withValues(alpha: 0.45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 11,
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 17),
                  label: const Text('Enviar a revisión'),
                ),
              TextButton.icon(
                onPressed: guardando ? null : onEliminar,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.sitioError,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 19),
                label: const Text('Eliminar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _informacionActividad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                actividad.nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.sitioTextPrimary,
                  fontSize: 17,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: _estadoActividad(actividad.estadoPublicacion),
            ),
          ],
        ),
        if (actividad.descripcion.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            actividad.descripcion,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.sitioTextSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
        if (actividad.precio > 0 ||
            actividad.horario.isNotEmpty ||
            actividad.duracion.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.sitioSurfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (actividad.precio > 0)
                  _datoActividad(
                    Icons.payments_outlined,
                    '\$${actividad.precio.toStringAsFixed(0)}',
                    AppColors.sitioSuccess,
                  ),
                if (actividad.horario.isNotEmpty) ...[
                  if (actividad.precio > 0)
                    const SizedBox(height: 9),
                  _datoActividad(
                    Icons.schedule_rounded,
                    actividad.horario,
                    AppColors.sitioPrimary,
                  ),
                ],
                if (actividad.duracion.isNotEmpty) ...[
                  if (actividad.precio > 0 || actividad.horario.isNotEmpty)
                    const SizedBox(height: 9),
                  _datoActividad(
                    Icons.timer_outlined,
                    actividad.duracion,
                    AppColors.sitioAccent,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _imagenActividad() {
    final String urlPrincipal = actividad.imagenPrincipal.trim();

    final String? url = urlPrincipal.isNotEmpty
        ? urlPrincipal
        : actividad.imagenes
            .where((imagen) => imagen.trim().isNotEmpty)
            .firstOrNull;

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AppDimensions.sitioItemImageRadius,
      ),
      child: SizedBox(
        width: AppDimensions.sitioItemImageWidth,
        height: AppDimensions.sitioItemImageHeight,
        child: url != null && url.trim().isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _imagenSinFoto();
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _imagenCargando();
                },
              )
            : _imagenSinFoto(),
      ),
    );
  }

  Widget _imagenCargando() {
    return Container(
      color: AppColors.sitioSurfaceGreen,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.sitioPrimary,
        ),
      ),
    );
  }

  Widget _imagenSinFoto() {
    return Container(
      color: AppColors.sitioSurfaceGreen,
      alignment: Alignment.center,
      child: const Icon(
        Icons.photo_camera_outlined,
        size: 34,
        color: AppColors.sitioPrimary,
      ),
    );
  }

  Widget _estadoActividad(String estado) {
    late final String texto;
    late final IconData icono;
    late final Color color;
    late final Color fondo;

    switch (estado) {
      case 'aprobado':
        texto = 'Aprobada';
        icono = Icons.check_circle_rounded;
        color = AppColors.sitioSuccess;
        fondo = AppColors.sitioSuccessSoft;
        break;
      case 'pendiente_revision':
        texto = 'En revisión';
        icono = Icons.hourglass_top_rounded;
        color = AppColors.sitioWarning;
        fondo = AppColors.sitioWarningSoft;
        break;
      case 'rechazado':
        texto = 'Rechazada';
        icono = Icons.cancel_rounded;
        color = AppColors.sitioError;
        fondo = AppColors.sitioErrorSoft;
        break;
      default:
        texto = 'Borrador';
        icono = Icons.edit_note_rounded;
        color = AppColors.sitioPrimary;
        fondo = AppColors.sitioSurfaceGreen;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sitioStatusHorizontalPadding,
        vertical: AppDimensions.sitioStatusVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioStatusRadius,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datoActividad(
    IconData icono,
    String texto,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 17, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              color: AppColors.sitioTextSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
