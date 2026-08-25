import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/categoria_model.dart';

class CategoriaService {
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
        'Error al obtener categorías: ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    List<dynamic> data;

    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final dynamic categorias =
          decoded['categorias'] ??
          decoded['data'] ??
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
        .where((categoria) => categoria.estado)
        .toList();
  }

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
        'Error al obtener categoría: ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Respuesta inválida del servidor.',
      );
    }

    return CategoriaModel.fromJson(decoded);
  }
}