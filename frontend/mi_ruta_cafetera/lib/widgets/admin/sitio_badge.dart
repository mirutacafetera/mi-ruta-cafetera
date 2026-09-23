import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class SitioBadge extends StatelessWidget {
  final String texto;
  final IconData icono;
  final bool? activo;

  const SitioBadge({
    super.key,
    required this.texto,
    required this.icono,
    this.activo,
  });

  const SitioBadge.estado({
    super.key,
    required bool activo,
  })  : texto = activo ? 'Activo' : 'Inactivo',
        icono = Icons.circle,
        activo = activo;

  @override
  Widget build(BuildContext context) {
    final esEstado = activo != null;

    final backgroundColor = esEstado
        ? activo!
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.error.withValues(alpha: 0.12)
        : AppColors.divider;

    final textColor = esEstado
        ? activo!
            ? AppColors.success
            : AppColors.error
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXs + 1,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 14,
            color: textColor,
          ),

          const SizedBox(
            width: AppDimensions.spacingXs,
          ),

          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: esEstado
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}