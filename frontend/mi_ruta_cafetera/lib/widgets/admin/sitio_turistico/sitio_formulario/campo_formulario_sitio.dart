import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class CampoFormularioSitio extends StatefulWidget {
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
  State<CampoFormularioSitio> createState() =>
      _CampoFormularioSitioState();
}

class _CampoFormularioSitioState
    extends State<CampoFormularioSitio> {
  late bool _ocultarTexto;

  @override
  void initState() {
    super.initState();
    _ocultarTexto = widget.ocultarTexto;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      child: TextFormField(
        controller: widget.controlador,
        maxLines: _ocultarTexto ? 1 : widget.maxLines,
        keyboardType: widget.tipoTeclado,
        obscureText: _ocultarTexto,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: widget.etiqueta,

          // La etiqueta permanece dentro del campo.
          floatingLabelBehavior: FloatingLabelBehavior.never,

          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),

          floatingLabelStyle: const TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),

          filled: true,
          fillColor: AppColors.creamLight,

          prefixIcon: widget.icono != null
              ? Icon(
                  widget.icono,
                  color: AppColors.secondary,
                  size: AppDimensions.iconMd,
                )
              : null,

          suffixIcon: widget.ocultarTexto
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _ocultarTexto = !_ocultarTexto;
                    });
                  },
                  icon: Icon(
                    _ocultarTexto
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.secondary,
                  ),
                )
              : null,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingLg,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.searchRadius,
            ),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.searchRadius,
            ),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.searchRadius,
            ),
            borderSide: const BorderSide(
              color: AppColors.secondary,
              width: 2,
            ),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.searchRadius,
            ),
            borderSide: const BorderSide(
              color: AppColors.error,
            ),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.searchRadius,
            ),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
        ),

        validator: widget.obligatorio
            ? (valor) {
                if (valor == null ||
                    valor.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }

                return null;
              }
            : null,
      ),
    );
  }
}