
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class IndicadorEscribiendo extends StatelessWidget {
  const IndicadorEscribiendo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingSm,
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.circularButtonSmall,
            height: AppDimensions.circularButtonSmall,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: AppColors.primary,
              size: AppDimensions.iconMd,
            ),
          ),
          const SizedBox(
            width: AppDimensions.spacingSm,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingLg,
              vertical: AppDimensions.spacingMd,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusLg,
              ),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: AppDimensions.iconSm,
                  height: AppDimensions.iconSm,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(
                  width: AppDimensions.spacingSm,
                ),
                Text(
                  'El chatbot está escribiendo...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
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
