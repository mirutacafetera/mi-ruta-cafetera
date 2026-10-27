import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class ResumenTarjetaConfig {
  final String titulo;
  final int cantidad;
  final IconData icono;
  final Color color;
  final String estado;

  const ResumenTarjetaConfig({
    required this.titulo,
    required this.cantidad,
    required this.icono,
    required this.color,
    required this.estado,
  });
}

class ResumenProductos extends StatelessWidget {
  final int pendientes;
  final int aprobados;
  final int rechazados;
  final String estadoSeleccionado;
  final ValueChanged<String>? onSeleccionar;
  final List<ResumenTarjetaConfig>? tarjetas;

  const ResumenProductos({
    super.key,
    this.pendientes = 0,
    this.aprobados = 0,
    this.rechazados = 0,
    this.estadoSeleccionado = 'pendiente_revision',
    this.onSeleccionar,
    this.tarjetas,
  });

  @override
  Widget build(BuildContext context) {
    final opciones = tarjetas ??
        [
          ResumenTarjetaConfig(
            titulo: 'Pendientes',
            cantidad: pendientes,
            icono: Icons.pending_actions_rounded,
            color: AppColors.secondary,
            estado: 'pendiente_revision',
          ),
          ResumenTarjetaConfig(
            titulo: 'Aprobados',
            cantidad: aprobados,
            icono: Icons.check_circle_rounded,
            color: AppColors.success,
            estado: 'aprobado',
          ),
          ResumenTarjetaConfig(
            titulo: 'Rechazados',
            cantidad: rechazados,
            icono: Icons.cancel_rounded,
            color: AppColors.error,
            estado: 'rechazado',
          ),
        ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalSmall,
        vertical: 5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < opciones.length; i++) ...[
            if (i > 0) const SizedBox(width: 7),
            Expanded(
              child: _TarjetaResumen(tarjeta: opciones[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _TarjetaResumen extends StatelessWidget {
  final ResumenTarjetaConfig tarjeta;

  const _TarjetaResumen({
    required this.tarjeta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 105),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.coffeeLight.withValues(alpha: 0.65),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.coffeeDark.withValues(alpha: 0.06),
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
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: tarjeta.color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tarjeta.icono,
                  color: tarjeta.color,
                  size: 17,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  tarjeta.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            '${tarjeta.cantidad}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.coffeeDark,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
          ),
          const SizedBox(height: 9),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: tarjeta.color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}