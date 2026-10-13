
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class FiltrosUsuarios extends StatelessWidget {
  final String filtroSeleccionado;
  final ValueChanged<String> onFiltroSeleccionado;

  const FiltrosUsuarios({
    super.key,
    required this.filtroSeleccionado,
    required this.onFiltroSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
      ),
      child: Wrap(
        spacing: AppDimensions.spacingSm,
        runSpacing: AppDimensions.spacingSm,
        children: [
          _construirFiltro(
            texto: 'Todos',
            valor: 'todos',
          ),
          _construirFiltro(
            texto: 'Activos',
            valor: 'activos',
          ),
          _construirFiltro(
            texto: 'Inactivos',
            valor: 'inactivos',
          ),
        ],
      ),
    );
  }

  Widget _construirFiltro({
    required String texto,
    required String valor,
  }) {
    final seleccionado = filtroSeleccionado == valor;

    return FilterChip(
      label: Text(texto),
      selected: seleccionado,
      onSelected: (_) => onFiltroSeleccionado(valor),
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.white,
      labelStyle: TextStyle(
        color: seleccionado
            ? AppColors.white
            : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: seleccionado
            ? AppColors.primary
            : AppColors.border,
      ),
    );
  }
}
