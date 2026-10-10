import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class IndicadoresCarrusel extends StatelessWidget {
  final int actual;
  final int total;
  final ValueChanged<int> onTap;

  const IndicadoresCarrusel({
    super.key,
    required this.actual,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final activo = index == actual;

        return GestureDetector(
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingXs,
            ),
            width: activo ? 28 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: activo
                  ? AppColors.secondary
                  : AppColors.white.withValues(
                      alpha: 0.45,
                    ),
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusPill,
              ),
            ),
          ),
        );
      }),
    );
  }
}