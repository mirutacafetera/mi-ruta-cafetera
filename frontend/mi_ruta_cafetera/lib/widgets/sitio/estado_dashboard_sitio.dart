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
            height: AppDimensions.sitioPanelCardGap,
          ),
          _fila(
            icono: Icons.person_rounded,
            titulo: 'Cuenta',
            valor: 'Activa',
            color: AppColors.sitioSuccess,
            fondo: AppColors.sitioSuccessSoft,
          ),
          _separador(),
          _fila(
            icono: Icons.calendar_month_rounded,
            titulo: 'Reservas pendientes',
            valor: dashboard.reservasPendientes.toString(),
            color: AppColors.sitioWarning,
            fondo: AppColors.sitioWarningSoft,
          ),
          _separador(),
          _fila(
            icono: Icons.check_circle_outline_rounded,
            titulo: 'Reservas confirmadas',
            valor: dashboard.reservasConfirmadas.toString(),
            color: AppColors.sitioSuccess,
            fondo: AppColors.sitioSuccessSoft,
          ),
          _separador(),
          _fila(
            icono: Icons.description_rounded,
            titulo: 'Contenido',
            valor: dashboard.totalContenidos.toString(),
            color: AppColors.sitioPrimary,
            fondo: AppColors.sitioSurfaceGreen,
          ),
        ],
      ),
    );
  }

  Widget _estadoPrincipal() {
    final activo = dashboard.activo;

    final color = activo
        ? AppColors.sitioSuccess
        : AppColors.sitioError;

    final fondo = activo
        ? AppColors.sitioSuccessSoft
        : AppColors.sitioErrorSoft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.sitioPanelCardPadding,
      ),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioFormRadius,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              activo
                  ? Icons.check_rounded
                  : Icons.priority_high_rounded,
              color: AppColors.sitioTextOnPrimary,
              size: AppDimensions.sitioActionIconSize + 2,
            ),
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activo ? 'Sitio activo' : 'Sitio inactivo',
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  activo
                      ? 'Tu sitio está disponible en la plataforma.'
                      : 'Tu sitio no está disponible actualmente.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.sitioTextSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _separador() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.sitioDivider,
    );
  }

  Widget _fila({
    required IconData icono,
    required String titulo,
    required String valor,
    required Color color,
    required Color fondo,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.sitioPanelCardGap,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icono,
              size: AppDimensions.sitioActionIconSize,
              color: color,
            ),
          ),
          const SizedBox(
            width: AppDimensions.spacingSm,
          ),
          Expanded(
            child: Text(
              titulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.sitioTextPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 34,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: fondo,
                borderRadius: BorderRadius.circular(
                  AppDimensions.sitioStatusRadius,
                ),
              ),
              child: Text(
                valor,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}