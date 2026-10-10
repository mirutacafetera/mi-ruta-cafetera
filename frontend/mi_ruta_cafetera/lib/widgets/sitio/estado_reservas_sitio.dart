import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class EstadoReservasSitio extends StatelessWidget {
  const EstadoReservasSitio({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            color: AppColors.textSecondary,
            size: AppDimensions.iconLg,
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          Text(
            'No hay reservas todavía',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(
            height: AppDimensions.spacingXs,
          ),
          Text(
            'Las reservas de los visitantes aparecerán aquí.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}