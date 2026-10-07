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
          foregroundColor: AppColors.secondary,
          side: const BorderSide(
            color: AppColors.secondary,
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