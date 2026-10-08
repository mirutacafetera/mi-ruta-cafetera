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
    return TextField(
      controller: controller,
      readOnly: soloLectura,
      keyboardType: tipoTeclado,
      style: const TextStyle(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixIcon: Icon(
          icono,
          color: AppColors.secondary,
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