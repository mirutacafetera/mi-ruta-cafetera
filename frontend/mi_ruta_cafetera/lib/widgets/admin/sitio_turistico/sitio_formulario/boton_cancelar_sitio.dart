import 'package:flutter/material.dart';

import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_dimensions.dart';

class BotonCancelarSitio extends StatelessWidget {
  final bool deshabilitado;
  final VoidCallback onPressed;

  const BotonCancelarSitio({
    super.key,
    required this.deshabilitado,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: OutlinedButton(
        onPressed: deshabilitado ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.secondary,
          disabledBackgroundColor: AppColors.white,
          disabledForegroundColor: AppColors.textLight,
          side: const BorderSide(
            color: AppColors.adminBorder,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusXl,
            ),
          ),
        ),
        child: const Text('Cancelar'),
      ),
    );
  }
}