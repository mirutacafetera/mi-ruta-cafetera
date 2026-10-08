import 'package:flutter/material.dart';

import '../../models/sitio/sitio_dashboard_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class EncabezadoDashboardSitio extends StatelessWidget {
  final SitioDashboardModel? dashboard;
  final bool esEscritorio;

  const EncabezadoDashboardSitio({
    super.key,
    required this.dashboard,
    required this.esEscritorio,
  });

  @override
  Widget build(BuildContext context) {
    final nombreSitio = dashboard?.nombreSitio;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        esEscritorio
            ? AppDimensions.spacingXl
            : AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.heroRadius,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(
              alpha: 0.18,
            ),
            blurRadius: AppDimensions.elevationFloating,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal:
                        AppDimensions.spacingSm,
                    vertical:
                        AppDimensions.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      AppDimensions.radiusPill,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_cafe_rounded,
                        color: AppColors.white,
                        size: AppDimensions.iconSm,
                      ),
                      const SizedBox(
                        width: AppDimensions.spacingXs,
                      ),
                      Text(
                        'PANEL DE TU EXPERIENCIA',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: AppColors.white,
                              fontWeight:
                                  FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: AppDimensions.spacingMd,
                ),

                Text(
                  nombreSitio == null ||
                          nombreSitio.isEmpty
                      ? '¡Bienvenido a tu panel! ☕'
                      : '¡Bienvenido a $nombreSitio! ☕',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                ),

                const SizedBox(
                  height: AppDimensions.spacingSm,
                ),

                Text(
                  'Gestiona tu experiencia turística, '
                  'mantén tu información actualizada y '
                  'conecta con los visitantes de '
                  'Mi Ruta Mágica del Café.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                        color: AppColors.white.withValues(
                          alpha: 0.86,
                        ),
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),

          if (esEscritorio) ...[
            const SizedBox(
              width: AppDimensions.spacingLg,
            ),
            _iconoCafe(),
          ],
        ],
      ),
    );
  }

  Widget _iconoCafe() {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(
          alpha: 0.13,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        border: Border.all(
          color: AppColors.white.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: const Icon(
        Icons.coffee_rounded,
        color: AppColors.white,
        size: AppDimensions.iconLg,
      ),
    );
  }
}