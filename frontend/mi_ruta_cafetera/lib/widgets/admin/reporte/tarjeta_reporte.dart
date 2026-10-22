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

  static const Color _bordeCafe = Color(0xFFB58A70);

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
      color: AppColors.creamLight,
      elevation: 2,
      shadowColor: AppColors.coffeeDark.withValues(alpha: 0.10),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        side: const BorderSide(
          color: _bordeCafe,
          width: 1.4,
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
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: colorEstado.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorEstado.withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  Icons.support_agent_rounded,
                  color: colorEstado,
                  size: 29,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
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
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
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
                    const SizedBox(height: AppDimensions.spacingSm),
                    Text(
                      reporte.mensaje,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    Wrap(
                      spacing: AppDimensions.spacingSm,
                      runSpacing: AppDimensions.spacingSm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorEstado.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorEstado.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            _textoEstado(),
                            style: TextStyle(
                              color: colorEstado,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.secondary,
                  size: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}