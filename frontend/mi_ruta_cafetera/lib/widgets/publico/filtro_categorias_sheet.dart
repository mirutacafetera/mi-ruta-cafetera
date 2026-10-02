import 'package:flutter/material.dart';

import '../../models/categoria_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../utils/text_utils.dart';

class CategoriaFiltroSheet extends StatelessWidget {
  final List<CategoriaModel> categorias;
  final String? categoriaSeleccionada;
  final ValueChanged<String?> onSeleccionar;

  const CategoriaFiltroSheet({
    super.key,
    required this.categorias,
    required this.categoriaSeleccionada,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.sizeOf(context).height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            AppDimensions.radiusXxl,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _construirEncabezado(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingLg,
                  0,
                  AppDimensions.spacingLg,
                  AppDimensions.spacingXl,
                ),
                child: Column(
                  children: [
                    _construirOpcionTodas(context),
                    const SizedBox(
                      height: AppDimensions.spacingSm,
                    ),
                    ...categorias.map(
                      (categoria) =>
                          _construirCategoria(
                        context,
                        categoria,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ENCABEZADO
  // ============================================================

  Widget _construirEncabezado(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingLg,
        AppDimensions.spacingMd,
        AppDimensions.spacingSm,
        AppDimensions.spacingMd,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppColors.secondary,
              size: AppDimensions.iconMd,
            ),
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtrar experiencias',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(
                  height: AppDimensions.spacingXs,
                ),
                Text(
                  'Encuentra lugares según lo que quieras vivir.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cerrar',
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TODAS LAS CATEGORÍAS
  // ============================================================

  Widget _construirOpcionTodas(
    BuildContext context,
  ) {
    final seleccionada =
        categoriaSeleccionada == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        onTap: () {
          onSeleccionar(null);
          Navigator.pop(context);
        },
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds:
                AppDimensions.animationFast,
          ),
          padding: const EdgeInsets.all(
            AppDimensions.spacingMd,
          ),
          decoration: BoxDecoration(
            color: seleccionada
                ? AppColors.primary
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusLg,
            ),
            border: Border.all(
              color: seleccionada
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: seleccionada
                      ? AppColors.white
                          .withValues(alpha: 0.16)
                      : AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(
                    AppDimensions.radiusMd,
                  ),
                ),
                child: Icon(
                  Icons.apps_rounded,
                  color: seleccionada
                      ? AppColors.textOnDark
                      : AppColors.primary,
                  size: AppDimensions.iconMd,
                ),
              ),
              const SizedBox(
                width: AppDimensions.spacingMd,
              ),
              Expanded(
                child: Text(
                  'Todas las experiencias',
                  style: TextStyle(
                    color: seleccionada
                        ? AppColors.textOnDark
                        : AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                seleccionada
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: seleccionada
                    ? AppColors.textOnDark
                    : AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORÍA
  // ============================================================

  Widget _construirCategoria(
    BuildContext context,
    CategoriaModel categoria,
  ) {
    final nombre = categoria.nombre.trim();

    final seleccionada =
        _esCategoriaSeleccionada(nombre);

    final color =
        AppColors.getColorForCategory(nombre);

    final icono =
        AppColors.getIconForCategory(nombre);

    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.spacingSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
          onTap: () {
            onSeleccionar(nombre);
            Navigator.pop(context);
          },
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds:
                  AppDimensions.animationFast,
            ),
            padding: const EdgeInsets.all(
              AppDimensions.spacingMd,
            ),
            decoration: BoxDecoration(
              color: seleccionada
                  ? color.withValues(alpha: 0.10)
                  : AppColors.surface,
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radiusLg,
              ),
              border: Border.all(
                color: seleccionada
                    ? color
                    : AppColors.border,
                width: seleccionada ? 1.4 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.getSoftColorForCategory(
                      nombre,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                  ),
                  child: Icon(
                    icono,
                    color: color,
                    size: AppDimensions.iconMd,
                  ),
                ),
                const SizedBox(
                  width: AppDimensions.spacingMd,
                ),
                Expanded(
                  child: Text(
                    nombre,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight:
                          seleccionada
                              ? FontWeight.w800
                              : FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(
                  width: AppDimensions.spacingSm,
                ),
                Icon(
                  seleccionada
                      ? Icons.check_circle_rounded
                      : Icons
                          .radio_button_unchecked_rounded,
                  color: seleccionada
                      ? color
                      : AppColors.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COMPARAR CATEGORÍA
  // ============================================================

  bool _esCategoriaSeleccionada(
    String categoria,
  ) {
    if (categoriaSeleccionada == null) {
      return false;
    }

    return TextUtils.normalizar(
          categoria,
        ) ==
        TextUtils.normalizar(
          categoriaSeleccionada!,
        );
  }
}