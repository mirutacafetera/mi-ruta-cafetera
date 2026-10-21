
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class ResumenReservas extends StatelessWidget {
  final int todas;
  final int pendientes;
  final int confirmadas;
  final int rechazadas;
  final int canceladas;
  final int completadas;

  const ResumenReservas({
    super.key,
    required this.todas,
    required this.pendientes,
    required this.confirmadas,
    required this.rechazadas,
    required this.canceladas,
    required this.completadas,
  });

  @override
  Widget build(BuildContext context) {
    final tarjetas = [
      _DatoReserva(
        titulo: 'Todas',
        cantidad: todas,
        icono: Icons.event_note_rounded,
        color: AppColors.primary,
      ),
      _DatoReserva(
        titulo: 'Pendientes',
        cantidad: pendientes,
        icono: Icons.schedule_rounded,
        color: Colors.orange,
      ),
      _DatoReserva(
        titulo: 'Confirmadas',
        cantidad: confirmadas,
        icono: Icons.event_available_rounded,
        color: Colors.green,
      ),
      _DatoReserva(
        titulo: 'Rechazadas',
        cantidad: rechazadas,
        icono: Icons.cancel_outlined,
        color: Colors.redAccent,
      ),
      _DatoReserva(
        titulo: 'Canceladas',
        cantidad: canceladas,
        icono: Icons.event_busy_rounded,
        color: Colors.blueGrey,
      ),
      _DatoReserva(
        titulo: 'Completadas',
        cantidad: completadas,
        icono: Icons.task_alt_rounded,
        color: AppColors.secondary,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: 8,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tarjetas.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          mainAxisExtent: 94,
        ),
        itemBuilder: (context, index) {
          return _TarjetaResumenReserva(
            dato: tarjetas[index],
          );
        },
      ),
    );
  }
}

class _DatoReserva {
  final String titulo;
  final int cantidad;
  final IconData icono;
  final Color color;

  const _DatoReserva({
    required this.titulo,
    required this.cantidad,
    required this.icono,
    required this.color,
  });
}

class _TarjetaResumenReserva extends StatelessWidget {
  final _DatoReserva dato;

  const _TarjetaResumenReserva({
    required this.dato,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFB58A70),
          width: 1.2,
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
        children: [
          Row(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: dato.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  dato.icono,
                  size: 14,
                  color: dato.color,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  dato.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF665D55),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${dato.cantidad}',
            style: const TextStyle(
              fontSize: 23,
              height: 1,
              fontWeight: FontWeight.bold,
              color: Color(0xFF38251B),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 3,
            width: 27,
            decoration: BoxDecoration(
              color: dato.color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }
}
