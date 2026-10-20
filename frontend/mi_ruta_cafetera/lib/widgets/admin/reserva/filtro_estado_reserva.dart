import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

class FiltroEstadoReserva extends StatelessWidget {
  final String estadoSeleccionado;
  final ValueChanged<String> onChanged;

  const FiltroEstadoReserva({
    super.key,
    required this.estadoSeleccionado,
    required this.onChanged,
  });

  static const List<String> estados = [
    'Todas',
    'Pendiente',
    'Confirmada',
    'Rechazada',
    'Cancelada',
    'Completada',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: estados.map((estado) {
          final seleccionado = estadoSeleccionado == estado;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(estado),
              selected: seleccionado,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: seleccionado
                    ? Colors.white
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => onChanged(estado),
            ),
          );
        }).toList(),
      ),
    );
  }
}
