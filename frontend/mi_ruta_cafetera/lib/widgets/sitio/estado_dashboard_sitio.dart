import 'package:flutter/material.dart';

import '../../models/sitio/sitio_dashboard_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import 'tarjeta_seccion_sitio.dart';

class EstadoDashboardSitio extends StatelessWidget {
  final SitioDashboardModel dashboard;

  const EstadoDashboardSitio({
    super.key,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    return TarjetaSeccionSitio(
      titulo: 'Estado de tu sitio',
      subtitulo:
          'Consulta rápidamente la situación actual de tu cuenta.',
      icono: Icons.verified_rounded,
      child: Column(
        children: [
          _estadoPrincipal(),

          const SizedBox(
            height: AppDimensions.spacingMd,
          ),

          _fila(
            icono: Icons.person_rounded,
            titulo: 'Cuenta',
            valor: 'Activa',
          ),

          const Divider(height: 1),

          _fila(
            icono: Icons.calendar_month_rounded,
            titulo: 'Reservas pendientes',
            valor:
                dashboard.reservasPendientes.toString(),
          ),

          const Divider(height: 1),

          _fila(
            icono:
                Icons.check_circle_outline_rounded,
            titulo: 'Reservas confirmadas',
            valor:
                dashboard.reservasConfirmadas.toString(),
          ),

          const Divider(height: 1),

          _fila(
            icono: Icons.description_rounded,
            titulo: 'Contenido',
            valor:
                dashboard.totalContenidos.toString(),
          ),
        ],
      ),
    );
  }

  Widget _estadoPrincipal() {
    final activo = dashboard.activo;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: activo
            ? AppColors.surfaceGreen
            : AppColors.orangeSoft.withValues(
                alpha: 0.45,
              ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
        border: Border.all(
          color: activo
              ? AppColors.primary.withValues(
                  alpha: 0.12,
                )
              : AppColors.orangeSoft,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: activo
                  ? AppColors.primary
                  : AppColors.orangeSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              activo
                  ? Icons.check_rounded
                  : Icons.priority_high_rounded,
              color: activo
                  ? AppColors.white
                  : AppColors.coffeeDark,
              size: AppDimensions.iconMd,
            ),
          ),

          const SizedBox(
            width: AppDimensions.spacingMd,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  activo
                      ? 'Sitio activo'
                      : 'Sitio inactivo',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: AppDimensions.spacingXs,
                ),

                Text(
                  activo
                      ? 'Tu sitio está disponible en la plataforma.'
                      : 'Tu sitio no está disponible actualmente.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
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

  Widget _fila({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingSm,
      ),
      child: Row(
        children: [
          Icon(
            icono,
            size: AppDimensions.iconMd,
            color: AppColors.textSecondary,
          ),

          const SizedBox(
            width: AppDimensions.spacingSm,
          ),

          Expanded(
            child: Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(
            width: AppDimensions.spacingSm,
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingSm,
              vertical: AppDimensions.spacingXs,
            ),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusPill,
              ),
            ),
            child: Text(
              valor,
              style: const TextStyle(
                color: AppColors.coffeeDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}