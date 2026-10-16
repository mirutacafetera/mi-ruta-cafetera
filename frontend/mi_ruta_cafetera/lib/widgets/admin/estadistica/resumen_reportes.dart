
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class ResumenReportes extends StatelessWidget {
  final int total;
  final int pendientes;
  final int enRevision;
  final int resueltos;

  const ResumenReportes({
    super.key,
    required this.total,
    required this.pendientes,
    required this.enRevision,
    required this.resueltos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Estado de los reportes',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orangeSoft,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.chipRadius,
                  ),
                ),
                child: Text(
                  'Total: $total',
                  style: const TextStyle(
                    color: AppColors.coffeeDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppDimensions.spacingLg,
          ),
          _EstadoReporte(
            titulo: 'Pendientes',
            cantidad: pendientes,
            color: AppColors.warning,
            icono: Icons.schedule_rounded,
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          _EstadoReporte(
            titulo: 'En revisión',
            cantidad: enRevision,
            color: AppColors.info,
            icono: Icons.manage_search_rounded,
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          _EstadoReporte(
            titulo: 'Resueltos',
            cantidad: resueltos,
            color: AppColors.success,
            icono: Icons.check_circle_outline_rounded,
          ),
        ],
      ),
    );
  }
}

class _EstadoReporte extends StatelessWidget {
  final String titulo;
  final int cantidad;
  final Color color;
  final IconData icono;

  const _EstadoReporte({
    required this.titulo,
    required this.cantidad,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMd,
            ),
          ),
          child: Icon(
            icono,
            color: color,
            size: AppDimensions.iconMd,
          ),
        ),
        const SizedBox(
          width: AppDimensions.spacingMd,
        ),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          '$cantidad',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
