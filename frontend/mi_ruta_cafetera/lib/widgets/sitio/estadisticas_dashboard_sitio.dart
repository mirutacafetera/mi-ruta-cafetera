import 'package:flutter/material.dart';

import '../../models/sitio/sitio_dashboard_model.dart';
import '../../theme/app_dimensions.dart';
import 'tarjeta_estadistica_sitio.dart';

class EstadisticasDashboardSitio extends StatelessWidget {
  final SitioDashboardModel dashboard;
  final bool esEscritorio;

  const EstadisticasDashboardSitio({
    super.key,
    required this.dashboard,
    required this.esEscritorio,
  });

  @override
  Widget build(BuildContext context) {
    final tarjetas = [
      const TarjetaEstadisticaSitio(
        titulo: 'Visitas',
        valor: '0',
        descripcion: 'Visitas a tu sitio',
        icono: Icons.visibility_rounded,
      ),
      TarjetaEstadisticaSitio(
        titulo: 'Reservas',
        valor: dashboard.totalReservas.toString(),
        descripcion: 'Reservas recibidas',
        icono: Icons.calendar_month_rounded,
      ),
      TarjetaEstadisticaSitio(
        titulo: 'Reseñas',
        valor: dashboard.totalResenas.toString(),
        descripcion:
            'Promedio ${dashboard.promedioCalificacion.toStringAsFixed(1)} ⭐',
        icono: Icons.star_rounded,
      ),
      TarjetaEstadisticaSitio(
        titulo: 'Actividades',
        valor: dashboard.totalActividades.toString(),
        descripcion: 'Actividades publicadas',
        icono: Icons.local_activity_rounded,
      ),
    ];

    if (esEscritorio) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tarjetas.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: AppDimensions.spacingMd,
          mainAxisSpacing: AppDimensions.spacingMd,
          childAspectRatio: 1.55,
        ),
        itemBuilder: (context, index) {
          return tarjetas[index];
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tarjetas.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.spacingSm,
        mainAxisSpacing: AppDimensions.spacingSm,
        mainAxisExtent: 220,
      ),
      itemBuilder: (context, index) {
        return tarjetas[index];
      },
    );
  }
}