
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
        AppDimensions.sitioPanelCardPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceSoft,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        border: Border.all(
          color: AppColors.sitioBorder,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.sitioSurfaceGreen,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              color: AppColors.sitioPrimary,
              size: 36,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No hay reservas todavía',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.sitioTextPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las reservas de los visitantes aparecerán aquí.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.sitioTextSecondary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
