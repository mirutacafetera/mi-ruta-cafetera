import 'package:flutter/material.dart';

import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_dimensions.dart';

class BotonGuardarSitio extends StatelessWidget {
  final bool guardando;
  final bool edicion;
  final VoidCallback onPressed;

  const BotonGuardarSitio({
    super.key,
    required this.guardando,
    required this.edicion,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeightLarge,
      child: ElevatedButton.icon(
        onPressed: guardando ? null : onPressed,
        icon: guardando
            ? const SizedBox(
                width: AppDimensions.iconMd,
                height: AppDimensions.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Icon(
                Icons.save_rounded,
                size: AppDimensions.iconMd,
              ),
        label: Text(
          guardando
              ? 'Guardando...'
              : edicion
                  ? 'Guardar cambios'
                  : 'Crear sitio turístico',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(
            double.infinity,
            AppDimensions.buttonHeightLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusXl,
            ),
          ),
        ),
      ),
    );
  }
}