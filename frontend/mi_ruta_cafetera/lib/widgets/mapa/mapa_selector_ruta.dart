import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class MapaSelectorRuta extends StatelessWidget {
  final bool activo;
  final List<SitioTuristicoModel> sitiosSeleccionados;
  final VoidCallback onIniciar;
  final VoidCallback onCancelar;
  final VoidCallback onCalcular;

  const MapaSelectorRuta({
    super.key,
    required this.activo,
    required this.sitiosSeleccionados,
    required this.onIniciar,
    required this.onCancelar,
    required this.onCalcular,
  });

  @override
  Widget build(BuildContext context) {
    if (!activo) {
      return ElevatedButton.icon(
        onPressed: onIniciar,
        icon: const Icon(Icons.alt_route),
        label: const Text(
          'Crear mi ruta',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingMd + 3,
          ),
        ),
      );
    }

    final cantidad = sitiosSeleccionados.length;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.route,
                  color: AppColors.primary,
                ),
                const SizedBox(
                  width: AppDimensions.spacingSm,
                ),
                const Expanded(
                  child: Text(
                    'Crear mi ruta',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '$cantidad/4',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: AppDimensions.spacingSm,
            ),

            Text(
              cantidad == 0
                  ? 'Selecciona entre 2 y 4 sitios del mapa.'
                  : cantidad == 1
                      ? 'Selecciona al menos un sitio más.'
                      : '$cantidad sitios seleccionados.',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),

            if (sitiosSeleccionados.isNotEmpty) ...[
              const SizedBox(
                height: AppDimensions.spacingMd - 2,
              ),

              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sitiosSeleccionados.length,
                  separatorBuilder: (_, index) =>
                      const SizedBox(
                    width: AppDimensions.spacingXs + 2,
                  ),
                  itemBuilder: (context, index) {
                    final sitio = sitiosSeleccionados[index];

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingMd - 2,
                        vertical: AppDimensions.spacingXs + 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusPill,
                        ),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 11,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: AppDimensions.spacingXs + 2,
                          ),

                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 130,
                            ),
                            child: Text(
                              sitio.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(
              height: AppDimensions.spacingMd,
            ),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancelar,
                    child: const Text('Cancelar'),
                  ),
                ),

                const SizedBox(
                  width: AppDimensions.spacingSm,
                ),

                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: cantidad >= 2
                        ? onCalcular
                        : null,
                    icon: const Icon(Icons.route),
                    label: const Text(
                      'Calcular ruta',
                    ),
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