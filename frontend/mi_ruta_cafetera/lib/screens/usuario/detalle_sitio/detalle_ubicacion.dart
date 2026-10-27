
import 'package:flutter/material.dart';

import '../../../../models/sitio_turistico_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';
import '../../../l10n/textos.dart';
import '../../../widgets/usuario/detalle_sitio/componentes_detalle.dart';

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
      decoration: decoracionTarjetaDetalle(
        radio: AppDimensions.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de ubicación.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: AppDimensions.sitioHeaderIconSize,
                height: AppDimensions.sitioHeaderIconSize,
                decoration: BoxDecoration(
                  color: AppColors.sitioSurfaceGreen,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLg,
                  ),
                  border: Border.all(
                    color: AppColors.sitioBorder,
                  ),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.sitioPrimary,
                  size: AppDimensions.iconLg,
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
                        color: AppColors.sitioTextPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Tr(
                      'Encuentra este destino',
                      style: TextStyle(
                        color: AppColors.sitioTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.explore_outlined,
                color: AppColors.sitioAccent,
                size: AppDimensions.iconLg,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          // Dirección.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.sitioSurfaceSoft,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.place_rounded,
                  color: AppColors.sitioAccent,
                  size: AppDimensions.iconMd,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Text(
                    ubicacion.isNotEmpty
                        ? ubicacion
                        : Textos.t('Ubicación no disponible'),
                    style: const TextStyle(
                      color: AppColors.sitioTextSecondary,
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
            height: AppDimensions.detalleActionHeight,
            child: ElevatedButton.icon(
              onPressed: onVerMapa,
              icon: const Icon(
                Icons.map_outlined,
                size: AppDimensions.iconMd,
              ),
              label: const Tr(
                'Ver ubicación en el mapa',
                textAlign: TextAlign.center,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sitioPrimary,
                foregroundColor: AppColors.sitioTextOnPrimary,
                elevation: AppDimensions.elevationButton,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusXxl,
                  ),
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
