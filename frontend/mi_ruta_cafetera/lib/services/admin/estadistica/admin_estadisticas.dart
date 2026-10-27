import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../models/admin/estadistica_model.dart';

class AdminEstadisticas {
  AdminEstadisticas._();

  static const Duration _tiempoEspera = Duration(seconds: 15);

  static String get _urlEstadisticas =>
      '${ApiConfig.baseUrl}/admin/estadisticas';

  static Future<ResumenEstadisticasModel> obtenerEstadisticas({
    int? anio,
  }) async {
    final uri = Uri.parse(_urlEstadisticas).replace(
      queryParameters: anio == null
          ? null
          : {'anio': anio.toString()},
    );

    try {
      final respuesta = await http
          .get(
            uri,
            headers: {'Accept': 'application/json'},
          )
          .timeout(_tiempoEspera);

      if (respuesta.statusCode != 200) {
        throw Exception(
          'Error al consultar las estadísticas.\n'
          'Estado: ${respuesta.statusCode}\n'
          'Respuesta: ${respuesta.body}',
        );
      }

      final dynamic datos = jsonDecode(respuesta.body);

      if (datos is! Map<String, dynamic>) {
        throw const FormatException(
          'El servidor no devolvió un objeto JSON válido.',
        );
      }

      return ResumenEstadisticasModel.fromJson(datos);
    } on FormatException catch (error) {
      throw Exception('Error al interpretar las estadísticas: $error');
    } on http.ClientException catch (error) {
      throw Exception('No se pudo conectar con el servidor: $error');
    } catch (error) {
      throw Exception('No se pudieron cargar las estadísticas: $error');
    }
  }
}