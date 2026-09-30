import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class BarraBusqueda extends StatelessWidget {
  final String valor;
  final String textoAyuda;
  final ValueChanged<String> onChanged;
  final VoidCallback onLimpiar;

  const BarraBusqueda({
    super.key,
    required this.valor,
    required this.textoAyuda,
    required this.onChanged,
    required this.onLimpiar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingLg,
        AppDimensions.spacingXs,
        AppDimensions.spacingLg,
        AppDimensions.spacingMd,
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: textoAyuda,
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: valor.isNotEmpty
              ? IconButton(
                  onPressed: onLimpiar,
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
    );
  }
}
