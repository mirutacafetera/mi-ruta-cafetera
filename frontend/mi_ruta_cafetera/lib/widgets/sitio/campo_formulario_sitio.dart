import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final List<TextInputFormatter>? inputFormatters;

  const CampoFormularioSitio({
    super.key,
    required this.controller,
    required this.label,
    required this.icono,
    this.maxLines = 1,
    this.obligatorio = false,
    this.habilitado = true,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final bordeNormal = OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        AppDimensions.sitioFormRadius,
      ),
      borderSide: const BorderSide(
        color: AppColors.sitioBorder,
        width: 1,
      ),
    );

    final bordeActivo = OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        AppDimensions.sitioFormRadius,
      ),
      borderSide: const BorderSide(
        color: AppColors.sitioPrimary,
        width: 1.6,
      ),
    );

    return TextFormField(
      controller: controller,
      enabled: habilitado,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: habilitado
            ? AppColors.sitioTextPrimary
            : AppColors.sitioTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      cursorColor: AppColors.sitioPrimary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.sitioTextSecondary,
          fontSize: 13,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.sitioPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icono,
          color: habilitado
              ? AppColors.sitioPrimary
              : AppColors.sitioTextSecondary,
          size: AppDimensions.sitioActionIconSize,
        ),
        filled: true,
        fillColor: habilitado
            ? AppColors.sitioSurface
            : AppColors.sitioSurfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 17,
        ),
        border: bordeNormal,
        enabledBorder: bordeNormal,
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.sitioDivider,
          ),
        ),
        focusedBorder: bordeActivo,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.sitioError,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.sitioError,
            width: 1.6,
          ),
        ),
        errorStyle: const TextStyle(
          color: AppColors.sitioError,
          fontSize: 12,
          height: 1.3,
        ),
      ),
      validator: obligatorio
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Este campo es obligatorio';
              }

              return null;
            }
          : null,
    );
  }
}