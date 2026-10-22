import 'package:flutter/material.dart';

import '../../../models/admin/admin_actividad_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class DetalleActividadAdmin extends StatelessWidget {
  final ActividadAdminModel actividad;
  final VoidCallback onVolver;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;
  final VoidCallback? onActualizar;
  final bool procesando;
  final Function(List<String>, int)? onMostrarGaleria;

  const DetalleActividadAdmin({
    super.key,
    required this.actividad,
    required this.onVolver,
    required this.onAprobar,
    required this.onRechazar,
    this.onActualizar,
    this.procesando = false,
    this.onMostrarGaleria,
  });

  static const Color _cafe = Color(0xFFB99A80);
  static const Color _verde = Color(0xFF27864D);

  @override
  Widget build(BuildContext context) {
    final imagenes = actividad.todasLasImagenes
        .where((url) => url.trim().isNotEmpty)
        .toList();

    final estado = actividad.estadoPublicacion.toLowerCase().trim();
    final pendiente = estado == 'pendiente_revision';
    final aprobado = estado == 'aprobado';
    final rechazado = estado == 'rechazado';

    return Column(
      children: [
        _encabezado(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pageHorizontalSmall,
              AppDimensions.spacingMd,
              AppDimensions.pageHorizontalSmall,
              AppDimensions.spacingXl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tarjeta(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppDimensions.spacingLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          actividad.nombre.trim().isEmpty
                              ? 'Actividad sin nombre'
                              : actividad.nombre,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 14),
                        _estado(estado),
                        const SizedBox(height: 24),
                        _titulo('Descripción', Icons.subject_rounded),
                        const SizedBox(height: 12),
                        Text(
                          actividad.descripcion.trim().isEmpty
                              ? 'No hay descripción disponible.'
                              : actividad.descripcion,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.6,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _tarjeta(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppDimensions.spacingLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _titulo(
                          'Información turística',
                          Icons.explore_outlined,
                        ),
                        const SizedBox(height: 24),
                        _dato(
                          Icons.storefront_outlined,
                          'Sitio turístico',
                          actividad.nombreSitio,
                        ),
                        _dato(
                          Icons.location_city_outlined,
                          'Ciudad',
                          actividad.ciudad,
                        ),
                        _dato(
                          Icons.map_outlined,
                          'Departamento',
                          actividad.departamento,
                        ),
                        if (actividad.precio != null)
                          _dato(
                            Icons.payments_outlined,
                            'Precio',
                            '${actividad.precio} COP',
                          ),
                        if (actividad.horario.trim().isNotEmpty)
                          _dato(
                            Icons.schedule_outlined,
                            'Horario',
                            actividad.horario,
                          ),
                        if (actividad.duracion.trim().isNotEmpty)
                          _dato(
                            Icons.hourglass_bottom_rounded,
                            'Duración',
                            actividad.duracion,
                          ),
                        if (actividad.fechaCreacion != null)
                          _dato(
                            Icons.event_outlined,
                            'Fecha de creación',
                            _formatearFecha(actividad.fechaCreacion!),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _tarjeta(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppDimensions.spacingLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _titulo(
                          'Fotografías',
                          Icons.photo_library_outlined,
                        ),
                        const SizedBox(height: 20),
                        if (imagenes.isEmpty)
                          _sinImagenes()
                        else
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final ancho = (constraints.maxWidth - 16) / 3;

                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(
                                  imagenes.length,
                                  (indice) => GestureDetector(
                                    onTap: onMostrarGaleria == null
                                        ? null
                                        : () => onMostrarGaleria!(
                                              imagenes,
                                              indice,
                                            ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(
                                        AppDimensions.radiusMd,
                                      ),
                                      child: Image.network(
                                        imagenes[indice],
                                        width: ancho,
                                        height: ancho,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(
                                          width: ancho,
                                          height: ancho,
                                          color: AppColors.surfaceVariant,
                                          child: const Icon(
                                            Icons.broken_image_outlined,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                if (actividad.motivoRechazo.trim().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _tarjeta(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppDimensions.spacingLg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _titulo(
                            'Motivo del rechazo anterior',
                            Icons.info_outline_rounded,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            actividad.motivoRechazo,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (!pendiente) ...[
                  const SizedBox(height: 24),
                  _tarjeta(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppDimensions.spacingLg,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            aprobado
                                ? Icons.check_circle_outline_rounded
                                : rechazado
                                    ? Icons.cancel_outlined
                                    : Icons.info_outline_rounded,
                            color: aprobado
                                ? _verde
                                : rechazado
                                    ? AppColors.error
                                    : AppColors.secondary,
                            size: 26,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  aprobado
                                      ? 'Actividad aprobada'
                                      : rechazado
                                          ? 'Actividad rechazada'
                                          : 'Estado de la actividad',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  aprobado
                                      ? 'Esta actividad ya fue aprobada.'
                                      : rechazado
                                          ? 'Esta actividad ya fue rechazada.'
                                          : 'Esta actividad no está pendiente de revisión.',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (pendiente) ...[
                  const SizedBox(height: 28),
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
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: procesando ? null : onAprobar,
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                          ),
                          label: const Text('Aprobar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (procesando) ...[
                  const SizedBox(height: 18),
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Procesando revisión...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _encabezado() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: 12,
          color: AppColors.primary,
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingLg,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(
                color: _cafe.withValues(alpha: 0.65),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              _botonEncabezado(
                icono: Icons.arrow_back_rounded,
                tooltip: 'Volver',
                onPressed: onVolver,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Detalles de la actividad',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Información y gestión turística',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              if (onActualizar != null)
                _botonEncabezado(
                  icono: Icons.refresh_rounded,
                  tooltip: 'Actualizar',
                  onPressed: procesando
                      ? null
                      : () {
                          onActualizar?.call();
                        },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _botonEncabezado({
    required IconData icono,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFFFFE4D2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(
          icono,
          size: 24,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  Widget _tarjeta({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        border: Border.all(
          color: _cafe,
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _titulo(String texto, IconData icono) {
    return Row(
      children: [
        Icon(
          icono,
          size: 23,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _estado(String estado) {
    final aprobado = estado == 'aprobado';
    final rechazado = estado == 'rechazado';

    final color = aprobado
        ? _verde
        : rechazado
            ? AppColors.error
            : AppColors.secondary;

    final texto = aprobado
        ? 'Aprobada'
        : rechazado
            ? 'Rechazada'
            : estado == 'pendiente_revision'
                ? 'Pendiente de revisión'
                : estado.isEmpty
                    ? 'Estado no disponible'
                    : estado.replaceAll('_', ' ');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(
          AppDimensions.chipRadius,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            aprobado
                ? Icons.check_circle_outline_rounded
                : rechazado
                    ? Icons.cancel_outlined
                    : Icons.pending_outlined,
            size: 17,
            color: color,
          ),
          const SizedBox(width: 7),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dato(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _cafe.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icono,
              size: 19,
              color: _cafe,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  valor.trim().isEmpty ? 'No disponible' : valor,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sinImagenes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 32,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 10),
          Text(
            'No hay fotografías disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
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