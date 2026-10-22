import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../models/admin/reporte_sitio_admin.dart';
import '../admin_servicio_autenticacion.dart';

class AdminReportesSitiosService {
  AdminReportesSitiosService._();

  static String get _urlBase => '${ApiConfig.baseUrl}/admin/reportes-sitios';

  static Map<String, String> _headers() {
    final token = AdminServicioAutenticacion.tokenAdmin;

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<ReporteSitioAdmin>> obtenerReportes({
    String estado = 'todos',
    String tipoReporte = 'todos',
  }) async {
    final uri = Uri.parse(
      _urlBase,
    ).replace(queryParameters: {'estado': estado, 'tipoReporte': tipoReporte});

    final response = await http
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);

      if (data is! List) {
        throw Exception(
          'La respuesta de reportes no tiene el formato esperado.',
        );
      }

      return data
          .whereType<Map>()
          .map(
            (item) =>
                ReporteSitioAdmin.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    throw Exception(_mensajeError(response));
  }

  static Future<ReporteSitioAdmin> responderReporte({
    required String id,
    required String estado,
    required String respuestaAdmin,
  }) async {
    final response = await http
        .put(
          Uri.parse('$_urlBase/${Uri.encodeComponent(id)}'),
          headers: _headers(),
          body: jsonEncode({
            'estado': estado,
            'respuestaAdmin': respuestaAdmin,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);

      if (data is! Map || data['reporte'] is! Map) {
        throw Exception('No se recibieron los datos actualizados.');
      }

      return ReporteSitioAdmin.fromJson(
        Map<String, dynamic>.from(data['reporte'] as Map),
      );
    }

    throw Exception(_mensajeError(response));
  }

  static String _mensajeError(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map) {
        return (data['mensaje'] ??
                data['error'] ??
                'No fue posible completar la operación.')
            .toString();
      }
    } catch (_) {
      // Se utiliza el mensaje genérico si el servidor no devuelve JSON.
    }

    return 'No fue posible completar la operación.';
  }
}
