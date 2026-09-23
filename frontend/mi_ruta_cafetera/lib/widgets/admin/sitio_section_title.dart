import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class SitioSectionTitle extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;

  const SitioSectionTitle({
    super.key,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spacingLg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd + 1,
              ),
            ),
            child: Icon(
              icono,
              color: AppColors.primary,
              size: 22,
            ),
          ),

          const SizedBox(
            width: AppDimensions.spacingMd,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),

                const SizedBox(
                  height: AppDimensions.spacingXs - 1,
                ),

                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}