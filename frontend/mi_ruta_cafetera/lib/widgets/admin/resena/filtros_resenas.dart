
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingSm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filtros.map((filtro) {
            final seleccionado = filtroSeleccionado == filtro;

            return Padding(
              padding: const EdgeInsets.only(
                right: AppDimensions.spacingSm,
              ),
              child: ChoiceChip(
                avatar: Icon(
                  _obtenerIcono(filtro),
                  size: AppDimensions.iconSm,
                  color: seleccionado
                      ? AppColors.white
                      : AppColors.secondary,
                ),
                label: Text(filtro),
                selected: seleccionado,
                onSelected: (_) => onChanged(filtro),
                showCheckmark: false,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.creamLight,
                elevation: 0,
                pressElevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingSm,
                  vertical: AppDimensions.spacingXs,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.chipRadius,
                  ),
                ),
                side: BorderSide(
                  color: seleccionado
                      ? AppColors.primary
                      : AppColors.coffeeLight.withValues(alpha: 0.65),
                  width: 1.2,
                ),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: seleccionado
                      ? AppColors.white
                      : AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
