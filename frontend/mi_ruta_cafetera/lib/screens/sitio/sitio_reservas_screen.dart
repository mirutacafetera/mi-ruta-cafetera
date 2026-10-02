import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/sitio/tarjeta_seccion_sitio.dart';

class SitioReservasScreen extends StatelessWidget {
  const SitioReservasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final esEscritorio = ancho >= 900;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        esEscritorio
            ? AppDimensions.spacingXl
            : AppDimensions.spacingMd,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _encabezado(context),
              const SizedBox(
                height: AppDimensions.spacingLg,
              ),
              _resumenReservas(esEscritorio),
              const SizedBox(
                height: AppDimensions.spacingLg,
              ),
              _seccionReservas(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reservas',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Consulta y administra las reservas realizadas en tu sitio turístico.',
          style: TextStyle(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _resumenReservas(bool esEscritorio) {
    final contenido = [
      _tarjetaResumen(
        icono: Icons.calendar_month_rounded,
        titulo: 'Reservas',
        valor: '0',
        descripcion: 'Reservas recibidas',
      ),
      _tarjetaResumen(
        icono: Icons.pending_actions_rounded,
        titulo: 'Pendientes',
        valor: '0',
        descripcion: 'Por revisar',
      ),
      _tarjetaResumen(
        icono: Icons.check_circle_rounded,
        titulo: 'Confirmadas',
        valor: '0',
        descripcion: 'Reservas confirmadas',
      ),
    ];

    if (esEscritorio) {
      return Row(
        children: [
          Expanded(child: contenido[0]),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(child: contenido[1]),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(child: contenido[2]),
        ],
      );
    }

    return Column(
      children: [
        contenido[0],
        const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        contenido[1],
        const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        contenido[2],
      ],
    );
  }

  Widget _tarjetaResumen({
    required IconData icono,
    required String titulo,
    required String valor,
    required String descripcion,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
            child: Icon(
              icono,
              color: AppColors.primary,
              size: 25,
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
                  titulo,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  valor,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccionReservas() {
    return TarjetaSeccionSitio(
      titulo: 'Reservas recibidas',
      subtitulo:
          'Aquí podrás revisar las solicitudes realizadas por los visitantes.',
      icono: Icons.event_available_rounded,
      child: Column(
        children: [
          _filtros(),
          const SizedBox(
            height: AppDimensions.spacingLg,
          ),
          _estadoSinReservas(),
        ],
      ),
    );
  }

  Widget _filtros() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.filter_list_rounded,
            ),
            label: const Text(
              'Filtrar reservas',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: AppColors.primary.withValues(
                  alpha: 0.35,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spacingMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: AppDimensions.spacingMd,
        ),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.calendar_today_rounded,
            ),
            label: const Text(
              'Seleccionar fecha',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: AppColors.primary.withValues(
                  alpha: 0.35,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spacingMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _estadoSinReservas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            color: AppColors.textSecondary,
            size: 44,
          ),
          SizedBox(
            height: AppDimensions.spacingMd,
          ),
          Text(
            'No hay reservas todavía',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Las reservas de los visitantes aparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}