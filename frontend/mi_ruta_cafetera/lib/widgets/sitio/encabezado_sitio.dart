import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class EncabezadoSitio extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final VoidCallback onCerrarSesion;
  final VoidCallback? onMenu;
  final bool mostrarMenu;

  const EncabezadoSitio({
    super.key,
    required this.titulo,
    required this.icono,
    required this.onCerrarSesion,
    this.onMenu,
    this.mostrarMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final esMovil = ancho < 600;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.16),
            blurRadius: AppDimensions.elevationFloating,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: esMovil
                ? AppDimensions.spacingMd
                : AppDimensions.spacingLg,
            vertical: esMovil
                ? AppDimensions.spacingSm
                : AppDimensions.spacingMd,
          ),
          child: Row(
            children: [
              if (mostrarMenu)
                Padding(
                  padding: const EdgeInsets.only(
                    right: AppDimensions.spacingSm,
                  ),
                  child: Material(
                    color: AppColors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                    child: InkWell(
                      onTap: onMenu,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      child: const SizedBox(
                        width: 42,
                        height: 42,
                        child: Icon(
                          Icons.menu_rounded,
                          color: AppColors.white,
                          size: AppDimensions.iconLg,
                        ),
                      ),
                    ),
                  ),
                ),
              Container(
                width: esMovil
                    ? AppDimensions.circularButtonSmall
                    : AppDimensions.circularButtonSize,
                height: esMovil
                    ? AppDimensions.circularButtonSmall
                    : AppDimensions.circularButtonSize,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLg,
                  ),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Icon(
                  icono,
                  color: AppColors.white,
                  size: esMovil
                      ? AppDimensions.iconMd
                      : AppDimensions.iconLg,
                ),
              ),
              SizedBox(
                width: esMovil
                    ? AppDimensions.spacingSm
                    : AppDimensions.spacingMd,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    SizedBox(
                      height: AppDimensions.spacingXs,
                    ),
                    Text(
                      'Gestiona tu experiencia turística',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: AppColors.white.withValues(
                              alpha: 0.78,
                            ),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: AppDimensions.spacingSm,
              ),
              Material(
                color: AppColors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusPill,
                ),
                child: InkWell(
                  onTap: onCerrarSesion,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusPill,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: esMovil
                          ? AppDimensions.spacingSm
                          : AppDimensions.spacingMd,
                      vertical: AppDimensions.spacingSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: AppColors.white,
                          size: AppDimensions.iconMd,
                        ),
                        if (!esMovil) ...[
                          const SizedBox(
                            width: AppDimensions.spacingSm,
                          ),
                          Text(
                            'Salir',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}