import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_config.dart';

class AdminServicioAutenticacion {
  AdminServicioAutenticacion._();

  static const String _claveToken = 'token_admin';
  static const String _claveIdAdministrador = 'id_admin';

  static String? _tokenAdmin;
  static String? _idAdministrador;

  static String? get tokenAdmin => _tokenAdmin;
  static String? get idAdministrador => _idAdministrador;

  static String get urlInicioSesion {
    return '${ApiConfig.baseUrl}/admin/administradores/login';
  }

  static String get urlRecuperarPassword {
    return '${ApiConfig.baseUrl}/admin/administradores/recuperar-password';
  }

  static String get urlVerificarCodigoRecuperacion {
    return '${ApiConfig.baseUrl}/admin/administradores/verificar-codigo-recuperacion';
  }

  static String get urlRestablecerPassword {
    return '${ApiConfig.baseUrl}/admin/administradores/restablecer-password';
  }

  static Future<void> cargarToken() async {
    final preferencias = await SharedPreferences.getInstance();

    _tokenAdmin = preferencias.getString(_claveToken);
    _idAdministrador =
        preferencias.getString(_claveIdAdministrador);
  }

  static Future<Map<String, dynamic>> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    try {
      debugPrint(
        'URL LOGIN: $urlInicioSesion',
      );

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

      debugPrint(
        'STATUS LOGIN: ${response.statusCode}',
      );

      debugPrint(
        'RESPUESTA LOGIN: ${response.body}',
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body.isEmpty) {
          throw Exception(
            'El servidor no devolvió ninguna respuesta.',
          );
        }

        final data = jsonDecode(response.body);

        if (data is! Map<String, dynamic>) {
          throw Exception(
            'La respuesta del servidor tiene un formato inválido.',
          );
        }

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

        if (administrador['rol'] != 'admin') {
          throw Exception(
            'La cuenta no tiene permisos de administrador.',
          );
        }

        final idAdministrador =
            administrador['id'] ??
            administrador['_id'];

        if (idAdministrador == null ||
            idAdministrador.toString().trim().isEmpty) {
          throw Exception(
            'El servidor no devolvió el ID del administrador.',
          );
        }

        _tokenAdmin = token.toString().trim();
        _idAdministrador =
            idAdministrador.toString().trim();

        final preferencias =
            await SharedPreferences.getInstance();

        await preferencias.setString(
          _claveToken,
          _tokenAdmin!,
        );

        await preferencias.setString(
          _claveIdAdministrador,
          _idAdministrador!,
        );

        return {
          'token': _tokenAdmin,
          'administrador': administrador,
        };
      }

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
      } catch (_) {}

      throw Exception(mensajeError);
    } on http.ClientException catch (e) {
      debugPrint(
        'ERROR DE CONEXIÓN LOGIN: $e',
      );

      throw Exception(
        'No fue posible conectarse con el servidor: $e',
      );
    } on FormatException catch (e) {
      debugPrint(
        'ERROR DE FORMATO LOGIN: $e',
      );

      throw Exception(
        'El servidor devolvió una respuesta inválida.',
      );
    } catch (e) {
      final mensaje = e.toString();

      debugPrint(
        'ERROR LOGIN: $e',
      );

      if (mensaje.contains('TimeoutException')) {
        throw Exception(
          'El servidor tardó demasiado en responder.',
        );
      }

      rethrow;
    }
  }

  static Future<void> solicitarRecuperacion({
    required String correo,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(urlRecuperarPassword),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'correo': correo.trim().toLowerCase(),
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return;
      }

      throw Exception(
        _obtenerMensajeError(response),
      );
    } on http.ClientException catch (e) {
      debugPrint(
        'ERROR DE CONEXIÓN RECUPERACIÓN: $e',
      );

      throw Exception(
        'No fue posible conectarse con el servidor: $e',
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

  static Future<String> verificarCodigoRecuperacion({
    required String correo,
    required String codigo,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(urlVerificarCodigoRecuperacion),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'correo': correo.trim().toLowerCase(),
              'codigo': codigo.trim(),
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body.isEmpty) {
          throw Exception(
            'El servidor no devolvió el token de recuperación.',
          );
        }

        final data = jsonDecode(response.body);

        if (data is! Map<String, dynamic>) {
          throw Exception(
            'La respuesta del servidor tiene un formato inválido.',
          );
        }

        final tokenRecuperacion =
            data['tokenRecuperacion'];

        if (tokenRecuperacion == null ||
            tokenRecuperacion
                .toString()
                .trim()
                .isEmpty) {
          throw Exception(
            'El servidor no devolvió el token de recuperación.',
          );
        }

        return tokenRecuperacion
            .toString()
            .trim();
      }

      throw Exception(
        _obtenerMensajeError(response),
      );
    } on http.ClientException catch (e) {
      debugPrint(
        'ERROR DE CONEXIÓN VERIFICACIÓN: $e',
      );

      throw Exception(
        'No fue posible conectarse con el servidor: $e',
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

  static Future<void> restablecerPassword({
    required String tokenRecuperacion,
    required String nuevaPassword,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(urlRestablecerPassword),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'tokenRecuperacion':
                  tokenRecuperacion.trim(),
              'nuevaPassword': nuevaPassword,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return;
      }

      throw Exception(
        _obtenerMensajeError(response),
      );
    } on http.ClientException catch (e) {
      debugPrint(
        'ERROR DE CONEXIÓN CAMBIO PASSWORD: $e',
      );

      throw Exception(
        'No fue posible conectarse con el servidor: $e',
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

  static Future<void> cerrarSesion() async {
    _tokenAdmin = null;
    _idAdministrador = null;

    final preferencias =
        await SharedPreferences.getInstance();

    await preferencias.remove(_claveToken);
    await preferencias.remove(_claveIdAdministrador);
  }
}