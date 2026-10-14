import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../config/api_config.dart';
import '../../models/sitio/sitio_contenido_model.dart';

class SitioContenidoService {
  String get _baseUrl => ApiConfig.baseUrl;

  // ============================================================
  // ENCABEZADOS HTTP
  // ============================================================

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // OBTENER MIS CONTENIDOS
  // ============================================================

  Future<List<SitioContenidoModel>> obtenerMisContenidos({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/mis-contenidos',
      ),
      headers: _headers(token),
    );

    _validarRespuesta(response);

    final dynamic data = jsonDecode(response.body);

    if (data is! List) {
      throw Exception(
        'La respuesta de mis contenidos no tiene el formato esperado.',
      );
    }

    return data
        .map(
          (item) => SitioContenidoModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  // ============================================================
  // OBTENER CONTENIDOS PÚBLICOS DE UN SITIO
  // ============================================================

  Future<List<SitioContenidoModel>> obtenerContenidosPublicos({
    required String sitioId,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/sitio/$sitioId',
      ),
    );

    _validarRespuesta(response);

    final dynamic data = jsonDecode(response.body);

    if (data is! List) {
      throw Exception(
        'La respuesta de contenidos públicos no tiene el formato esperado.',
      );
    }

    return data
        .map(
          (item) => SitioContenidoModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  // ============================================================
  // OBTENER UN CONTENIDO
  // ============================================================

  Future<SitioContenidoModel> obtenerContenido({
    required String contenidoId,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/$contenidoId',
      ),
    );

    _validarRespuesta(response);

    final dynamic data = jsonDecode(response.body);

    if (data is! Map) {
      throw Exception(
        'La respuesta del contenido no tiene el formato esperado.',
      );
    }

    return SitioContenidoModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // ============================================================
  // CREAR CONTENIDO
  // ============================================================

  Future<SitioContenidoModel> crearContenido({
    required String token,
    required String titulo,
    required String descripcion,
    String imagenPrincipal = '',
    List<String> imagenes = const [],
    List<SitioAudioGuiaModel> audioGuias = const [],
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido',
      ),
      headers: _headers(token),
      body: jsonEncode({
        'titulo': titulo,
        'descripcion': descripcion,
        'imagenPrincipal': imagenPrincipal,
        'imagenes': imagenes,
        'audioGuias': audioGuias
            .map((audio) => audio.toJson())
            .toList(),
      }),
    );

    _validarRespuesta(response);

    final dynamic data = jsonDecode(response.body);

    if (data is! Map || data['contenido'] is! Map) {
      throw Exception(
        'No se recibió el contenido creado desde el servidor.',
      );
    }

    return SitioContenidoModel.fromJson(
      Map<String, dynamic>.from(data['contenido'] as Map),
    );
  }

  // ============================================================
  // ACTUALIZAR CONTENIDO
  // ============================================================

  Future<SitioContenidoModel> actualizarContenido({
    required String token,
    required String contenidoId,
    required String titulo,
    required String descripcion,
    String? imagenPrincipal,
    List<String>? imagenes,
    List<SitioAudioGuiaModel>? audioGuias,
  }) async {
    final Map<String, dynamic> body = {
      'titulo': titulo,
      'descripcion': descripcion,
    };

    if (imagenPrincipal != null) {
      body['imagenPrincipal'] = imagenPrincipal;
    }

    if (imagenes != null) {
      body['imagenes'] = imagenes;
    }

    if (audioGuias != null) {
      body['audioGuias'] = audioGuias
          .map((audio) => audio.toJson())
          .toList();
    }

    final response = await http.put(
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/$contenidoId',
      ),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    _validarRespuesta(response);

    final dynamic data = jsonDecode(response.body);

    if (data is! Map || data['contenido'] is! Map) {
      throw Exception(
        'No se recibió el contenido actualizado desde el servidor.',
      );
    }

    return SitioContenidoModel.fromJson(
      Map<String, dynamic>.from(data['contenido'] as Map),
    );
  }

  // ============================================================
  // SUBIR IMÁGENES DEL CONTENIDO
  // ============================================================

  Future<SitioContenidoModel> subirImagenesContenido({
    required String token,
    required String contenidoId,
    XFile? imagenPrincipal,
    required List<XFile> imagenes,
  }) async {
    if (imagenPrincipal == null && imagenes.isEmpty) {
      throw Exception(
        'Selecciona al menos una imagen para subir.',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/$contenidoId/imagenes',
      ),
    );

    request.headers['Authorization'] = 'Bearer $token';

    if (imagenPrincipal != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'imagenPrincipal',
          await imagenPrincipal.readAsBytes(),
          filename: imagenPrincipal.name,
        ),
      );
    }

