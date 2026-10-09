import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class EtiquetaSitio extends StatelessWidget {
  final String texto;
  final IconData icono;
  final bool? activo;

  /// Indica si esta etiqueta representa una categoría.
  final bool esCategoria;

  const EtiquetaSitio({
    super.key,
    required this.texto,
    required this.icono,
    this.activo,
    this.esCategoria = false,
  });

  const EtiquetaSitio.estado({
    super.key,
    required bool activo,
  })  : texto = activo ? 'Activo' : 'Inactivo',
        icono = Icons.circle,
        activo = activo,
        esCategoria = false;

  @override
  Widget build(BuildContext context) {
    final esEstado = activo != null;

    // ==========================================================
    // COLORES
    // ==========================================================

    Color colorFondo;
    Color colorTexto;

    if (esEstado) {
      colorFondo = activo!
          ? AppColors.success.withValues(alpha: 0.12)
          : AppColors.error.withValues(alpha: 0.12);

      colorTexto = activo!
          ? AppColors.success
          : AppColors.error;
    } else if (esCategoria) {
      // La categoría obtiene automáticamente
      // su color oficial.
      colorTexto = AppColors.getColorForCategory(texto);

      colorFondo = AppColors.getSoftColorForCategory(texto);
    } else {
      colorFondo = AppColors.divider;
      colorTexto = AppColors.textSecondary;
    }

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
              fontWeight: esEstado || esCategoria
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