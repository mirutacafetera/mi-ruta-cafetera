import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/admin/admin_contenido_model.dart';
import 'admin_sesion_service.dart';

class AdminModeracionContenidoService {
  AdminModeracionContenidoService._();

  static const Duration _timeout = Duration(seconds: 15);

  static Future<Map<String, String>> _headers({
    bool json = false,
  }) async {
    final token = await AdminSesionService.obtenerToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        'La sesión del administrador ha expirado.',
      );
    }

    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token.trim()}',
    };
  }

  static String get _baseUrl =>
      '${ApiConfig.baseUrl}/admin/moderacion-contenidos';

  static Future<List<AdminContenidoModel>>
      obtenerPendientes() async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/pendientes'),
          headers: await _headers(),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is! Map) return [];

      final lista = data['contenidos'];

      if (lista is! List) return [];

      return lista
          .whereType<Map>()
          .map(
            (item) => AdminContenidoModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    throw _error(response);
  }

  static Future<AdminContenidoModel> obtenerDetalle(
    String contenidoId,
  ) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/$contenidoId'),
          headers: await _headers(),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is! Map || data['contenido'] is! Map) {
        throw Exception(
          'La respuesta del contenido no es válida.',
        );
      }

      return AdminContenidoModel.fromJson(
        Map<String, dynamic>.from(data['contenido']),
      );
    }

    throw _error(response);
  }

  static Future<void> aprobar(String contenidoId) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/$contenidoId/aprobar'),
          headers: await _headers(),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw _error(response);
    }
  }

  static Future<void> rechazar({
    required String contenidoId,
    required String motivoRechazo,
  }) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/$contenidoId/rechazar'),
          headers: await _headers(json: true),
          body: jsonEncode({
            'motivoRechazo': motivoRechazo.trim(),
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw _error(response);
    }
  }

  static Exception _error(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map) {
        final mensaje = data['mensaje'] ?? data['error'];

        if (mensaje != null) {
          return Exception(mensaje.toString());
        }
      }
    } catch (_) {}

    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      return Exception(
        'No tienes autorización para realizar esta operación.',
      );
    }

    return Exception(
      'No fue posible completar la operación '
      '(HTTP ${response.statusCode}).',
    );
  }
}