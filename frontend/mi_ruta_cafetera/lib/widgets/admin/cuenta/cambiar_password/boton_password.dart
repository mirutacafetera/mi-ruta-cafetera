import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class BotonPassword extends StatelessWidget {
  final String texto;
  final IconData icono;
  final bool cargando;
  final VoidCallback? onPressed;

  const BotonPassword({
    super.key,
    required this.texto,
    required this.icono,
    required this.onPressed,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: cargando ? null : onPressed,
        icon: cargando
            ? const SizedBox(
                width: AppDimensions.iconMd,
                height: AppDimensions.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Icon(
                icono,
                size: AppDimensions.iconMd,
              ),
        label: Text(
          cargando ? 'Procesando...' : texto,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.primary.withValues(
            alpha: 0.6,
          ),
          disabledForegroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMd,
            ),
            side: const BorderSide(
              color: Color(0xFFB58A70),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}