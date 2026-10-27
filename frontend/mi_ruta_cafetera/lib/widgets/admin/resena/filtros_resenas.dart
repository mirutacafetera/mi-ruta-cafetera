import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class FiltrosResenas extends StatelessWidget {
  final String filtroSeleccionado;
  final ValueChanged<String> onChanged;

  const FiltrosResenas({
    super.key,
    required this.filtroSeleccionado,
    required this.onChanged,
  });

  static const List<String> filtros = [
    'Todas',
    'Activas',
    'Inactivas',
  ];

  IconData _obtenerIcono(String filtro) {
    switch (filtro) {
      case 'Todas':
        return Icons.fact_check_outlined;
      case 'Activas':
        return Icons.check_circle_outline_rounded;
      case 'Inactivas':
        return Icons.pause_circle_outline_rounded;
      default:
        return Icons.filter_list_rounded;
    }
  }

  Color _obtenerColor(String filtro) {
    switch (filtro) {
      case 'Activas':
        return AppColors.success;
      case 'Inactivas':
        return AppColors.warning;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingSm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: filtros.map((filtro) {
            final seleccionado = filtroSeleccionado == filtro;
            final color = _obtenerColor(filtro);

            return Padding(
              padding: const EdgeInsets.only(
                right: AppDimensions.spacingSm,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: seleccionado
                      ? color.withValues(alpha: 0.12)
                      : AppColors.creamLight,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.chipRadius,
                  ),
                  border: Border.all(
                    color: seleccionado
                        ? color
                        : AppColors.coffeeLight.withValues(alpha: 0.65),
                    width: seleccionado ? 1.3 : 1.1,
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
                    onTap: () => onChanged(filtro),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingSm + 4,
                        vertical: AppDimensions.spacingSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _obtenerIcono(filtro),
                            size: AppDimensions.iconSm,
                            color: color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            filtro,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: seleccionado
                                  ? color
                                  : AppColors.textPrimary,
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
      ),
    );
  }
}