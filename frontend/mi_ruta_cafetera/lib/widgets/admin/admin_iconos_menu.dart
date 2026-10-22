import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class AdminIconoMenu extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String opcion;
  final String opcionSeleccionada;
  final Function(String) onOpcionSeleccionada;

  const AdminIconoMenu({
    super.key,
    required this.icon,
    required this.titulo,
    required this.opcion,
    required this.opcionSeleccionada,
    required this.onOpcionSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    final bool seleccionado = opcion == opcionSeleccionada;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
        ),
        leading: Icon(
          icon,
          size: AppDimensions.iconMd,
          color: AppColors.primary,
        ),
        title: Text(
          titulo,
          style: TextStyle(
            fontSize: 14,
            fontWeight: seleccionado
                ? FontWeight.w700
                : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: seleccionado
            ? Container(
                width: 4,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
              )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMd,
          ),
        ),
        onTap: () {
          onOpcionSeleccionada(opcion);
          Navigator.pop(context);
        },
      ),
    );
  }
}