import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/ruta_model.dart';

class RutaService {
  Future<List<RutaModel>> obtenerRutas() async {
    final response = await http.get(
      Uri.parse(ApiConfig.rutasUrl),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Error al obtener las rutas: '
        '${response.statusCode}',
      );
    }

    final decoded =
        jsonDecode(response.body);

    dynamic data = decoded;

    if (decoded is Map<String, dynamic>) {
      data = decoded['rutas'] ??
          decoded['data'] ??
          decoded['results'] ??
          [];
    }

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(RutaModel.fromJson)
        .toList();
  }

  Future<RutaModel> obtenerRuta(
    String rutaId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.rutasUrl}/$rutaId',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Error al obtener la ruta: '
        '${response.statusCode}',
      );
    }

    final decoded =
        jsonDecode(response.body);

    final data = decoded is Map<String, dynamic>
        ? (decoded['ruta'] ??
            decoded['data'] ??
            decoded)
        : decoded;

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Respuesta inválida del servidor.',
      );
    }

    return RutaModel.fromJson(data);
  }

  Future<void> eliminarRuta(
    String rutaId,
  ) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.rutasUrl}/$rutaId',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Error al eliminar la ruta: '
        '${response.statusCode}',
      );
    }
  }
}