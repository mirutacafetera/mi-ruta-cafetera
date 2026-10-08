import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class CampoFormularioSitio extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icono;
  final int maxLines;
  final bool obligatorio;
  final bool habilitado;
  final TextInputType? keyboardType;

  const CampoFormularioSitio({
    super.key,
    required this.controller,
    required this.label,
    required this.icono,
    this.maxLines = 1,
    this.obligatorio = false,
    this.habilitado = true,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: habilitado,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icono,
          color: AppColors.primary,
        ),
        filled: true,
        fillColor: habilitado
            ? AppColors.surface
            : AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMd,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMd,
          ),
          borderSide: BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMd,
          ),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
      validator: obligatorio
          ? (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Este campo es obligatorio';
              }

              return null;
            }
          : null,
    );
  }
}