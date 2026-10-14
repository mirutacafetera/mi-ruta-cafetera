import 'package:flutter/material.dart';

import '../../../models/admin/reporte_admin.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class TarjetaReporte extends StatelessWidget {
  final ReporteAdmin reporte;
  final VoidCallback onTap;

  const TarjetaReporte({
    super.key,
    required this.reporte,
    required this.onTap,
  });

  Color _colorEstado() {
    switch (reporte.estado) {
      case 'pendiente':
        return Colors.orange;
      case 'en_revision':
        return Colors.blue;
      case 'resuelto':
        return Colors.green;
      default:
        return AppColors.textSecondary;
    }
  }

  String _textoEstado() {
    switch (reporte.estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_revision':
        return 'En revisión';
      case 'resuelto':
        return 'Resuelto';
      default:
        return reporte.estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = _colorEstado();

    return Card(
      color: AppColors.surface,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        side: BorderSide(
          color: AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppDimensions.spacingMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorEstado.withValues(alpha: 0.15),
                child: Icon(
                  Icons.support_agent_rounded,
                  color: colorEstado,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reporte.asunto,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      reporte.nombreCompleto.isEmpty
                          ? 'Usuario sin nombre'
                          : reporte.nombreCompleto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      reporte.correoUsuario.isEmpty
                          ? 'Correo no disponible'
                          : reporte.correoUsuario,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reporte.mensaje,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colorEstado.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _textoEstado(),
                            style: TextStyle(
                              color: colorEstado,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (reporte.createdAt != null)
                          Text(
                            '${reporte.createdAt!.day.toString().padLeft(2, '0')}/'
                            '${reporte.createdAt!.month.toString().padLeft(2, '0')}/'
                            '${reporte.createdAt!.year}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}