import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

class EtiquetaSitio extends StatelessWidget {
  final String texto;
  final IconData icono;
  final bool esCategoria;

  const EtiquetaSitio({
    super.key,
    required this.texto,
    required this.icono,
    this.esCategoria = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = esCategoria
        ? AppColors.secondary
        : AppColors.coffeeLight;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.adminBorder.withValues(alpha: 0.45),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static Widget estado({required bool activo}) {
    final color = activo
        ? const Color(0xFF267447)
        : AppColors.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
          width: 0.8,
        ),
      ),
      child: Text(
        activo ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}