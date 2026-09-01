import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    // Android Emulator
    return 'http://10.0.2.2:3000/api';
  }

  static String get sitiosUrl {
    return '$baseUrl/sitiosturisticos';
  }

  static String get categoriasSitiosUrl {
    return '$baseUrl/categorias-sitios';
  }

  static String get rutasUrl {
    return '$baseUrl/rutas';
  }

  static String get calcularRutaUrl {
    return '$rutasUrl/calcular';
  }
}