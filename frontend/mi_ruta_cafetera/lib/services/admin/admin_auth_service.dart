import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

class AdminAuthService {
  AdminAuthService._();

  // =====================================================
  // URL DE LOGIN ADMINISTRADOR
  // =====================================================

  static String get loginUrl {
    return '${ApiConfig.baseUrl}/admin/administradores/login';
  }

  // =====================================================
  // INICIAR SESIÓN
  // =====================================================

  static Future<Map<String, dynamic>> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(loginUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'correo': correo.trim().toLowerCase(),
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      // =================================================
      // RESPUESTA EXITOSA
      // =================================================

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body.isEmpty) {
          throw Exception(
            'El servidor no devolvió ninguna respuesta.',
          );
        }

        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          final token = data['token'];
          final administrador = data['administrador'];

          if (token == null ||
              token.toString().trim().isEmpty) {
            throw Exception(
              'El servidor no devolvió el token de autenticación.',
            );
          }

          if (administrador == null ||
              administrador is! Map<String, dynamic>) {
            throw Exception(
              'El servidor no devolvió los datos del administrador.',
            );
          }

          // ---------------------------------------------
          // COMPROBAR ROL DEVUELTO POR EL BACKEND
          // ---------------------------------------------

          if (administrador['rol'] != 'admin') {
            throw Exception(
              'La cuenta no tiene permisos de administrador.',
            );
          }

          return {
            'token': token.toString(),
            'administrador': administrador,
          };
        }

        throw Exception(
          'La respuesta del servidor tiene un formato inválido.',
        );
      }

      // =================================================
      // RESPUESTA DE ERROR
      // =================================================

      String mensajeError =
          'No fue posible iniciar sesión.';

      try {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          if (data['mensaje'] != null) {
            mensajeError =
                data['mensaje'].toString();
          } else if (data['error'] != null) {
            mensajeError =
                data['error'].toString();
          }
        }
      } catch (_) {
        // Si la respuesta no es JSON, usamos el mensaje
        // general.
      }

      throw Exception(mensajeError);
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
}