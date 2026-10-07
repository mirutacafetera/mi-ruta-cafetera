import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class ImagenTarjetaSitio extends StatelessWidget {
  final String? imagen;
  final String? categoria;

  const ImagenTarjetaSitio({
    super.key,
    required this.imagen,
    this.categoria,
  });

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // COLOR E ICONO DE LA CATEGORÍA
    // ==========================================================

    final colorCategoria =
        AppColors.getColorForCategory(categoria);

    final iconoCategoria =
        AppColors.getIconForCategory(categoria);

    final fondoCategoria =
        AppColors.getSoftColorForCategory(categoria);

    // ==========================================================
    // SIN IMAGEN
    // ==========================================================

    if (imagen == null || imagen!.isEmpty) {
      return Container(
        width: AppDimensions.categoryCardWidth,
        height: AppDimensions.categoryCardWidth,
        decoration: BoxDecoration(
          color: fondoCategoria,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMd,
          ),
          border: Border.all(
            color: AppColors.getBorderColorForCategory(
              categoria,
            ),
          ),
        ),
        child: Icon(
          iconoCategoria,
          size: AppDimensions.categoryIconLarge,
          color: colorCategoria,
        ),
      );
    }

    // ==========================================================
    // CON IMAGEN
    // ==========================================================

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusMd,
      ),
      child: Image.network(
        imagen!,
        width: AppDimensions.categoryCardWidth,
        height: AppDimensions.categoryCardWidth,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: AppDimensions.categoryCardWidth,
            height: AppDimensions.categoryCardWidth,
            decoration: BoxDecoration(
              color: fondoCategoria,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
              border: Border.all(
                color: AppColors.getBorderColorForCategory(
                  categoria,
                ),
              ),
            ),
            child: Icon(
              iconoCategoria,
              size: AppDimensions.categoryIconLarge,
              color: colorCategoria,
            ),
          );
        },
      ),
    );
  }
}