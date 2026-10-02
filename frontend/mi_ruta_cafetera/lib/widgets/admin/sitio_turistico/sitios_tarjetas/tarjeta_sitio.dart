import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';
import 'etiqueta_sitio.dart';
import 'imagen_tarjeta_sitio.dart';

class TarjetaSitio extends StatelessWidget {
  final Map<String, dynamic> sitio;
  final String categoria;
  final bool activo;
  final String? imagen;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const TarjetaSitio({
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
    final nombre = (sitio['nombre'] ?? 'Sin nombre').toString();
    final descripcion =
        (sitio['descripcion'] ?? 'Sin descripción').toString();
    final ciudad = (sitio['ciudad'] ?? '').toString();
    final direccion = (sitio['direccion'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      elevation: AppDimensions.elevationCard,
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioCardRadius,
        ),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.sitioContentPadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImagenTarjetaSitio(
              imagen: imagen,
            ),
            const SizedBox(
              width: AppDimensions.spacingMd,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColors.textSecondary,
                        ),
                        onSelected: (opcion) {
                          if (opcion == 'editar') {
                            onEditar();
                          } else if (opcion == 'eliminar') {
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
                                  width: AppDimensions.spacingSm,
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
                                  width: AppDimensions.spacingSm,
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
                    height: AppDimensions.spacingXs,
                  ),
                  Wrap(
                    spacing: AppDimensions.spacingXs,
                    runSpacing: AppDimensions.spacingXs,
                    children: [
                      EtiquetaSitio(
                        texto: categoria,
                        icono: Icons.category_outlined,
                      ),
                      if (ciudad.isNotEmpty)
                        EtiquetaSitio(
                          texto: ciudad,
                          icono: Icons.location_city_outlined,
                        ),
                      EtiquetaSitio.estado(
                        activo: activo,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingSm,
                  ),
                  Text(
                    descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
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
                          width: AppDimensions.spacingXs,
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