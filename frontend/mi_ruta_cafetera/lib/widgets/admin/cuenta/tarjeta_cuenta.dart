import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class TarjetaCuenta extends StatelessWidget {
  final String nombre;
  final String correo;
  final String rol;

  const TarjetaCuenta({
    super.key,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXxl,
        ),
        border: Border.all(
          color: const Color(0xFFB58A70),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(
              alpha: 0.18,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF6F4328).withValues(
              alpha: 0.10,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white.withValues(
                alpha: 0.10,
              ),
              border: Border.all(
                color: AppColors.secondary,
                width: 2.5,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 48,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingLg,
          ),
          Text(
            nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingSm,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email_outlined,
                size: AppDimensions.iconSm,
                color: AppColors.secondary,
              ),
              const SizedBox(
                width: AppDimensions.spacingSm,
              ),
              Flexible(
                child: Text(
                  correo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textOnDarkSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppDimensions.spacingLg,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingLg,
              vertical: AppDimensions.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusPill,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  size: 17,
                  color: AppColors.white,
                ),
                const SizedBox(
                  width: AppDimensions.spacingSm,
                ),
                Text(
                  rol,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
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