import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../l10n/textos.dart';
import '../usuario/detalle_sitio/componentes_detalle.dart';

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
    final categoria = sitio.categoriaNombre.trim();
    final descripcion = sitio.descripcion.trim();
    final direccion = sitio.direccion.trim();
    final ciudad = sitio.ciudad.trim();
    final departamento = sitio.departamento.trim();

    final zona = [
      if (ciudad.isNotEmpty) ciudad,
      if (departamento.isNotEmpty) departamento,
    ].join(', ');

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
            color: AppColors.sitioBackground,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(
                AppDimensions.detalleContentRadius,
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
                  // Indicador del bottom sheet.
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.sitioBorder,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSm,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingLg),

                  // Nombre del sitio.
                  Semantics(
                    header: true,
                    child: Text(
                      sitio.nombre,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: AppColors.sitioTextPrimary,
                      ),
                    ),
                  ),

                  // Categoría.
                  if (categoria.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingMd),
                    EtiquetaDetalle(
                      texto: categoria,
                      icono: Icons.category_outlined,
                    ),
                  ],

                  // Descripción.
                  if (descripcion.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingLg),
                    const Tr(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.sitioPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Text(
                      descripcion,
                      style: const TextStyle(
                        color: AppColors.sitioTextSecondary,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],

                  // Ubicación.
                  if (zona.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingLg),
                    FilaDatoDetalle(
                      icono: Icons.location_on_outlined,
                      titulo: Textos.t('Ubicación'),
                      valor: zona,
                    ),
                  ],

                  // Dirección.
                  if (direccion.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingSm),
                    FilaDatoDetalle(
                      icono: Icons.place_outlined,
                      titulo: Textos.t('Dirección'),
                      valor: direccion,
                    ),
                  ],

                  const SizedBox(height: AppDimensions.spacingXxl),

                  // Botón: ver en el mapa.
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.detalleActionHeight,
                    child: ElevatedButton.icon(
                      onPressed: onVerMapa,
                      icon: const Icon(Icons.map_outlined),
                      label: const Tr('Ver en el mapa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sitioPrimary,
                        foregroundColor: AppColors.sitioTextOnPrimary,
                        elevation: AppDimensions.elevationButton,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusXxl,
                          ),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingSm),

                  // Botón: agregar a mi ruta.
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.detalleActionHeight,
                    child: OutlinedButton.icon(
                      onPressed: onAgregarRuta,
                      icon: const Icon(Icons.add_road),
                      label: const Tr('Agregar a mi ruta'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.sitioPrimary,
                        side: BorderSide(
                          color: AppColors.sitioPrimary.withValues(
                            alpha: 0.55,
                          ),
                          width: 1.3,
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
            ),
          );
        },
      ),
    );
  }
}
