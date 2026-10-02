import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../config/api_config.dart';
import '../../models/sitio/sitio_contenido_model.dart';

class SitioContenidoService {
  SitioContenidoService();

  String get _baseUrl => ApiConfig.baseUrl;

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // =========================================================
  // OBTENER CONTENIDOS DEL SITIO AUTENTICADO
  // =========================================================

  Future<List<SitioContenidoModel>> obtenerMisContenidos({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/mis-contenidos',
      ),
      headers: _headers(token),
    );

    _validarRespuesta(
      response,
      'No fue posible obtener los contenidos del sitio.',
    );

    final dynamic datos = jsonDecode(response.body);

    if (datos is! List) {
      throw Exception(
        'La respuesta de contenidos no tiene un formato válido.',
      );
    }

    return datos
        .whereType<Map>()
        .map(
          (item) => SitioContenidoModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // =========================================================
  // OBTENER CONTENIDOS PÚBLICOS DE UN SITIO
  // =========================================================

  Future<List<SitioContenidoModel>> obtenerContenidosPublicos({
    required String sitioId,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/sitio/$sitioId',
      ),
    );

    _validarRespuesta(
      response,
      'No fue posible obtener los contenidos públicos.',
    );

    final dynamic datos = jsonDecode(response.body);

    if (datos is! List) {
      throw Exception(
        'La respuesta de contenidos no tiene un formato válido.',
      );
    }

    return datos
        .whereType<Map>()
        .map(
          (item) => SitioContenidoModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // =========================================================
  // OBTENER UN CONTENIDO
  // =========================================================

  Future<SitioContenidoModel> obtenerContenido({
    required String contenidoId,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/$contenidoId',
      ),
    );

    _validarRespuesta(
      response,
      'No fue posible obtener el contenido.',
    );

    final dynamic datos = jsonDecode(response.body);

    if (datos is! Map) {
      throw Exception(
        'La respuesta del contenido no tiene un formato válido.',
      );
    }

    return SitioContenidoModel.fromJson(
      Map<String, dynamic>.from(datos),
    );
  }

  // =========================================================
  // CREAR CONTENIDO
  // =========================================================

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

    _validarRespuesta(
      response,
      'No fue posible crear el contenido.',
    );

    final dynamic datos = jsonDecode(response.body);

    if (datos is! Map || datos['contenido'] is! Map) {
      throw Exception(
        'La respuesta al crear contenido no tiene un formato válido.',
      );
    }

    return SitioContenidoModel.fromJson(
      Map<String, dynamic>.from(
        datos['contenido'],
      ),
    );
  }

  // =========================================================
  // ACTUALIZAR CONTENIDO
  // =========================================================

  Future<SitioContenidoModel> actualizarContenido({
    required String token,
    required String contenidoId,
    required String titulo,
    required String descripcion,
    String imagenPrincipal = '',
    List<String> imagenes = const [],
    List<SitioAudioGuiaModel> audioGuias = const [],
  }) async {
    final response = await http.put(
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/$contenidoId',
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

    _validarRespuesta(
      response,
      'No fue posible actualizar el contenido.',
    );

    final dynamic datos = jsonDecode(response.body);

    if (datos is! Map || datos['contenido'] is! Map) {
      throw Exception(
        'La respuesta al actualizar contenido no tiene un formato válido.',
      );
    }

    return SitioContenidoModel.fromJson(
      Map<String, dynamic>.from(
        datos['contenido'],
      ),
    );
  }

  // =========================================================
  // SUBIR IMAGEN PRINCIPAL Y GALERÍA
  // =========================================================

  Future<SitioContenidoModel> subirImagenesContenido({
    required String token,
    required String contenidoId,
    XFile? imagenPrincipal,
    List<XFile> imagenes = const [],
  }) async {
    if (imagenPrincipal == null && imagenes.isEmpty) {
      throw Exception(
        'Debes seleccionar al menos una imagen.',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/$contenidoId/imagenes',
      ),
    );

    request.headers['Authorization'] = 'Bearer $token';

    // =======================================================
    // IMAGEN PRINCIPAL
    // =======================================================

    if (imagenPrincipal != null) {
      final bytes = await imagenPrincipal.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'imagenPrincipal',
          bytes,
          filename: imagenPrincipal.name,
        ),
      );
    }

