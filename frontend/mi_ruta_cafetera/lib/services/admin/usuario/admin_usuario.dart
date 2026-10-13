
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../models/admin/usuario_admin.dart';
import '../admin_servicio_autenticacion.dart';

class AdminUsuarioService {
  AdminUsuarioService._();

  static String get _urlBase {
    return '${ApiConfig.baseUrl}/admin/usuarios';
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

  static Future<List<UsuarioAdmin>> obtenerUsuarios() async {
    try {
      final response = await http
          .get(
            Uri.parse(_urlBase),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body.isEmpty) {
          return [];
        }

        final data = jsonDecode(response.body);

        if (data is! List) {
          throw Exception(
            'La respuesta de usuarios tiene un formato inválido.',
          );
        }

        return data
            .whereType<Map<String, dynamic>>()
            .map(UsuarioAdmin.fromJson)
            .toList();
      }

      throw Exception(_obtenerMensajeError(response));
    } on http.ClientException {
      throw Exception(
        'No fue posible conectarse con el servidor.',
      );
    } on FormatException {
      throw Exception(
        'El servidor devolvió una respuesta inválida.',
      );
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
          'El servidor tardó demasiado en responder.',
        );
      }

      rethrow;
    }
  }

  static Future<UsuarioAdmin> obtenerUsuario(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_urlBase/${Uri.encodeComponent(id)}'),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data = jsonDecode(response.body);

        if (data is! Map<String, dynamic>) {
          throw Exception(
            'La respuesta del usuario tiene un formato inválido.',
          );
        }

        return UsuarioAdmin.fromJson(data);
      }

      throw Exception(_obtenerMensajeError(response));
    } on http.ClientException {
      throw Exception(
        'No fue posible conectarse con el servidor.',
      );
    } on FormatException {
      throw Exception(
        'El servidor devolvió una respuesta inválida.',
      );
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
          'El servidor tardó demasiado en responder.',
        );
      }

      rethrow;
    }
  }

  static Future<UsuarioAdmin> desactivarUsuario(String id) async {
    return _cambiarEstadoUsuario(
      id: id,
      accion: 'desactivar',
    );
  }

  static Future<UsuarioAdmin> activarUsuario(String id) async {
    return _cambiarEstadoUsuario(
      id: id,
      accion: 'activar',
    );
  }

  static Future<UsuarioAdmin> _cambiarEstadoUsuario({
    required String id,
    required String accion,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse(
              '$_urlBase/${Uri.encodeComponent(id)}/$accion',
            ),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data = jsonDecode(response.body);

        if (data is! Map<String, dynamic>) {
          throw Exception(
            'La respuesta del servidor tiene un formato inválido.',
          );
        }

        final usuario = data['usuario'];

        if (usuario is! Map<String, dynamic>) {
          throw Exception(
            'El servidor no devolvió los datos del usuario.',
          );
        }

        return UsuarioAdmin.fromJson(usuario);
      }

      throw Exception(_obtenerMensajeError(response));
    } on http.ClientException {
      throw Exception(
        'No fue posible conectarse con el servidor.',
      );
    } on FormatException {
      throw Exception(
        'El servidor devolvió una respuesta inválida.',
      );
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
          'El servidor tardó demasiado en responder.',
        );
      }

      rethrow;
    }
  }

  static Future<void> eliminarUsuario(String id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_urlBase/${Uri.encodeComponent(id)}'),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return;
      }

      throw Exception(_obtenerMensajeError(response));
    } on http.ClientException {
      throw Exception(
        'No fue posible conectarse con el servidor.',
      );
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
          'El servidor tardó demasiado en responder.',
        );
      }

      rethrow;
    }
  }

  static String _obtenerMensajeError(http.Response response) {
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
