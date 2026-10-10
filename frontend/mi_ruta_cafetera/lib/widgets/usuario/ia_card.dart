import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// Tarjeta de entrada a "Mi Ruta Cafetera IA".
///
/// Ocupa, para usuarios con sesión, el lugar del banner
/// "Vive la experiencia completa".
class IaCard extends StatelessWidget {
  final VoidCallback onTap;

  const IaCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXxl,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            AppDimensions.spacingXl + 2,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.secondary,
                AppColors.coffeeLight,
              ],
            ),
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusXxl,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(
                  alpha: 0.20,
                ),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.white,
                          size: AppDimensions.iconMd,
                        ),
                        SizedBox(
                          width: AppDimensions.spacingSm,
                        ),
                        Expanded(
                          child: Text(
                            'Mi Ruta Cafetera IA',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingSm,
                    ),
                    Text(
                      'Te recomiendo lugares y experiencias '
                      'reales del Huila según tu ubicación, '
                      'la hora y el clima.',
                      style: TextStyle(
                        color: AppColors.white.withValues(
                          alpha: 0.88,
                        ),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingMd + 4,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal:
                            AppDimensions.spacingMd + 2,
                        vertical: AppDimensions.spacingSm + 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(
                          alpha: 0.16,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusPill,
                        ),
                        border: Border.all(
                          color: AppColors.white.withValues(
                            alpha: 0.70,
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_cafe_rounded,
                            color: AppColors.white,
                            size: AppDimensions.iconSm,
                          ),
                          SizedBox(
                            width: AppDimensions.spacingSm,
                          ),
                          Text(
                            'Recomiéndame algo',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}