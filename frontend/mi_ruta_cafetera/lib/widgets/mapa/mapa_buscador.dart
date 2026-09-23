import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class MapaBuscador extends StatelessWidget {
  final TextEditingController controller;
  final List<SitioTuristicoModel> resultados;
  final ValueChanged<String> onChanged;
  final ValueChanged<SitioTuristicoModel> onSeleccionar;
  final VoidCallback onLimpiar;

  const MapaBuscador({
    super.key,
    required this.controller,
    required this.resultados,
    required this.onChanged,
    required this.onSeleccionar,
    required this.onLimpiar,
  });

  @override
  Widget build(BuildContext context) {
    final mostrarResultados =
        controller.text.trim().isNotEmpty &&
        resultados.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          // =====================================================
          // CAMPO DE BÚSQUEDA
          // =====================================================

          Container(
            height: AppDimensions.buttonHeightLarge,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusLg,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(
                    alpha: 0.18,
                  ),
                  blurRadius: AppDimensions.elevationFloating * 2,
                  offset: const Offset(
                    0,
                    3,
                  ),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar sitio turístico...',
                hintStyle: const TextStyle(
                  color: AppColors.textLight,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.secondary,
                  size: AppDimensions.iconLg,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: onLimpiar,
                        icon: const Icon(
                          Icons.close,
                        ),
                        tooltip: 'Limpiar búsqueda',
                        color: AppColors.textSecondary,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingMd,
                ),
              ),
            ),
          ),

          // =====================================================
          // RESULTADOS
          // =====================================================

          if (mostrarResultados) ...[
            const SizedBox(
              height: AppDimensions.spacingXs +
                  AppDimensions.spacingXs / 2,
            ),

            Container(
              constraints: const BoxConstraints(
                maxHeight: 260,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(
                      alpha: 0.18,
                    ),
                    blurRadius:
                        AppDimensions.elevationFloating * 2,
                    offset: const Offset(
                      0,
                      3,
                    ),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacingXs +
                      AppDimensions.spacingXs / 2,
                ),
                itemCount: resultados.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: AppColors.divider,
                ),
                itemBuilder: (context, index) {
                  final sitio = resultados[index];

                  return ListTile(
                    dense: true,

                    // =================================================
                    // ICONO DEL RESULTADO
                    // =================================================

                    leading: const CircleAvatar(
                      backgroundColor: AppColors.cream,
                      child: Icon(
                        Icons.location_on_outlined,
                        color: AppColors.secondary,
                        size: AppDimensions.iconMd,
                      ),
                    ),

                    // =================================================
                    // NOMBRE DEL SITIO
                    // =================================================

                    title: Text(
                      sitio.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // =================================================
                    // CATEGORÍA
                    // =================================================

                    subtitle:
                        sitio.categoriaNombre.isNotEmpty
                            ? Text(
                                sitio.categoriaNombre,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color:
                                      AppColors.textSecondary,
                                ),
                              )
                            : null,

                    // =================================================
                    // SELECCIÓN
                    // =================================================

                    onTap: () {
                      onSeleccionar(sitio);
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}