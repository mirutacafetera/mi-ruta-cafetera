
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import 'componentes_detalle_actividad.dart';

/// Tarjeta principal reutilizable para actividades, productos y contenido.
class TarjetaPrincipalActividad extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String? imagenUrl;
  final String? estado;

  const TarjetaPrincipalActividad({
    super.key,
    required this.titulo,
    required this.descripcion,
    this.imagenUrl,
    this.estado,
  });

  @override
  Widget build(BuildContext context) {
    final mostrarImagen =
        imagenUrl != null && imagenUrl!.trim().isNotEmpty;

    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre de la actividad y estado en la misma fila.
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                titulo.trim().isEmpty ? 'Sin título' : titulo,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            _EstadoActividad(estado: estado),
          ],
        ),
        const SizedBox(height: 20),
        const TituloDetalleActividad(
          texto: 'Descripción',
          icono: Icons.subject_rounded,
          color: AppColors.secondary,
        ),
        const SizedBox(height: 10),
        Text(
          descripcion.trim().isEmpty
              ? 'No hay descripción disponible.'
              : descripcion,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );

    return TarjetaDetalleActividad(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (!mostrarImagen) {
              return contenido;
            }

            final imagen = ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imagenUrl!,
                width: constraints.maxWidth < 420
                    ? double.infinity
                    : 112,
                height: constraints.maxWidth < 420 ? 175 : 190,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: constraints.maxWidth < 420
                      ? double.infinity
                      : 112,
                  height: constraints.maxWidth < 420 ? 175 : 190,
                  color: AppColors.surfaceVariant,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );

            if (constraints.maxWidth < 420) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imagen,
                  const SizedBox(height: 16),
                  contenido,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imagen,
                const SizedBox(width: 16),
                Expanded(child: contenido),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Estado ubicado a la derecha del nombre de la actividad.
class _EstadoActividad extends StatelessWidget {
  final String? estado;

  const _EstadoActividad({this.estado});

  @override
  Widget build(BuildContext context) {
    final valor = estado?.toLowerCase().trim() ?? '';

    final Color color;
    final String texto;
    final IconData icono;

    if (valor == 'aprobada' || valor == 'aprobado') {
      color = const Color(0xFF276749);
      texto = 'Aprobada';
      icono = Icons.check_circle_rounded;
    } else if (valor == 'rechazada' || valor == 'rechazado') {
      color = const Color(0xFFB85C50);
      texto = 'Rechazada';
      icono = Icons.cancel_rounded;
    } else if (valor == 'pendiente_revision' ||
        valor == 'pendiente de revisión' ||
        valor == 'pendiente de revision' ||
        valor == 'pendiente') {
      color = const Color(0xFFD97706);
      texto = 'Pendiente';
      icono = Icons.schedule_rounded;
    } else {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icono,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 3),
        Text(
          texto,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
