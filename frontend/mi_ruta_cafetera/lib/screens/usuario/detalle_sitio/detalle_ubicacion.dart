
import 'package:flutter/material.dart';

import '../../../../models/sitio_turistico_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';
import '../../../l10n/textos.dart';

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

    final ubicacion = [
      if (direccion.isNotEmpty) direccion,
      if (ciudad.isNotEmpty) ciudad,
      if (departamento.isNotEmpty) departamento,
    ].join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de ubicación.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.divider,
                  ),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.secondary,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tr(
                      'Cómo llegar',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Tr(
                      'Encuentra este destino',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.explore_outlined,
                color: AppColors.secondary,
                size: 23,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          // Dirección.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.place_rounded,
                  color: AppColors.secondary,
                  size: 23,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Text(
                    ubicacion.isNotEmpty
                        ? ubicacion
                        : Textos.t('Ubicación no disponible'),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          // Acción principal.
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onVerMapa,
              icon: const Icon(
                Icons.map_outlined,
                size: 21,
              ),
              label: const Tr(
                'Ver ubicación en el mapa',
                textAlign: TextAlign.center,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 1,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
