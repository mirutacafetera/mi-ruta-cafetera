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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
        border: Border.all(
          color: AppColors.borderDark,
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.cream,
            child: Icon(
              Icons.admin_panel_settings,
              size: 52,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          Text(
            nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingSm,
          ),
          Text(
            correo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
            child: Text(
              rol,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}