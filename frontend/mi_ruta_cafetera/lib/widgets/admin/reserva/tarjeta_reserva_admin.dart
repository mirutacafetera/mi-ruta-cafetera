
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

  static const Color _bordeCafe = Color(0xFFB58A70);

  Color obtenerColorEstado() {
    switch (reserva.estado.trim().toLowerCase()) {
      case 'confirmada':
        return AppColors.success;
      case 'cancelada':
      case 'rechazada':
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
      margin: EdgeInsets.zero,
      elevation: 2,
      color: AppColors.creamLight,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        side: const BorderSide(
          color: _bordeCafe,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        child: Padding(
          padding: EdgeInsets.all(
            AppDimensions.spacingMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      reserva.nombreSitio,
                      style: const TextStyle(
                        color: AppColors.coffeeDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingSm,
                      vertical: AppDimensions.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
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
              Text(
                'Usuario: ${reserva.nombreUsuario}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Actividad: ${reserva.nombreActividad}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Personas: ${reserva.cantidadPersonas}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Fecha: ${reserva.fecha.day.toString().padLeft(2, '0')}/'
                '${reserva.fecha.month.toString().padLeft(2, '0')}/'
                '${reserva.fecha.year}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                ),
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
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
