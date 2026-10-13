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

  static const List<Map<String, String>> estados = [
    {'valor': 'todos', 'titulo': 'Todos'},
    {'valor': 'pendiente', 'titulo': 'Pendientes'},
    {'valor': 'en_revision', 'titulo': 'En revisión'},
    {'valor': 'resuelto', 'titulo': 'Resueltos'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: estados.map((estado) {
          final seleccionadoActual =
              seleccionado == estado['valor'];

          return Padding(
            padding: const EdgeInsets.only(
              right: AppDimensions.spacingSm,
            ),
            child: ChoiceChip(
              label: Text(estado['titulo']!),
              selected: seleccionadoActual,
              onSelected: (_) {
                onChanged(estado['valor']!);
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: seleccionadoActual
                    ? AppColors.primary
                    : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.chipRadius,
                ),
              ),
              labelStyle: TextStyle(
                color: seleccionadoActual
                    ? AppColors.white
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}