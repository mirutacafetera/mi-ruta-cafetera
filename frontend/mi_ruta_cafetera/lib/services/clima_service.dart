import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/clima_model.dart';

/// Consulta el clima actual en Open-Meteo (sin API key).
class ClimaService {
  ClimaService._();

  static Future<ClimaModel> obtener({
    required double latitud,
    required double longitud,
  }) async {
    final uri = Uri.parse(ApiConfig.climaUrl).replace(
      queryParameters: {
        'latitude': latitud.toStringAsFixed(4),
        'longitude': longitud.toStringAsFixed(4),
        'current':
            'temperature_2m,weather_code,precipitation,is_day',
        'hourly': 'precipitation_probability',
        'forecast_days': '1',
        'timezone': 'auto',
      },
    );

    final response = await http.get(uri).timeout(
          const Duration(seconds: 8),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'El servicio de clima respondió '
        '${response.statusCode}.',
      );
    }

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta del clima no tiene un formato válido.',
      );
    }

    return ClimaModel.fromOpenMeteo(data);
  }
}