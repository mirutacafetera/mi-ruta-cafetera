
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

  static const Color _cafe = Color(0xFFB58A70);
  static const Color _crema = Color(0xFFFBF7F0);

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
              const SizedBox(width: 10),
              Expanded(
                child: _tarjeta(
                  titulo: 'Con cuenta',
                  cantidad: conCuenta,
                  icono: Icons.person_outline,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
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
          const SizedBox(height: 10),
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
              const SizedBox(width: 10),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: _crema,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _cafe,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: _cafe.withValues(alpha: 0.06),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icono,
                  color: color,
                  size: 17,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  titulo,
                  softWrap: true,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            cantidad.toString(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
