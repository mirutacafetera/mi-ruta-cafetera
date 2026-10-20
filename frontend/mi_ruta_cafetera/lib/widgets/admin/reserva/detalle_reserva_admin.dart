import 'package:flutter/material.dart';

import '../../../../models/admin/reserva_admin_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class DetalleReservaAdmin extends StatelessWidget {
  final ReservaAdminModel reserva;
  final bool guardando;
  final ValueChanged<String> onCambiarEstado;

  const DetalleReservaAdmin({
    super.key,
    required this.reserva,
    required this.guardando,
    required this.onCambiarEstado,
  });

  @override
  Widget build(BuildContext context) {
    const estados = [
      'pendiente',
      'confirmada',
      'rechazada',
      'cancelada',
      'completada',
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalle de la reserva',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          SizedBox(height: AppDimensions.spacingLg),
          _dato('Sitio turístico', reserva.nombreSitio),
          _dato('Usuario', reserva.nombreUsuario),
          _dato('Actividad', reserva.nombreActividad),
          _dato('Cantidad de personas', '${reserva.cantidadPersonas}'),
          _dato(
            'Fecha',
            '${reserva.fecha.day.toString().padLeft(2, '0')}/'
                '${reserva.fecha.month.toString().padLeft(2, '0')}/'
                '${reserva.fecha.year}',
          ),
          _dato(
            'Precio total',
            '\$${reserva.precioTotal.toStringAsFixed(0)}',
          ),
          _dato(
            'Observaciones',
            reserva.observaciones.isEmpty
                ? 'Sin observaciones'
                : reserva.observaciones,
          ),
          SizedBox(height: AppDimensions.spacingLg),
          Text(
            'Estado de la reserva',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: AppDimensions.spacingSm),
          DropdownButtonFormField<String>(
            initialValue: estados.contains(reserva.estado.toLowerCase())
                ? reserva.estado.toLowerCase()
                : 'pendiente',
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Seleccionar estado',
            ),
            items: estados.map((estado) {
              return DropdownMenuItem(
                value: estado,
                child: Text(
                  '${estado[0].toUpperCase()}${estado.substring(1)}',
                ),
              );
            }).toList(),
            onChanged: guardando
                ? null
                : (estado) {
                    if (estado != null && estado != reserva.estado) {
                      onCambiarEstado(estado);
                    }
                  },
          ),
          if (guardando) ...[
            SizedBox(height: AppDimensions.spacingMd),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppDimensions.spacingXs),
          Text(
            valor,
            style: const TextStyle(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
