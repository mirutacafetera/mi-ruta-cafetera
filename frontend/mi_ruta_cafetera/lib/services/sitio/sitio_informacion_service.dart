import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/sitio/sitio_informacion_model.dart';

class SitioInformacionService {
  Future<SitioInformacionModel> obtenerInformacion(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/informacion',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return SitioInformacionModel.fromJson(
        Map<String, dynamic>.from(data['sitio']),
      );
    }

    try {
      final data = jsonDecode(response.body);

      throw Exception(
        data['mensaje']?.toString() ??
            'No fue posible obtener la información del sitio.',
      );
    } catch (_) {
      throw Exception(
        'No fue posible obtener la información del sitio.',
      );
    }
  }

  Future<SitioInformacionModel> actualizarInformacion({
    required String token,
    required SitioInformacionModel sitio,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/informacion',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(sitio.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return SitioInformacionModel.fromJson(
        Map<String, dynamic>.from(data['sitio']),
      );
    }

    try {
      final data = jsonDecode(response.body);

      throw Exception(
        data['mensaje']?.toString() ??
            'No fue posible actualizar la información.',
      );
    } catch (_) {
      throw Exception(
        'No fue posible actualizar la información.',
      );
    }
  }
}