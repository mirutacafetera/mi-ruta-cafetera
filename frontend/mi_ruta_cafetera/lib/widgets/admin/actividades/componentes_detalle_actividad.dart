
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

/// Tarjeta reutilizable con el borde café y el fondo original.
class TarjetaDetalleActividad extends StatelessWidget {
  final Widget child;

  const TarjetaDetalleActividad({
    super.key,
    required this.child,
  });

  static const Color _cafe = AppColors.adminBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: _cafe,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(15.5),
        ),
        child: child,
      ),
    );
  }
}

/// Título con icono y color configurable.
class TituloDetalleActividad extends StatelessWidget {
  final String texto;
  final IconData icono;
  final Color color;

  const TituloDetalleActividad({
    super.key,
    required this.texto,
    required this.icono,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 23, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Panel que representa el estado actual de la actividad.
class PanelEstadoActividad extends StatelessWidget {
  final bool aprobado;
  final bool rechazado;
  final bool pendiente;

  const PanelEstadoActividad({
    super.key,
    required this.aprobado,
    required this.rechazado,
    required this.pendiente,
  });

  static const Color _terracota = Color(0xFFB85C50);

  @override
  Widget build(BuildContext context) {
    final color = aprobado
        ? AppColors.success
        : rechazado
            ? _terracota
            : AppColors.secondary;

    final titulo = aprobado
        ? 'Actividad aprobada'
        : rechazado
            ? 'Actividad rechazada'
            : pendiente
                ? 'Pendiente de revisión'
                : 'Estado de la actividad';

    final descripcion = aprobado
        ? 'Esta actividad ya fue aprobada.'
        : rechazado
            ? 'Esta actividad ya fue rechazada.'
            : 'Esta actividad está esperando ser aprobada o rechazada.';

    final icono = aprobado
        ? Icons.check_circle_outline_rounded
        : rechazado
            ? Icons.cancel_outlined
            : Icons.schedule_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: .35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icono,
              color: color,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Elemento de información turística con icono, título y valor.
class DatoDetalleActividad extends StatelessWidget {
  final double ancho;
  final IconData icono;
  final String titulo;
  final String valor;

  const DatoDetalleActividad({
    super.key,
    required this.ancho,
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ancho,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.orangeSoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icono,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  valor.trim().isEmpty ? 'No disponible' : valor,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Imagen alternativa cuando no se puede cargar una fotografía.
class ImagenNoDisponibleActividad extends StatelessWidget {
  final double? ancho;
  final double? alto;

  const ImagenNoDisponibleActividad({
    super.key,
    this.ancho,
    this.alto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ancho,
      height: alto ?? 150,
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        size: 30,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// Mensaje mostrado cuando la actividad no tiene fotografías.
class SinImagenesActividad extends StatelessWidget {
  const SinImagenesActividad({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 32,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 10),
          Text(
            'No hay fotografías disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Formato de fecha utilizado en los detalles de la actividad.
class FormateadorFechaActividad {
  static String formatear(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
}
