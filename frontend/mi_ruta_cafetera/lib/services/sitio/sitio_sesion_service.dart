import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/sitio/sitio_sesion_model.dart';

class SitioSesionService {
  static const String _claveSesion = 'sitio_sesion';

  Future<void> guardarSesion(SitioSesionModel sesion) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setString(
      _claveSesion,
      jsonEncode(sesion.toJson()),
    );
  }

  Future<SitioSesionModel?> obtenerSesion() async {
    final preferencias = await SharedPreferences.getInstance();

    final datos = preferencias.getString(_claveSesion);

    if (datos == null || datos.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(datos);

      return SitioSesionModel.fromJson(
        Map<String, dynamic>.from(json),
      );
    } catch (_) {
      await cerrarSesion();
      return null;
    }
  }

  Future<String?> obtenerToken() async {
    final sesion = await obtenerSesion();

    return sesion?.token;
  }

  Future<void> cerrarSesion() async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.remove(_claveSesion);
  }

  Future<bool> haySesionActiva() async {
    final sesion = await obtenerSesion();

    return sesion != null &&
        sesion.token.isNotEmpty &&
        sesion.activo;
  }
}