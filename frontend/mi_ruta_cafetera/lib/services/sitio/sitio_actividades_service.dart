import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/sitio/sitio_actividad_model.dart';

class SitioActividadesService {
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

  Future<SitioActividadModel> subirImagenes({
    required String token,
    required String sitioId,
    required String actividadId,
    required List<File> archivos,
  }) async {
    if (archivos.isEmpty) {
      throw Exception(
        'Debes seleccionar al menos una imagen.',
      );
    }

    if (archivos.length > 10) {
      throw Exception(
        'Puedes seleccionar máximo 10 imágenes.',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/actividades/$sitioId/$actividadId/imagenes',
      ),
    );

    request.headers['Authorization'] =
        'Bearer $token';

    for (final archivo in archivos) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'imagenes',
          archivo.path,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      return SitioActividadModel.fromJson(
        Map<String, dynamic>.from(data['actividad']),
      );
    }

    throw _crearError(response);
  }

  Future<SitioActividadModel> eliminarImagen({
    required String token,
    required String sitioId,
    required String actividadId,
    required String url,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/actividades/$sitioId/$actividadId/imagenes',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'url': url,
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

  Future<SitioActividadModel> establecerImagenPrincipal({
    required String token,
    required String sitioId,
    required String actividadId,
    required String url,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/actividades/$sitioId/$actividadId/imagenes/principal',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'url': url,
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