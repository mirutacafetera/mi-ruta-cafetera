import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // ============================================================
  // IP DEL COMPUTADOR
  // ============================================================

  static const String _ipPc = String.fromEnvironment(
    'API_PC_IP',
    defaultValue: '192.168.1.112',
  );

  // ============================================================
  // DISPOSITIVO FÍSICO
  // ============================================================

  static const bool _celular = bool.fromEnvironment(
    'USE_PHYSICAL_DEVICE',
    defaultValue: false,
  );

  // ============================================================
  // URL BASE
  // ============================================================

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    if (_celular) {
      return 'http://$_ipPc:3000/api';
    }

    return 'http://10.0.2.2:3000/api';
  }

  // ============================================================
  // URL PARA CELULAR
  // ============================================================

  static String get baseUrlCelular =>
      'http://$_ipPc:3000/api';

  // ============================================================
  // SITIOS TURÍSTICOS
  // ============================================================

  static String get sitiosUrl =>
    '$baseUrl/sitios';

  // ============================================================
  // CATEGORÍAS DE SITIOS
  // ============================================================

  static String get categoriasSitiosUrl =>
      '$baseUrl/categorias-sitios';

  // ============================================================
  // CATEGORÍAS GENERALES
  // ============================================================

  static String get categoriasUrl =>
      '$baseUrl/categorias';

  // ============================================================
  // RUTAS
  // ============================================================

  static String get rutasUrl =>
      '$baseUrl/rutas';

  static String get calcularRutaUrl =>
      '$rutasUrl/calcular';

  // ============================================================
  // CHAT
  // ============================================================

  static String get chatUrl =>
      '$baseUrl/chat';
}