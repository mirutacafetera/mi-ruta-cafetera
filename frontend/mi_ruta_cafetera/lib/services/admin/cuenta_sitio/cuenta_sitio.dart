
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../config/api_config.dart';
import '../../../../models/admin/cuenta_sitio_model.dart';

class CuentaSitio {
  static String get _baseUrl => ApiConfig.baseUrl;

  static String get _ruta => '$_baseUrl/admin/authsitio';

  static Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> get _headersPublicos {
    return {
      'Content-Type': 'application/json',
    };
  }

  static dynamic _decodificar(String cuerpo) {
    try {
      return jsonDecode(cuerpo);
    } catch (_) {
      return <String, dynamic>{'mensaje': cuerpo};
    }
  }

  static Map<String, dynamic> _procesarRespuesta(
    http.Response respuesta,
    String mensajeError,
  ) {
    final dynamic datos = _decodificar(respuesta.body);

    debugPrint('Estado: ${respuesta.statusCode}');
    debugPrint('Respuesta: ${respuesta.body}');

    if (respuesta.statusCode < 200 ||
        respuesta.statusCode >= 300) {
      final mensaje = datos is Map
          ? datos['mensaje'] ?? mensajeError
          : mensajeError;

      throw Exception(mensaje.toString());
    }

    if (datos is Map) {
      return Map<String, dynamic>.from(datos);
    }

    return {'datos': datos};
  }

  // =====================================================
  // OBTENER CUENTAS
  // =====================================================

  static Future<List<CuentaSitioModel>> obtenerCuentas({
    required String token,
  }) async {
    final respuesta = await http.get(
      Uri.parse('$_ruta/cuentas'),
      headers: _headers(token),
    );

    final datos = _procesarRespuesta(
      respuesta,
      'Error al consultar las cuentas.',
    );

    if (datos['cuentas'] is! List) {
      throw Exception(
        'El servidor no devolvió una lista de cuentas.',
      );
    }

    return (datos['cuentas'] as List)
        .whereType<Map>()
        .map(
          (cuenta) => CuentaSitioModel.fromJson(
            Map<String, dynamic>.from(cuenta),
          ),
        )
        .toList();
  }

  // =====================================================
  // CREAR CUENTA
  // =====================================================

  static Future<CuentaSitioModel> crearCuenta({
    required String token,
    required String sitioId,
    required String nombre,
    required String apellido,
    required String correo,
    required String password,
    required String telefono,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$_ruta/crear-cuenta-sitio'),
      headers: _headers(token),
      body: jsonEncode({
        'sitioId': sitioId,
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'password': password,
        'telefono': telefono,
      }),
    );

    final datos = _procesarRespuesta(
      respuesta,
      'No se pudo crear la cuenta.',
    );

    final cuenta = datos['cuenta'];

    if (cuenta is! Map) {
      throw Exception(
        'El servidor no devolvió la cuenta creada.',
      );
    }

    return CuentaSitioModel.fromJson(
      Map<String, dynamic>.from(cuenta),
    );
  }

  // =====================================================
  // VERIFICAR CORREO AL CREAR LA CUENTA
  // =====================================================

  static Future<Map<String, dynamic>> verificarCorreo({
    required String correo,
    required String codigo,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$_ruta/verificar-correo'),
      headers: _headersPublicos,
      body: jsonEncode({
        'correo': correo.trim(),
        'codigo': codigo.trim(),
      }),
    );

    return _procesarRespuesta(
      respuesta,
      'No se pudo verificar el correo.',
    );
  }

  // =====================================================
  // SOLICITAR CÓDIGO PARA CAMBIAR CORREO O CONTRASEÑA
  // =====================================================

  static Future<Map<String, dynamic>> solicitarCodigoCambioCuenta({
    required String token,
    required String cuentaId,
    String? correo,
    String? password,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$_ruta/cuentas/$cuentaId/solicitar-codigo-cambio'),
      headers: _headers(token),
      body: jsonEncode({
        if (correo != null && correo.trim().isNotEmpty)
          'correo': correo.trim(),
        if (password != null && password.isNotEmpty)
          'password': password,
      }),
    );

    return _procesarRespuesta(
      respuesta,
      'No se pudo enviar el código de autorización.',
    );
  }

  // =====================================================
  // VERIFICAR CÓDIGO Y APLICAR CAMBIOS
  // =====================================================

  static Future<Map<String, dynamic>> verificarCodigoCambioCuenta({
    required String token,
    required String cuentaId,
    required String codigo,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$_ruta/cuentas/$cuentaId/verificar-codigo-cambio'),
      headers: _headers(token),
      body: jsonEncode({
        'codigo': codigo.trim(),
      }),
    );

    return _procesarRespuesta(
      respuesta,
      'No se pudo verificar el código de autorización.',
    );
  }

  // =====================================================
  // ACTUALIZAR DATOS PERSONALES DE LA CUENTA
  // =====================================================

  static Future<Map<String, dynamic>> actualizarCuenta({
    required String token,
    required String cuentaId,
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
  }) async {
    final respuesta = await http.put(
      Uri.parse('$_ruta/cuentas/$cuentaId'),
      headers: _headers(token),
      body: jsonEncode({
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'telefono': telefono,
      }),
    );

    return _procesarRespuesta(
      respuesta,
      'No se pudo actualizar la cuenta.',
    );
  }

  // =====================================================
  // CAMBIAR ESTADO DE LA CUENTA
  // =====================================================

  static Future<Map<String, dynamic>> cambiarEstado({
    required String token,
    required String cuentaId,
    required bool activo,
  }) async {
    final respuesta = await http.patch(
      Uri.parse('$_ruta/cuentas/$cuentaId/estado'),
      headers: _headers(token),
      body: jsonEncode({'activo': activo}),
    );

    return _procesarRespuesta(
      respuesta,
      'No se pudo cambiar el estado de la cuenta.',
    );
  }

  // =====================================================
  // ELIMINAR SITIO Y CUENTA
  // =====================================================

  static Future<Map<String, dynamic>> eliminarSitioYCuenta({
    required String token,
    required String sitioId,
  }) async {
    final respuesta = await http.delete(
      Uri.parse('$_ruta/eliminar-sitio/$sitioId'),
      headers: _headers(token),
    );

    return _procesarRespuesta(
      respuesta,
      'No se pudo eliminar el sitio y su cuenta.',
    );
  }
}
