
import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // ============================================================
  // CONFIGURACIÓN DE ENTORNO
  // ============================================================

  // true: utiliza el backend remoto de Render.
  // false: utiliza el backend local.
  //
  // Por defecto se utiliza Render.
  //
  // Para ejecutar con el backend local:
  // flutter run --dart-define=USE_REMOTE_API=false
  //
  // Para ejecutar con Render explícitamente:
  // flutter run --dart-define=USE_REMOTE_API=true

  static const bool _usarBackendRemoto = bool.fromEnvironment(
    'USE_REMOTE_API',
    defaultValue: true,
  );

  // IP del computador para pruebas desde un celular físico.
  //
  // Puedes cambiarla al ejecutar Flutter con:
  // --dart-define=API_PC_IP=192.168.1.101

  static const String _ipPc = String.fromEnvironment(
    'API_PC_IP',
    defaultValue: '192.168.1.101',
  );

  // true: dispositivo físico conectado a la red local.
  // false: emulador Android.
  //
  // Solo se utiliza cuando el backend remoto está desactivado.

  static const bool _celular = bool.fromEnvironment(
    'USE_PHYSICAL_DEVICE',
    defaultValue: false,
  );

  // ============================================================
  // DIRECCIONES DEL BACKEND
  // ============================================================

  static const String _remoteUrl =
      'https://mi-ruta-cafetera.onrender.com/api';

  static const String _localUrlWeb =
      'http://localhost:3000/api';

  static const String _localUrlEmulador =
      'http://10.0.2.2:3000/api';

  static String get _localUrlCelular =>
      'http://$_ipPc:3000/api';

  // ============================================================
  // URL BASE
  // ============================================================

  static String get baseUrl {
    // Backend remoto en Render.
    if (_usarBackendRemoto) {
      return _remoteUrl;
    }

    // Backend local cuando se ejecuta en navegador.
    if (kIsWeb) {
      return _localUrlWeb;
    }

    // Backend local desde un celular físico.
    if (_celular) {
      return _localUrlCelular;
    }

    // Backend local desde el emulador Android.
    return _localUrlEmulador;
  }

  // Dirección del backend local para un celular físico.
  static String get baseUrlCelular => _localUrlCelular;

  // Indica si la aplicación utiliza el backend remoto.
  static bool get usaBackendRemoto => _usarBackendRemoto;

  // ============================================================
  // ENDPOINTS
  // ============================================================

  static String get chatUrl => '$baseUrl/chat';

  static String get sitiosUrl => '$baseUrl/sitios';

  static String get categoriasUrl => '$baseUrl/categorias';

  static String get categoriasSitiosUrl =>
      '$baseUrl/categorias-sitios';

  static String get rutasUrl => '$baseUrl/rutas';

  static String get calcularRutaUrl => '$rutasUrl/calcular';

  static String get recomendacionesIaUrl =>
      '$baseUrl/v1/ai/recommendations';

  // ============================================================
  // SERVICIOS EXTERNOS
  // ============================================================

  static const String climaUrl =
      'https://api.open-meteo.com/v1/forecast';
}
