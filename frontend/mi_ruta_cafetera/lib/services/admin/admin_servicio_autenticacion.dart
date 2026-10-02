import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

class AdminServicioAutenticacion {
  AdminServicioAutenticacion._();

  // ============================================================
  // TOKEN DEL ADMINISTRADOR
  // ============================================================

  static String? _tokenAdmin;

  static String? get tokenAdmin => _tokenAdmin;

  // ============================================================
  // URL DE INICIO DE SESIÓN
  // ============================================================

  static String get urlInicioSesion {
    return '${ApiConfig.baseUrl}/admin/administradores/login';
  }

  // ============================================================
  // INICIAR SESIÓN
  // ============================================================

  static Future<Map<String, dynamic>> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(urlInicioSesion),
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

      // ========================================================
      // RESPUESTA EXITOSA
      // ========================================================

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

          // ----------------------------------------------------
          // VALIDAR TOKEN
          // ----------------------------------------------------

          if (token == null ||
              token.toString().trim().isEmpty) {
            throw Exception(
              'El servidor no devolvió el token de autenticación.',
            );
          }

          // ----------------------------------------------------
          // VALIDAR ADMINISTRADOR
          // ----------------------------------------------------

          if (administrador == null ||
              administrador is! Map<String, dynamic>) {
            throw Exception(
              'El servidor no devolvió los datos del administrador.',
            );
          }

          // ----------------------------------------------------
          // VALIDAR ROL
          // ----------------------------------------------------

          if (administrador['rol'] != 'admin') {
            throw Exception(
              'La cuenta no tiene permisos de administrador.',
            );
          }

          // ----------------------------------------------------
          // GUARDAR TOKEN
          // ----------------------------------------------------

          _tokenAdmin = token.toString().trim();

          return {
            'token': _tokenAdmin,
            'administrador': administrador,
          };
        }

        throw Exception(
          'La respuesta del servidor tiene un formato inválido.',
        );
      }

      // ========================================================
      // RESPUESTA DE ERROR
      // ========================================================

      String mensajeError =
          'No fue posible iniciar sesión.';

      try {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          if (data['mensaje'] != null) {
            mensajeError = data['mensaje'].toString();
          } else if (data['error'] != null) {
            mensajeError = data['error'].toString();
          }
        }
      } catch (_) {
        // La respuesta no era JSON.
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

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  static void cerrarSesion() {
    _tokenAdmin = null;
  }
}