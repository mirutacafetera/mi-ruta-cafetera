import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../models/admin/cuenta_admin.dart';
import '../admin_servicio_autenticacion.dart';

class AdminServicioCuenta {
  AdminServicioCuenta._();

  static String get _urlBase {
    return '${ApiConfig.baseUrl}/admin/administradores';
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

  static Future<CuentaAdmin> obtenerCuenta(
    String idAdministrador,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_urlBase/$idAdministrador'),
            headers: _headers(),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body.isEmpty) {
          throw Exception(
            'El servidor no devolvió información de la cuenta.',
          );
        }

        final data = jsonDecode(response.body);

        if (data is! Map<String, dynamic>) {
          throw Exception(
            'La respuesta del servidor tiene un formato inválido.',
          );
        }

        return CuentaAdmin.fromJson(data);
      }

      throw Exception(
        _obtenerMensajeError(response),
      );
    } on http.ClientException {
      throw Exception(
        'No fue posible conectarse con el servidor.',
      );
    } on FormatException {
      throw Exception(
        'El servidor devolvió una respuesta inválida.',
      );
    } catch (e) {
      final mensaje = e.toString();

      if (mensaje.contains('TimeoutException')) {
        throw Exception(
          'El servidor tardó demasiado en responder.',
        );
      }

      rethrow;
    }
  }

  static Future<CuentaAdmin> actualizarCuenta({
    required String idAdministrador,
    required String nombre,
    required String apellido,
    required String telefono,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_urlBase/$idAdministrador'),
            headers: _headers(),
            body: jsonEncode({
              'nombre': nombre.trim(),
              'apellido': apellido.trim(),
              'telefono': telefono.trim(),
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body.isEmpty) {
          throw Exception(
            'El servidor no devolvió la cuenta actualizada.',
          );
        }

        final data = jsonDecode(response.body);

        if (data is! Map<String, dynamic>) {
          throw Exception(
            'La respuesta del servidor tiene un formato inválido.',
          );
        }

        final administrador = data['administrador'];

        if (administrador is! Map<String, dynamic>) {
          throw Exception(
            'El servidor no devolvió los datos actualizados.',
          );
        }

        return CuentaAdmin.fromJson(administrador);
      }

      throw Exception(
        _obtenerMensajeError(response),
      );
    } on http.ClientException {
      throw Exception(
        'No fue posible conectarse con el servidor.',
      );
    } on FormatException {
      throw Exception(
        'El servidor devolvió una respuesta inválida.',
      );
    } catch (e) {
      final mensaje = e.toString();

      if (mensaje.contains('TimeoutException')) {
        throw Exception(
          'El servidor tardó demasiado en responder.',
        );
      }

      rethrow;
    }
  }

  static String _obtenerMensajeError(
    http.Response response,
  ) {
    try {
      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          if (data['mensaje'] != null) {
            return data['mensaje'].toString();
          }

          if (data['error'] != null) {
            return data['error'].toString();
          }
        }
      }
    } catch (_) {}

    return 'No fue posible realizar la operación.';
  }
}