import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class MapaMarcador extends StatelessWidget {
  final SitioTuristicoModel sitio;
  final bool seleccionado;
  final int numero;
  final VoidCallback onTap;

  const MapaMarcador({
    super.key,
    required this.sitio,
    required this.seleccionado,
    required this.numero,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorCategoria = _obtenerColorCategoria();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(
              milliseconds: 200,
            ),
            width: seleccionado
                ? AppDimensions.mapaMarkerWidth - 8
                : AppDimensions.mapaMarkerWidth - 14,
            height: seleccionado
                ? AppDimensions.mapaMarkerWidth - 8
                : AppDimensions.mapaMarkerWidth - 14,
            decoration: BoxDecoration(
              color: seleccionado
                  ? AppColors.tertiary
                  : colorCategoria,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white,
                width: seleccionado
                    ? 4
                    : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: seleccionado
                      ? AppColors.tertiary.withValues(
                          alpha: 0.45,
                        )
                      : AppColors.black.withValues(
                          alpha: 0.24,
                        ),
                  blurRadius: seleccionado
                      ? 10
                      : 6,
                  spreadRadius: seleccionado
                      ? 2
                      : 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: seleccionado
                ? Text(
                    '$numero',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Icon(
                    _obtenerIconoCategoria(),
                    color: AppColors.white,
                    size: AppDimensions.iconMd,
                  ),
          ),

          Container(
            width: 3,
            height: 12,
            color: seleccionado
                ? AppColors.tertiary
                : colorCategoria,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // COLOR SEGÚN CATEGORÍA
  // =====================================================

  Color _obtenerColorCategoria() {
    final categoria =
        sitio.categoriaNombre.toLowerCase();

    if (categoria.contains('café') ||
        categoria.contains('cafe')) {
      return AppColors.secondary;
    }

    if (categoria.contains('naturaleza') ||
        categoria.contains('aventura')) {
      return AppColors.success;
    }

    if (categoria.contains('mirador') ||
        categoria.contains('paisaje')) {
      return AppColors.info;
    }

    if (categoria.contains('cultura') ||
        categoria.contains('historia')) {
      return AppColors.coffeeDark;
    }

    if (categoria.contains('artesanía') ||
        categoria.contains('artesania') ||
        categoria.contains('productos locales')) {
      return AppColors.coffeeLight;
    }

    if (categoria.contains('familiar') ||
        categoria.contains('familia')) {
      return AppColors.warning;
    }

    if (categoria.contains('alojamiento') ||
        categoria.contains('hotel') ||
        categoria.contains('hospedaje')) {
      return AppColors.natureLight;
    }

    if (categoria.contains('gastronom')) {
      return AppColors.error;
    }

    if (categoria.contains('relig')) {
      return AppColors.coffeeDark;
    }

    return AppColors.primary;
  }

  // =====================================================
  // ICONO SEGÚN CATEGORÍA
  // =====================================================

  IconData _obtenerIconoCategoria() {
    final categoria =
        sitio.categoriaNombre.toLowerCase();

    if (categoria.contains('café') ||
        categoria.contains('cafe')) {
      return Icons.coffee;
    }

    if (categoria.contains('naturaleza') ||
        categoria.contains('aventura')) {
      return Icons.park;
    }

    if (categoria.contains('mirador') ||
        categoria.contains('paisaje')) {
      return Icons.landscape;
    }

    if (categoria.contains('cultura') ||
        categoria.contains('historia')) {
      return Icons.account_balance;
    }

    if (categoria.contains('artesanía') ||
        categoria.contains('artesania') ||
        categoria.contains('productos locales')) {
      return Icons.storefront;
    }

    if (categoria.contains('familiar') ||
        categoria.contains('familia')) {
      return Icons.family_restroom;
    }

    if (categoria.contains('alojamiento') ||
        categoria.contains('hotel') ||
        categoria.contains('hospedaje')) {
      return Icons.hotel;
    }

    if (categoria.contains('gastronom')) {
      return Icons.restaurant;
    }

    if (categoria.contains('relig')) {
      return Icons.church;
    }

    return Icons.location_on;
  }
}