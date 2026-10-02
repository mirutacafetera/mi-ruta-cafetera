import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class NavegacionSitio extends StatelessWidget {
  final int indiceActual;
  final List<String> titulos;
  final List<IconData> iconos;
  final bool modoEscritorio;
  final ValueChanged<int> onSeleccionar;
  final VoidCallback onCerrarSesion;

  const NavegacionSitio({
    super.key,
    required this.indiceActual,
    required this.titulos,
    required this.iconos,
    required this.modoEscritorio,
    required this.onSeleccionar,
    required this.onCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    if (modoEscritorio) {
      return _navegacionEscritorio();
    }

    return _navegacionMovil(context);
  }

  Widget _navegacionEscritorio() {
    return Container(
      width: 250,
      color: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            _logo(),
            const SizedBox(
              height: AppDimensions.spacingLg,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingSm,
                ),
                itemCount: titulos.length,
                itemBuilder: (context, index) {
                  return _itemNavegacion(
                    index: index,
                  );
                },
              ),
            ),
            _botonCerrarSesion(),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingLg,
        AppDimensions.spacingMd,
        0,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
            child: const Icon(
              Icons.coffee_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          const Expanded(
            child: Text(
              'Mi Ruta\nCafetera',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemNavegacion({
    required int index,
  }) {
    final seleccionado = indiceActual == index;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spacingXs,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSeleccionar(index),
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMd,
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
              color: seleccionado
                  ? AppColors.primary.withValues(
                      alpha: 0.10,
                    )
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  iconos[index],
                  size: 21,
                  color: seleccionado
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(
                  width: AppDimensions.spacingMd,
                ),
                Expanded(
                  child: Text(
                    titulos[index],
                    style: TextStyle(
                      color: seleccionado
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: seleccionado
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonCerrarSesion() {
    return Padding(
      padding: const EdgeInsets.all(
        AppDimensions.spacingMd,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onCerrarSesion,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMd,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: AppColors.textSecondary,
                  size: 21,
                ),
                const SizedBox(
                  width: AppDimensions.spacingMd,
                ),
                const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navegacionMovil(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXs,
            vertical: AppDimensions.spacingXs,
          ),
          child: Row(
            children: [
              Expanded(
                child: _itemMovil(
                  context,
                  indice: 0,
                ),
              ),
              Expanded(
                child: _itemMovil(
                  context,
                  indice: 1,
                ),
              ),
              Expanded(
                child: _itemMovil(
                  context,
                  indice: 2,
                ),
              ),
              Expanded(
                child: _itemMas(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemMovil(
    BuildContext context, {
    required int indice,
  }) {
    final seleccionado = indiceActual == indice;

    return InkWell(
      onTap: () => onSeleccionar(indice),
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusMd,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingXs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconos[indice],
              size: 21,
              color: seleccionado
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              titulos[indice],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: seleccionado
                    ? FontWeight.w800
                    : FontWeight.w600,
                color: seleccionado
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemMas(BuildContext context) {
    return InkWell(
      onTap: () => _mostrarMenu(context),
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusMd,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingXs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.more_horiz_rounded,
              size: 21,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              'Más',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            AppDimensions.radiusXl,
          ),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(
              AppDimensions.spacingMd,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(
                      alpha: 0.25,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingMd,
                ),
                const Text(
                  'Más opciones',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingSm,
                ),
                for (int index = 3;
                    index < titulos.length;
                    index++)
                  ListTile(
                    leading: Icon(
                      iconos[index],
                      color: AppColors.primary,
                    ),
                    title: Text(
                      titulos[index],
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onSeleccionar(index);
                    },
                  ),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.textSecondary,
                  ),
                  title: const Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onCerrarSesion();
                  },
                ),
                const SizedBox(
                  height: AppDimensions.spacingSm,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}