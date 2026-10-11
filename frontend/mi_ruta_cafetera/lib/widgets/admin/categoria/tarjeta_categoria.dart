
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
    return Card(
      color: AppColors.surface,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppDimensions.spacingMd,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(
                  icono,
                  color: color,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion.isEmpty
                          ? 'Explora esta categoría'
                          : descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$cantidadSitios '
                        '${cantidadSitios == 1 ? 'sitio' : 'sitios'}',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
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
                          ? Colors.green.withValues(alpha: 0.10)
                          : AppColors.error.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      activa ? 'Activa' : 'Inactiva',
                      style: TextStyle(
                        color: activa ? Colors.green : AppColors.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
                    itemBuilder: (_) => const [
                      PopupMenuItem(
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
                            SizedBox(width: 8),
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
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
