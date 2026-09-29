import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class CampoFormularioSitio extends StatelessWidget {
  final TextEditingController controlador;
  final String etiqueta;
  final IconData? icono;
  final int maxLines;
  final TextInputType? tipoTeclado;
  final bool obligatorio;
  final bool ocultarTexto;

  const CampoFormularioSitio({
    super.key,
    required this.controlador,
    required this.etiqueta,
    this.icono,
    this.maxLines = 1,
    this.tipoTeclado,
    this.obligatorio = false,
    this.ocultarTexto = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd + 2),
      child: TextFormField(
        controller: controlador,
        maxLines: ocultarTexto ? 1 : maxLines,
        keyboardType: tipoTeclado,
        obscureText: ocultarTexto,

        // ====================================================
        // TEXTO
        // ====================================================
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),

        // ====================================================
        // DECORACIÓN
        // ====================================================
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

          filled: true,
          fillColor: AppColors.surface,

          // ==================================================
          // ICONO
          // ==================================================
          prefixIcon: icono != null
              ? Icon(
                  icono,
                  color: AppColors.secondary,
                  size: AppDimensions.iconMd,
                )
              : null,

          // ==================================================
          // ESPACIADO INTERNO
          // ==================================================
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingLg,
          ),

          // ==================================================
          // BORDE NORMAL
          // ==================================================
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),

          // ==================================================
          // BORDE HABILITADO
          // ==================================================
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),

          // ==================================================
          // BORDE ENFOCADO
          // ==================================================
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),

          // ==================================================
          // BORDE DE ERROR
          // ==================================================
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.error),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),

        // ====================================================
        // VALIDACIÓN
        // ====================================================
        validator: obligatorio
            ? (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }

                return null;
              }
            : null,
      ),
    );
  }
}
