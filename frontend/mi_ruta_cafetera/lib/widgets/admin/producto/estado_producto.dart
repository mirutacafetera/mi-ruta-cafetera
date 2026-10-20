
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class EstadoProducto extends StatelessWidget {
  final String estado;

  const EstadoProducto({
    super.key,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    final String texto;
    final Color color;

    switch (estado) {
      case 'pendiente_revision':
        texto = 'Pendiente de revisión';
        color = Colors.orange;
        break;

      case 'aprobado':
        texto = 'Aprobado';
        color = Colors.green;
        break;

      case 'rechazado':
        texto = 'Rechazado';
        color = Colors.red;
        break;

      case 'borrador':
        texto = 'Borrador';
        color = AppColors.textSecondary;
        break;

      case 'activo':
        texto = 'Activo';
        color = Colors.green;
        break;

      case 'inactivo':
        texto = 'Inactivo';
        color = Colors.red;
        break;

      default:
        texto = estado;
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
