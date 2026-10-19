
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
    final nombreSitio = dashboard?.nombreSitio.trim();
    final tieneNombre = nombreSitio != null && nombreSitio.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        esEscritorio
            ? AppDimensions.spacingXxl
            : AppDimensions.sitioPanelCardPadding,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.sitioPrimary,
            AppColors.sitioPrimaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioCoverImageRadius,
        ),
        border: Border.all(
          color: AppColors.sitioTextOnPrimary.withValues(alpha: 0.08),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -45,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sitioTextOnPrimary.withValues(
                  alpha: 0.035,
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingSm,
                        vertical: AppDimensions.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sitioTextOnPrimary.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusPill,
                        ),
                        border: Border.all(
                          color: AppColors.sitioTextOnPrimary.withValues(
                            alpha: 0.12,
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.coffee_rounded,
                            color: AppColors.sitioAccent,
                            size: AppDimensions.iconSm,
                          ),
                          SizedBox(width: AppDimensions.spacingXs),
                          Flexible(
                            child: Text(
                              'PANEL DE TU SITIO',
                              style: TextStyle(
                                color: AppColors.sitioTextOnPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    Text(
                      tieneNombre
                          ? '¡Bienvenido a\n$nombreSitio!'
                          : '¡Bienvenido a tu panel!',
                      style: TextStyle(
                        color: AppColors.sitioTextOnPrimary,
                        fontSize: esEscritorio ? 28 : 24,
                        fontWeight: FontWeight.w800,
                        height: 1.16,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    Text(
                      'Administra tu experiencia turística, '
                      'actualiza tu información y conecta '
                      'con los visitantes.',
                      style: TextStyle(
                        color: AppColors.sitioTextOnPrimary.withValues(
                          alpha: 0.84,
                        ),
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    Container(
                      height: 3,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.sitioAccent,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusPill,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (esEscritorio) ...[
                const SizedBox(width: AppDimensions.spacingXl),
                _iconoCafe(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconoCafe() {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.sitioTextOnPrimary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        border: Border.all(
          color: AppColors.sitioTextOnPrimary.withValues(alpha: 0.14),
        ),
      ),
      child: const Icon(
        Icons.coffee_rounded,
        color: AppColors.sitioAccent,
        size: 38,
      ),
    );
  }
}
