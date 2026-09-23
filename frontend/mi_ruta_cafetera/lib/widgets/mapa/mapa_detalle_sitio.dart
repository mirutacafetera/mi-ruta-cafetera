import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class MapaDetalleSitio extends StatelessWidget {
  final SitioTuristicoModel sitio;
  final VoidCallback onVerMapa;
  final VoidCallback onAgregarRuta;

  const MapaDetalleSitio({
    super.key,
    required this.sitio,
    required this.onVerMapa,
    required this.onAgregarRuta,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: AppDimensions.sheetInitialSize,
        minChildSize: AppDimensions.sheetMinSize,
        maxChildSize: AppDimensions.sheetMaxSize,
        builder: (
          context,
          scrollController,
        ) {
          return Material(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(
                AppDimensions.radiusXxl,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingXl,
                AppDimensions.spacingMd,
                AppDimensions.spacingXl,
                AppDimensions.spacingXxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =====================================================
                  // INDICADOR DEL BOTTOM SHEET
                  // =====================================================

                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSm,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingLg,
                  ),

                  // =====================================================
                  // NOMBRE DEL SITIO
                  // =====================================================

                  Text(
                    sitio.nombre,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  // =====================================================
                  // CATEGORÍA
                  // =====================================================

                  if (sitio.categoriaNombre.isNotEmpty) ...[
                    const SizedBox(
                      height: AppDimensions.spacingSm,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: AppDimensions.iconSm,
                          color: AppColors.primary,
                        ),
                        const SizedBox(
                          width: AppDimensions.spacingXs + 3,
                        ),
                        Expanded(
                          child: Text(
                            sitio.categoriaNombre,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // =====================================================
                  // DESCRIPCIÓN
                  // =====================================================

                  if (sitio.descripcion.isNotEmpty) ...[
                    const SizedBox(
                      height: AppDimensions.spacingLg,
                    ),
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingXs + 3,
                    ),
                    Text(
                      sitio.descripcion,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],

                  // =====================================================
                  // UBICACIÓN
                  // =====================================================

                  const SizedBox(
                    height: AppDimensions.spacingLg,
                  ),

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(
                        width: AppDimensions.spacingSm,
                      ),
                      Expanded(
                        child: Text(
                          '${sitio.ciudad}, '
                          '${sitio.departamento}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // =====================================================
                  // DIRECCIÓN
                  // =====================================================

                  if (sitio.direccion.isNotEmpty) ...[
                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(
                          width: AppDimensions.spacingSm,
                        ),
                        Expanded(
                          child: Text(
                            sitio.direccion,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // =====================================================
                  // BOTÓN: VER EN EL MAPA
                  // =====================================================

                  const SizedBox(
                    height: AppDimensions.spacingXxl,
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onVerMapa,
                      icon: const Icon(
                        Icons.map_outlined,
                      ),
                      label: const Text(
                        'Ver en el mapa',
                      ),
                    ),
                  ),

                  // =====================================================
                  // BOTÓN: AGREGAR A MI RUTA
                  // =====================================================

                  const SizedBox(
                    height: AppDimensions.spacingSm + 2,
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onAgregarRuta,
                      icon: const Icon(
                        Icons.add_road,
                      ),
                      label: const Text(
                        'Agregar a mi ruta',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}