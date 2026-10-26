
import 'package:flutter/material.dart';

import '../../../models/admin/admin_actividad_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class HojaDetallesEvaluacionActividad {
  HojaDetallesEvaluacionActividad._();

  static void mostrar(
    BuildContext context, {
    required ActividadAdminModel actividad,
  }) {
    final esAdmin = actividad.revisado;
    final evaluacion = actividad.evaluacionIA;

    final aprobado =
        actividad.estadoPublicacion.toLowerCase() == 'aprobado';
    final rechazado =
        actividad.estadoPublicacion.toLowerCase() == 'rechazado';

    final color = rechazado
        ? AppColors.error
        : aprobado
            ? AppColors.primary
            : AppColors.secondary;

    final titulo = esAdmin
        ? 'Detalles de la revisión'
        : 'Detalles de la evaluación';

    final resultado = esAdmin
        ? '${aprobado ? 'Aprobado' : 'Rechazado'} manualmente'
        : evaluacion?.decision == 'aprobado'
            ? 'Aprobado por IA'
            : 'Rechazado por IA';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final alturaPantalla = MediaQuery.of(context).size.height;

        return Container(
          constraints: BoxConstraints(
            maxHeight: alturaPantalla * (esAdmin ? 0.58 : 0.65),
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.sheetRadius),
            ),
            border: const Border(
              top: BorderSide(
                color: AppColors.adminBorder,
                width: 2,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Indicador superior.
                Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: AppColors.adminBorder,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                  ),
                ),

                // Encabezado.
                Padding(
                  padding: const EdgeInsets.all(
                    AppDimensions.spacingXl,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                        ),
                        child: Icon(
                          esAdmin
                              ? Icons.admin_panel_settings_outlined
                              : Icons.smart_toy_outlined,
                          color: color,
                          size: AppDimensions.iconLg,
                        ),
                      ),
                      const SizedBox(
                        width: AppDimensions.spacingMd,
                      ),
                      Expanded(
                        child: Text(
                          titulo,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Cerrar',
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.coffee,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  color: AppColors.adminBorder,
                  height: 1,
                ),

                // Contenido desplazable para ambas hojas.
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(
                      AppDimensions.spacingXl,
                    ),
                    children: [
                      _tarjetaResultado(
                        color: color,
                        rechazado: rechazado,
                        resultado: resultado,
                      ),

                      const SizedBox(
                        height: AppDimensions.spacingXl,
                      ),

                      if (esAdmin) ...[
                        _titulo('Revisado por'),
                        const SizedBox(
                          height: AppDimensions.spacingSm,
                        ),
                        _texto('Administrador'),

                        const SizedBox(
                          height: AppDimensions.spacingXl,
                        ),

                        _titulo('Motivo de la revisión'),
                        const SizedBox(
                          height: AppDimensions.spacingSm,
                        ),
                        _texto(
                          rechazado &&
                                  actividad.motivoRechazo
                                      .trim()
                                      .isNotEmpty
                              ? actividad.motivoRechazo
                              : aprobado
                                  ? 'Actividad aprobada por el administrador.'
                                  : 'Actividad rechazada por el administrador.',
                        ),
                      ] else if (evaluacion != null) ...[
                        _titulo('Motivo de la evaluación'),
                        const SizedBox(
                          height: AppDimensions.spacingSm,
                        ),
                        _texto(
                          evaluacion.motivo.trim().isNotEmpty
                              ? evaluacion.motivo
                              : 'No se registró el motivo de la evaluación.',
                        ),

                        if (evaluacion.criterios.isNotEmpty) ...[
                          const SizedBox(
                            height: AppDimensions.spacingXl,
                          ),
                          _titulo('Criterios evaluados'),
                          const SizedBox(
                            height: AppDimensions.spacingMd,
                          ),
                          ...evaluacion.criterios.map(
                            (criterio) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppDimensions.spacingMd,
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    aprobado
                                        ? Icons.check_circle_rounded
                                        : Icons.check_circle_outline,
                                    color: color,
                                    size: AppDimensions.iconMd,
                                  ),
                                  const SizedBox(
                                    width: AppDimensions.spacingMd,
                                  ),
                                  Expanded(
                                    child: _texto(criterio),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        if (evaluacion.fechaDecision != null) ...[
                          const SizedBox(
                            height: AppDimensions.spacingXl,
                          ),
                          _titulo('Fecha de evaluación'),
                          const SizedBox(
                            height: AppDimensions.spacingSm,
                          ),
                          _texto(
                            _formatearFecha(
                              evaluacion.fechaDecision!,
                            ),
                          ),
                        ],
                      ] else ...[
                        _titulo('Información de la evaluación'),
                        const SizedBox(
                          height: AppDimensions.spacingSm,
                        ),
                        _texto(
                          'No hay información adicional registrada.',
                        ),
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

  // Tarjeta de resultado con el chulo relleno para aprobaciones.
  static Widget _tarjetaResultado({
    required Color color,
    required String resultado,
    required bool rechazado,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
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
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            rechazado
                ? Icons.cancel_rounded
                : Icons.check_circle_rounded,
            color: color,
            size: AppDimensions.iconLg,
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resultado',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingXs,
                ),
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

  // Títulos en naranja.
  static Widget _titulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: AppColors.secondary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Texto descriptivo.
  static Widget _texto(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 15,
        height: 1.6,
      ),
    );
  }

  // Formato de fecha dd/mm/aaaa.
  static String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }
}
