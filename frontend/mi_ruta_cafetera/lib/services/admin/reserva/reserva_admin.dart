import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../models/admin/reserva_admin_model.dart';
import '../../../config/api_config.dart';

class ReservaAdminService {
  static Future<List<ReservaAdminModel>> obtenerReservas({
    required String token,
  }) async {
    final respuesta = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/reservas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error al consultar las reservas: ${respuesta.body}',
      );
    }

    final datos = jsonDecode(respuesta.body);

    final List<dynamic> lista = datos is List
        ? datos
        : datos['reservas'] ?? datos['data'] ?? [];

    return lista
        .map(
          (json) => ReservaAdminModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  static Future<ReservaAdminModel> actualizarEstado({
    required String token,
    required String id,
    required String estado,
  }) async {
    final respuesta = await http.patch(
      Uri.parse(
        '${ApiConfig.baseUrl}/admin/reservas/$id/estado',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'estado': estado,
      }),
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error al actualizar la reserva: ${respuesta.body}',
      );
    }

    final datos = jsonDecode(respuesta.body);
    final reserva = datos['reserva'] ?? datos['data'] ?? datos;

    return ReservaAdminModel.fromJson(
      Map<String, dynamic>.from(reserva),
    );
  }
}