import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/sitio/sitio_sesion_model.dart';
import 'sitio_sesion_service.dart';

class SitioAuthService {
  final SitioSesionService _sesionService = SitioSesionService();

  // Correo y contraseña (flujo tradicional, sin cambios).
  Future<SitioSesionModel> iniciarSesion({
    required String correo,
    required String password,
  }) {
    return _autenticar(
      ruta: 'login',
      cuerpo: {
        'correo': correo.trim(),
        'password': password,
      },
    );
  }

  // Google: el backend valida el idToken y solo admite cuentas de
  // sitio que ya existen. Guarda la sesión igual que el flujo
  // tradicional.
  Future<SitioSesionModel> iniciarSesionConGoogle({
    required String idToken,
  }) {
    return _autenticar(
      ruta: 'login-google',
      cuerpo: {
        'idToken': idToken,
      },
    );
  }

  Future<SitioSesionModel> _autenticar({
    required String ruta,
    required Map<String, dynamic> cuerpo,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/sitios/auth/$ruta'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(cuerpo),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final sesion = SitioSesionModel.fromJson(data);

      await _sesionService.guardarSesion(sesion);

      return sesion;
    }

    try {
      final data = jsonDecode(response.body);

      throw Exception(
        data['mensaje']?.toString() ??
            'No fue posible iniciar sesión.',
      );
    } catch (_) {
      throw Exception(
        'No fue posible iniciar sesión.',
      );
    }
  }

  Future<void> cerrarSesion() async {
    await _sesionService.cerrarSesion();
  }
}
