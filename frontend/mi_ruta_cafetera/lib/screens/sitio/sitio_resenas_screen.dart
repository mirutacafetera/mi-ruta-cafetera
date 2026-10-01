import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/sitio/tarjeta_seccion_sitio.dart';

class SitioResenasScreen extends StatelessWidget {
  const SitioResenasScreen({super.key});

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
              _resumenResenas(esEscritorio),
              const SizedBox(
                height: AppDimensions.spacingLg,
              ),
              _seccionResenas(),
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
          'Consulta las opiniones que los visitantes han dejado sobre tu sitio turístico.',
          style: TextStyle(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _resumenResenas(bool esEscritorio) {
    final contenido = [
      _tarjetaResumen(
        icono: Icons.star_rounded,
        titulo: 'Calificación',
        valor: '0.0',
        descripcion: 'Promedio de calificación',
      ),
      _tarjetaResumen(
        icono: Icons.rate_review_rounded,
        titulo: 'Reseñas',
        valor: '0',
        descripcion: 'Opiniones recibidas',
      ),
      _tarjetaResumen(
        icono: Icons.thumb_up_alt_rounded,
        titulo: 'Valoraciones',
        valor: '0',
        descripcion: 'Valoraciones positivas',
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

  Widget _seccionResenas() {
    return TarjetaSeccionSitio(
      titulo: 'Opiniones de los visitantes',
      subtitulo:
          'Consulta las experiencias y comentarios que han compartido tus visitantes.',
      icono: Icons.rate_review_rounded,
      child: Column(
        children: [
          _filtros(),
          const SizedBox(
            height: AppDimensions.spacingLg,
          ),
          _estadoSinResenas(),
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
              'Filtrar reseñas',
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
              Icons.star_rounded,
            ),
            label: const Text(
              'Filtrar por calificación',
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

  Widget _estadoSinResenas() {
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
            Icons.rate_review_outlined,
            color: AppColors.textSecondary,
            size: 44,
          ),
          SizedBox(
            height: AppDimensions.spacingMd,
          ),
          Text(
            'Todavía no hay reseñas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Las opiniones de los visitantes aparecerán aquí.',
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