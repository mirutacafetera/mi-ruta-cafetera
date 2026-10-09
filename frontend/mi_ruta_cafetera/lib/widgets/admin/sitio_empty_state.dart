import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class SitioEmptyState extends StatelessWidget {
  final bool buscando;
  final VoidCallback onRegistrar;

  const SitioEmptyState({
    super.key,
    required this.buscando,
    required this.onRegistrar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingSection,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ==================================================
            // ICONO
            // ==================================================

            const Icon(
              Icons.location_off_outlined,
              size: 70,
              color: AppColors.textLight,
            ),

            const SizedBox(
              height: AppDimensions.spacingLg,
            ),

            // ==================================================
            // TÍTULO
            // ==================================================

            Text(
              buscando
                  ? 'No se encontraron sitios'
                  : 'No hay sitios registrados',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: AppDimensions.spacingSm,
            ),

            // ==================================================
            // DESCRIPCIÓN
            // ==================================================

            Text(
              buscando
                  ? 'Prueba con otro nombre, ciudad, dirección o categoría.'
                  : 'Puedes registrar el primer sitio turístico.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),

            // ==================================================
            // REGISTRAR SITIO
            // ==================================================

            if (!buscando) ...[
              const SizedBox(
                height: AppDimensions.spacingXl,
              ),
              FilledButton.icon(
                onPressed: onRegistrar,
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  'Registrar sitio',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}