
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class TarjetaCategoria extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final int cantidadSitios;
  final bool activa;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const TarjetaCategoria({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.cantidadSitios,
    required this.activa,
    required this.icono,
    required this.color,
    required this.onTap,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppColors.creamLight,
      elevation: AppDimensions.elevationNone,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.categoryRadius,
        ),
        side: const BorderSide(
          color: AppColors.adminBorder,
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withValues(alpha: 0.13),
                child: Icon(
                  icono,
                  color: color,
                  size: AppDimensions.categoryIconLarge,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      descripcion.isEmpty
                          ? 'Explora esta categoría'
                          : descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.chipRadius,
                        ),
                      ),
                      child: Text(
                        '$cantidadSitios '
                        '${cantidadSitios == 1 ? 'sitio' : 'sitios'}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spacingXs),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: activa
                          ? AppColors.success.withValues(alpha: 0.10)
                          : AppColors.error.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.chipRadius,
                      ),
                    ),
                    child: Text(
                      activa ? 'Activa' : 'Inactiva',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: activa
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    tooltip: 'Opciones',
                    onSelected: (opcion) {
                      if (opcion == 'editar') onEditar();
                      if (opcion == 'eliminar') onEliminar();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
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
                            const SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: const Padding(
                      padding: EdgeInsets.all(AppDimensions.spacingXs),
                      child: Icon(
                        Icons.more_vert,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