    // =======================================================
    // GALERÍA
    // =======================================================

    for (final imagen in imagenes) {
      final bytes = await imagen.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'imagenes',
          bytes,
          filename: imagen.name,
        ),
      );
    }

    // =======================================================
    // ENVIAR
    // =======================================================

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    _validarRespuesta(
      response,
      'No fue posible subir las imágenes del contenido.',
    );

    final dynamic datos = jsonDecode(response.body);

    if (datos is! Map || datos['contenido'] is! Map) {
      throw Exception(
        'La respuesta al subir las imágenes no tiene un formato válido.',
      );
    }

    return SitioContenidoModel.fromJson(
      Map<String, dynamic>.from(
        datos['contenido'],
      ),
    );
  }

  // =========================================================
  // ENVIAR A REVISIÓN
  // =========================================================

  Future<SitioContenidoModel> enviarContenidoRevision({
    required String token,
    required String contenidoId,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/$contenidoId/enviar-revision',
      ),
      headers: _headers(token),
    );

    _validarRespuesta(
      response,
      'No fue posible enviar el contenido a revisión.',
    );

    final dynamic datos = jsonDecode(response.body);

    if (datos is! Map || datos['contenido'] is! Map) {
      throw Exception(
        'La respuesta al enviar el contenido a revisión '
        'no tiene un formato válido.',
      );
    }

    return SitioContenidoModel.fromJson(
      Map<String, dynamic>.from(
        datos['contenido'],
      ),
    );
  }

  // =========================================================
  // DESACTIVAR CONTENIDO
  // =========================================================

  Future<SitioContenidoModel> desactivarContenido({
    required String token,
    required String contenidoId,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/$contenidoId/desactivar',
      ),
      headers: _headers(token),
    );

    _validarRespuesta(
      response,
      'No fue posible desactivar el contenido.',
    );

    final dynamic datos = jsonDecode(response.body);

    if (datos is! Map || datos['contenido'] is! Map) {
      throw Exception(
        'La respuesta al desactivar contenido '
        'no tiene un formato válido.',
      );
    }

    return SitioContenidoModel.fromJson(
      Map<String, dynamic>.from(
        datos['contenido'],
      ),
    );
  }

  // =========================================================
  // ACTIVAR CONTENIDO
  // =========================================================

  Future<SitioContenidoModel> activarContenido({
    required String token,
    required String contenidoId,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$_baseUrl/sitiosturisticos/contenido/$contenidoId/activar',
      ),
      headers: _headers(token),
    );

    _validarRespuesta(
      response,
      'No fue posible activar el contenido.',
    );

    final dynamic datos = jsonDecode(response.body);

    if (datos is! Map || datos['contenido'] is! Map) {
      throw Exception(
        'La respuesta al activar contenido '
        'no tiene un formato válido.',
      );
    }

    return SitioContenidoModel.fromJson(
      Map<String, dynamic>.from(
        datos['contenido'],
      ),
    );
  }

  // =========================================================
  // VALIDACIÓN GENERAL DE RESPUESTAS
  // =========================================================

  void _validarRespuesta(
    http.Response response,
    String mensajePorDefecto,
  ) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    String mensaje = mensajePorDefecto;

    try {
      final dynamic datos = jsonDecode(response.body);

      if (datos is Map &&
          datos['mensaje'] != null) {
        mensaje = datos['mensaje'].toString();
      } else if (datos is Map &&
          datos['error'] != null) {
        mensaje = datos['error'].toString();
      }
    } catch (_) {
      // Conservamos el mensaje por defecto.
    }

    throw Exception(mensaje);
  }
}