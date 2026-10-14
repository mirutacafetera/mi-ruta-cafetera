import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../models/admin/reporte_admin.dart';
import '../admin_servicio_autenticacion.dart';

class AdminReporteService {
  AdminReporteService._();

  static String get _urlBase {
    return '${ApiConfig.baseUrl}/admin/ayuda';
  }

  static Map<String, String> _headers() {
    final token = AdminServicioAutenticacion.tokenAdmin;

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  static Future<List<ReporteAdmin>> obtenerReportes() async {
    try {
      final response = await http
          .get(Uri.parse(_urlBase), headers: _headers())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data = jsonDecode(response.body);

        if (data is! List) {
          throw Exception('Formato de reportes inválido.');
        }

        return data
            .whereType<Map<String, dynamic>>()
            .map(ReporteAdmin.fromJson)
            .toList();
      }

      throw Exception(_mensajeError(response));
    } catch (e) {
      rethrow;
    }
  }

  static Future<ReporteAdmin> obtenerReporte(String id) async {
    final response = await http
        .get(
          Uri.parse('$_urlBase/${Uri.encodeComponent(id)}'),
          headers: _headers(),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw Exception('Formato de reporte inválido.');
      }

      return ReporteAdmin.fromJson(data);
    }

    throw Exception(_mensajeError(response));
  }

  static Future<ReporteAdmin> responderReporte({
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

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final reporte = data['reporte'];

      if (reporte is! Map<String, dynamic>) {
        throw Exception('No se recibieron los datos actualizados.');
      }

      return ReporteAdmin.fromJson(reporte);
    }

    throw Exception(_mensajeError(response));
  }

  static String _mensajeError(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return (data['mensaje'] ??
                data['error'] ??
                'No fue posible realizar la operación.')
            .toString();
      }
    } catch (_) {}

    return 'No fue posible realizar la operación.';
  }
}