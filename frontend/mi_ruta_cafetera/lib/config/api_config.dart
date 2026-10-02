import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // ============================================================
  // IP DEL PC EN LA RED LOCAL
  // ============================================================
  //
  // Esta es la IPv4 actual obtenida mediante ipconfig.
  //
  // PC:
  // 192.168.1.102
  //
  // Android:
  // utiliza esta IP para comunicarse con Node.js.
  // ============================================================

  static const String _ipPc = '192.168.1.111';

  // ============================================================
  // URL BASE
  // ============================================================

  static String get baseUrl {
    // Flutter Web se ejecuta directamente en el PC,
    // por lo tanto puede utilizar localhost.

    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    // Android / dispositivo físico:
    // utiliza la IP del PC dentro de la red Wi-Fi.
    return 'http://$_ipPc:3000/api';
  }

  // ============================================================
  // CHAT
  // ============================================================

  static String get chatUrl {
    return '$baseUrl/chat';
  }

  // ============================================================
  // SITIOS TURÍSTICOS
  // ============================================================

  static String get sitiosUrl {
    return '$baseUrl/sitios';
  }

  // ============================================================
  // CATEGORÍAS GENERALES
  // ============================================================

  static String get categoriasUrl {
    return '$baseUrl/categorias';
  }

  // ============================================================
  // CATEGORÍAS DE SITIOS TURÍSTICOS
  // ============================================================

  static String get categoriasSitiosUrl {
    return '$baseUrl/categorias-sitios';
  }

  // ============================================================
  // RUTAS
  // ============================================================

  static String get rutasUrl {
    return '$baseUrl/rutas';
  }

  // ============================================================
  // CALCULAR RUTA
  // ============================================================

  static String get calcularRutaUrl {
    return '$rutasUrl/calcular';
  }
}