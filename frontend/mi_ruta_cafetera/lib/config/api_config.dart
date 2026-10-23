
import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // ============================================================
  // CONFIGURACIÓN DE ENTORNO
  // ============================================================

  // Para utilizar Render:
  // --dart-define=USE_REMOTE_API=true
  static const bool _usarBackendRemoto = bool.fromEnvironment(
    'USE_REMOTE_API',
    defaultValue: false,
  );

  // IP del computador para pruebas en red local.
  static const String _ipPc = String.fromEnvironment(
    'API_PC_IP',
    defaultValue: '192.168.1.101',
  );

  // Selección del dispositivo físico o emulador.
  static const bool _celular = bool.fromEnvironment(
    'USE_PHYSICAL_DEVICE',
    defaultValue: true,
  );

  // Backend desplegado.
  static const String _remoteUrl =
      'https://mi-ruta-cafetera.onrender.com/api';

  // ============================================================
  // URL BASE
  // ============================================================

  static String get baseUrl {
    if (_usarBackendRemoto) {
      return _remoteUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    if (_celular) {
      return 'http://$_ipPc:3000/api';
    }

    return 'http://10.0.2.2:3000/api';
  }

  static String get baseUrlCelular =>
      'http://$_ipPc:3000/api';

  // ============================================================
  // ENDPOINTS
  // ============================================================

  static String get chatUrl => '$baseUrl/chat';

  static String get sitiosUrl => '$baseUrl/sitios';

  static String get categoriasUrl => '$baseUrl/categorias';

  static String get categoriasSitiosUrl =>
      '$baseUrl/categorias-sitios';

  static String get rutasUrl => '$baseUrl/rutas';

  static String get calcularRutaUrl =>
      '$rutasUrl/calcular';

  static String get recomendacionesIaUrl =>
      '$baseUrl/v1/ai/recommendations';

  static const String climaUrl =
      'https://api.open-meteo.com/v1/forecast';
}
