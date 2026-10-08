import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class EstadoResenasSitio extends StatelessWidget {
  const EstadoResenasSitio({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rate_review_outlined,
              color: AppColors.primary,
              size: AppDimensions.iconLg,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          Text(
            'Todavía no hay reseñas',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(
            height: AppDimensions.spacingXs,
          ),
          Text(
            'Las opiniones de los visitantes aparecerán aquí.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}