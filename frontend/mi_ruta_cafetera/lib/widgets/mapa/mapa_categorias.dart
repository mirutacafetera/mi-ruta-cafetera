import 'package:flutter/material.dart';

import '../../models/categoria_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class MapaCategorias extends StatelessWidget {
  final List<CategoriaModel> categorias;
  final String? categoriaSeleccionada;
  final ValueChanged<String?> onCategoriaSeleccionada;

  const MapaCategorias({
    super.key,
    required this.categorias,
    required this.categoriaSeleccionada,
    required this.onCategoriaSeleccionada,
  });

  // Los iconos salen del mapeo central (AppColors), igual que en
  // el resto de la aplicación.
  IconData _obtenerIcono(CategoriaModel categoria) {
    return AppColors.getIconForCategory(categoria.nombre);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
        ),
        itemCount: categorias.length + 1,
        separatorBuilder: (context, index) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          // ==========================================================
          // OPCIÓN "TODAS"
          // ==========================================================

          if (index == 0) {
            final seleccionada =
                categoriaSeleccionada == null;

            return ChoiceChip(
              avatar: Icon(
                Icons.apps_outlined,
                size: 18,
                color: seleccionada
                    ? AppColors.white
                    : AppColors.textSecondary,
              ),
              label: const Text('Todas'),
              selected: seleccionada,
              onSelected: (_) {
                onCategoriaSeleccionada(null);
              },
              selectedColor: AppColors.primary,
              backgroundColor:
                  AppColors.surfaceVariant.withValues(
                alpha: 0.8,
              ),
              labelStyle: TextStyle(
                color: seleccionada
                    ? AppColors.white
                    : AppColors.textSecondary,
                fontWeight: seleccionada
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              side: BorderSide(
                color: seleccionada
                    ? AppColors.primary
                    : AppColors.border.withValues(
                        alpha: 0.5,
                      ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
              ),
            );
          }

          // ==========================================================
          // CATEGORÍAS
          // ==========================================================

          final categoria = categorias[index - 1];

          final seleccionada =
              categoria.id == categoriaSeleccionada;

          return ChoiceChip(
            avatar: Icon(
              _obtenerIcono(categoria),
              size: 18,
              color: seleccionada
                  ? AppColors.white
                  : AppColors.textSecondary,
            ),
            label: Text(categoria.nombre),
            selected: seleccionada,
            onSelected: (_) {
              onCategoriaSeleccionada(
                seleccionada ? null : categoria.id,
              );
            },
            selectedColor: AppColors.primary,
            backgroundColor:
                AppColors.surfaceVariant.withValues(
              alpha: 0.8,
            ),
            labelStyle: TextStyle(
              color: seleccionada
                  ? AppColors.white
                  : AppColors.textSecondary,
              fontWeight: seleccionada
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            side: BorderSide(
              color: seleccionada
                  ? AppColors.primary
                  : AppColors.border.withValues(
                      alpha: 0.5,
                    ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
          );
        },
      ),
    );
  }
}
