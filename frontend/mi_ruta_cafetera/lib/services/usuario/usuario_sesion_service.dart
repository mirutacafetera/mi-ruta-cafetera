import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/usuario/usuario_sesion_model.dart';
import '../google_auth_service.dart';

class UsuarioSesionService {
  UsuarioSesionService._();

  static final UsuarioSesionService instance =
      UsuarioSesionService._();

  static const String _claveSesion = 'usuario_sesion';

  // ============================================================
  // SESIÓN EN MEMORIA
  // ============================================================
  //
  // Null = sin sesión. Perfil, Shell y Home pueden escucharla.
  // ============================================================

  final ValueNotifier<UsuarioSesionModel?> sesionActual =
      ValueNotifier<UsuarioSesionModel?>(null);

  // ============================================================
  // RESTAURAR
  // ============================================================
  //
  // Se llama una vez en main() antes de runApp().
  // ============================================================

  Future<void> restaurar() async {
    sesionActual.value = await obtenerSesion();
  }

  // ============================================================
  // GUARDAR
  // ============================================================

  Future<void> guardarSesion(
    UsuarioSesionModel sesion,
  ) async {
    final preferencias =
        await SharedPreferences.getInstance();

    await preferencias.setString(
      _claveSesion,
      jsonEncode(sesion.toJson()),
    );

    sesionActual.value = sesion;
  }

  // ============================================================
  // OBTENER
  // ============================================================
  //
  // Devuelve null si no hay sesión, si los datos están dañados
  // o si el token ya caducó. En esos casos limpia lo guardado.
  // ============================================================

  Future<UsuarioSesionModel?> obtenerSesion() async {
    final preferencias =
        await SharedPreferences.getInstance();

    final datos = preferencias.getString(_claveSesion);

    if (datos == null || datos.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(datos);

      final sesion = UsuarioSesionModel.fromJson(
        Map<String, dynamic>.from(json),
      );

      if (sesion.token.isEmpty ||
          sesion.id.isEmpty ||
          sesion.expirada) {
        await cerrarSesion();
        return null;
      }

      return sesion;
    } catch (_) {
      await cerrarSesion();
      return null;
    }
  }

  // ============================================================
  // CERRAR
  // ============================================================

  Future<void> cerrarSesion() async {
    final preferencias =
        await SharedPreferences.getInstance();

    await preferencias.remove(_claveSesion);

    sesionActual.value = null;
  }

  // ============================================================
  // CERRAR SESIÓN COMPLETA
  // ============================================================
  //
  // Punto único para el cierre de sesión iniciado por la persona
  // (o por un token vencido): borra la sesión guardada y en
  // memoria, y también cierra la sesión de Google Sign-In para
  // que no quede una cuenta "pegada" en el dispositivo.
  // No elimina la cuenta ni datos del servidor.
  // ============================================================

  Future<void> cerrarSesionCompleta() async {
    await cerrarSesion();

    try {
      await GoogleAuthService.instance.cerrarSesion();
    } catch (_) {
      // Si no había sesión de Google, se ignora.
    }
  }

  // ============================================================
  // HAY SESIÓN
  // ============================================================

  Future<bool> haySesionActiva() async {
    return await obtenerSesion() != null;
  }
}
