import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../l10n/textos.dart';

/// Bloque institucional del Home: qué es Mi Ruta Cafetera,
/// para qué sirve y qué busca aportar.
///
/// Solo describe lo que la aplicación hace hoy (descubrir sitios,
/// guardar favoritos, planear rutas y reservar actividades) y no
/// afirma alianzas, cifras ni resultados. Los iconos y colores
/// salen del mapeo central de categorías ([AppColors]).
class BloqueInstitucional extends StatelessWidget {
  const BloqueInstitucional({super.key});

  /// Categorías que ilustran los temas que reúne la aplicación.
  static const List<String> _pilares = [
    'Café',
    'Gastronomía',
    'Cultura',
    'Naturaleza',
    'Artesanías',
    'Alojamiento',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Tr(
            'Sobre Mi Ruta Cafetera',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.textOnDark,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        // En pantallas anchas (Web, tabletas) el texto no se estira
        // a todo el ancho para conservar una lectura cómoda.
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.spacingXl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Parrafo(
                    'Mi Ruta Cafetera es una aplicación de '
                    'turismo que reúne en un solo lugar fincas '
                    'cafeteras, gastronomía, cultura, naturaleza y '
                    'otros sitios del Huila, para que visitantes y '
                    'viajeros descubran el territorio con información '
                    'clara y organizada.',
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  const _Parrafo(
                    'Su propósito es acercar a quienes visitan la '
                    'región con los lugares y las experiencias que la '
                    'hacen especial, y facilitar que exploren el mapa, '
                    'guarden sus sitios favoritos, planeen rutas y '
                    'reserven actividades.',
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  const _Parrafo(
                    'Al dar visibilidad a quienes mantienen vivos '
                    'estos lugares, la aplicación busca aportar al '
                    'turismo de la región y a la valoración del '
                    'patrimonio cafetero, natural y cultural del '
                    'Huila.',
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  Wrap(
                    spacing: AppDimensions.spacingSm,
                    runSpacing: AppDimensions.spacingSm,
                    children: [
                      for (final pilar in _pilares) _Pilar(nombre: pilar),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Parrafo extends StatelessWidget {
  final String texto;

  const _Parrafo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Tr(
      texto,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        height: 1.5,
      ),
    );
  }
}

class _Pilar extends StatelessWidget {
  final String nombre;

  const _Pilar({required this.nombre});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getColorForCategory(nombre);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingXs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.getSoftColorForCategory(nombre),
        borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
        border: Border.all(color: AppColors.getBorderColorForCategory(nombre)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppColors.getIconForCategory(nombre),
            size: AppDimensions.iconSm,
            color: color,
          ),
          const SizedBox(width: AppDimensions.spacingXs + 2),
          Tr(
            nombre,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
