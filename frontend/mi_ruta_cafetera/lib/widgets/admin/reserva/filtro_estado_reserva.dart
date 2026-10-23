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
    {'valor': 'Todas', 'icono': Icons.event_note_rounded, 'color': AppColors.secondary},
    {'valor': 'Pendiente', 'icono': Icons.schedule_rounded, 'color': Colors.orange},
    {'valor': 'Confirmada', 'icono': Icons.check_circle_outline_rounded, 'color': Colors.green},
    {'valor': 'Rechazada', 'icono': Icons.cancel_outlined, 'color': Colors.red},
    {'valor': 'Cancelada', 'icono': Icons.event_busy_rounded, 'color': Colors.deepOrange},
    {'valor': 'Completada', 'icono': Icons.task_alt_rounded, 'color': Colors.teal},
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
          final icono = estado['icono'] as IconData;
          final color = estado['color'] as Color;
          final activo = estadoSeleccionado == valor;

          return Padding(
            padding: const EdgeInsets.only(
              right: AppDimensions.spacingSm,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: activo
                    ? color.withValues(alpha: 0.12)
                    : AppColors.creamLight,
                borderRadius: BorderRadius.circular(
                  AppDimensions.chipRadius,
                ),
                border: Border.all(
                  color: activo ? color : _bordeCafe,
                  width: activo ? 1.3 : 1.1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.chipRadius,
                  ),
                  splashColor: color.withValues(alpha: 0.08),
                  highlightColor: color.withValues(alpha: 0.05),
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
                          icono,
                          size: 17,
                          color: color,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          valor,
                          style: TextStyle(
                            color: activo ? color : AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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