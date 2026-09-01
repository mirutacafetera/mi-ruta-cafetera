import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/sitio_turistico_model.dart';

class SitioService {
  Future<List<SitioTuristicoModel>> obtenerSitios() async {
    final response = await http
        .get(
          Uri.parse(
            ApiConfig.sitiosUrl,
          ),
        )
        .timeout(
          const Duration(seconds: 20),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener sitios: '
        '${response.statusCode}',
      );
    }

    final dynamic decoded =
        jsonDecode(response.body);

    List<dynamic> data = [];

    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map) {
      final dynamic sitios =
          decoded['sitios'] ??
          decoded['sitiosTuristicos'] ??
          decoded['data'] ??
          decoded['results'];

      if (sitios is List) {
        data = sitios;
      }
    }

    return data
        .whereType<Map>()
        .map(
          (item) => SitioTuristicoModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where(
          (sitio) =>
              sitio.activo &&
              sitio.tieneCoordenadas,
        )
        .toList();
  }

  Future<SitioTuristicoModel> obtenerSitioPorId(
    String id,
  ) async {
    final response = await http
        .get(
          Uri.parse(
            '${ApiConfig.sitiosUrl}/$id',
          ),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener sitio: '
        '${response.statusCode}',
      );
    }

    final dynamic decoded =
        jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Respuesta inválida del servidor.',
      );
    }

    return SitioTuristicoModel.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  }
}