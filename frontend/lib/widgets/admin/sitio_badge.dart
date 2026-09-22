import 'package:flutter/material.dart';

class SitioBadge extends StatelessWidget {
  final String texto;
  final IconData icono;
  final bool? activo;

  const SitioBadge({
    super.key,
    required this.texto,
    required this.icono,
    this.activo,
  });

  const SitioBadge.estado({
    super.key,
    required bool activo,
  })  : texto = activo ? 'Activo' : 'Inactivo',
        icono = Icons.circle,
        activo = activo;

  @override
  Widget build(BuildContext context) {
    final esEstado = activo != null;

    final backgroundColor = esEstado
        ? activo!
            ? Colors.green.shade50
            : Colors.red.shade50
        : Colors.grey.shade100;

    final textColor = esEstado
        ? activo!
            ? Colors.green.shade700
            : Colors.red.shade700
        : Colors.grey.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: esEstado
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}