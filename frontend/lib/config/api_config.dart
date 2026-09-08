import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // ============================================================
  // URL BASE DE LA API
  // ============================================================

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    // Android Emulator
    return 'http://10.0.2.2:3000/api';
  }

  // ============================================================
  // SITIOS / PUNTOS DE INTERÉS
  //
  // Consulta pública utilizada por la aplicación del usuario
  // para cargar los sitios que aparecen en el mapa.
  //
  // Backend:
  // GET /api/sitios
  // ============================================================

  static String get sitiosUrl {
  return '$baseUrl/sitios';
  }

  // ============================================================
  // CATEGORÍAS
  //
  // Consulta pública utilizada por la aplicación del usuario
  // para cargar las categorías de los puntos de interés.
  //
  // Backend:
  // GET /api/categorias
  // ============================================================

  static String get categoriasUrl {
    return '$baseUrl/categorias';
  }

  // ============================================================
  // CATEGORÍAS DE SITIOS
  //
  // Se conserva por ahora.
  //
  // NO se elimina porque puede estar siendo utilizada por
  // módulos administrativos u otras partes del proyecto.
  //
  // Backend:
  // /api/categorias-sitios
  // ============================================================

  static String get categoriasSitiosUrl {
    return '$baseUrl/categorias-sitios';
  }

  // ============================================================
  // RUTAS
  //
  // Backend:
  // /api/rutas
  // ============================================================

  static String get rutasUrl {
    return '$baseUrl/rutas';
  }

  // ============================================================
  // CALCULAR RUTA
  //
  // Backend:
  // POST /api/rutas/calcular
  // ============================================================

  static String get calcularRutaUrl {
    return '$rutasUrl/calcular';
  }
}