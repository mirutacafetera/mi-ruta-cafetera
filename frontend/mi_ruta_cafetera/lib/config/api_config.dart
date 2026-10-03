import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // ============================================================
<<<<<<< HEAD
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
=======
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
>>>>>>> origin/main
  // URL BASE
  // ============================================================

  static String get baseUrl {
<<<<<<< HEAD
    // Flutter Web se ejecuta directamente en el PC,
    // por lo tanto puede utilizar localhost.

=======
>>>>>>> origin/main
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

<<<<<<< HEAD
    // Android / dispositivo físico:
    // utiliza la IP del PC dentro de la red Wi-Fi.
    return 'http://$_ipPc:3000/api';
  }

  // ============================================================
  // CHAT
=======
    if (_celular) {
      return 'http://$_ipPc:3000/api';
    }

    return 'http://10.0.2.2:3000/api';
  }

  // ============================================================
  // URL PARA CELULAR
>>>>>>> origin/main
  // ============================================================

  static String get baseUrlCelular =>
      'http://$_ipPc:3000/api';

  // ============================================================
  // SITIOS TURÍSTICOS
  // ============================================================

<<<<<<< HEAD
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
=======
  static String get sitiosUrl =>
    '$baseUrl/sitios';

  // ============================================================
  // CATEGORÍAS DE SITIOS
  // ============================================================

  static String get categoriasSitiosUrl =>
      '$baseUrl/categorias-sitios';

  // ============================================================
  // CATEGORÍAS GENERALES
>>>>>>> origin/main
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
<<<<<<< HEAD
  // CALCULAR RUTA
=======
  // CHAT
>>>>>>> origin/main
  // ============================================================

  static String get chatUrl =>
      '$baseUrl/chat';
}