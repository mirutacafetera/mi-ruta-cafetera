import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AdminSesionService {
  AdminSesionService._();

  static const String _claveSesion = 'admin_sesion';
  static const String _claveTokenAdmin = 'token_admin';
  static const String _claveIdAdministrador = 'id_admin';

  /// Guarda una sesión completa de administrador.
  static Future<void> guardarSesion(
    Map<String, dynamic> sesion,
  ) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setString(
      _claveSesion,
      jsonEncode(sesion),
    );

    final token = sesion['token'];

    if (token != null && token.toString().trim().isNotEmpty) {
      await preferencias.setString(
        _claveTokenAdmin,
        token.toString().trim(),
      );
    }

    final administrador = sesion['administrador'];

    if (administrador is Map) {
      final id = administrador['_id'] ??
          administrador['id'] ??
          administrador['idAdministrador'];

      if (id != null && id.toString().trim().isNotEmpty) {
        await preferencias.setString(
          _claveIdAdministrador,
          id.toString().trim(),
        );
      }
    }
  }

  /// Recupera la sesión completa, si existe.
  static Future<Map<String, dynamic>?> obtenerSesion() async {
    final preferencias = await SharedPreferences.getInstance();
    final datos = preferencias.getString(_claveSesion);

    if (datos == null || datos.trim().isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(datos);

      if (json is Map) {
        return Map<String, dynamic>.from(json);
      }

      return null;
    } catch (_) {
      await preferencias.remove(_claveSesion);
      return null;
    }
  }

  /// Recupera el token utilizado por el inicio de sesión real.
  ///
  /// Primero consulta `token_admin`, que es la clave que guarda
  /// AdminServicioAutenticacion. Después intenta la sesión anterior.
  static Future<String?> obtenerToken() async {
    final preferencias = await SharedPreferences.getInstance();

    final tokenAdmin = preferencias.getString(_claveTokenAdmin);

    if (tokenAdmin != null && tokenAdmin.trim().isNotEmpty) {
      return tokenAdmin.trim();
    }

    final sesion = await obtenerSesion();
    final tokenAnterior = sesion?['token'];

    if (tokenAnterior != null &&
        tokenAnterior.toString().trim().isNotEmpty) {
      return tokenAnterior.toString().trim();
    }

    return null;
  }

  /// Recupera los datos del administrador de la sesión guardada.
  static Future<Map<String, dynamic>?> obtenerAdministrador() async {
    final sesion = await obtenerSesion();
    final administrador = sesion?['administrador'];

    if (administrador is Map) {
      return Map<String, dynamic>.from(administrador);
    }

    return null;
  }

  /// Comprueba si existe una sesión con token e información del administrador.
  static Future<bool> haySesionActiva() async {
    final token = await obtenerToken();

    if (token == null || token.trim().isEmpty) {
      return false;
    }

    final administrador = await obtenerAdministrador();

    if (administrador == null) {
      // El inicio de sesión actual también guarda el ID por separado.
      final preferencias = await SharedPreferences.getInstance();
      final idAdministrador =
          preferencias.getString(_claveIdAdministrador);

      return idAdministrador != null &&
          idAdministrador.trim().isNotEmpty;
    }

    final rol = administrador['rol']?.toString().toLowerCase();
    final activo = administrador['activo'];

    return rol == 'admin' && activo != false;
  }

  /// Elimina los datos de sesión guardados por este servicio.
  static Future<void> cerrarSesion() async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.remove(_claveSesion);
    await preferencias.remove(_claveTokenAdmin);
    await preferencias.remove(_claveIdAdministrador);
  }
}