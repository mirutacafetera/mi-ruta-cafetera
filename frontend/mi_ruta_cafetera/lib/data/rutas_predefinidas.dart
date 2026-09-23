import 'package:flutter/material.dart';

import '../models/ruta_predefinida_model.dart';
import '../theme/app_colors.dart';

class RutasPredefinidas {
  RutasPredefinidas._();

  static const List<RutaPredefinidaModel> todas = [
    // =====================================================
    // CORREDOR GIGANTE → ZULUAGA → GARZÓN
    // =====================================================

    RutaPredefinidaModel(
      id: 'corredor_gigante_zuluaga_garzon',
      nombre: 'Gigante → Zuluaga → Garzón',
      descripcion:
          'Corredor turístico regional que integra sitios de Gigante, Zuluaga y Garzón siguiendo la red vial disponible.',
      icono: Icons.alt_route,
      color: AppColors.secondary,
      municipios: [
        'Gigante',
        'Zuluaga',
        'Garzón',
      ],
      esCorredorRegional: true,
    ),

    // =====================================================
    // CORREDOR GIGANTE → GARZÓN
    // =====================================================

    RutaPredefinidaModel(
      id: 'corredor_gigante_garzon',
      nombre: 'Gigante → Garzón',
      descripcion:
          'Recorrido turístico entre Gigante y Garzón utilizando la trayectoria vial disponible.',
      icono: Icons.route,
      color: AppColors.info,
      municipios: [
        'Gigante',
        'Garzón',
      ],
      esCorredorRegional: true,
    ),

    // =====================================================
    // RUTA INTEGRAL DEL CAFÉ
    // =====================================================

    RutaPredefinidaModel(
      id: 'r1',
      nombre: 'Ruta Integral del Café Especial',
      descripcion:
          'Experiencia que integra café, naturaleza, gastronomía, miradores y productos locales.',
      icono: Icons.coffee,
      color: AppColors.secondary,
      categorias: [
        'Café',
        'Aventuras',
        'Experiencias Familiares',
        'Artesanías y Productos Locales',
      ],
    ),

    // =====================================================
    // AVENTURA Y NATURALEZA
    // =====================================================

    RutaPredefinidaModel(
      id: 'r2',
      nombre: 'Aventura y Naturaleza Cafetera',
      descripcion:
          'Recorrido orientado a naturaleza, senderos, miradores y actividades de aventura.',
      icono: Icons.terrain,
      color: AppColors.success,
      categorias: [
        'Aventuras',
      ],
    ),

    // =====================================================
    // EXPERIENCIA FAMILIAR
    // =====================================================

    RutaPredefinidaModel(
      id: 'r3',
      nombre: 'Experiencia Familiar y Tradición',
      descripcion:
          'Recorrido enfocado en cultura, experiencias familiares y productos locales.',
      icono: Icons.family_restroom,
      color: AppColors.warning,
      categorias: [
        'Cultura e Historia',
        'Experiencias Familiares',
        'Artesanías y Productos Locales',
      ],
    ),
  ];
}