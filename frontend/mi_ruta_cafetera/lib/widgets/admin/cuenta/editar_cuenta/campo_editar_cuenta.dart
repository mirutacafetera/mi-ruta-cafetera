import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class CampoEditarCuenta extends StatelessWidget {
  final TextEditingController controller;
  final String etiqueta;
  final IconData icono;
  final TextInputType? tipoTeclado;
  final bool soloLectura;

  const CampoEditarCuenta({
    super.key,
    required this.controller,
    required this.etiqueta,
    required this.icono,
    this.tipoTeclado,
    this.soloLectura = false,
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
      readOnly: soloLectura,
      keyboardType: tipoTeclado,
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
        prefixIcon: Icon(
          icono,
          color: AppColors.secondary,
          size: 21,
        ),
        filled: true,
        fillColor: soloLectura
            ? AppColors.cream
            : AppColors.creamLight,
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