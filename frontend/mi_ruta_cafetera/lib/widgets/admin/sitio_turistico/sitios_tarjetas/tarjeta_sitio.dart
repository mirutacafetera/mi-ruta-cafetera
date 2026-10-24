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
  final VoidCallback? onTap;

  const TarjetaSitio({
    super.key,
    required this.sitio,
    required this.categoria,
    required this.activo,
    required this.imagen,
    required this.onEditar,
    required this.onEliminar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nombre = (sitio['nombre'] ?? 'Sin nombre').toString();
    final descripcion =
        (sitio['descripcion'] ?? 'Sin descripción').toString();
    final ciudad = (sitio['ciudad'] ?? '').toString();
    final direccion = (sitio['direccion'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      elevation: 0,
      color: AppColors.creamLight,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioCardRadius,
        ),
        side: const BorderSide(
          color: AppColors.adminBorder,
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioCardRadius,
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
                categoria: categoria,
              ),
              const SizedBox(
                width: AppDimensions.spacingMd,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            nombre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Opciones',
                          icon: const Icon(
                            Icons.more_vert,
                            color: AppColors.secondary,
                          ),
                          onSelected: (opcion) {
                            if (opcion == 'editar') onEditar();
                            if (opcion == 'eliminar') onEliminar();
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'editar',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'eliminar',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Eliminar'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingSm,
                    ),
                    Wrap(
                      spacing: AppDimensions.spacingXs,
                      runSpacing: AppDimensions.spacingXs,
                      children: [
                        EtiquetaSitio(
                          texto: categoria,
                          icono: AppColors.getIconForCategory(categoria),
                          esCategoria: true,
                        ),
                        if (ciudad.isNotEmpty)
                          EtiquetaSitio(
                            texto: ciudad,
                            icono: Icons.location_city_outlined,
                          ),
                        EtiquetaSitio.estado(activo: activo),
                      ],
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingSm,
                    ),
                    Text(
                      descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    if (direccion.isNotEmpty) ...[
                      const SizedBox(
                        height: AppDimensions.spacingSm,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: AppDimensions.iconSm,
                            color: AppColors.coffeeLight,
                          ),
                          const SizedBox(
                            width: AppDimensions.spacingXs,
                          ),
                          Expanded(
                            child: Text(
                              direccion,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.35,
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
      ),
    );
  }
}