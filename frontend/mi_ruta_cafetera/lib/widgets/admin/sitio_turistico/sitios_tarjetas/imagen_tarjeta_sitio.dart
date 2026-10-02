import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class ImagenTarjetaSitio extends StatelessWidget {
  final String? imagen;

  const ImagenTarjetaSitio({
    super.key,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    if (imagen == null || imagen!.isEmpty) {
      return Container(
        width: AppDimensions.categoryCardWidth,
        height: AppDimensions.categoryCardWidth,
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMd,
          ),
        ),
        child: const Icon(
          Icons.place_outlined,
          size: 42,
          color: AppColors.primary,
        ),
      );
    }

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
            color: AppColors.cream,
            child: const Icon(
              Icons.broken_image_outlined,
              size: 38,
              color: AppColors.textLight,
            ),
          );
        },
      ),
    );
  }
}