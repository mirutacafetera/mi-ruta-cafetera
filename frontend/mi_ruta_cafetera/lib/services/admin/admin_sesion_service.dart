import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AdminSesionService {
  AdminSesionService._();

  static const String _claveSesion = 'admin_sesion';

  // ============================================================
  // GUARDAR SESIÓN
  // ============================================================

  static Future<void> guardarSesion(
    Map<String, dynamic> sesion,
  ) async {
    final preferencias =
        await SharedPreferences.getInstance();

    await preferencias.setString(
      _claveSesion,
      jsonEncode(sesion),
    );
  }

  // ============================================================
  // OBTENER SESIÓN
  // ============================================================

  static Future<Map<String, dynamic>?> obtenerSesion() async {
    final preferencias =
        await SharedPreferences.getInstance();

    final datos =
        preferencias.getString(_claveSesion);

    if (datos == null || datos.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(datos);

      if (json is Map<String, dynamic>) {
        return json;
      }

      return null;
    } catch (_) {
      await cerrarSesion();
      return null;
    }
  }

  // ============================================================
  // OBTENER TOKEN
  // ============================================================

  static Future<String?> obtenerToken() async {
    final sesion = await obtenerSesion();

    final token = sesion?['token'];

    if (token == null || token.toString().trim().isEmpty) {
      return null;
    }

    return token.toString();
  }

  // ============================================================
  // OBTENER DATOS DEL ADMINISTRADOR
  // ============================================================

  static Future<Map<String, dynamic>?> obtenerAdministrador() async {
    final sesion = await obtenerSesion();

    final administrador =
        sesion?['administrador'];

    if (administrador is Map<String, dynamic>) {
      return administrador;
    }

    return null;
  }

  // ============================================================
  // COMPROBAR SESIÓN
  // ============================================================

  static Future<bool> haySesionActiva() async {
    final sesion = await obtenerSesion();

    if (sesion == null) {
      return false;
    }

    final token = sesion['token'];
    final administrador = sesion['administrador'];

    if (token == null ||
        token.toString().trim().isEmpty) {
      return false;
    }

    if (administrador is! Map<String, dynamic>) {
      return false;
    }

    return administrador['activo'] == true &&
        administrador['rol'] == 'admin';
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  static Future<void> cerrarSesion() async {
    final preferencias =
        await SharedPreferences.getInstance();

    await preferencias.remove(_claveSesion);
  }
}