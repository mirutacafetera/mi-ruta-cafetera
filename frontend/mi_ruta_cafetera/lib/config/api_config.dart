import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // ============================================================
  // IP DEL COMPUTADOR EN LA RED LOCAL
  // ============================================================
  //
  // Para celular físico.
  // Si la IP del PC cambia, se puede cambiar al ejecutar mediante:
  //
  // --dart-define=API_PC_IP=192.168.1.101
  //
  static const String _ipPc = String.fromEnvironment(
    'API_PC_IP',
    defaultValue: '192.168.1.101',
  );

  // ============================================================
  // DISPOSITIVO FÍSICO
  // ============================================================
  //
  // Por defecto Flutter utilizará el emulador Android.
  //
  // Para celular físico:
  //
  // --dart-define=USE_PHYSICAL_DEVICE=true
  //
  static const bool _celular = bool.fromEnvironment(
    'USE_PHYSICAL_DEVICE',
    defaultValue: false,
  );

  // ============================================================
  // URL BASE
  // ============================================================

  static String get baseUrl {
    // Flutter Web
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    // Celular físico conectado a la misma red del PC
    if (_celular) {
      return 'http://$_ipPc:3000/api';
    }

    // Emulador Android
    return 'http://10.0.2.2:3000/api';
  }

  // ============================================================
  // URL PARA CELULAR FÍSICO
  // ============================================================

  static String get baseUrlCelular =>
      'http://$_ipPc:3000/api';

  // ============================================================
  // ENDPOINTS
  // ============================================================

  static String get chatUrl =>
      '$baseUrl/chat';

  static String get sitiosUrl =>
      '$baseUrl/sitios';

  static String get categoriasUrl =>
      '$baseUrl/categorias';

  static String get categoriasSitiosUrl =>
      '$baseUrl/categorias-sitios';

  static String get rutasUrl =>
      '$baseUrl/rutas';

  static String get calcularRutaUrl =>
      '$rutasUrl/calcular';
}
