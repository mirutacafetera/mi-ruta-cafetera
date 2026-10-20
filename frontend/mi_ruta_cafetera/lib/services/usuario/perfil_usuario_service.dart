import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/usuario/avatar_cafetero_model.dart';
import '../../models/usuario/usuario_sesion_model.dart';
import 'usuario_sesion_service.dart';

// ============================================================
// PERFIL DEL USUARIO
// ============================================================
//
// Usa los endpoints existentes del backend:
//
//   GET    /usuarios/perfil   (token)
//   PUT    /usuarios/:id      (token, solo el propio usuario)
//   DELETE /usuarios/:id      (token, solo el propio usuario)
//
// Todos los métodos devuelven un mapa con:
//   exito   bool
//   mensaje String
//   codigo  int?   (status HTTP; útil para distinguir 401)
//
// Cuando el backend devuelve el usuario actualizado, la sesión
// local (UsuarioSesionService) se actualiza conservando el token.
// ============================================================

class PerfilUsuarioService {
  PerfilUsuarioService._();

  static Map<String, String> _cabeceras(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // CONSULTAR MI PERFIL
  // ============================================================

  static Future<Map<String, dynamic>> obtenerPerfil() async {
    final sesion = UsuarioSesionService.instance.sesionActual.value;

    if (sesion == null) {
      return _sinSesion();
    }

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/usuarios/perfil'),
            headers: _cabeceras(sesion.token),
          )
          .timeout(const Duration(seconds: 10));

      final data = _decodificar(response.body);

      if (response.statusCode == 200 && data['usuario'] is Map) {
        await _guardarUsuario(sesion, data['usuario']);

        return {
          'exito': true,
          'mensaje': '',
          'codigo': response.statusCode,
          // true si la cuenta se creó con Google (la identidad se
          // confirma con Google en vez de con contraseña).
          'cuentaGoogle':
              (data['usuario'] as Map)['cuentaGoogle'] == true,
        };
      }

      return _fallo(response.statusCode, data,
          'No fue posible cargar tu perfil');
    } catch (e) {
      debugPrint('Error consultando perfil: $e');
      return _errorConexion(e);
    }
  }

  // ============================================================
  // ACTUALIZAR DATOS PERSONALES
  // ============================================================
  //
  // Solo se envían los campos indicados. El correo no se puede
  // modificar desde aquí (el backend lo ignora).
  // ============================================================

  static Future<Map<String, dynamic>> actualizarDatos({
    required String nombre,
    required String apellido,
    required String telefono,
    required String ciudad,
  }) {
    return _actualizar({
      'nombre': nombre.trim(),
      'apellido': apellido.trim(),
      'telefono': telefono.trim(),
      'ciudad': ciudad.trim(),
    });
  }

  // ============================================================
  // ACTUALIZAR AVATAR
  // ============================================================

  static Future<Map<String, dynamic>> actualizarAvatar(
    AvatarCafeteroModel avatar,
  ) {
    return _actualizar({'avatar': avatar.toJson()});
  }

  static Future<Map<String, dynamic>> _actualizar(
    Map<String, dynamic> cambios,
  ) async {
    final sesion = UsuarioSesionService.instance.sesionActual.value;

    if (sesion == null) {
      return _sinSesion();
    }

    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/usuarios/${sesion.id}'),
            headers: _cabeceras(sesion.token),
            body: jsonEncode(cambios),
          )
          .timeout(const Duration(seconds: 10));

      final data = _decodificar(response.body);

      if (response.statusCode == 200 && data['usuario'] is Map) {
        await _guardarUsuario(sesion, data['usuario']);

        return {
          'exito': true,
          'mensaje':
              data['mensaje'] ?? 'Perfil actualizado correctamente',
          'codigo': response.statusCode,
        };
      }

      return _fallo(response.statusCode, data,
          'No fue posible guardar los cambios');
    } catch (e) {
      debugPrint('Error actualizando perfil: $e');
      return _errorConexion(e);
    }
  }

  // ============================================================
  // ELIMINAR (ANONIMIZAR) MI CUENTA
  // ============================================================
  //
  // Cuenta con contraseña → se envía `password`.
  // Cuenta de Google      → se envía `idToken` recién obtenido.
  //
  // El backend exige `confirmar: true`. Si todo sale bien, la
  // sesión local se cierra desde la pantalla que llama.
  // ============================================================

  static Future<Map<String, dynamic>> eliminarCuenta({
    String? password,
    String? idToken,
  }) async {
    final sesion = UsuarioSesionService.instance.sesionActual.value;

    if (sesion == null) {
      return _sinSesion();
    }

    try {
      final request = http.Request(
        'DELETE',
        Uri.parse('${ApiConfig.baseUrl}/usuarios/${sesion.id}'),
      );

      request.headers.addAll(_cabeceras(sesion.token));
      request.body = jsonEncode({
        'confirmar': true,
        'password': ?password,
        'idToken': ?idToken,
      });

      final streamed = await request
          .send()
          .timeout(const Duration(seconds: 15));

      final response = await http.Response.fromStream(streamed);

      final data = _decodificar(response.body);

      if (response.statusCode == 200) {
        return {
          'exito': true,
          'mensaje': data['mensaje'] ??
              'Tu cuenta fue eliminada correctamente',
          'codigo': response.statusCode,
        };
      }

      return _fallo(response.statusCode, data,
          'No fue posible eliminar la cuenta');
    } catch (e) {
      debugPrint('Error eliminando cuenta: $e');
      return _errorConexion(e);
    }
  }

  // ============================================================
  // AUXILIARES
  // ============================================================

  static Future<void> _guardarUsuario(
    UsuarioSesionModel sesion,
    dynamic usuario,
  ) async {
    final nueva = UsuarioSesionModel.fromRespuesta(
      token: sesion.token,
      usuario: Map<String, dynamic>.from(usuario as Map),
    );

    await UsuarioSesionService.instance.guardarSesion(nueva);
  }

  static Map<String, dynamic> _decodificar(String cuerpo) {
    try {
      final data = jsonDecode(cuerpo);

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
    } catch (_) {}

    return <String, dynamic>{};
  }

  static Map<String, dynamic> _fallo(
    int codigo,
    Map<String, dynamic> data,
    String porDefecto,
  ) {
    return {
      'exito': false,
      'mensaje': (data['mensaje'] ?? porDefecto).toString(),
      'codigo': codigo,
    };
  }

  static Map<String, dynamic> _sinSesion() {
    return {
      'exito': false,
      'mensaje': 'Debes iniciar sesión para continuar.',
      'codigo': 401,
    };
  }

  static Map<String, dynamic> _errorConexion(Object error) {
    String mensaje = 'No se pudo completar la operación.';

    if (error is http.ClientException) {
      mensaje = 'No se pudo conectar con el servidor. '
          'Verifica que el backend esté funcionando.';
    } else if (error is FormatException) {
      mensaje = 'El servidor devolvió una respuesta no válida.';
    } else if (error is Exception) {
      mensaje = 'Ocurrió un problema durante la solicitud. '
          'Inténtalo nuevamente.';
    }

    return {
      'exito': false,
      'mensaje': mensaje,
      'codigo': 0,
    };
  }
}