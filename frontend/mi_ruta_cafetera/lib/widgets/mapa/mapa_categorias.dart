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

  IconData _obtenerIcono(CategoriaModel categoria) {
    final nombre = _normalizar(categoria.nombre);

    if (nombre.contains('cafe') ||
        nombre.contains('experiencias cafeteras')) {
      return Icons.coffee_outlined;
    }

    if (nombre.contains('naturaleza') ||
        nombre.contains('ecoturismo')) {
      return Icons.forest_outlined;
    }

    if (nombre.contains('miradores') ||
        nombre.contains('paisajes')) {
      return Icons.landscape_outlined;
    }

    if (nombre.contains('gastronomia')) {
      return Icons.restaurant_outlined;
    }

    if (nombre.contains('cultura') ||
        nombre.contains('historia')) {
      return Icons.account_balance_outlined;
    }

    if (nombre.contains('artesanias') ||
        nombre.contains('productos locales')) {
      return Icons.storefront_outlined;
    }

    if (nombre.contains('aventuras')) {
      return Icons.hiking_outlined;
    }

    if (nombre.contains('alojamiento')) {
      return Icons.hotel_outlined;
    }

    if (nombre.contains('experiencias familiares')) {
      return Icons.family_restroom_outlined;
    }

    return Icons.category_outlined;
  }

  String _normalizar(String texto) {
    return texto
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
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