import 'package:flutter/material.dart';

import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_dimensions.dart';

class ContenedorSeccionSitio extends StatelessWidget {
  final Widget contenido;

  const ContenedorSeccionSitio({super.key, required this.contenido});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      // Espacio por fuera del contenedor
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingLg + 2),

      // Espacio por dentro del contenedor
      padding: const EdgeInsets.all(AppDimensions.spacingLg + 2),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: contenido,
    );
  }
}
