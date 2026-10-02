import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // ============================================================
  // CONFIGURACIÓN DEL SERVIDOR
  // ============================================================

  // IP del computador dentro de la red Wi-Fi.
  //
  // Esta IP se utiliza cuando la aplicación se ejecuta
  // en un celular físico, por ejemplo, el Motorola.
  //
  // El celular y el computador deben estar conectados
  // a la misma red Wi-Fi.
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
    // IMPORTANTE:
    //
    // Para el emulador Android se utiliza:
    // 10.0.2.2
    //
    // 10.0.2.2 representa el localhost de tu computador
    // desde el emulador Android.
    //
    // Para un celular físico se debe utilizar la IP del PC:
    // 192.168.100.41
    //
    // Como Flutter no puede distinguir aquí automáticamente
    // si es un emulador o un celular físico, esta configuración
    // se puede cambiar según el dispositivo que se esté usando.
    //
    // ----------------------------------------------------------

    return 'http://10.0.2.2:3000/api';
  }

  // ============================================================
  // URL PARA CELULAR FÍSICO
  // ============================================================

  // Esta URL se utiliza cuando se ejecuta la aplicación
  // directamente en un celular físico, como el Motorola.
  //
  // El celular y el PC deben estar conectados a la misma
  // red Wi-Fi.
  static String get baseUrlCelular {
    return 'http://$_ipPc:3000/api';
  }

  // ============================================================
  // CHAT
  // ============================================================

  // Backend:
  // POST /api/chat
  static String get chatUrl {
    return '$baseUrl/chat';
  }

  // ============================================================
  // SITIOS / PUNTOS DE INTERÉS
  // ============================================================

  // Backend:
  // GET /api/sitios
  static String get sitiosUrl {
    return '$baseUrl/sitios';
  }

  // ============================================================
  // CATEGORÍAS
  // ============================================================

  // Backend:
  // GET /api/categorias
  static String get categoriasUrl {
    return '$baseUrl/categorias';
  }

  // ============================================================
  // CATEGORÍAS DE SITIOS
  // ============================================================

  // Backend:
  // GET /api/categorias-sitios
  static String get categoriasSitiosUrl {
    return '$baseUrl/categorias-sitios';
  }

  // ============================================================
  // RUTAS
  // ============================================================

  // Backend:
  // GET /api/rutas
  static String get rutasUrl {
    return '$baseUrl/rutas';
  }

  // ============================================================
  // CALCULAR RUTA
  // ============================================================

  // Backend:
  // POST /api/rutas/calcular
  static String get calcularRutaUrl {
    return '$rutasUrl/calcular';
  }
}
