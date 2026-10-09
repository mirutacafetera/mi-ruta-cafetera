import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class TarjetaResumenReservasSitio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;
  final String descripcion;

  const TarjetaResumenReservasSitio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
            child: Icon(
              icono,
              color: AppColors.primary,
              size: AppDimensions.iconSm,
            ),
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingXs,
                ),
                Text(
                  valor,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  descripcion,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
