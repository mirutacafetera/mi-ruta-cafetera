import 'package:flutter/material.dart';

import '../../../../models/admin/reserva_admin_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class DetalleReservaAdmin extends StatelessWidget {
  final ReservaAdminModel reserva;

  const DetalleReservaAdmin({
    super.key,
    required this.reserva,
  });

  static const Color _bordeCafe = Color(0xFFB58A70);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: AppColors.primary,
                  size: 25,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalle de la reserva',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Información de la reservación',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.creamLight,
              borderRadius: BorderRadius.circular(
                AppDimensions.cardRadius,
              ),
              border: Border.all(
                color: _bordeCafe,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.coffeeDark.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _dato(
                  Icons.storefront_outlined,
                  'Sitio turístico',
                  reserva.nombreSitio,
                ),
                _separador(),
                _dato(
                  Icons.person_outline_rounded,
                  'Usuario',
                  reserva.nombreUsuario,
                ),
                _separador(),
                _dato(
                  Icons.local_activity_outlined,
                  'Actividad',
                  reserva.nombreActividad,
                ),
                _separador(),
                _dato(
                  Icons.groups_outlined,
                  'Cantidad de personas',
                  '${reserva.cantidadPersonas}',
                ),
                _separador(),
                _dato(
                  Icons.calendar_month_outlined,
                  'Fecha de reserva',
                  '${reserva.fecha.day.toString().padLeft(2, '0')}/'
                      '${reserva.fecha.month.toString().padLeft(2, '0')}/'
                      '${reserva.fecha.year}',
                ),
                _separador(),
                _dato(
                  Icons.payments_outlined,
                  'Precio total',
                  '\$${reserva.precioTotal.toStringAsFixed(0)}',
                  destacado: true,
                ),
                _separador(),
                _dato(
                  Icons.notes_rounded,
                  'Observaciones',
                  reserva.observaciones.trim().isEmpty
                      ? 'Sin observaciones'
                      : reserva.observaciones,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          const Text(
            'Estado de la reserva',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          _estadoReserva(reserva.estado),
        ],
      ),
    );
  }

  Widget _dato(
    IconData icono,
    String titulo,
    String valor, {
    bool destacado = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (destacado ? AppColors.secondary : AppColors.primary)
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icono,
              color: destacado ? AppColors.secondary : AppColors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: TextStyle(
                    color: destacado
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontSize: destacado ? 17 : 14,
                    fontWeight:
                        destacado ? FontWeight.bold : FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _separador() {
    return const Divider(
      color: _bordeCafe,
      height: 1,
      thickness: 0.5,
    );
  }

  Widget _estadoReserva(String estado) {
    final normalizado = estado.trim().toLowerCase();

    final configuracion = switch (normalizado) {
      'pendiente' => (
          texto: 'Pendiente',
          color: AppColors.warning,
          icono: Icons.schedule_rounded,
        ),
      'confirmada' => (
          texto: 'Confirmada',
          color: AppColors.success,
          icono: Icons.check_circle_outline_rounded,
        ),
      'rechazada' => (
          texto: 'Rechazada',
          color: AppColors.error,
          icono: Icons.cancel_outlined,
        ),
      'cancelada' => (
          texto: 'Cancelada',
          color: AppColors.textSecondary,
          icono: Icons.event_busy_rounded,
        ),
      'completada' => (
          texto: 'Completada',
          color: AppColors.primary,
          icono: Icons.task_alt_rounded,
        ),
      _ => (
          texto: normalizado.isEmpty
              ? 'Sin estado'
              : '${normalizado[0].toUpperCase()}${normalizado.substring(1)}',
          color: AppColors.textSecondary,
          icono: Icons.info_outline_rounded,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: configuracion.color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: configuracion.color.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            configuracion.icono,
            color: configuracion.color,
            size: 23,
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Text(
              configuracion.texto,
              style: TextStyle(
                color: configuracion.color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(
            Icons.verified_outlined,
            color: AppColors.secondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}