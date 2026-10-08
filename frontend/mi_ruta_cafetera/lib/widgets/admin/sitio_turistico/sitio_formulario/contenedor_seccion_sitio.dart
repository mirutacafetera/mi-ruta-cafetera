import 'package:flutter/material.dart';

import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_dimensions.dart';

class ContenedorSeccionSitio extends StatelessWidget {
  final Widget contenido;

  const ContenedorSeccionSitio({
    super.key,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingLg,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.borderDark,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXxl,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(
              alpha: 0.10,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: contenido,
    );
  }
}