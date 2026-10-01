import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/sitio/sitio_actividad_model.dart';

class SitioActividadesService {
  // ======================================================
  // OBTENER ACTIVIDADES
  // ======================================================

  Future<List<SitioActividadModel>> obtenerActividades({
    required String token,
    required String sitioId,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/actividades/$sitioId',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is! List) {
        throw Exception(
          'La respuesta de actividades no tiene un formato válido.',
        );
      }

      return data
          .map(
            (item) => SitioActividadModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    throw _crearError(response);
  }

  // ======================================================
  // CREAR ACTIVIDAD
  // ======================================================

  Future<SitioActividadModel> crearActividad({
    required String token,
    required String sitioId,
    required String nombre,
    required String descripcion,
    required double precio,
    required String horario,
    required String duracion,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/actividades/$sitioId',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'horario': horario,
        'duracion': duracion,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      return SitioActividadModel.fromJson(
        Map<String, dynamic>.from(data['actividad']),
      );
    }

    throw _crearError(response);
  }

  // ======================================================
  // ACTUALIZAR ACTIVIDAD
  // ======================================================

  Future<SitioActividadModel> actualizarActividad({
    required String token,
    required String sitioId,
    required String actividadId,
    required String nombre,
    required String descripcion,
    required double precio,
    required String horario,
    required String duracion,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/actividades/$sitioId/$actividadId',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'horario': horario,
        'duracion': duracion,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return SitioActividadModel.fromJson(
        Map<String, dynamic>.from(data['actividad']),
      );
    }

    throw _crearError(response);
  }

  // ======================================================
  // ENVIAR A REVISIÓN
  // ======================================================

  Future<SitioActividadModel> enviarARevision({
    required String token,
    required String sitioId,
    required String actividadId,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/actividades/$sitioId/$actividadId/enviar-revision',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return SitioActividadModel.fromJson(
        Map<String, dynamic>.from(data['actividad']),
      );
    }

    throw _crearError(response);
  }

  // ======================================================
  // DESACTIVAR
  // ======================================================

  Future<SitioActividadModel> desactivarActividad({
    required String token,
    required String sitioId,
    required String actividadId,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/actividades/$sitioId/$actividadId/desactivar',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return SitioActividadModel.fromJson(
        Map<String, dynamic>.from(data['actividad']),
      );
    }

    throw _crearError(response);
  }

  // ======================================================
  // MANEJO DE ERRORES
  // ======================================================

  Exception _crearError(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      return Exception(
        data['mensaje']?.toString() ??
            'No fue posible completar la operación.',
      );
    } catch (_) {
      return Exception(
        'Error ${response.statusCode}: '
        'No fue posible completar la operación.',
      );
    }
  }
}