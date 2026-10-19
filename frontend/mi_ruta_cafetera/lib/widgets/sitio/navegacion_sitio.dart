
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
    return modoEscritorio
        ? _navegacionEscritorio(context)
        : _navegacionMovil(context);
  }

  Widget _navegacionEscritorio(BuildContext context) {
    return Container(
      width: 270,
      decoration: const BoxDecoration(
        color: AppColors.sitioSurface,
        border: Border(
          right: BorderSide(color: AppColors.sitioBorder),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            _marca(context),
            const SizedBox(height: AppDimensions.sitioSectionGap),
            Expanded(child: _listaNavegacion(context)),
            _cerrarSesion(context),
          ],
        ),
      ),
    );
  }

  Widget _navegacionMovil(BuildContext context) {
    return Container(
      color: AppColors.sitioSurface,
      child: SafeArea(
        child: Column(
          children: [
            _marca(context),
            const SizedBox(height: AppDimensions.sitioSectionGapCompact),
            Expanded(child: _listaNavegacion(context)),
            _cerrarSesion(context),
          ],
        ),
      ),
    );
  }

  Widget _listaNavegacion(BuildContext context) {
    final cantidad = titulos.length < iconos.length
        ? titulos.length
        : iconos.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sitioPagePadding,
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
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.sitioTextSecondary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          ...List.generate(
            cantidad,
            (indice) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.spacingSm,
              ),
              child: _item(context, indice),
            ),
          ),
        ],
      ),
    );
  }

  Widget _marca(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sitioPagePadding,
        AppDimensions.sitioHeaderPaddingTop,
        AppDimensions.sitioPagePadding,
        0,
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.sitioHeaderIconSize,
            height: AppDimensions.sitioHeaderIconSize,
            decoration: BoxDecoration(
              color: AppColors.sitioPrimary,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusLg,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.sitioCardShadow,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_cafe_rounded,
              color: AppColors.sitioTextOnPrimary,
              size: AppDimensions.iconLg,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mi Ruta',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.sitioTextPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cafetera',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.sitioPrimary,
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

  Widget _item(BuildContext context, int indice) {
    final seleccionado = indiceActual == indice;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(
        AppDimensions.sitioPanelCardRadius,
      ),
      child: InkWell(
        onTap: () => onSeleccionar(indice),
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: AppDimensions.animationNormal,
          ),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(
            minHeight: AppDimensions.sitioButtonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingSm,
          ),
          decoration: BoxDecoration(
            color: seleccionado
                ? AppColors.sitioSurfaceGreen
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
              AppDimensions.sitioPanelCardRadius,
            ),
            border: Border.all(
              color: seleccionado
                  ? AppColors.sitioPrimary.withValues(alpha: 0.12)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(
                  milliseconds: AppDimensions.animationFast,
                ),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: seleccionado
                      ? AppColors.sitioPrimary
                      : AppColors.sitioSurfaceSoft,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMd,
                  ),
                ),
                child: Icon(
                  iconos[indice],
                  size: AppDimensions.navigationIcon,
                  color: seleccionado
                      ? AppColors.sitioTextOnPrimary
                      : AppColors.sitioTextSecondary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Text(
                  titulos[indice],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: seleccionado
                            ? AppColors.sitioPrimary
                            : AppColors.sitioTextPrimary,
                        fontWeight:
                            seleccionado ? FontWeight.w800 : FontWeight.w600,
                      ),
                ),
              ),
              if (seleccionado)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.sitioPrimary,
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
        AppDimensions.sitioPagePadding,
      ),
      child: Material(
        color: AppColors.sitioErrorSoft,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        child: InkWell(
          onTap: onCerrarSesion,
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioPanelCardRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              AppDimensions.spacingSm,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.sitioSurface,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.sitioError,
                    size: AppDimensions.iconMd,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Text(
                    'Cerrar sesión',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.sitioError,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.sitioError,
                  size: AppDimensions.iconSm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
