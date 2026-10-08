import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // ============================================================
  // IP DEL COMPUTADOR
  // ============================================================

  // Para celular físico.
  // Si la IP de tu PC cambia, puedes cambiarla al ejecutar
  // usando --dart-define=API_PC_IP=...
  static const String _ipPc = String.fromEnvironment(
    'API_PC_IP',
    defaultValue: '192.168.0.42',
  );

  // ============================================================
  // DISPOSITIVO FÍSICO
  // ============================================================

  static const bool _celular = String.fromEnvironment(
    'USE_PHYSICAL_DEVICE',
    defaultValue: 'false',
  ) == 'true';

  // ============================================================
  // URL BASE
  // ============================================================

  static String get baseUrl {
    // Flutter Web
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    // Celular físico
    if (_celular) {
      return 'http://$_ipPc:3000/api';
    }

    // Emulador Android
    return 'http://10.0.2.2:3000/api';
  }

  // ============================================================
  // URL PARA CELULAR FÍSICO
  // ============================================================

  static String get baseUrlCelular {
    return 'http://$_ipPc:3000/api';
  }

  // ============================================================
  // SITIOS
  // ============================================================

  static String get sitiosUrl {
    return '$baseUrl/sitios';
  }

  // ============================================================
  // CATEGORÍAS DE SITIOS
  // ============================================================

  static String get categoriasSitiosUrl {
    return '$baseUrl/categorias-sitios';
  }

  // ============================================================
  // CATEGORÍAS GENERALES
  // ============================================================

  static String get categoriasUrl {
    return '$baseUrl/categorias';
  }

  // ============================================================
  // RUTAS
  // ============================================================

  static String get rutasUrl {
    return '$baseUrl/rutas';
  }

  static String get calcularRutaUrl {
    return '$rutasUrl/calcular';
  }

  // ============================================================
  // CHAT
  // ============================================================

  static String get chatUrl {
    return '$baseUrl/chat';
  }
}