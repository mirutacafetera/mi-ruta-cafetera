import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AdminSitioService {
  // =====================================================
  // URL DEL BACKEND
  // =====================================================

  static String get baseUrl {
    // Flutter Web / Chrome
    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    // Android Emulator
    return 'http://10.0.2.2:3000/api';
  }

  // =====================================================
  // OBTENER SITIOS
  // =====================================================

  static Future<List<dynamic>> obtenerSitios() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/sitios'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Error al obtener los sitios turísticos: '
      '${response.statusCode} - ${response.body}',
    );
  }

  // =====================================================
  // CREAR SITIO
  // =====================================================

  static Future<void> crearSitio({
    required String nombre,
    required String descripcion,
    required String categoria,
    String direccion = '',
    double latitud = 0,
    double longitud = 0,
    List<String> fotos = const [],
    List<String> videos = const [],
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/sitios'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'categoria': categoria,
        'direccion': direccion,
        'ubicacion': {'latitud': latitud, 'longitud': longitud},
        'fotos': fotos,
        'videos': videos,
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
  // ACTUALIZAR SITIO
  // =====================================================

  static Future<void> actualizarSitio({
    required String id,
    required String nombre,
    required String descripcion,
    required String categoria,
    String direccion = '',
    double latitud = 0,
    double longitud = 0,
    List<String> fotos = const [],
    List<String> videos = const [],
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/sitios/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'categoria': categoria,
        'direccion': direccion,
        'ubicacion': {'latitud': latitud, 'longitud': longitud},
        'fotos': fotos,
        'videos': videos,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al actualizar el sitio turístico: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }

  // =====================================================
  // DESACTIVAR SITIO
  // =====================================================

  static Future<void> desactivarSitio(String id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/sitios/$id/desactivar'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al desactivar el sitio turístico: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }
}