    for (final imagen in imagenes) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'imagenes',
          await imagen.readAsBytes(),
          filename: imagen.name,
        ),
      );
    }

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    _validarRespuesta(response);

    final dynamic data = jsonDecode(response.body);

    if (data is! Map || data['contenido'] is! Map) {
      throw Exception(
        'No se recibió el contenido después de subir las imágenes.',
      );
    }

    return SitioContenidoModel.fromJson(
      Map<String, dynamic>.from(data['contenido'] as Map),
    );
  }

  // ============================================================
  // SUBIR AUDIOGUÍA A CLOUDINARY
  // ============================================================

  Future<SitioContenidoModel> subirAudioGuia({
    required String token,
    required String contenidoId,
    required PlatformFile archivo,
    required String titulo,
    String descripcion = '',
  }) async {
    if (titulo.trim().length < 2) {
      throw Exception(
        'El título de la audioguía debe tener al menos 2 caracteres.',
      );
    }

    // Leer el archivo sin depender del getter archivo.bytes.
    final bytes = await archivo.readAsBytes();

    if (bytes.isEmpty) {
      throw Exception(
        'El archivo de audio seleccionado está vacío.',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/'
        '$contenidoId/audioguias',
      ),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['titulo'] = titulo.trim();
    request.fields['descripcion'] = descripcion.trim();

    request.files.add(
      http.MultipartFile.fromBytes(
        'audio',
        bytes,
        filename: archivo.name,
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    _validarRespuesta(response);

    final dynamic data = jsonDecode(response.body);

    if (data is! Map || data['contenido'] is! Map) {
      throw Exception(
        'No se recibió el contenido después de subir la audioguía.',
      );
    }

    return SitioContenidoModel.fromJson(
      Map<String, dynamic>.from(data['contenido'] as Map),
    );
  }

  // ============================================================
  // ELIMINAR AUDIOGUÍA
  // ============================================================

  Future<SitioContenidoModel> eliminarAudioGuia({
    required String token,
    required String contenidoId,
    required String audioId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/'
        '$contenidoId/audioguias/$audioId',
      ),
      headers: _headers(token),
    );

    _validarRespuesta(response);

    final dynamic data = jsonDecode(response.body);

    if (data is! Map || data['contenido'] is! Map) {
      throw Exception(
        'No se recibió el contenido después de eliminar la audioguía.',
      );
    }

    return SitioContenidoModel.fromJson(
      Map<String, dynamic>.from(data['contenido'] as Map),
    );
  }

  // ============================================================
  // ENVIAR CONTENIDO A REVISIÓN
  // ============================================================

  Future<void> enviarContenidoRevision({
    required String token,
    required String contenidoId,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/'
        '$contenidoId/enviar-revision',
      ),
      headers: _headers(token),
    );

    _validarRespuesta(response);
  }

  // ============================================================
  // ELIMINAR CONTENIDO
  // ============================================================

  Future<void> eliminarContenido({
    required String token,
    required String contenidoId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/$contenidoId',
      ),
      headers: _headers(token),
    );

    _validarRespuesta(response);
  }

  // ============================================================
  // VALIDAR RESPUESTAS DEL SERVIDOR
  // ============================================================

  void _validarRespuesta(http.Response response) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    String mensaje =
        'Error del servidor (${response.statusCode}).';

    try {
      final dynamic data = jsonDecode(response.body);

      if (data is Map && data['mensaje'] != null) {
        mensaje = data['mensaje'].toString();
      } else if (data is Map && data['message'] != null) {
        mensaje = data['message'].toString();
      }
    } catch (_) {
      if (response.body.trim().isNotEmpty) {
        mensaje = response.body;
      }
    }

    throw Exception(mensaje);
  }
}