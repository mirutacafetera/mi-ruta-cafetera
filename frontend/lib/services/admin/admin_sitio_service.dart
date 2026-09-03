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
      Uri.parse('$baseUrl/admin/authsitio'),
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
  // OBTENER TODAS LAS CATEGORÍAS
  // =====================================================

  static Future<List<dynamic>> obtenerCategorias() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/categorias')
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Caso 1:
      // El backend devuelve directamente:
      //
      // [
      //   {...},
      //   {...}
      // ]

      if (data is List) {
        return data;
      }

      // Caso 2:
      // El backend devuelve:
      //
      // {
      //   "categorias": [...]
      // }

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
      Uri.parse('$baseUrl/admin/authsitio/$id'),
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
  // CREAR SITIO TURÍSTICO
  // =====================================================

  static Future<void> crearSitio({
    required String correo,
    required String password,
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
    final response = await http.post(
      Uri.parse('$baseUrl/admin/authsitio'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'correo': correo,
        'password': password,
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

    if (response.statusCode != 201) {
      throw Exception(
        'Error al crear el sitio turístico: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }

  // =====================================================
  // ACTUALIZAR SITIO TURÍSTICO
  // =====================================================

  static Future<void> actualizarSitio({
    required String id,
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

    // El correo solamente se envía
    // si se quiere actualizar.
    if (correo != null && correo.trim().isNotEmpty) {
      datos['correo'] = correo.trim();
    }

    // La contraseña solamente se envía
    // si se quiere cambiar.
    if (password != null && password.trim().isNotEmpty) {
      datos['password'] = password.trim();
    }

    final response = await http.put(
      Uri.parse('$baseUrl/admin/authsitio/$id'),
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
      Uri.parse('$baseUrl/admin/authsitio/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al eliminar el sitio turístico: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }
}