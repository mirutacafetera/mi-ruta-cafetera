
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../models/admin/reporte_admin.dart';
import '../admin_servicio_autenticacion.dart';

class AdminReporteService {
  AdminReporteService._();

  static String get _urlBase {
    return '${ApiConfig.baseUrl}/admin/ayuda';
  }

  static Map<String, String> _headers() {
    final token = AdminServicioAutenticacion.tokenAdmin;

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // =====================================================
  // OBTENER TODOS LOS REPORTES
  // =====================================================

  static Future<List<ReporteAdmin>> obtenerReportes() async {
    try {
      final response = await http
          .get(
            Uri.parse(_urlBase),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('URL REPORTES: $_urlBase');
      debugPrint('ESTADO REPORTES: ${response.statusCode}');

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data = jsonDecode(response.body);

        debugPrint('RESPUESTA COMPLETA REPORTES: ${response.body}');

        if (data is! List) {
          throw Exception('Formato de reportes inválido.');
        }

        final reportes = data
            .whereType<Map<String, dynamic>>()
            .map((json) {
              final usuario = json['usuarioId'];

              if (usuario is Map) {
                debugPrint(
                  'USUARIO DEL REPORTE: ${usuario['nombre']} '
                  '${usuario['apellido']}',
                );
                debugPrint(
                  'FOTO GOOGLE: ${usuario['fotoPerfil']}',
                );
                debugPrint(
                  'AVATAR: ${usuario['avatar']}',
                );
              } else {
                debugPrint(
                  'El reporte no tiene usuarioId poblado: $usuario',
                );
              }

              return ReporteAdmin.fromJson(json);
            })
            .toList();

        return reportes;
      }

      throw Exception(_mensajeError(response));
    } catch (e, stackTrace) {
      debugPrint('ERROR AL OBTENER REPORTES: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // =====================================================
  // OBTENER UN REPORTE POR ID
  // =====================================================

  static Future<ReporteAdmin> obtenerReporte(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_urlBase/${Uri.encodeComponent(id)}'),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('ESTADO REPORTE INDIVIDUAL: ${response.statusCode}');

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data = jsonDecode(response.body);

        debugPrint('RESPUESTA REPORTE: ${response.body}');

        if (data is! Map<String, dynamic>) {
          throw Exception('Formato de reporte inválido.');
        }

        final usuario = data['usuarioId'];

        if (usuario is Map) {
          debugPrint('FOTO GOOGLE: ${usuario['fotoPerfil']}');
          debugPrint('AVATAR: ${usuario['avatar']}');
        }

        return ReporteAdmin.fromJson(data);
      }

      throw Exception(_mensajeError(response));
    } catch (e, stackTrace) {
      debugPrint('ERROR AL OBTENER REPORTE: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // =====================================================
  // RESPONDER / ACTUALIZAR REPORTE
  // =====================================================

  static Future<ReporteAdmin> responderReporte({
    required String id,
    required String estado,
    required String respuestaAdmin,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_urlBase/${Uri.encodeComponent(id)}'),
            headers: _headers(),
            body: jsonEncode({
              'estado': estado,
              'respuestaAdmin': respuestaAdmin,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data = jsonDecode(response.body);

        if (data is! Map<String, dynamic>) {
          throw Exception('Formato de respuesta inválido.');
        }

        final reporte = data['reporte'];

        if (reporte is! Map<String, dynamic>) {
          throw Exception('No se recibieron los datos actualizados.');
        }

        final usuario = reporte['usuarioId'];

        if (usuario is Map) {
          debugPrint('FOTO GOOGLE: ${usuario['fotoPerfil']}');
          debugPrint('AVATAR: ${usuario['avatar']}');
        }

        return ReporteAdmin.fromJson(reporte);
      }

      throw Exception(_mensajeError(response));
    } catch (e, stackTrace) {
      debugPrint('ERROR AL RESPONDER REPORTE: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // =====================================================
  // MENSAJES DE ERROR
  // =====================================================

  static String _mensajeError(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return (data['mensaje'] ??
                data['error'] ??
                'No fue posible realizar la operación.')
            .toString();
      }
    } catch (_) {}

    return 'No fue posible realizar la operación.';
  }
}
