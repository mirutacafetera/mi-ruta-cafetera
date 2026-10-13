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
                label: Text(filtro),
                selected: seleccionado,
                onSelected: (_) => onChanged(filtro),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: seleccionado
                      ? Colors.white
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: seleccionado
                      ? AppColors.primary
                      : AppColors.textSecondary.withValues(alpha: 0.3),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}