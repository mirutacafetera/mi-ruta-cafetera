import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class NavegacionSitio extends StatelessWidget {
  final int indiceActual;
  final List<String> titulos;
  final List<IconData> iconos;
  final bool modoEscritorio;
  final bool menuMovil;
  final ValueChanged<int> onSeleccionar;
  final VoidCallback onCerrarSesion;

  const NavegacionSitio({
    super.key,
    required this.indiceActual,
    required this.titulos,
    required this.iconos,
    required this.modoEscritorio,
    this.menuMovil = false,
    required this.onSeleccionar,
    required this.onCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    if (modoEscritorio) {
      return _navegacionEscritorio(context);
    }

    return _navegacionMovil(context);
  }

  Widget _navegacionEscritorio(BuildContext context) {
    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(
            color: AppColors.border.withValues(alpha: 0.65),
          ),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            _marca(context),
            const SizedBox(
              height: AppDimensions.spacingLg,
            ),
            Expanded(
              child: _listaNavegacion(context),
            ),
            _cerrarSesion(context),
          ],
        ),
      ),
    );
  }

  Widget _navegacionMovil(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _marca(context),
          const SizedBox(
            height: AppDimensions.spacingLg,
          ),
          Expanded(
            child: _listaNavegacion(context),
          ),
          _cerrarSesion(context),
        ],
      ),
    );
  }

  Widget _listaNavegacion(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingSm,
            ),
            child: Text(
              'GESTIÓN DE TU SITIO',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingSm,
          ),
          ...List.generate(
            titulos.length,
            (indice) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.spacingXs,
              ),
              child: _item(
                context,
                indice,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _marca(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingLg,
        AppDimensions.spacingLg,
        AppDimensions.spacingLg,
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
                AppDimensions.radiusLg,
              ),
            ),
            child: const Icon(
              Icons.local_cafe_rounded,
              color: AppColors.white,
              size: AppDimensions.iconLg,
            ),
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mi Ruta',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  'Mágica del Café',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    int indice,
  ) {
    final seleccionado = indiceActual == indice;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusLg,
      ),
      child: InkWell(
        onTap: () => onSeleccionar(indice),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingSm,
          ),
          decoration: BoxDecoration(
            color: seleccionado
                ? AppColors.primary.withValues(alpha: 0.11)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusLg,
            ),
            border: Border.all(
              color: seleccionado
                  ? AppColors.primary.withValues(alpha: 0.10)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: seleccionado
                      ? AppColors.primary
                      : AppColors.surfaceGreen,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMd,
                  ),
                ),
                child: Icon(
                  iconos[indice],
                  size: AppDimensions.iconMd,
                  color: seleccionado
                      ? AppColors.white
                      : AppColors.primary,
                ),
              ),
              const SizedBox(
                width: AppDimensions.spacingMd,
              ),
              Expanded(
                child: Text(
                  titulos[indice],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color: seleccionado
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: seleccionado
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                ),
              ),
              if (seleccionado)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: AppDimensions.iconMd,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cerrarSesion(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        AppDimensions.spacingMd,
      ),
      child: Material(
        color: AppColors.orangeSoft.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        child: InkWell(
          onTap: onCerrarSesion,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.orangeSoft,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.coffeeDark,
                    size: AppDimensions.iconMd,
                  ),
                ),
                const SizedBox(
                  width: AppDimensions.spacingMd,
                ),
                Expanded(
                  child: Text(
                    'Cerrar sesión',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color: AppColors.coffeeDark,
                          fontWeight: FontWeight.w700,
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
}