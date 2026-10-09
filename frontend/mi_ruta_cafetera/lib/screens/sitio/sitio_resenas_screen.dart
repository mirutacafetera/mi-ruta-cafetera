import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/sitio/estado_resenas_sitio.dart';
import '../../widgets/sitio/tarjeta_resumen_resenas_sitio.dart';
import '../../widgets/sitio/tarjeta_seccion_sitio.dart';

class SitioResenasScreen extends StatelessWidget {
  const SitioResenasScreen({super.key});

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
              _resumenResenas(escritorio: esEscritorio),
              const SizedBox(
                height: AppDimensions.sectionGap,
              ),
              _seccionResenas(escritorio: esEscritorio),
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
          'Reseñas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(
          height: AppDimensions.spacingXs,
        ),
        Text(
          'Consulta las opiniones que los visitantes han dejado sobre tu sitio turístico.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _resumenResenas({
    required bool escritorio,
  }) {
    final tarjetas = [
      const TarjetaResumenResenasSitio(
        icono: Icons.star_rounded,
        titulo: 'Calificación',
        valor: '0.0',
        descripcion: 'Promedio de calificación',
      ),
      const TarjetaResumenResenasSitio(
        icono: Icons.rate_review_rounded,
        titulo: 'Reseñas',
        valor: '0',
        descripcion: 'Opiniones recibidas',
      ),
      const TarjetaResumenResenasSitio(
        icono: Icons.thumb_up_alt_rounded,
        titulo: 'Valoraciones',
        valor: '0',
        descripcion: 'Valoraciones positivas',
      ),
    ];

    if (escritorio) {
      return Row(
        children: [
          Expanded(
            child: tarjetas[0],
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(
            child: tarjetas[1],
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(
            child: tarjetas[2],
          ),
        ],
      );
    }

    return Column(
      children: [
        tarjetas[0],
        const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        tarjetas[1],
        const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        tarjetas[2],
      ],
    );
  }

  Widget _seccionResenas({
    required bool escritorio,
  }) {
    return TarjetaSeccionSitio(
      titulo: 'Opiniones de los visitantes',
      subtitulo:
          'Consulta las experiencias y comentarios que han compartido tus visitantes.',
      icono: Icons.rate_review_rounded,
      child: Column(
        children: [
          _filtros(escritorio: escritorio),
          const SizedBox(
            height: AppDimensions.spacingLg,
          ),
          const EstadoResenasSitio(),
        ],
      ),
    );
  }

  Widget _filtros({
    required bool escritorio,
  }) {
    final filtros = [
      OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(
          Icons.filter_list_rounded,
        ),
        label: const Text(
          'Filtrar reseñas',
        ),
      ),
      OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(
          Icons.star_rounded,
        ),
        label: const Text(
          'Filtrar por calificación',
        ),
      ),
    ];

    if (!escritorio) {
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