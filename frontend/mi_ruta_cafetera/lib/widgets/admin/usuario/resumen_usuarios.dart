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

  static const Color _bordeCafe = Color(0xFFB58A70);

  @override
  Widget build(BuildContext context) {
    if (tarjetas.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const columnas = 2;
        const espacio = AppDimensions.spacingSm;

        final anchoTarjeta =
            (constraints.maxWidth - espacio) / columnas;

        return Wrap(
          spacing: espacio,
          runSpacing: espacio,
          children: tarjetas.map((tarjeta) {
            return SizedBox(
              width: anchoTarjeta,
              child: _construirTarjeta(
                tarjeta,
                compacta: anchoTarjeta < 155,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _construirTarjeta(
    ResumenTarjeta tarjeta, {
    required bool compacta,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: EdgeInsets.all(
        compacta
            ? AppDimensions.spacingSm
            : AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.creamLight.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        border: Border.all(
          color: _bordeCafe,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.coffeeDark.withValues(alpha: 0.06),
            blurRadius: 7,
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
                width: compacta ? 30 : 36,
                height: compacta ? 30 : 36,
                decoration: BoxDecoration(
                  color: tarjeta.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tarjeta.icono,
                  color: tarjeta.color,
                  size: compacta ? 17 : 20,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tarjeta.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: compacta ? 10 : 12,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${tarjeta.cantidad}',
            maxLines: 1,
            style: TextStyle(
              color: AppColors.coffeeDark,
              fontSize: compacta ? 23 : 27,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 9),
          Container(
            width: compacta ? 27 : 34,
            height: 3,
            decoration: BoxDecoration(
              color: tarjeta.color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}