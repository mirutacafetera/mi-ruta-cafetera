import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class FiltroEstadoReserva extends StatelessWidget {
  final String estadoSeleccionado;
  final ValueChanged<String> onChanged;

  const FiltroEstadoReserva({
    super.key,
    required this.estadoSeleccionado,
    required this.onChanged,
  });

  static const Color _bordeCafe = Color(0xFFB58A70);

  static const List<Map<String, dynamic>> estados = [
    {
      'valor': 'Todas',
      'icono': Icons.event_note_rounded,
    },
    {
      'valor': 'Pendiente',
      'icono': Icons.schedule_rounded,
    },
    {
      'valor': 'Confirmada',
      'icono': Icons.check_circle_outline_rounded,
    },
    {
      'valor': 'Rechazada',
      'icono': Icons.cancel_outlined,
    },
    {
      'valor': 'Cancelada',
      'icono': Icons.event_busy_rounded,
    },
    {
      'valor': 'Completada',
      'icono': Icons.task_alt_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
      ),
      child: Row(
        children: estados.map((estado) {
          final valor = estado['valor'] as String;
          final activo = estadoSeleccionado == valor;

          return Padding(
            padding: const EdgeInsets.only(
              right: AppDimensions.spacingSm,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: activo
                    ? AppColors.primary
                    : AppColors.creamLight,
                borderRadius: BorderRadius.circular(
                  AppDimensions.chipRadius,
                ),
                border: Border.all(
                  color: activo ? AppColors.primary : _bordeCafe,
                  width: activo ? 1.5 : 1.2,
                ),
                boxShadow: activo
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.14),
                          blurRadius: 7,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.chipRadius,
                  ),
                  onTap: () {
                    if (!activo) onChanged(valor);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingMd,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          estado['icono'] as IconData,
                          size: 17,
                          color: activo
                              ? AppColors.white
                              : AppColors.secondary,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          valor,
                          style: TextStyle(
                            color: activo
                                ? AppColors.white
                                : AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: activo
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                        if (activo) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.check_rounded,
                            size: 15,
                            color: AppColors.white,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}