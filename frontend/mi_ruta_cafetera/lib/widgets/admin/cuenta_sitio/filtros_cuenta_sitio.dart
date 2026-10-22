
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class FiltrosCuentaSitio extends StatelessWidget {
  final String filtroSeleccionado;
  final ValueChanged<String> onChanged;

  const FiltrosCuentaSitio({
    super.key,
    required this.filtroSeleccionado,
    required this.onChanged,
  });

  static const List<String> filtros = [
    'Todos',
    'Con cuenta',
    'Sin cuenta',
    'Activas',
    'Inactivas',
  ];

  Color _colorFiltro(String filtro) {
    switch (filtro) {
      case 'Todos':
        return AppColors.secondary;
      case 'Con cuenta':
        return AppColors.success;
      case 'Sin cuenta':
        return AppColors.secondary;
      case 'Activas':
        return AppColors.success;
      case 'Inactivas':
        return AppColors.error;
      default:
        return AppColors.coffeeLight;
    }
  }

  IconData _iconoFiltro(String filtro) {
    switch (filtro) {
      case 'Todos':
        return Icons.grid_view_rounded;
      case 'Con cuenta':
        return Icons.person_outline_rounded;
      case 'Sin cuenta':
        return Icons.person_add_alt_1_rounded;
      case 'Activas':
        return Icons.check_circle_outline_rounded;
      case 'Inactivas':
        return Icons.block_rounded;
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
            final color = _colorFiltro(filtro);

            return Padding(
              padding: const EdgeInsets.only(
                right: AppDimensions.spacingSm,
              ),
              child: ChoiceChip(
                avatar: Icon(
                  _iconoFiltro(filtro),
                  size: AppDimensions.iconSm,
                  color: color,
                ),
                label: Text(filtro),
                selected: seleccionado,
                onSelected: (_) => onChanged(filtro),
                showCheckmark: false,
                backgroundColor: AppColors.surface,
                selectedColor: color.withValues(alpha: 0.12),
                side: BorderSide(
                  color: seleccionado
                      ? color.withValues(alpha: 0.45)
                      : AppColors.coffeeLight.withValues(alpha: 0.55),
                  width: seleccionado ? 1.2 : 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.chipRadius,
                  ),
                ),
                labelStyle: TextStyle(
                  color: seleccionado
                      ? color
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingSm,
                  vertical: AppDimensions.spacingXs,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
