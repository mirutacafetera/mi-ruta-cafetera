import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import 'sitio_sesion_service.dart';

class SitioAyudaService {
  final SitioSesionService _sesionService = SitioSesionService();

  Uri get _url => Uri.parse('${ApiConfig.baseUrl}/sitios/ayuda');

  Future<Map<String, String>> _headers() async {
    final token = await _sesionService.obtenerToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception('Tu sesión ha expirado. Inicia sesión nuevamente.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token.trim()}',
    };
  }

  dynamic _decodificar(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _mensajeError(dynamic data, String alternativo) {
    if (data is Map<String, dynamic>) {
      final mensaje = data['mensaje']?.toString().trim();
      if (mensaje != null && mensaje.isNotEmpty) {
        return mensaje;
      }
    }
    return alternativo;
  }

  Future<void> crearReporte({
    required String tipoReporte,
    required String asunto,
    required String mensaje,
  }) async {
    final response = await http.post(
      _url,
      headers: await _headers(),
      body: jsonEncode({
        'tipoReporte': tipoReporte,
        'asunto': asunto.trim(),
        'mensaje': mensaje.trim(),
      }),
    );

    final data = _decodificar(response);

    if (response.statusCode != 201) {
      throw Exception(_mensajeError(data, 'No fue posible enviar el reporte.'));
    }
  }

  Future<List<Map<String, dynamic>>> obtenerMisReportes() async {
    final response = await http.get(_url, headers: await _headers());

    final data = _decodificar(response);

    if (response.statusCode != 200) {
      throw Exception(
        _mensajeError(data, 'No fue posible cargar tus reportes.'),
      );
    }

    if (data is! List) {
      throw Exception(
        'La respuesta del servidor no tiene el formato esperado.',
      );
    }

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
