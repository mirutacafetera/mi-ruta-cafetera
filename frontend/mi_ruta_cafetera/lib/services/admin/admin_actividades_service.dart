import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/admin/admin_actividad_model.dart';
import 'admin_sesion_service.dart';

class AdminActividadesService {
  AdminActividadesService._();

  // ============================================================
  // OBTENER ACTIVIDADES PENDIENTES
  // ============================================================

  static Future<List<AdminActividadModel>>
      obtenerPendientes() async {
    final token =
        await AdminSesionService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'La sesión del administrador ha expirado.',
      );
    }

    final response = await http
        .get(
          Uri.parse(
            '${ApiConfig.baseUrl}/admin/actividades/pendientes',
          ),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final actividades = data['actividades'];

      if (actividades is! List) {
        return [];
      }

      return actividades
          .whereType<Map<String, dynamic>>()
          .map(
            AdminActividadModel.fromJson,
          )
          .toList();
    }

    throw _crearError(response);
  }

  // ============================================================
  // APROBAR ACTIVIDAD
  // ============================================================

  static Future<AdminActividadModel>
      aprobarActividad(String actividadId) async {
    final token =
        await AdminSesionService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'La sesión del administrador ha expirado.',
      );
    }

    final response = await http
        .put(
          Uri.parse(
            '${ApiConfig.baseUrl}/admin/actividades/$actividadId/aprobar',
          ),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return AdminActividadModel.fromJson(
        Map<String, dynamic>.from(
          data['actividad'],
        ),
      );
    }

    throw _crearError(response);
  }

  // ============================================================
  // RECHAZAR ACTIVIDAD
  // ============================================================

  static Future<AdminActividadModel>
      rechazarActividad({
    required String actividadId,
    required String motivoRechazo,
  }) async {
    final token =
        await AdminSesionService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'La sesión del administrador ha expirado.',
      );
    }

    final response = await http
        .put(
          Uri.parse(
            '${ApiConfig.baseUrl}/admin/actividades/$actividadId/rechazar',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'motivoRechazo':
                motivoRechazo.trim(),
          }),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return AdminActividadModel.fromJson(
        Map<String, dynamic>.from(
          data['actividad'],
        ),
      );
    }

    throw _crearError(response);
  }

  // ============================================================
  // ERROR
  // ============================================================

  static Exception _crearError(
    http.Response response,
  ) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic> &&
          data['mensaje'] != null) {
        return Exception(
          data['mensaje'].toString(),
        );
      }
    } catch (_) {}

    return Exception(
      'No fue posible completar la operación.',
    );
  }
}