
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../models/admin/admin_actividad_model.dart';

class ActividadAdmin {
  static String get _baseUrl => ApiConfig.baseUrl;

  static Future<String> _obtenerToken() async {
    final preferencias = await SharedPreferences.getInstance();

    const claves = [
      'tokenAdministrador',
      'token_admin',
      'adminToken',
      'token',
    ];

    for (final clave in claves) {
      final token = preferencias.getString(clave);

      if (token != null && token.trim().isNotEmpty) {
        return token.trim();
      }
    }

    throw Exception(
      'No se encontró el token del administrador. Inicia sesión nuevamente.',
    );
  }

  static Future<Map<String, String>> _encabezados() async {
    final token = await _obtenerToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static dynamic _procesarRespuesta(http.Response respuesta) {
    final contenido = utf8.decode(respuesta.bodyBytes);

    try {
      return jsonDecode(contenido);
    } catch (_) {
      return {
        'mensaje': contenido.isEmpty
            ? 'El servidor devolvió una respuesta vacía.'
            : contenido,
      };
    }
  }

  static String _obtenerMensaje(dynamic datos) {
    if (datos is Map && datos['mensaje'] != null) {
      return datos['mensaje'].toString();
    }

    return 'La solicitud no pudo completarse.';
  }

  // Obtener actividades por estado.
  // Si no se indica estado, solicita los tres estados.
  static Future<List<ActividadAdminModel>> obtenerActividadesPendientes({
    String? estado,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/admin/actividades/pendientes',
    ).replace(
      queryParameters: estado == null ? null : {'estado': estado},
    );

    final respuesta = await http.get(
      uri,
      headers: await _encabezados(),
    );

    final datos = _procesarRespuesta(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_obtenerMensaje(datos));
    }

    if (datos is! Map || datos['actividades'] is! List) {
      throw Exception(
        'El servidor devolvió una lista de actividades inválida.',
      );
    }

    return (datos['actividades'] as List)
        .whereType<Map>()
        .map(
          (elemento) => ActividadAdminModel.fromJson(
            Map<String, dynamic>.from(elemento),
          ),
        )
        .toList();
  }

  static Future<ActividadAdminModel> obtenerActividad(String id) async {
    final respuesta = await http.get(
      Uri.parse('$_baseUrl/admin/actividades/$id'),
      headers: await _encabezados(),
    );

    final datos = _procesarRespuesta(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_obtenerMensaje(datos));
    }

    if (datos is! Map || datos['actividad'] is! Map) {
      throw Exception(
        'No se encontraron los detalles de la actividad.',
      );
    }

    return ActividadAdminModel.fromJson(
      Map<String, dynamic>.from(datos['actividad']),
    );
  }

  static Future<String> aprobarActividad(String id) async {
    final respuesta = await http.put(
      Uri.parse('$_baseUrl/admin/actividades/$id/aprobar'),
      headers: await _encabezados(),
    );

    final datos = _procesarRespuesta(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_obtenerMensaje(datos));
    }

    return _obtenerMensaje(datos);
  }

  static Future<String> rechazarActividad(
    String id,
    String motivoRechazo,
  ) async {
    final motivo = motivoRechazo.trim();

    if (motivo.length < 3) {
      throw Exception(
        'El motivo del rechazo debe tener al menos 3 caracteres.',
      );
    }

    final respuesta = await http.put(
      Uri.parse('$_baseUrl/admin/actividades/$id/rechazar'),
      headers: await _encabezados(),
      body: jsonEncode({
        'motivoRechazo': motivo,
      }),
    );

    final datos = _procesarRespuesta(respuesta);

    if (respuesta.statusCode != 200) {
      throw Exception(_obtenerMensaje(datos));
    }

    return _obtenerMensaje(datos);
  }
}
