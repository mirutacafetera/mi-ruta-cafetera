import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AdminSitioService {
  // =====================================================
  // URL BASE DEL BACKEND
  // =====================================================

  static String get baseUrl {
    // Flutter Web / Chrome
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    // Android Emulator
    return 'http://10.0.2.2:3000/api';
  }

  // =====================================================
  // OBTENER TODOS LOS SITIOS
  // =====================================================

  static Future<List<dynamic>> obtenerSitios() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/sitios'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      throw Exception(
        'La respuesta del servidor no tiene '
        'el formato esperado.',
      );
    }

    throw Exception(
      'Error al obtener los sitios turísticos: '
      '${response.statusCode} - ${response.body}',
    );
  }

  // =====================================================
  // OBTENER TODAS LAS CATEGORÍAS DE SITIOS
  // =====================================================

  static Future<List<dynamic>> obtenerCategorias() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categorias-sitios'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // -------------------------------------------------
      // Caso 1:
      // El backend devuelve directamente una lista
      // -------------------------------------------------

      if (data is List) {
        return data;
      }

      // -------------------------------------------------
      // Caso 2:
      // El backend devuelve:
      //
      // {
      //   "categorias": [...]
      // }
      // -------------------------------------------------

      if (data is Map<String, dynamic>) {
        final categorias = data['categorias'];

        if (categorias is List) {
          return categorias;
        }
      }

      throw Exception(
        'La respuesta del servidor no tiene '
        'el formato esperado para categorías.',
      );
    }

    throw Exception(
      'Error al obtener las categorías: '
      '${response.statusCode} - ${response.body}',
    );
  }

  // =====================================================
  // OBTENER UN SITIO POR ID
  // =====================================================

  static Future<Map<String, dynamic>> obtenerSitio(
    String id,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/sitios/$id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }

      throw Exception(
        'La respuesta del servidor no tiene '
        'el formato esperado.',
      );
    }

    throw Exception(
      'Error al obtener el sitio turístico: '
      '${response.statusCode} - ${response.body}',
    );
  }

  // =====================================================
  // CREAR SITIO TURÍSTICO + CUENTA
  // =====================================================
  //
  // PRIMERO:
  //   POST /api/admin/sitios
  //
  // DESPUÉS:
  //   POST /api/admin/authsitio/cuenta
  //
  // La cuenta necesita el ID del sitio recién creado.
  // =====================================================

  static Future<Map<String, dynamic>> crearSitio({
    // ---------------------------------------------------
    // DATOS DE LA CUENTA
    // ---------------------------------------------------

    required String nombreCuenta,
    required String apellidoCuenta,
    required String correo,
    required String password,
    String telefonoCuenta = '',

    // ---------------------------------------------------
    // DATOS DEL SITIO
    // ---------------------------------------------------

    required String nombre,
    required String descripcion,
    required String categoria,
    String direccion = '',
    String ciudad = 'Garzón',
    String departamento = 'Huila',
    required double latitud,
    required double longitud,
    List<String> etiquetas = const [],
    bool activo = true,
    String telefono = '',
    String correos = '',
    String sitioWeb = '',
    String imagen = '',
    List<String> imagenes = const [],
    String horario = '',
    double precioDesde = 0,
  }) async {
    // ===================================================
    // 1. CREAR SITIO TURÍSTICO
    // ===================================================

    final responseSitio = await http.post(
      Uri.parse('$baseUrl/admin/sitios'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'direccion': direccion,
        'ciudad': ciudad,
        'departamento': departamento,
        'latitud': latitud,
        'longitud': longitud,
        'categoria': categoria,
        'etiquetas': etiquetas,
        'activo': activo,
        'telefono': telefono,
        'correos': correos,
        'sitioWeb': sitioWeb,
        'imagen': imagen,
        'imagenes': imagenes,
        'horario': horario,
        'precioDesde': precioDesde,
      }),
    );

    if (responseSitio.statusCode != 201) {
      throw Exception(
        'Error al crear el sitio turístico: '
        '${responseSitio.statusCode} - '
        '${responseSitio.body}',
      );
    }

    // ===================================================
    // 2. LEER EL SITIO CREADO
    // ===================================================

    final dataSitio = jsonDecode(
      responseSitio.body,
    );

    if (dataSitio is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta al crear el sitio '
        'no tiene el formato esperado.',
      );
    }

    // El controller devuelve:
    //
    // {
    //   "mensaje": "...",
    //   "sitio": {...}
    // }

    final sitioCreado = dataSitio['sitio'];

    if (sitioCreado is! Map<String, dynamic>) {
      throw Exception(
        'El servidor no devolvió el sitio creado.',
      );
    }

    final sitioId =
        sitioCreado['_id']?.toString() ?? '';

    if (sitioId.isEmpty) {
      throw Exception(
        'No se pudo obtener el ID del sitio creado.',
      );
    }

    // ===================================================
    // 3. CREAR CUENTA DEL SITIO
    // ===================================================

    final responseCuenta = await http.post(
      Uri.parse('$baseUrl/admin/authsitio/cuenta'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sitioId': sitioId,
        'nombre': nombreCuenta,
        'apellido': apellidoCuenta,
        'correo': correo,
        'password': password,
        'telefono': telefonoCuenta,
      }),
    );

    if (responseCuenta.statusCode != 201) {
      throw Exception(
        'El sitio fue creado, pero no se pudo crear '
        'su cuenta: '
        '${responseCuenta.statusCode} - '
        '${responseCuenta.body}',
      );
    }

    // ===================================================
    // 4. DEVOLVER RESULTADO
    // ===================================================

    final dataCuenta = jsonDecode(
      responseCuenta.body,
    );

    return {
      'sitio': sitioCreado,
      'cuenta': dataCuenta is Map<String, dynamic>
          ? dataCuenta['cuenta']
          : null,
    };
  }

  // =====================================================
  // ACTUALIZAR SITIO TURÍSTICO
  // =====================================================
  //
  // IMPORTANTE:
  // correo y password NO se envían aquí.
  //
  // El backend actual NO tiene una ruta para actualizar
  // la cuenta del sitio.
  //
  // Estos parámetros se mantienen opcionales para que
  // el formulario pueda seguir funcionando mientras
  // trabajamos posteriormente la actualización de cuenta.
  // =====================================================

  static Future<void> actualizarSitio({
    required String id,

    // Se mantienen para compatibilidad con el formulario.
    String? correo,
    String? password,

    required String nombre,
    required String descripcion,
    required String categoria,
    String direccion = '',
    String ciudad = 'Garzón',
    String departamento = 'Huila',
    required double latitud,
    required double longitud,
    List<String> etiquetas = const [],
    bool activo = true,
    String telefono = '',
    String correos = '',
    String sitioWeb = '',
    String imagen = '',
    List<String> imagenes = const [],
    String horario = '',
    double precioDesde = 0,
  }) async {
    final Map<String, dynamic> datos = {
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'ciudad': ciudad,
      'departamento': departamento,
      'latitud': latitud,
      'longitud': longitud,
      'categoria': categoria,
      'etiquetas': etiquetas,
      'activo': activo,
      'telefono': telefono,
      'correos': correos,
      'sitioWeb': sitioWeb,
      'imagen': imagen,
      'imagenes': imagenes,
      'horario': horario,
      'precioDesde': precioDesde,
    };

    // ===================================================
    // ACTUALIZAR SITIO
    // ===================================================

    final response = await http.put(
      Uri.parse('$baseUrl/admin/sitios/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(datos),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al actualizar el sitio turístico: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }

  // =====================================================
  // ELIMINAR SITIO TURÍSTICO
  // =====================================================

  static Future<void> eliminarSitio(
    String id,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/sitios/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al eliminar el sitio turístico: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }
}