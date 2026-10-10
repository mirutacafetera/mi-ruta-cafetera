import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import 'sitio_badge.dart';
import 'sitio_card_imagen.dart';

class SitioCard extends StatelessWidget {
  final Map<String, dynamic> sitio;
  final String categoria;
  final bool activo;
  final String? imagen;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const SitioCard({
    super.key,
    required this.sitio,
    required this.categoria,
    required this.activo,
    required this.imagen,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final nombre =
        (sitio['nombre'] ?? 'Sin nombre').toString();

    final descripcion =
        (sitio['descripcion'] ?? 'Sin descripción').toString();

    final ciudad =
        (sitio['ciudad'] ?? '').toString();

    final direccion =
        (sitio['direccion'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      elevation: AppDimensions.elevationCard,
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingMd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // IMAGEN
            // ==================================================

            SitioCardImagen(
              imagen: imagen,
            ),

            const SizedBox(
              width: AppDimensions.spacingMd + 2,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============================================
                  // NOMBRE Y MENÚ
                  // ============================================

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          nombre,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      PopupMenuButton<String>(
                        onSelected: (opcion) {
                          if (opcion == 'editar') {
                            onEditar();
                          }

                          if (opcion == 'eliminar') {
                            onEliminar();
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem<String>(
                            value: 'editar',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.primary,
                                ),
                                SizedBox(
                                  width: AppDimensions.spacingSm + 2,
                                ),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'eliminar',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                ),
                                SizedBox(
                                  width: AppDimensions.spacingSm + 2,
                                ),
                                Text('Eliminar'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingXs + 1,
                  ),

                  // ============================================
                  // BADGES
                  // ============================================

                  Wrap(
                    spacing: AppDimensions.spacingXs + 2,
                    runSpacing: AppDimensions.spacingXs + 2,
                    children: [
                      SitioBadge(
                        texto: categoria,
                        icono: Icons.category_outlined,
                      ),

                      if (ciudad.isNotEmpty)
                        SitioBadge(
                          texto: ciudad,
                          icono: Icons.location_city_outlined,
                        ),

                      SitioBadge.estado(
                        activo: activo,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingSm,
                  ),

                  // ============================================
                  // DESCRIPCIÓN
                  // ============================================

                  Text(
                    descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  // ============================================
                  // DIRECCIÓN
                  // ============================================

                  if (direccion.isNotEmpty) ...[
                    const SizedBox(
                      height: AppDimensions.spacingSm,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: AppDimensions.iconSm,
                          color: AppColors.textSecondary,
                        ),

                        const SizedBox(
                          width: AppDimensions.spacingXs + 1,
                        ),

                        Expanded(
                          child: Text(
                            direccion,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}