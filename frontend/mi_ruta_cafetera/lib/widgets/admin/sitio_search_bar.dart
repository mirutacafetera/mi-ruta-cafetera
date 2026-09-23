import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class SitioSearchBar extends StatelessWidget {
  final String valor;
  final ValueChanged<String> onChanged;
  final VoidCallback onLimpiar;

  const SitioSearchBar({
    super.key,
    required this.valor,
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
          hintText: 'Buscar por nombre, ciudad, dirección o categoría...',
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.primary,
          ),
          suffixIcon: valor.isNotEmpty
              ? IconButton(
                  onPressed: onLimpiar,
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMd,
            ),
          ),
        ),
      ),
    );
  }
}