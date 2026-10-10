import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/api_config.dart';
import '../../models/sitio/sitio_actividad_model.dart';

class SitioActividadesService {
  // ============================================================
  // OBTENER ACTIVIDADES
  // ============================================================

  Future<List<SitioActividadModel>> obtenerActividades({
    required String token,
    required String sitioId,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/actividades/$sitioId',
      ),
      headers: _crearHeaders(token),
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

  // ============================================================
  // CREAR ACTIVIDAD
  // ============================================================

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
      headers: _crearHeaders(token),
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

  // ============================================================
  // ACTUALIZAR ACTIVIDAD
  // ============================================================

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
      headers: _crearHeaders(token),
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

  // ============================================================
  // SUBIR IMÁGENES
  // ============================================================

  Future<SitioActividadModel> subirImagenes({
    required String token,
    required String sitioId,
    required String actividadId,
    required List<XFile> archivos,
  }) async {
    if (archivos.isEmpty) {
      throw Exception(
        'Debes seleccionar al menos una imagen.',
      );
    }

    if (archivos.length > 10) {
      throw Exception(
        'Puedes seleccionar máximo 10 imágenes por carga.',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/actividades/$sitioId/$actividadId/imagenes',
      ),
    );

    request.headers['Authorization'] = 'Bearer $token';

    for (final archivo in archivos) {
      final bytes = await archivo.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception(
          'La imagen "${archivo.name}" está vacía o no se pudo leer.',
        );
      }

      final nombre = archivo.name.toLowerCase();

      final MediaType tipo;

      if (nombre.endsWith('.jpg') ||
          nombre.endsWith('.jpeg')) {
        tipo = MediaType('image', 'jpeg');
      } else if (nombre.endsWith('.png')) {
        tipo = MediaType('image', 'png');
      } else if (nombre.endsWith('.webp')) {
        tipo = MediaType('image', 'webp');
      } else {
        throw Exception(
          'Formato no permitido: ${archivo.name}. '
          'Usa imágenes JPG, JPEG, PNG o WEBP.',
        );
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'imagenes',
          bytes,
          filename: archivo.name,
          contentType: tipo,
        ),
      );
    }

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
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

  // ============================================================
  // ELIMINAR UNA IMAGEN DE LA ACTIVIDAD
  // ============================================================

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
      headers: _crearHeaders(token),
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

  // ============================================================
  // ESTABLECER IMAGEN PRINCIPAL
  // ============================================================

  Future<SitioActividadModel> establecerImagenPrincipal({
    required String token,
    required String sitioId,
    required String actividadId,
    required String url,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/actividades/$sitioId/$actividadId/imagen-principal',
      ),
      headers: _crearHeaders(token),
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

  // ============================================================
  // ENVIAR ACTIVIDAD A REVISIÓN
  // ============================================================

  Future<SitioActividadModel> enviarARevision({
    required String token,
    required String sitioId,
    required String actividadId,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/actividades/$sitioId/$actividadId/enviar-revision',
      ),
      headers: _crearHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return SitioActividadModel.fromJson(
        Map<String, dynamic>.from(data['actividad']),
      );
    }

    throw _crearError(response);
  }

  // ============================================================
  // ELIMINAR ACTIVIDAD PERMANENTEMENTE
  // ============================================================

  Future<void> eliminarActividad({
    required String token,
    required String sitioId,
    required String actividadId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/actividades/$sitioId/$actividadId',
      ),
      headers: _crearHeaders(token),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204) {
      return;
    }

    throw _crearError(response);
  }

  // ============================================================
  // ENCABEZADOS HTTP
  // ============================================================

  Map<String, String> _crearHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // MANEJO DE ERRORES
  // ============================================================

  Exception _crearError(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map) {
        return Exception(
          data['mensaje']?.toString() ??
              data['error']?.toString() ??
              'No fue posible completar la operación.',
        );
      }

      return Exception(
        'Error ${response.statusCode}: '
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