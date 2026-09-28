import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // ============================================================
  // CONFIGURACIÓN DEL SERVIDOR
  // ============================================================

  // IP del computador dentro de la red Wi-Fi.
  //
  // Esta es la IP de tu PC:
  // 192.168.100.41
  //
  // El Motorola debe estar conectado a la misma red Wi-Fi.
  static const String _ipPc = '192.168.100.41';

  // ============================================================
  // URL BASE DE LA API
  // ============================================================

  static String get baseUrl {
    // ----------------------------------------------------------
    // FLUTTER WEB / CHROME
    // ----------------------------------------------------------
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    // ----------------------------------------------------------
    // ANDROID
    // ----------------------------------------------------------
    //
    // Para el Motorola físico utilizamos la IP del PC.
    //
    // IMPORTANTE:
    // El teléfono y el computador deben estar conectados
    // a la misma red Wi-Fi.
    //
    return 'http://$_ipPc:3000/api';
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
  // GET /api/categorias-sitios
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
  // GET /api/rutas
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