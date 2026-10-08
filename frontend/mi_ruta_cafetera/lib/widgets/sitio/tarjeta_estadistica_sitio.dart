import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class TarjetaEstadisticaSitio extends StatelessWidget {
  final String titulo;
  final String valor;
  final String descripcion;
  final IconData icono;

  const TarjetaEstadisticaSitio({
    super.key,
    required this.titulo,
    required this.valor,
    required this.descripcion,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.55,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.coffeeDark.withValues(
              alpha: 0.07,
            ),
            blurRadius: AppDimensions.elevationFloating,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Icon(
                  icono,
                  color: AppColors.white,
                  size: AppDimensions.iconLg,
                ),
              ),
              const Spacer(),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(
                    alpha: 0.75,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.coffeeDark,
                  size: AppDimensions.iconSm,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(
            height: AppDimensions.spacingXs,
          ),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(
            height: AppDimensions.spacingXs,
          ),
          Text(
            descripcion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.25,
                ),
          ),
        ],
      ),
    );
  }
}