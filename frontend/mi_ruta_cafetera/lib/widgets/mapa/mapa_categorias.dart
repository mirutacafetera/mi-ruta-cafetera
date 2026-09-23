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

  // ============================================================
  // ICONOS SEGÚN EL NOMBRE REAL DE MONGODB
  // ============================================================

  IconData _obtenerIcono(
    CategoriaModel categoria,
  ) {
    final nombre = _normalizar(
      categoria.nombre,
    );

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

  String _normalizar(
    String texto,
  ) {
    return texto
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final ancho = constraints.maxWidth;

        // --------------------------------------------------------
        // Pantallas pequeñas
        // --------------------------------------------------------

        if (ancho < 600) {
          return _construirVersionCompacta(
            context,
          );
        }

        // --------------------------------------------------------
        // Pantallas grandes
        // --------------------------------------------------------

        return _construirVersionResponsive(
          context,
        );
      },
    );
  }

  // ============================================================
  // VERSION COMPACTA
  // ============================================================

  Widget _construirVersionCompacta(
    BuildContext context,
  ) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: AppDimensions.floatingButtonSize +
            AppDimensions.spacingXs,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXs / 2,
          ),
          children: [
            _construirIconoCategoria(
              icono: Icons.apps_outlined,
              seleccionada: categoriaSeleccionada == null,
              tooltip: 'Todas',
              onTap: () {
                onCategoriaSeleccionada(null);
              },
            ),
            ...categorias.map(
              (categoria) {
                return _construirIconoCategoria(
                  icono: _obtenerIcono(categoria),
                  seleccionada:
                      categoriaSeleccionada == categoria.id,
                  tooltip: categoria.nombre,
                  onTap: () {
                    final seleccionada =
                        categoriaSeleccionada == categoria.id;

                    onCategoriaSeleccionada(
                      seleccionada
                          ? null
                          : categoria.id,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // VERSION RESPONSIVE
  // ============================================================

  Widget _construirVersionResponsive(
    BuildContext context,
  ) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingXs / 2,
          vertical: AppDimensions.spacingXs / 2,
        ),
        child: Wrap(
          spacing: AppDimensions.spacingSm - 1,
          runSpacing: AppDimensions.spacingSm - 1,
          children: [
            _construirChipCategoria(
              icono: Icons.apps_outlined,
              nombre: 'Todas',
              seleccionada:
                  categoriaSeleccionada == null,
              onTap: () {
                onCategoriaSeleccionada(null);
              },
            ),
            ...categorias.map(
              (categoria) {
                final seleccionada =
                    categoriaSeleccionada == categoria.id;

                return _construirChipCategoria(
                  icono: _obtenerIcono(categoria),
                  nombre: categoria.nombre,
                  seleccionada: seleccionada,
                  onTap: () {
                    onCategoriaSeleccionada(
                      seleccionada
                          ? null
                          : categoria.id,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ICONO DE CATEGORÍA - MÓVIL
  // ============================================================

  Widget _construirIconoCategoria({
    required IconData icono,
    required bool seleccionada,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        right: AppDimensions.spacingSm,
      ),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusPill,
            ),
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 180,
              ),
              width: AppDimensions.floatingButtonSize,
              height: AppDimensions.floatingButtonSize,
              decoration: BoxDecoration(
                color: seleccionada
                    ? AppColors.primary
                    : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: seleccionada
                      ? AppColors.primary
                      : AppColors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(
                      alpha: 0.12,
                    ),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icono,
                color: seleccionada
                    ? AppColors.white
                    : AppColors.primary,
                size: AppDimensions.iconLg,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CHIP DE CATEGORÍA - RESPONSIVE
  // ============================================================

  Widget _construirChipCategoria({
    required IconData icono,
    required String nombre,
    required bool seleccionada,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusPill,
        ),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingSm,
          ),
          decoration: BoxDecoration(
            color: seleccionada
                ? AppColors.primary
                : AppColors.white,
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusPill,
            ),
            border: Border.all(
              color: seleccionada
                  ? AppColors.primary
                  : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(
                  alpha: 0.10,
                ),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icono,
                size: AppDimensions.iconSm,
                color: seleccionada
                    ? AppColors.white
                    : AppColors.primary,
              ),

              const SizedBox(
                width: AppDimensions.spacingSm,
              ),

              Text(
                nombre,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: seleccionada
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: seleccionada
                      ? AppColors.white
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}