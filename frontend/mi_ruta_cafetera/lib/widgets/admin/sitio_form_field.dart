import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class SitioFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool obligatorio;
  final bool obscureText;

  const SitioFormField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.obligatorio = false,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd + 2,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: obscureText ? 1 : maxLines,
        keyboardType: keyboardType,
        obscureText: obscureText,

        // ====================================================
        // TEXTO
        // ====================================================

        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),

        // ====================================================
        // DECORACIÓN
        // ====================================================

        decoration: InputDecoration(
          labelText: label,

          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),

          floatingLabelStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),

          filled: true,
          fillColor: AppColors.surface,

          // --------------------------------------------------
          // ICONO
          // --------------------------------------------------

          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: AppColors.secondary,
                  size: AppDimensions.iconMd,
                )
              : null,

          // --------------------------------------------------
          // ESPACIADO INTERNO
          // --------------------------------------------------

          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingLg,
          ),

          // --------------------------------------------------
          // BORDE NORMAL
          // --------------------------------------------------

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMd,
            ),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),

          // --------------------------------------------------
          // BORDE HABILITADO
          // --------------------------------------------------

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMd,
            ),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),

          // --------------------------------------------------
          // BORDE ENFOCADO
          // --------------------------------------------------

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMd,
            ),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),

          // --------------------------------------------------
          // ERROR
          // --------------------------------------------------

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMd,
            ),
            borderSide: const BorderSide(
              color: AppColors.error,
            ),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMd,
            ),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
        ),

        // ====================================================
        // VALIDACIÓN
        // ====================================================

        validator: obligatorio
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }

                return null;
              }
            : null,
      ),
    );
  }
}