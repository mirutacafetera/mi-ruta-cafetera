import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

class AuthUsuarioService {
  // ============================================================
  // REGISTRO DE USUARIO
  // ============================================================

  static Future<Map<String, dynamic>> registrarUsuario({
    required String nombre,
    required String apellido,
    required String correo,
    required String password,
    String telefono = '',
    String ciudad = '',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}/usuarios/registrar',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'nombre': nombre.trim(),
              'apellido': apellido.trim(),
              'correo': correo.trim(),
              'password': password,
              'telefono': telefono.trim(),
              'ciudad': ciudad.trim(),
            }),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      debugPrint(
        '📝 Registro usuario - Status: '
        '${response.statusCode}',
      );

      debugPrint(
        '📥 Respuesta: ${response.body}',
      );

      final Map<String, dynamic> data =
          jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return {
          'exito': true,
          'mensaje':
              data['mensaje'] ??
              'Registro realizado correctamente',
          'usuario': data['usuario'],
        };
      }

      return {
        'exito': false,
        'mensaje':
            data['mensaje'] ??
            'No fue posible registrar el usuario',
      };
    } catch (e) {
      debugPrint(
        '❌ Error registrando usuario: $e',
      );

      return {
        'exito': false,
        'mensaje':
            'No se pudo conectar con el servidor',
      };
    }
  }

  // ============================================================
  // VERIFICAR CORREO
  // ============================================================

  static Future<Map<String, dynamic>>
      verificarCorreo({
    required String correo,
    required String codigo,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}/usuarios/'
              'verificar-correo',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'correo': correo.trim(),
              'codigo': codigo.trim(),
            }),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      debugPrint(
        '📧 Verificación correo - Status: '
        '${response.statusCode}',
      );

      debugPrint(
        '📥 Respuesta: ${response.body}',
      );

      final Map<String, dynamic> data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje':
              data['mensaje'] ??
              'Correo verificado correctamente',
        };
      }

      return {
        'exito': false,
        'mensaje':
            data['mensaje'] ??
            'No fue posible verificar el correo',
      };
    } catch (e) {
      debugPrint(
        '❌ Error verificando correo: $e',
      );

      return {
        'exito': false,
        'mensaje':
            'No se pudo conectar con el servidor',
      };
    }
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
            Uri.parse(
              '${ApiConfig.baseUrl}/usuarios/login',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'correo': correo.trim(),
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      debugPrint(
        '🔐 Login usuario - Status: '
        '${response.statusCode}',
      );

      debugPrint(
        '📥 Respuesta: ${response.body}',
      );

      final Map<String, dynamic> data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje':
              data['mensaje'] ??
              'Inicio de sesión exitoso',
          'token': data['token'],
          'usuario': data['usuario'],
        };
      }

      return {
        'exito': false,
        'mensaje':
            data['mensaje'] ??
            'No fue posible iniciar sesión',
      };
    } catch (e) {
      debugPrint(
        '❌ Error en login de usuario: $e',
      );

      return {
        'exito': false,
        'mensaje':
            'No se pudo conectar con el servidor',
      };
    }
  }

  // ============================================================
  // RECUPERAR CONTRASEÑA
  // ============================================================

  static Future<Map<String, dynamic>> recuperarPassword({
    required String correo,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}/usuarios/'
              'recuperar-password',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'correo': correo.trim(),
            }),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      debugPrint(
        '📧 Recuperar contraseña - Status: '
        '${response.statusCode}',
      );

      debugPrint(
        '📥 Respuesta: ${response.body}',
      );

      final Map<String, dynamic> data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje':
              data['mensaje'] ??
              'Código enviado correctamente',
        };
      }

      return {
        'exito': false,
        'mensaje':
            data['mensaje'] ??
            'No fue posible enviar el código',
      };
    } catch (e) {
      debugPrint(
        '❌ Error recuperando contraseña: $e',
      );

      return {
        'exito': false,
        'mensaje':
            'No se pudo conectar con el servidor',
      };
    }
  }

  // ============================================================
  // VERIFICAR CÓDIGO DE RECUPERACIÓN
  // ============================================================

  static Future<Map<String, dynamic>>
      verificarCodigoRecuperacion({
    required String correo,
    required String codigo,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}/usuarios/'
              'verificar-codigo-recuperacion',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'correo': correo.trim(),
              'codigo': codigo.trim(),
            }),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      debugPrint(
        '🔢 Verificar código - Status: '
        '${response.statusCode}',
      );

      debugPrint(
        '📥 Respuesta: ${response.body}',
      );

      final Map<String, dynamic> data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje':
              data['mensaje'] ??
              'Código correcto',
          'tokenRecuperacion':
              data['tokenRecuperacion'],
        };
      }

      return {
        'exito': false,
        'mensaje':
            data['mensaje'] ??
            'Código incorrecto',
      };
    } catch (e) {
      debugPrint(
        '❌ Error verificando código: $e',
      );

      return {
        'exito': false,
        'mensaje':
            'No se pudo conectar con el servidor',
      };
    }
  }

  // ============================================================
  // RESTABLECER CONTRASEÑA
  // ============================================================

  static Future<Map<String, dynamic>>
      restablecerPassword({
    required String tokenRecuperacion,
    required String nuevaPassword,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}/usuarios/'
              'restablecer-password',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'tokenRecuperacion':
                  tokenRecuperacion,
              'nuevaPassword':
                  nuevaPassword,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      debugPrint(
        '🔑 Restablecer contraseña - Status: '
        '${response.statusCode}',
      );

      debugPrint(
        '📥 Respuesta: ${response.body}',
      );

      final Map<String, dynamic> data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje':
              data['mensaje'] ??
              'Contraseña actualizada correctamente',
        };
      }

      return {
        'exito': false,
        'mensaje':
            data['mensaje'] ??
            'No fue posible cambiar la contraseña',
      };
    } catch (e) {
      debugPrint(
        '❌ Error restableciendo contraseña: $e',
      );

      return {
        'exito': false,
        'mensaje':
            'No se pudo conectar con el servidor',
      };
    }
  }
}