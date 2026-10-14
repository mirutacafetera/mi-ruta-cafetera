
import 'package:flutter/material.dart';

import '../../../../models/sitio_turistico_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class DetalleUbicacion extends StatelessWidget {
  const DetalleUbicacion({
    super.key,
    required this.sitio,
    required this.onVerMapa,
  });

  final SitioTuristicoModel sitio;
  final VoidCallback onVerMapa;

  @override
  Widget build(BuildContext context) {
    final direccion = sitio.direccion.trim();
    final ciudad = sitio.ciudad.trim();
    final departamento = sitio.departamento.trim();
    final theme = Theme.of(context);

    final ubicacion = [
      if (direccion.isNotEmpty) direccion,
      if (ciudad.isNotEmpty) ciudad,
      if (departamento.isNotEmpty) departamento,
    ].join(', ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubicación',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                    top: AppDimensions.spacingXs,
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.secondary,
                    size: AppDimensions.iconLg,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Text(
                    ubicacion.isNotEmpty
                        ? ubicacion
                        : 'Ubicación no disponible',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onVerMapa,
                icon: const Icon(Icons.map_outlined),
                label: const Text(
                  'Ver ubicación en el mapa',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}