
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
  // Datos originales de Productos. Se conservan para no romper
  // la pantalla que ya utiliza este componente.
  final int pendientes;
  final int aprobados;
  final int rechazados;

  // Configuración compartida.
  final String estadoSeleccionado;
  final ValueChanged<String>? onSeleccionar;

  // Permite reutilizar las mismas tarjetas en otras pantallas.
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
            icono: Icons.inventory_2_outlined,
            color: AppColors.primary,
            estado: 'pendiente_revision',
          ),
          ResumenTarjetaConfig(
            titulo: 'Aprobados',
            cantidad: aprobados,
            icono: Icons.check_circle_outline,
            color: Colors.green,
            estado: 'aprobado',
          ),
          ResumenTarjetaConfig(
            titulo: 'Rechazados',
            cantidad: rechazados,
            icono: Icons.cancel_outlined,
            color: Colors.red,
            estado: 'rechazado',
          ),
        ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingSm,
      ),
      child: Row(
        children: [
          for (var i = 0; i < opciones.length; i++) ...[
            if (i > 0)
              const SizedBox(width: AppDimensions.spacingSm),
            Expanded(
              child: _TarjetaResumen(
                titulo: opciones[i].titulo,
                cantidad: opciones[i].cantidad,
                icono: opciones[i].icono,
                color: opciones[i].color,
                seleccionada:
                    estadoSeleccionado == opciones[i].estado,
                onTap: () => onSeleccionar?.call(
                  opciones[i].estado,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TarjetaResumen extends StatelessWidget {
  final String titulo;
  final int cantidad;
  final IconData icono;
  final Color color;
  final bool seleccionada;
  final VoidCallback onTap;

  const _TarjetaResumen({
    required this.titulo,
    required this.cantidad,
    required this.icono,
    required this.color,
    required this.seleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(
        alpha: seleccionada ? 0.16 : 0.08,
      ),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(
            AppDimensions.spacingSm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(
                alpha: seleccionada ? 0.65 : 0.25,
              ),
              width: seleccionada ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icono,
                color: color,
                size: 24,
              ),
              const SizedBox(
                height: AppDimensions.spacingSm,
              ),
              Text(
                cantidad.toString(),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(
                height: AppDimensions.spacingXs,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
