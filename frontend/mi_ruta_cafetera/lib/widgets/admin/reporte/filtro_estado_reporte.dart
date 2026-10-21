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

  static const List<Map<String, dynamic>> estados = [
    {
      'valor': 'todos',
      'titulo': 'Todos',
      'icono': Icons.groups_rounded,
    },
    {
      'valor': 'pendiente',
      'titulo': 'Pendientes',
      'icono': Icons.mark_email_unread_rounded,
    },
    {
      'valor': 'en_revision',
      'titulo': 'En revisión',
      'icono': Icons.manage_search_rounded,
    },
    {
      'valor': 'resuelto',
      'titulo': 'Resueltos',
      'icono': Icons.check_circle_outline_rounded,
    },
  ];

  static const Color _bordeCafe = Color(0xFFB58A70);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: estados.map((estado) {
          final activo = seleccionado == estado['valor'];

          return Padding(
            padding: const EdgeInsets.only(
              right: AppDimensions.spacingSm,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: activo
                    ? AppColors.primary
                    : AppColors.creamLight,
                borderRadius: BorderRadius.circular(
                  AppDimensions.chipRadius,
                ),
                border: Border.all(
                  color: activo
                      ? AppColors.primary
                      : _bordeCafe,
                  width: activo ? 1.6 : 1.2,
                ),
                boxShadow: activo
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: 0.16,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (!activo) {
                      onChanged(estado['valor'] as String);
                    }
                  },
                  borderRadius: BorderRadius.circular(
                    AppDimensions.chipRadius,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingMd,
                      vertical: 11,
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
                          estado['titulo'] as String,
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
                          const SizedBox(width: 7),
                          const Icon(
                            Icons.check_rounded,
                            size: 16,
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