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
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  actividad.nombre,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(
                width: AppDimensions.spacingSm,
              ),
              _estadoActividad(
                actividad.estadoPublicacion,
              ),
            ],
          ),

          if (actividad.descripcion.isNotEmpty) ...[
            const SizedBox(
              height: AppDimensions.spacingSm,
            ),
            Text(
              actividad.descripcion,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(
            height: AppDimensions.spacingMd,
          ),

          Wrap(
            spacing: AppDimensions.spacingLg,
            runSpacing: AppDimensions.spacingSm,
            children: [
              if (actividad.precio > 0)
                _datoActividad(
                  Icons.attach_money_rounded,
                  '\$${actividad.precio.toStringAsFixed(0)}',
                ),
              if (actividad.horario.isNotEmpty)
                _datoActividad(
                  Icons.schedule_rounded,
                  actividad.horario,
                ),
              if (actividad.duracion.isNotEmpty)
                _datoActividad(
                  Icons.timer_outlined,
                  actividad.duracion,
                ),
            ],
          ),

          if (actividad.motivoRechazo.isNotEmpty &&
              actividad.estadoPublicacion == 'rechazado') ...[
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
                  alpha: 0.06,
                ),
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
              ),
              child: Text(
                'Motivo del rechazo:\n'
                '${actividad.motivoRechazo}',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 13,
                ),
              ),
            ),
          ],

          const SizedBox(
            height: AppDimensions.spacingLg,
          ),

          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: [
              OutlinedButton.icon(
                onPressed: guardando ? null : onEditar,
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 18,
                ),
                label: const Text('Editar'),
              ),

              if (actividad.estadoPublicacion == 'borrador')
                ElevatedButton.icon(
                  onPressed:
                      guardando ? null : onEnviarRevision,
                  icon: const Icon(
                    Icons.send_rounded,
                    size: 18,
                  ),
                  label: const Text('Enviar a revisión'),
                ),

              TextButton.icon(
                onPressed: guardando ? null : onEliminar,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppColors.error,
                ),
                label: const Text(
                  'Eliminar',
                  style: TextStyle(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _estadoActividad(String estado) {
    String texto;
    IconData icono;

    switch (estado) {
      case 'aprobado':
        texto = 'Aprobada';
        icono = Icons.check_circle_rounded;
        break;
      case 'pendiente_revision':
        texto = 'En revisión';
        icono = Icons.hourglass_top_rounded;
        break;
      case 'rechazado':
        texto = 'Rechazada';
        icono = Icons.cancel_rounded;
        break;
      default:
        texto = 'Borrador';
        icono = Icons.edit_note_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceGreen,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusPill,
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
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _datoActividad(
    IconData icono,
    String texto,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icono,
          size: AppDimensions.iconSm,
          color: AppColors.primary,
        ),
        const SizedBox(width: 5),
        Text(
          texto,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}