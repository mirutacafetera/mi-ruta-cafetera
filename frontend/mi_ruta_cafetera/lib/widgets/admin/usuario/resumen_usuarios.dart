import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class ResumenTarjeta {
  final String titulo;
  final int cantidad;
  final IconData icono;
  final Color color;

  const ResumenTarjeta({
    required this.titulo,
    required this.cantidad,
    required this.icono,
    required this.color,
  });
}

class ResumenUsuarios extends StatelessWidget {
  final List<ResumenTarjeta> tarjetas;

  const ResumenUsuarios({
    super.key,
    required this.tarjetas,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = constraints.maxWidth < 400
            ? 2
            : tarjetas.length == 1
                ? 1
                : tarjetas.length == 2
                    ? 2
                    : 3;

        final ancho = (constraints.maxWidth -
                AppDimensions.spacingMd * (columnas - 1)) /
            columnas;

        return Wrap(
          spacing: AppDimensions.spacingMd,
          runSpacing: AppDimensions.spacingMd,
          children: tarjetas.map((tarjeta) {
            return SizedBox(
              width: ancho,
              child: _construirTarjeta(tarjeta),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _construirTarjeta(ResumenTarjeta tarjeta) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            tarjeta.icono,
            color: tarjeta.color,
            size: AppDimensions.iconLg,
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          Text(
            '${tarjeta.cantidad}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingXs,
          ),
          Text(
            tarjeta.titulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}