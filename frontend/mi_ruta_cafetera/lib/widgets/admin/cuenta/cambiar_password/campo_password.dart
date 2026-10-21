import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class CampoPassword extends StatelessWidget {
  final TextEditingController controller;
  final String etiqueta;
  final bool visible;
  final VoidCallback onCambiarVisibilidad;

  const CampoPassword({
    super.key,
    required this.controller,
    required this.etiqueta,
    required this.visible,
    required this.onCambiarVisibilidad,
  });

  @override
  Widget build(BuildContext context) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusMd,
      ),
      borderSide: const BorderSide(
        color: Color(0xFFB58A70),
        width: 1.5,
      ),
    );

    return TextField(
      controller: controller,
      obscureText: !visible,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: etiqueta,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.secondary,
        ),
        suffixIcon: IconButton(
          onPressed: onCambiarVisibilidad,
          tooltip: visible
              ? 'Ocultar contraseña'
              : 'Mostrar contraseña',
          icon: Icon(
            visible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: AppColors.secondary,
          ),
        ),
        filled: true,
        fillColor: AppColors.creamLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingLg,
        ),
        border: borde,
        enabledBorder: borde,
        disabledBorder: borde,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMd,
          ),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.8,
          ),
        ),
      ),
    );
  }
}