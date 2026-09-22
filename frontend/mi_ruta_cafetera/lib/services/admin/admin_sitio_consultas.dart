import 'dart:convert';

import 'package:http/http.dart' as http;

class AdminSitioConsultas {
  static Future<List<dynamic>> obtenerSitios(
    String baseUrl,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/sitios'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      throw Exception(
        'La respuesta del servidor no tiene el formato esperado.',
      );
    }

    throw Exception(
      'Error al obtener los sitios turísticos: '
      '${response.statusCode} - ${response.body}',
    );
  }

  static Future<List<dynamic>> obtenerCategorias(
    String baseUrl,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/categorias-sitios'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      if (data is Map<String, dynamic>) {
        final categorias = data['categorias'];

        if (categorias is List) {
          return categorias;
        }
      }

      throw Exception(
        'La respuesta del servidor no tiene el formato '
        'esperado para categorías.',
      );
    }

    throw Exception(
      'Error al obtener las categorías: '
      '${response.statusCode} - ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> obtenerSitio(
    String baseUrl,
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
        'La respuesta del servidor no tiene el formato esperado.',
      );
    }

    throw Exception(
      'Error al obtener el sitio turístico: '
      '${response.statusCode} - ${response.body}',
    );
  }
}