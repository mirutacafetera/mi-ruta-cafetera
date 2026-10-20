import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../models/admin/historial_revision_ia_model.dart';
import '../admin_sesion_service.dart';

class AdminHistorialRevisionIAService {
  AdminHistorialRevisionIAService._();

  static const Duration _timeout = Duration(seconds: 15);

  static Future<Map<String, dynamic>> obtenerHistorial({
    required String tipoSolicitud,
    int pagina = 1,
    int limite = 20,
    String? decision,
  }) async {
    final token = await AdminSesionService.obtenerToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        'La sesión del administrador ha expirado.',
      );
    }

    final parametros = <String, String>{
      'tipoSolicitud': tipoSolicitud,
      'pagina': pagina.toString(),
      'limite': limite.toString(),
      if (decision != null && decision.isNotEmpty)
        'decision': decision,
    };

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/admin/moderacion-contenidos/historial-ia',
    ).replace(queryParameters: parametros);

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${token.trim()}',
          },
        )
        .timeout(_timeout);

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'El servidor devolvió una respuesta no válida.',
      );
    }

    if (response.statusCode != 200) {
      if (data is Map) {
        throw Exception(
          (data['mensaje'] ??
                  data['error'] ??
                  'No se pudo consultar el historial.')
              .toString(),
        );
      }

      throw Exception(
        'No se pudo consultar el historial.',
      );
    }

    if (data is! Map || data['historial'] is! List) {
      throw Exception(
        'La respuesta del historial no es válida.',
      );
    }

    final historial = (data['historial'] as List)
        .whereType<Map>()
        .map(
          (item) => HistorialRevisionIAModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    final paginacion = data['paginacion'] is Map
        ? Map<String, dynamic>.from(data['paginacion'])
        : <String, dynamic>{};

    return {
      'historial': historial,
      'paginacion': paginacion,
    };
  }
}