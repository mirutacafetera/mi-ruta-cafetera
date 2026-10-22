
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

  static const Color _fondo = Color(0xFFFFFCF7);
  static const Color _borde = Color(0xFFD8B69C);
  static const Color _cafe = Color(0xFF76513B);
  static const Color _verde = Color(0xFF285943);
  static const Color _naranja = Color(0xFFFF783E);

  @override
  Widget build(BuildContext context) {
    final opciones = tarjetas ??
        [
          ResumenTarjetaConfig(
            titulo: 'Pendientes',
            cantidad: pendientes,
            icono: Icons.pending_actions_rounded,
            color: _naranja,
            estado: 'pendiente_revision',
          ),
          ResumenTarjetaConfig(
            titulo: 'Aprobados',
            cantidad: aprobados,
            icono: Icons.check_circle_outline_rounded,
            color: _verde,
            estado: 'aprobado',
          ),
          ResumenTarjetaConfig(
            titulo: 'Rechazados',
            cantidad: rechazados,
            icono: Icons.cancel_outlined,
            color: const Color(0xFFB9574D),
            estado: 'rechazado',
          ),
        ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  const _TarjetaResumen({
    required this.titulo,
    required this.cantidad,
    required this.icono,
    required this.color,
  });

  static const Color _fondo = Color(0xFFFFFCF7);
  static const Color _borde = Color(0xFFD8B69C);
  static const Color _cafe = Color(0xFF76513B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: _fondo,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _borde,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: _cafe.withValues(alpha: 0.07),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icono,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              cantidad.toString(),
              style: const TextStyle(
                color: Color(0xFF293D32),
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _cafe,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          Container(
            width: 30,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
