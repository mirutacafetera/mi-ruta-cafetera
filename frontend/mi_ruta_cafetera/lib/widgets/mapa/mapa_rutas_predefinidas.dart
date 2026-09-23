import 'package:flutter/material.dart';

import '../../data/rutas_predefinidas.dart';
import '../../models/ruta_predefinida_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class MapaRutasPredefinidas extends StatelessWidget {
  final ValueChanged<RutaPredefinidaModel> onSeleccionar;

  const MapaRutasPredefinidas({
    super.key,
    required this.onSeleccionar,
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
            child: Column(
              children: [
                // =====================================================
                // INDICADOR DEL BOTTOM SHEET
                // =====================================================

                const SizedBox(
                  height: AppDimensions.spacingMd,
                ),

                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusSm,
                    ),
                  ),
                ),

                const SizedBox(
                  height: AppDimensions.spacingLg +
                      AppDimensions.spacingXs / 2,
                ),

                // =====================================================
                // TÍTULO
                // =====================================================

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXl,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rutas predefinidas',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: AppDimensions.spacingXs + 2,
                ),

                // =====================================================
                // DESCRIPCIÓN
                // =====================================================

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXl,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Elige una experiencia para '
                      'explorar sus sitios.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: AppDimensions.spacingMd,
                ),

                // =====================================================
                // LISTA DE RUTAS
                // =====================================================

                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.spacingLg,
                      AppDimensions.spacingSm,
                      AppDimensions.spacingLg,
                      AppDimensions.spacingXxl,
                    ),
                    itemCount: RutasPredefinidas.todas.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final ruta =
                          RutasPredefinidas.todas[index];

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: AppDimensions.spacingMd,
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.all(
                            AppDimensions.spacingMd,
                          ),

                          // =================================================
                          // ICONO DE LA RUTA
                          // =================================================

                          leading: CircleAvatar(
                            radius: AppDimensions.spacingXl +
                                AppDimensions.spacingXs +
                                1,
                            backgroundColor:
                                ruta.color.withValues(
                              alpha: 0.15,
                            ),
                            child: Icon(
                              ruta.icono,
                              color: ruta.color,
                              size: AppDimensions.iconMd,
                            ),
                          ),

                          // =================================================
                          // NOMBRE
                          // =================================================

                          title: Text(
                            ruta.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          // =================================================
                          // DESCRIPCIÓN
                          // =================================================

                          subtitle: Padding(
                            padding: const EdgeInsets.only(
                              top: AppDimensions.spacingXs,
                            ),
                            child: Text(
                              ruta.descripcion,
                              style: const TextStyle(
                                color:
                                    AppColors.textSecondary,
                              ),
                            ),
                          ),

                          // =================================================
                          // INDICADOR
                          // =================================================

                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: AppDimensions.iconSm,
                            color: AppColors.textSecondary,
                          ),

                          // =================================================
                          // SELECCIÓN
                          // =================================================

                          onTap: () {
                            Navigator.pop(context);

                            onSeleccionar(ruta);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}