import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/sitio/estado_reservas_sitio.dart';
import '../../widgets/sitio/tarjeta_resumen_reservas_sitio.dart';
import '../../widgets/sitio/tarjeta_seccion_sitio.dart';

class SitioReservasScreen extends StatelessWidget {
  const SitioReservasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final esEscritorio = ancho >= 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: esEscritorio
            ? AppDimensions.pageHorizontal
            : AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingLg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1400,
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
                height: AppDimensions.sectionGap,
              ),
              _seccionReservas(esEscritorio),
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
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(
          height: AppDimensions.spacingXs,
        ),
        Text(
          'Consulta y administra las reservas realizadas en tu sitio turístico.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _resumenReservas(bool esEscritorio) {
    final contenido = [
      const TarjetaResumenReservasSitio(
        icono: Icons.calendar_month_rounded,
        titulo: 'Reservas',
        valor: '0',
        descripcion: 'Reservas recibidas',
      ),
      const TarjetaResumenReservasSitio(
        icono: Icons.pending_actions_rounded,
        titulo: 'Pendientes',
        valor: '0',
        descripcion: 'Por revisar',
      ),
      const TarjetaResumenReservasSitio(
        icono: Icons.check_circle_rounded,
        titulo: 'Confirmadas',
        valor: '0',
        descripcion: 'Reservas confirmadas',
      ),
    ];

    if (esEscritorio) {
      return Row(
        children: [
          Expanded(
            child: contenido[0],
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(
            child: contenido[1],
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(
            child: contenido[2],
          ),
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

  Widget _seccionReservas(bool esEscritorio) {
    return TarjetaSeccionSitio(
      titulo: 'Reservas recibidas',
      subtitulo:
          'Aquí podrás revisar las solicitudes realizadas por los visitantes.',
      icono: Icons.event_available_rounded,
      child: Column(
        children: [
          _filtros(esEscritorio),
          const SizedBox(
            height: AppDimensions.spacingLg,
          ),
          const EstadoReservasSitio(),
        ],
      ),
    );
  }

  Widget _filtros(bool esEscritorio) {
    final filtros = [
      OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(
          Icons.filter_list_rounded,
        ),
        label: const Text(
          'Filtrar reservas',
        ),
      ),
      OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(
          Icons.calendar_today_rounded,
        ),
        label: const Text(
          'Seleccionar fecha',
        ),
      ),
    ];

    if (!esEscritorio) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: filtros[0],
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          SizedBox(
            width: double.infinity,
            child: filtros[1],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: filtros[0],
        ),
        const SizedBox(
          width: AppDimensions.spacingMd,
        ),
        Expanded(
          child: filtros[1],
        ),
      ],
    );
  }
}