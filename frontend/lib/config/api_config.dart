import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // ============================================================
  // URL BASE DE LA API
  // ============================================================

  static String get baseUrl {
    // Flutter Web / Chrome
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    // Android Emulator
    return 'http://10.0.2.2:3000/api';
  }

  // ============================================================
  // CHAT
  // ============================================================
  //
  // Backend:
  // POST /api/chat
  //
  // ============================================================

  static String get chatUrl {
    return '$baseUrl/chat';
  }

  // ============================================================
  // SITIOS / PUNTOS DE INTERÉS
  // ============================================================
  //
  // Backend:
  // GET /api/sitios
  //
  // ============================================================

  static String get sitiosUrl {
    return '$baseUrl/sitios';
  }

  // ============================================================
  // CATEGORÍAS
  // ============================================================
  //
  // Backend:
  // GET /api/categorias
  //
  // ============================================================

  static String get categoriasUrl {
    return '$baseUrl/categorias';
  }

  // ============================================================
  // CATEGORÍAS DE SITIOS
  // ============================================================
  //
  // Se conserva porque puede ser utilizada por otros módulos.
  //
  // Backend:
  // /api/categorias-sitios
  //
  // ============================================================

  static String get categoriasSitiosUrl {
    return '$baseUrl/categorias-sitios';
  }

  // ============================================================
  // RUTAS
  // ============================================================
  //
  // Backend:
  // /api/rutas
  //
  // ============================================================

  static String get rutasUrl {
    return '$baseUrl/rutas';
  }

  // ============================================================
  // CALCULAR RUTA
  // ============================================================
  //
  // Backend:
  // POST /api/rutas/calcular
  //
  // ============================================================

  static String get calcularRutaUrl {
    return '$rutasUrl/calcular';
  }
}