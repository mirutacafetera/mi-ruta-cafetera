import 'package:flutter/material.dart';

import '../../../models/admin/admin_actividad_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../producto/estado_producto.dart';

class TarjetaActividadAdmin extends StatelessWidget {
  final ActividadAdminModel actividad;
  final VoidCallback onVerDetalles;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;
  final bool procesando;
  final bool seleccionado;

  const TarjetaActividadAdmin({
    super.key,
    required this.actividad,
    required this.onVerDetalles,
    required this.onAprobar,
    required this.onRechazar,
    this.procesando = false,
    this.seleccionado = false,
  });

  @override
  Widget build(BuildContext context) {
    final estado = actividad.estadoPublicacion;
    final pendiente = estado == 'pendiente_revision';
    final imagenes = actividad.todasLasImagenes;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingSm,
      ),
      elevation: seleccionado ? 3 : 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: seleccionado
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onVerDetalles,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _construirImagen(actividad.imagenPrincipal),
                Padding(
                  padding: const EdgeInsets.all(
                    AppDimensions.spacingMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              actividad.nombre.isEmpty
                                  ? 'Actividad sin nombre'
                                  : actividad.nombre,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                          ),
                          const SizedBox(
                            width: AppDimensions.spacingSm,
                          ),
                          EstadoProducto(
                            estado: estado,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingSm,
                      ),
                      Text(
                        actividad.descripcion.isEmpty
                            ? 'Sin descripción'
                            : actividad.descripcion,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingMd,
                      ),
                      if (actividad.nombreSitio.isNotEmpty)
                        _fila(
                          Icons.place_outlined,
                          actividad.nombreSitio,
                        ),
                      if (actividad.ciudad.isNotEmpty ||
                          actividad.departamento.isNotEmpty) ...[
                        const SizedBox(
                          height: AppDimensions.spacingXs,
                        ),
                        _fila(
                          Icons.location_city_outlined,
                          [
                            actividad.ciudad,
                            actividad.departamento,
                          ]
                              .where(
                                (dato) => dato.trim().isNotEmpty,
                              )
                              .join(', '),
                        ),
                      ],
                      const SizedBox(
                        height: AppDimensions.spacingMd,
                      ),
                      Wrap(
                        spacing: AppDimensions.spacingSm,
                        runSpacing: AppDimensions.spacingXs,
                        children: [
                          _etiqueta(
                            Icons.photo_library_outlined,
                            '${imagenes.length} imágenes',
                          ),
                          if (actividad.precio != null)
                            _etiqueta(
                              Icons.payments_outlined,
                              'Precio: ${actividad.precio}',
                            ),
                          if (actividad.duracion.trim().isNotEmpty)
                            _etiqueta(
                              Icons.schedule_outlined,
                              actividad.duracion,
                            ),
                        ],
                      ),
                      if (actividad.motivoRechazo.trim().isNotEmpty) ...[
                        const SizedBox(
                          height: AppDimensions.spacingMd,
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(
                            AppDimensions.spacingMd,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Motivo del rechazo: '
                            '${actividad.motivoRechazo}',
                            style: const TextStyle(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                      if (actividad.fechaCreacion != null) ...[
                        const SizedBox(
                          height: AppDimensions.spacingSm,
                        ),
                        _fila(
                          Icons.calendar_today_outlined,
                          'Creada el '
                          '${_formatearFecha(actividad.fechaCreacion!)}',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingMd,
              0,
              AppDimensions.spacingMd,
              AppDimensions.spacingMd,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: procesando ? null : onVerDetalles,
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Ver detalles'),
                  ),
                ),
                if (pendiente) ...[
                  const SizedBox(
                    height: AppDimensions.spacingSm,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: procesando ? null : onRechazar,
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Rechazar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: AppDimensions.spacingSm,
                      ),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: procesando ? null : onAprobar,
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                          ),
                          label: const Text('Aprobar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (procesando) ...[
                  const SizedBox(
                    height: AppDimensions.spacingMd,
                  ),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirImagen(String url) {
    if (url.trim().isEmpty) {
      return _imagenVacia();
    }

    return Image.network(
      url,
      height: AppDimensions.cardImageHeight,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _imagenVacia();
      },
    );
  }

  Widget _imagenVacia() {
    return Container(
      height: AppDimensions.cardImageHeight,
      width: double.infinity,
      alignment: Alignment.center,
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 48,
        color: AppColors.primary.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _fila(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spacingXs,
      ),
      child: Row(
        children: [
          Icon(
            icono,
            size: AppDimensions.iconSm,
            color: AppColors.primary,
          ),
          const SizedBox(
            width: AppDimensions.spacingSm,
          ),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _etiqueta(IconData icono, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          AppDimensions.chipRadius,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: AppDimensions.iconSm,
            color: AppColors.primary,
          ),
          const SizedBox(
            width: AppDimensions.spacingXs,
          ),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }
}