import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../models/admin/sitio_admin_model.dart';

class AdminSitioConsultas {
  // Obtener todos los sitios turísticos
  static Future<List<SitioAdminModel>> obtenerSitios(
    String baseUrl,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/sitios'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (item) => SitioAdminModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
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

  // Obtener las categorías de los sitios turísticos
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
        'La respuesta del servidor no tiene el formato esperado '
        'para categorías.',
      );
    }

    throw Exception(
      'Error al obtener las categorías: '
      '${response.statusCode} - ${response.body}',
    );
  }

  // Obtener un sitio turístico por su ID
  static Future<SitioAdminModel> obtenerSitio(
    String baseUrl,
    String id,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/sitios/$id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        final sitioData = data['sitio'];

        if (sitioData is Map) {
          return SitioAdminModel.fromJson(
            Map<String, dynamic>.from(sitioData),
          );
        }

        return SitioAdminModel.fromJson(data);
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