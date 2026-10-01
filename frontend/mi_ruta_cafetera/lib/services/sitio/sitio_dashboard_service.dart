import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/sitio/sitio_dashboard_model.dart';

class SitioDashboardService {
  // =====================================================
  // OBTENER DASHBOARD DEL SITIO
  // =====================================================

  Future<SitioDashboardModel> obtenerDashboard(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitios/panel/dashboard',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    // ---------------------------------------------------
    // RESPUESTA EXITOSA
    // ---------------------------------------------------

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body);

      return SitioDashboardModel.fromJson(
        data,
      );
    }

    // ---------------------------------------------------
    // ERROR DE AUTENTICACIÓN
    // ---------------------------------------------------

    if (response.statusCode == 401) {
      throw Exception(
        'La sesión ha expirado. Debes iniciar sesión nuevamente.',
      );
    }

    // ---------------------------------------------------
    // ERROR DE PERMISOS
    // ---------------------------------------------------

    if (response.statusCode == 403) {
      throw Exception(
        'No tienes permisos para acceder al dashboard del sitio.',
      );
    }

    // ---------------------------------------------------
    // OTROS ERRORES
    // ---------------------------------------------------

    try {
      final data =
          jsonDecode(response.body);

      throw Exception(
        data['mensaje'] ??
            'Error al obtener el dashboard del sitio.',
      );
    } catch (_) {
      throw Exception(
        'Error al obtener el dashboard del sitio.',
      );
    }
  }
}