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
    return TextField(
      controller: controller,
      obscureText: !visible,
      style: const TextStyle(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppColors.secondary,
        ),
        suffixIcon: IconButton(
          onPressed: onCambiarVisibilidad,
          icon: Icon(
            visible
                ? Icons.visibility_off
                : Icons.visibility,
            color: AppColors.textSecondary,
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMd,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMd,
          ),
          borderSide: const BorderSide(
            color: AppColors.borderDark,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMd,
          ),
          borderSide: const BorderSide(
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }
}