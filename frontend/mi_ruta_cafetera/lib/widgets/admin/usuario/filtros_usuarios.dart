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

  static const Color _bordeCafe = Color(0xFFB58A70);

  static const List<Map<String, dynamic>> _filtros = [
    {
      'texto': 'Todos',
      'valor': 'todos',
      'icono': Icons.groups_rounded,
      'color': AppColors.secondary,
    },
    {
      'texto': 'Activos',
      'valor': 'activos',
      'icono': Icons.check_circle_rounded,
      'color': AppColors.success,
    },
    {
      'texto': 'Inactivos',
      'valor': 'inactivos',
      'icono': Icons.pause_circle_filled_rounded,
      'color': AppColors.warning,
    },
    {
      'texto': 'Eliminados',
      'valor': 'eliminados',
      'icono': Icons.delete_rounded,
      'color': AppColors.error,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _filtros.map((filtro) {
            return Padding(
              padding: const EdgeInsets.only(
                right: AppDimensions.spacingSm,
              ),
              child: _construirFiltro(
                texto: filtro['texto'] as String,
                valor: filtro['valor'] as String,
                icono: filtro['icono'] as IconData,
                colorIcono: filtro['color'] as Color,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _construirFiltro({
    required String texto,
    required String valor,
    required IconData icono,
    required Color colorIcono,
  }) {
    final seleccionado = filtroSeleccionado == valor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: seleccionado ? AppColors.primary : AppColors.creamLight,
        borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
        border: Border.all(
          color: seleccionado ? AppColors.primary : _bordeCafe,
          width: seleccionado ? 1.5 : 1.2,
        ),
        boxShadow: seleccionado
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
          borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
          onTap: () {
            if (!seleccionado) {
              onFiltroSeleccionado(valor);
            }
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
                  color: seleccionado ? AppColors.white : colorIcono,
                ),
                const SizedBox(width: 7),
                Text(
                  texto,
                  style: TextStyle(
                    color: seleccionado
                        ? AppColors.white
                        : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (seleccionado) ...[
                  const SizedBox(width: 5),
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
    );
  }
}