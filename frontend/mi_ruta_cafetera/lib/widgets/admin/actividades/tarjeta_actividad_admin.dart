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

  static const Color _verde = Color(0xFF27864D);
  static const Color _naranja = Color(0xFFFF9800);
  static const Color _fondo = Color(0xFF162019);
  static const Color _cafe = Color(0xFF966F52);

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
                        const SizedBox(height: AppDimensions.spacingSm),
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
                        const SizedBox(height: AppDimensions.spacingMd),
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
                                .where((dato) => dato.trim().isNotEmpty)
                                .join(', '),
                          ),
                        const SizedBox(height: AppDimensions.spacingMd),
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

                        // Evaluación visible solo si está finalizada.
                        if (!pendiente && _tieneEvaluacionFinal) ...[
                        const SizedBox(height: 20),
                        _tarjetaEvaluacion(context),
],

                        if (actividad.fechaCreacion != null) ...[
                        const SizedBox(height: 24),
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
                    const SizedBox(height: AppDimensions.spacingSm),
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
                        const SizedBox(width: AppDimensions.spacingSm),
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
                    const SizedBox(height: AppDimensions.spacingMd),
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

  bool get _tieneEvaluacionFinal {
    return actividad.revisado ||
        actividad.evaluacionIA?.decision == 'aprobado' ||
        actividad.evaluacionIA?.decision == 'rechazado';
  }

  Color get _colorEvaluacion {
    if (actividad.estadoPublicacion == 'aprobado') return _verde;
    if (actividad.estadoPublicacion == 'rechazado') {
      return AppColors.error;
    }
    return _naranja;
  }

  Widget _tarjetaEvaluacion(BuildContext context) {
    final esAdmin = actividad.revisado;
    final rechazado = actividad.estadoPublicacion == 'rechazado';
    final color = _colorEvaluacion;

    final titulo =
        esAdmin ? 'Revisión del administrador' : 'Evaluación de IA';

    final resultado = esAdmin
        ? '${rechazado ? 'Rechazado' : 'Aprobado'} manualmente'
        : actividad.evaluacionIA?.decision == 'aprobado'
            ? 'Aprobado por IA'
            : 'Rechazado por IA';

    return InkWell(
      onTap: () => _mostrarDetallesEvaluacion(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.35),
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
            const SizedBox(width: AppDimensions.spacingMd),
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
                        rechazado ? Icons.cancel : Icons.check_circle,
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
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  void _mostrarDetallesEvaluacion(BuildContext context) {
    final esAdmin = actividad.revisado;
    final evaluacion = actividad.evaluacionIA;
    final aprobado = actividad.estadoPublicacion == 'aprobado';
    final rechazado = actividad.estadoPublicacion == 'rechazado';
    final color = _colorEvaluacion;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: _fondo,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Icon(
                          esAdmin
                              ? Icons.admin_panel_settings_outlined
                              : Icons.smart_toy_outlined,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          esAdmin
                              ? 'Detalles de la revisión'
                              : 'Detalles de la evaluación',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _detalleResultado(
                        color: color,
                        rechazado: rechazado,
                        resultado: esAdmin
                            ? '${aprobado ? 'Aprobado' : 'Rechazado'} manualmente'
                            : evaluacion?.decision == 'aprobado'
                                ? 'Aprobado por IA'
                                : 'Rechazado por IA',
                      ),
                      const SizedBox(height: 30),
                      if (esAdmin) ...[
                        _tituloDetalle('Revisado por'),
                        const SizedBox(height: 10),
                        const Text(
                          'Administrador',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 26),
                        _tituloDetalle('Motivo de la revisión'),
                        const SizedBox(height: 10),
                        Text(
                          rechazado &&
                                  actividad.motivoRechazo.trim().isNotEmpty
                              ? actividad.motivoRechazo
                              : aprobado
                                  ? 'Actividad aprobada por el administrador.'
                                  : 'Actividad rechazada por el administrador.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                      ] else if (evaluacion != null) ...[
                        _tituloDetalle('Motivo de la evaluación'),
                        const SizedBox(height: 10),
                        Text(
                          evaluacion.motivo.isNotEmpty
                              ? evaluacion.motivo
                              : 'No se registró el motivo de la evaluación.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                        if (evaluacion.criterios.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          _tituloDetalle('Criterios evaluados'),
                          const SizedBox(height: 12),
                          ...evaluacion.criterios.map(
                            (criterio) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: color,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      criterio,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (evaluacion.modeloIA.isNotEmpty) ...[
                          const SizedBox(height: 26),
                          _tituloDetalle('Modelo de IA'),
                          const SizedBox(height: 10),
                          Text(
                            evaluacion.modeloIA,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                        if (evaluacion.fechaDecision != null) ...[
                          const SizedBox(height: 26),
                          _tituloDetalle('Fecha de evaluación'),
                          const SizedBox(height: 10),
                          Text(
                            _formatearFecha(evaluacion.fechaDecision!),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detalleResultado({
    required Color color,
    required String resultado,
    required bool rechazado,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            rechazado ? Icons.cancel : Icons.check_circle,
            color: color,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resultado',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  resultado,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tituloDetalle(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: _naranja,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _construirImagen(String url) {
    if (url.trim().isEmpty) return _imagenVacia();

    return Image.network(
      url,
      height: AppDimensions.cardImageHeight,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _imagenVacia(),
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
          const SizedBox(width: AppDimensions.spacingSm),
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
          const SizedBox(width: AppDimensions.spacingXs),
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