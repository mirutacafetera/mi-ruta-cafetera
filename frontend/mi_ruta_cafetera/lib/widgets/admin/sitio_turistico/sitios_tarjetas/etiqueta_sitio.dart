import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class EtiquetaSitio extends StatelessWidget {
  final String texto;
  final IconData icono;
  final bool? activo;

  const EtiquetaSitio({
    super.key,
    required this.texto,
    required this.icono,
    this.activo,
  });

  const EtiquetaSitio.estado({
    super.key,
    required bool activo,
  }) : texto = activo ? 'Activo' : 'Inactivo',
       icono = Icons.circle,
       activo = activo;

  @override
  Widget build(BuildContext context) {
    final esEstado = activo != null;

    final colorFondo = esEstado
        ? activo!
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.error.withValues(alpha: 0.12)
        : AppColors.divider;

    final colorTexto = esEstado
        ? activo!
            ? AppColors.success
            : AppColors.error
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(
          AppDimensions.chipRadius,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: AppDimensions.iconSm,
            color: colorTexto,
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
              color: colorTexto,
            ),
          ),
        ],
      ),
    );
  }
}