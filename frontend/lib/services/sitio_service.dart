import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/sitio_turistico_model.dart';

class SitioService {
  Future<List<SitioTuristicoModel>> obtenerSitios() async {
    final response = await http
        .get(
          Uri.parse(ApiConfig.sitiosUrl),
        )
        .timeout(
          const Duration(seconds: 10),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener sitios: ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    List<dynamic> data;

    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final dynamic sitios =
          decoded['sitios'] ??
          decoded['data'] ??
          [];

      data = sitios is List ? sitios : [];
    } else {
      data = [];
    }

    final sitios = data
        .whereType<Map>()
        .map(
          (item) => SitioTuristicoModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((sitio) => sitio.activo)
        .where(
          (sitio) =>
              sitio.latitud != 0.0 &&
              sitio.longitud != 0.0,
        )
        .toList();

    return sitios;
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
          const Duration(seconds: 10),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener el sitio: ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Respuesta inválida del servidor.',
      );
    }

    return SitioTuristicoModel.fromJson(decoded);
  }
}