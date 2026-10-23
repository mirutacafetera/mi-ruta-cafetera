import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class FiltrosContenido extends StatelessWidget {
  final String seleccionado;
  final ValueChanged<String> onSeleccionar;

  const FiltrosContenido({
    super.key,
    required this.seleccionado,
    required this.onSeleccionar,
  });

  static const List<_OpcionFiltro> _opciones = [
    _OpcionFiltro(
      titulo: 'Todos',
      valor: 'todas',
      icono: Icons.grid_view_rounded,
      color: AppColors.primary,
    ),
    _OpcionFiltro(
      titulo: 'Pendientes',
      valor: 'pendiente_revision',
      icono: Icons.pending_actions_rounded,
      color: Colors.orange,
    ),
    _OpcionFiltro(
      titulo: 'Aprobados',
      valor: 'aprobado',
      icono: Icons.check_circle_outline_rounded,
      color: Colors.green,
    ),
    _OpcionFiltro(
      titulo: 'Rechazados',
      valor: 'rechazado',
      icono: Icons.cancel_outlined,
      color: Colors.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingSm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < _opciones.length; i++) ...[
              if (i > 0)
                const SizedBox(width: AppDimensions.spacingSm),
              _FiltroContenidoItem(
                opcion: _opciones[i],
                seleccionado: seleccionado == _opciones[i].valor,
                onTap: () => onSeleccionar(_opciones[i].valor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OpcionFiltro {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _OpcionFiltro({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });
}

class _FiltroContenidoItem extends StatelessWidget {
  final _OpcionFiltro opcion;
  final bool seleccionado;
  final VoidCallback onTap;

  const _FiltroContenidoItem({
    required this.opcion,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: seleccionado
          ? opcion.color.withValues(alpha: 0.12)
          : const Color(0xFFFFFCF7),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        splashColor: opcion.color.withValues(alpha: 0.08),
        highlightColor: opcion.color.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: seleccionado
                  ? opcion.color
                  : const Color(0xFFC18A65),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                opcion.icono,
                size: 18,
                color: opcion.color,
              ),
              const SizedBox(width: 6),
              Text(
                opcion.titulo,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: seleccionado
                      ? opcion.color
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}