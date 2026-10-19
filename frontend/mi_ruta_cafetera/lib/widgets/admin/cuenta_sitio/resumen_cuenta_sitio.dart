import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class ResumenCuentaSitio extends StatelessWidget {
  final int totalSitios;
  final int conCuenta;
  final int sinCuenta;
  final int activas;
  final int inactivas;

  const ResumenCuentaSitio({
    super.key,
    required this.totalSitios,
    required this.conCuenta,
    required this.sinCuenta,
    required this.activas,
    required this.inactivas,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingSm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _tarjeta(
                  titulo: 'Sitios',
                  cantidad: totalSitios,
                  icono: Icons.landscape_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(
                width: AppDimensions.spacingSm,
              ),
              Expanded(
                child: _tarjeta(
                  titulo: 'Con cuenta',
                  cantidad: conCuenta,
                  icono: Icons.person_outline,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(
                width: AppDimensions.spacingSm,
              ),
              Expanded(
                child: _tarjeta(
                  titulo: 'Sin cuenta',
                  cantidad: sinCuenta,
                  icono: Icons.person_add_alt_1,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppDimensions.spacingSm,
          ),
          Row(
            children: [
              Expanded(
                child: _tarjeta(
                  titulo: 'Activas',
                  cantidad: activas,
                  icono: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(
                width: AppDimensions.spacingSm,
              ),
              Expanded(
                child: _tarjeta(
                  titulo: 'Inactivas',
                  cantidad: inactivas,
                  icono: Icons.block_outlined,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjeta({
    required String titulo,
    required int cantidad,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.spacingMd,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            color: color,
            size: AppDimensions.iconLg,
          ),
          const SizedBox(
            height: AppDimensions.spacingSm,
          ),
          Text(
            cantidad.toString(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingXs,
          ),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}