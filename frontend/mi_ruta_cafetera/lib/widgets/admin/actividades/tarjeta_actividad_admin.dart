
import 'package:flutter/material.dart';

import '../../../models/admin/admin_actividad_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../producto/estado_producto.dart';
import 'hoja_detalles_evaluacion_actividad.dart';

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

  static const Color _verde = Color(0xFF27864D);
  static const Color _naranja = AppColors.secondary;
  static const Color _cafe = AppColors.adminBorder;

  @override
  Widget build(BuildContext context) {
    final estado = actividad.estadoPublicacion.toLowerCase();
    final pendiente = estado == 'pendiente_revision';
    final imagenes = actividad.todasLasImagenes;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingSm,
      ),
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: _cafe,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: seleccionado ? 3 : 1,
        clipBehavior: Clip.antiAlias,
        color: AppColors.creamLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.5),
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
                            EstadoProducto(estado: estado),
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
                            actividad.departamento.isNotEmpty)
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

                        const SizedBox(
                          height: AppDimensions.spacingMd,
                        ),

                        // Etiquetas con fondo crema e iconos naranjas.
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
                                'Precio: ${actividad.precio} COP',
                              ),
                            if (actividad.duracion.trim().isNotEmpty)
                              _etiqueta(
                                Icons.schedule_outlined,
                                actividad.duracion,
                              ),
                          ],
                        ),

                        // Evaluación final.
                        if (!pendiente && _tieneEvaluacionFinal) ...[
                          const SizedBox(
                            height: AppDimensions.spacingLg,
                          ),
                          _tarjetaEvaluacion(context),
                        ],

                        if (actividad.fechaCreacion != null) ...[
                          const SizedBox(
                            height: AppDimensions.spacingLg,
                          ),
                          _fila(
                            Icons.calendar_today_outlined,
                            'Creada el ${_formatearFecha(actividad.fechaCreacion!)}',
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Botones de administración con tamaño intermedio.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                0,
                AppDimensions.spacingMd,
                AppDimensions.spacingMd,
              ),
              child: Column(
                children: [
                  if (pendiente) ...[
                    const SizedBox(
                      height: AppDimensions.spacingSm,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: procesando ? null : onRechazar,
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                            ),
                            label: const Text('Rechazar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.terracota,
                              side: const BorderSide(
                                color: AppColors.terracota,
                              ),
                              minimumSize: const Size(0, 42),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.standard,
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
                              size: 20,
                            ),
                            label: const Text('Aprobar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              minimumSize: const Size(0, 42),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.standard,
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
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
      ),
    );
  }

  // ============================================================
  // EVALUACIÓN FINAL
  // ============================================================

  bool get _tieneEvaluacionFinal {
    return actividad.revisado ||
        actividad.evaluacionIA?.decision == 'aprobado' ||
        actividad.evaluacionIA?.decision == 'rechazado';
  }

  Color get _colorEvaluacion {
    final estado = actividad.estadoPublicacion.toLowerCase();

    if (estado == 'aprobado') return _verde;
    if (estado == 'rechazado') return AppColors.terracota;

    return _naranja;
  }

  Widget _tarjetaEvaluacion(BuildContext context) {
    final esAdmin = actividad.revisado;
    final rechazado =
        actividad.estadoPublicacion.toLowerCase() == 'rechazado';
    final color = _colorEvaluacion;

    final titulo = esAdmin
        ? 'Revisión del administrador'
        : 'Evaluación de IA';

    final resultado = esAdmin
        ? '${rechazado ? 'Rechazado' : 'Aprobado'} manualmente'
        : actividad.evaluacionIA?.decision == 'aprobado'
            ? 'Aprobado por IA'
            : 'Rechazado por IA';

    return InkWell(
      onTap: () {
        HojaDetallesEvaluacionActividad.mostrar(
          context,
          actividad: actividad,
        );
      },
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusLg,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(
          AppDimensions.spacingMd,
        ),
        decoration: BoxDecoration(
          color: AppColors.creamLight,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
          border: Border.all(
            color: AppColors.adminBorder,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              esAdmin
                  ? Icons.admin_panel_settings_outlined
                  : Icons.smart_toy_outlined,
              color: color,
              size: 25,
            ),
            const SizedBox(
              width: AppDimensions.spacingMd,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        rechazado
                            ? Icons.cancel
                            : Icons.check_circle,
                        color: color,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          resultado,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGEN
  // ============================================================

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
      color: AppColors.cream,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 48,
        color: AppColors.secondary,
      ),
    );
  }

  // ============================================================
  // FILAS DE INFORMACIÓN
  // ============================================================

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
            color: AppColors.secondary,
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

  // ============================================================
  // ETIQUETAS: IMÁGENES, PRECIO Y DURACIÓN
  // ============================================================

  Widget _etiqueta(IconData icono, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(
          AppDimensions.chipRadius,
        ),
        border: Border.all(
          color: AppColors.adminBorder.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: AppDimensions.iconSm,
            color: AppColors.secondary,
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

  // ============================================================
  // FECHAS
  // ============================================================

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }
}
