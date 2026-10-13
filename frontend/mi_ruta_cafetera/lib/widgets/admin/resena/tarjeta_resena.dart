import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';
import '../../../../models/admin/resena_admin.dart';

class TarjetaResena extends StatelessWidget {
  final ResenaAdmin resena;
  final VoidCallback onCambiarEstado;
  final VoidCallback onEliminar;

  const TarjetaResena({
    super.key,
    required this.resena,
    required this.onCambiarEstado,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingXs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Text(
                    resena.usuario,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (opcion) {
                    if (opcion == 'estado') onCambiarEstado();
                    if (opcion == 'eliminar') onEliminar();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'estado',
                      child: Text(
                        resena.activo ? 'Desactivar' : 'Activar',
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              resena.sitio,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < resena.calificacion
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: AppColors.secondary,
                  size: AppDimensions.iconMd,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              resena.comentario,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Row(
              children: [
                Icon(
                  resena.activo
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  size: AppDimensions.iconSm,
                  color: resena.activo
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                Text(
                  resena.activo ? 'Activa' : 'Inactiva',
                  style: TextStyle(
                    color: resena.activo
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (resena.fecha != null)
                  Text(
                    '${resena.fecha!.day.toString().padLeft(2, '0')}/'
                    '${resena.fecha!.month.toString().padLeft(2, '0')}/'
                    '${resena.fecha!.year}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}