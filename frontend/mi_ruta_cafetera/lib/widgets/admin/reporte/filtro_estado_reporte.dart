import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class FiltroEstadoReporte extends StatelessWidget {
  final String seleccionado;
  final ValueChanged<String> onChanged;

  const FiltroEstadoReporte({
    super.key,
    required this.seleccionado,
    required this.onChanged,
  });

  static const Color _bordeCafe = Color(0xFFB58A70);

  static const List<Map<String, dynamic>> estados = [
    {
      'valor': 'todos',
      'titulo': 'Todos',
      'icono': Icons.groups_rounded,
      'color': AppColors.secondary,
    },
    {
      'valor': 'pendiente',
      'titulo': 'Pendientes',
      'icono': Icons.mark_email_unread_rounded,
      'color': Colors.orange,
    },
    {
      'valor': 'en_revision',
      'titulo': 'En revisión',
      'icono': Icons.manage_search_rounded,
      'color': Colors.blue,
    },
    {
      'valor': 'resuelto',
      'titulo': 'Resueltos',
      'icono': Icons.check_circle_outline_rounded,
      'color': AppColors.success,
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
          final color = estado['color'] as Color;
          final activo = seleccionado == valor;

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
                  onTap: () {
                    if (!activo) onChanged(valor);
                  },
                  borderRadius: BorderRadius.circular(
                    AppDimensions.chipRadius,
                  ),
                  splashColor: color.withValues(alpha: 0.08),
                  highlightColor: color.withValues(alpha: 0.05),
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
                          color: color,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          estado['titulo'] as String,
                          style: TextStyle(
                            color: activo
                                ? color
                                : AppColors.textPrimary,
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