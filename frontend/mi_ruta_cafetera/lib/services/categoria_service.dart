import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/categoria_model.dart';

class CategoriaService {
  // ============================================================
  // OBTENER TODAS LAS CATEGORÍAS DE SITIOS
  // ============================================================

  Future<List<CategoriaModel>> obtenerCategorias() async {
    final response = await http
        .get(
          Uri.parse(ApiConfig.categoriasSitiosUrl),
        )
        .timeout(
          const Duration(seconds: 10),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener categorías de sitios: '
        '${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(
      response.body,
    );

    List<dynamic> data;

    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final dynamic categorias =
              decoded['categorias'] ??
              decoded['categoriasSitios'] ??
              decoded['data'] ??
              decoded['value'] ??
              decoded['results'] ??
            [];

      data = categorias is List ? categorias : [];
    } else {
      data = [];
    }

    return data
        .whereType<Map>()
        .map(
          (item) => CategoriaModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where(
          (categoria) => categoria.activo || categoria.estado,
        )
        .toList();
  }

  // ============================================================
  // OBTENER UNA CATEGORÍA POR ID
  // ============================================================

  Future<CategoriaModel> obtenerCategoriaPorId(
    String id,
  ) async {
    final response = await http
        .get(
          Uri.parse(
            '${ApiConfig.categoriasSitiosUrl}/$id',
          ),
        )
        .timeout(
          const Duration(seconds: 10),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener categoría de sitio: '
        '${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(
      response.body,
    );

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Respuesta inválida del servidor.',
      );
    }

    return CategoriaModel.fromJson(
      decoded,
    );
  }
}