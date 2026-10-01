import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/sitio/sitio_sesion_model.dart';
import 'sitio_sesion_service.dart';

class SitioAuthService {
  final SitioSesionService _sesionService = SitioSesionService();

  Future<SitioSesionModel> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/sitios/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'correo': correo.trim(),
        'password': password,
      }),
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