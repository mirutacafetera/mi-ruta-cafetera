import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class SitioCardImagen extends StatelessWidget {
  final String? imagen;

  const SitioCardImagen({
    super.key,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    if (imagen == null || imagen!.isEmpty) {
      return Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.place_outlined,
          size: 42,
          color: AppColors.primary,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imagen!,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return Container(
            width: 90,
            height: 90,
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