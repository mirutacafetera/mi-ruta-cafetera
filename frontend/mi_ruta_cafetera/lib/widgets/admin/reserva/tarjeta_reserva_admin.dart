import 'package:flutter/material.dart';

import '../../../../models/admin/reserva_admin_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class TarjetaReservaAdmin extends StatelessWidget {
  final ReservaAdminModel reserva;
  final VoidCallback onTap;

  const TarjetaReservaAdmin({
    super.key,
    required this.reserva,
    required this.onTap,
  });

  Color obtenerColorEstado() {
    switch (reserva.estado.toLowerCase()) {
      case 'confirmada':
        return AppColors.success;
      case 'cancelada':
        return AppColors.error;
      case 'completada':
        return AppColors.primary;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = obtenerColorEstado();

    return Card(
      margin: EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
        child: Padding(
          padding: EdgeInsets.all(
            AppDimensions.spacingMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reserva.nombreSitio,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingSm,
                      vertical: AppDimensions.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: Text(
                      reserva.estado.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spacingSm),
              Text('Usuario: ${reserva.nombreUsuario}'),
              Text('Actividad: ${reserva.nombreActividad}'),
              Text('Personas: ${reserva.cantidadPersonas}'),
              Text(
                'Fecha: ${reserva.fecha.day.toString().padLeft(2, '0')}/'
                '${reserva.fecha.month.toString().padLeft(2, '0')}/'
                '${reserva.fecha.year}',
              ),
              SizedBox(height: AppDimensions.spacingSm),
              Text(
                'Total: \$${reserva.precioTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (reserva.observaciones.isNotEmpty) ...[
                SizedBox(height: AppDimensions.spacingSm),
                Text(
                  'Observaciones: ${reserva.observaciones}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}