import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class SitioListHeader extends StatelessWidget {
  final int cantidadSitios;
  final bool cargando;
  final VoidCallback onActualizar;
  final VoidCallback onNuevoSitio;

  const SitioListHeader({
    super.key,
    required this.cantidadSitios,
    required this.cargando,
    required this.onActualizar,
    required this.onNuevoSitio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingLg,
        AppDimensions.spacingLg,
        AppDimensions.spacingLg,
        AppDimensions.spacingSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sitios turísticos',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(
                  height: AppDimensions.spacingXs,
                ),

                Text(
                  '$cantidadSitios sitios registrados',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Actualizar',
            onPressed: cargando ? null : onActualizar,
            icon: const Icon(
              Icons.refresh,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(
            width: AppDimensions.spacingXs,
          ),

          FilledButton.icon(
            onPressed: onNuevoSitio,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo sitio'),
          ),
        ],
      ),
    );
  }
}