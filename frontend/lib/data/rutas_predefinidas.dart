import 'package:flutter/material.dart';

import '../models/ruta_model.dart';

class RutasPredefinidas {
  RutasPredefinidas._();

  static const List<RutaModel> todas = [
    // =====================================================
    // CORREDOR GIGANTE → ZULUAGA → GARZÓN
    // =====================================================

    RutaModel(
      id: 'corredor_gigante_zuluaga_garzon',
      nombre: 'Gigante → Zuluaga → Garzón',
      descripcion:
          'Corredor turístico regional que integra sitios de Gigante, Zuluaga y Garzón siguiendo la red vial disponible.',
      icono: Icons.alt_route,
      color: Color(0xFF6F4E37),
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

    RutaModel(
      id: 'corredor_gigante_garzon',
      nombre: 'Gigante → Garzón',
      descripcion:
          'Recorrido turístico entre Gigante y Garzón utilizando la trayectoria vial disponible.',
      icono: Icons.route,
      color: Color(0xFF1565C0),
      municipios: [
        'Gigante',
        'Garzón',
      ],
      esCorredorRegional: true,
    ),

    // =====================================================
    // RUTA INTEGRAL DEL CAFÉ
    // =====================================================

    RutaModel(
      id: 'r1',
      nombre: 'Ruta Integral del Café Especial',
      descripcion:
          'Experiencia que integra café, naturaleza, gastronomía, miradores y productos locales.',
      icono: Icons.coffee,
      color: Color(0xFF6F4E37),
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

    RutaModel(
      id: 'r2',
      nombre: 'Aventura y Naturaleza Cafetera',
      descripcion:
          'Recorrido orientado a naturaleza, senderos, miradores y actividades de aventura.',
      icono: Icons.terrain,
      color: Color(0xFF2E7D32),
      categorias: [
        'Aventuras',
      ],
    ),

    // =====================================================
    // EXPERIENCIA FAMILIAR
    // =====================================================

    RutaModel(
      id: 'r3',
      nombre: 'Experiencia Familiar y Tradición',
      descripcion:
          'Recorrido enfocado en cultura, experiencias familiares y productos locales.',
      icono: Icons.family_restroom,
      color: Color(0xFFF57F17),
      categorias: [
        'Cultura e Historia',
        'Experiencias Familiares',
        'Artesanías y Productos Locales',
      ],
    ),
  ];
}