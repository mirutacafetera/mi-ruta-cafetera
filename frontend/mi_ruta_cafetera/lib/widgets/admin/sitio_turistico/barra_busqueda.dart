import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class BarraBusqueda extends StatelessWidget {
  final String valor;
  final String textoAyuda;
  final ValueChanged<String> onChanged;
  final VoidCallback onLimpiar;
  final TextEditingController? controller;

  const BarraBusqueda({
    super.key,
    required this.valor,
    required this.textoAyuda,
    required this.onChanged,
    required this.onLimpiar,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final enfocada = FocusNode();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingLg,
        AppDimensions.spacingSm,
        AppDimensions.spacingLg,
        AppDimensions.spacingMd,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.creamLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFB58A70),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.coffeeDark.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          focusNode: enfocada,
          onChanged: onChanged,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: textoAyuda,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 5, right: 10),
              child: Container(
                margin: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 55,
              minHeight: 50,
            ),
            suffixIcon: valor.isNotEmpty
                ? IconButton(
                    tooltip: 'Limpiar búsqueda',
                    onPressed: onLimpiar,
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.secondary,
                        size: 17,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(
                      Icons.tune_rounded,
                      color: AppColors.coffeeLight.withValues(alpha: 0.8),
                      size: 21,
                    ),
                  ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}