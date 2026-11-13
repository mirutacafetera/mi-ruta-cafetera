import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/api_config.dart';
import '../../models/sitio/sitio_resena_model.dart';
import '../usuario/usuario_sesion_service.dart';

class SitioResenasService {
  SitioResenasService._();

  static final SitioResenasService instance =
      SitioResenasService._();

  final UsuarioSesionService _sesion =
      UsuarioSesionService.instance;

  Uri _uri(String ruta) =>
      Uri.parse('${ApiConfig.baseUrl}/resenas$ruta');

  Future<Map<String, String>> _headers({
    bool autenticado = false,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (autenticado) {
      final sesion = await _sesion.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception(
          'Debes iniciar sesión para realizar esta acción.',
        );
      }

      headers['Authorization'] = 'Bearer ${sesion.token}';
    }

    return headers;
  }

  dynamic _decodificar(http.Response respuesta) {
    dynamic datos;

    try {
      datos = respuesta.body.isEmpty
          ? null
          : jsonDecode(respuesta.body);
    } catch (_) {
      throw Exception(
        'El servidor devolvió una respuesta no válida.',
      );
    }

    if (respuesta.statusCode < 200 ||
        respuesta.statusCode >= 300) {
      final mensaje = datos is Map
          ? datos['mensaje'] ??
              datos['error'] ??
              'Error en la solicitud.'
          : 'Error en la solicitud (${respuesta.statusCode}).';

      throw Exception(mensaje.toString());
    }

    return datos;
  }

  List<dynamic> _listaDesde(dynamic datos) {
    if (datos is List) return datos;

    if (datos is Map && datos['resenas'] is List) {
      return datos['resenas'] as List;
    }

    return const [];
  }

  MediaType _tipoImagen(XFile imagen) {
    // Primero intenta con el tipo que reporta image_picker (puede venir nulo).
    final mime = imagen.mimeType;
    if (mime != null && mime.startsWith('image/')) {
      final partes = mime.split('/');
      return MediaType(partes[0], partes[1]);
    }

    // Si no, deduce el tipo por la extensión del nombre o de la ruta.
    final nombre = imagen.name.isNotEmpty ? imagen.name : imagen.path;
    final ext = nombre.toLowerCase().split('.').last;

    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'avif':
        return MediaType('image', 'avif');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  Future<List<SitioResenaModel>> obtenerPorSitio(
    String sitioId,
  ) async {
    final id = sitioId.trim();

    if (id.isEmpty) {
      throw Exception(
        'El sitio turístico no tiene un identificador válido.',
      );
    }

    final respuesta = await http.get(
      _uri('/sitio/${Uri.encodeComponent(id)}'),
      headers: await _headers(),
    );

    final datos = _decodificar(respuesta);

    return _listaDesde(datos)
        .whereType()
        .map(
          (json) => SitioResenaModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .where((resena) => resena.activo)
        .toList();
  }

  Future<SitioResenaModel> crear({
    required String sitioId,
    required int calificacion,
    required String comentario,
    List<XFile> imagenes = const [],
  }) async {
    final id = sitioId.trim();
    final texto = comentario.trim();

    if (id.isEmpty) {
      throw Exception('El sitio turístico no es válido.');
    }

    if (calificacion < 1 || calificacion > 5) {
      throw Exception(
        'Selecciona una calificación entre 1 y 5 estrellas.',
      );
    }

    if (texto.isEmpty) {
      throw Exception(
        'Escribe un comentario antes de publicar.',
      );
    }

    if (imagenes.length > 10) {
      throw Exception(
        'Solo puedes adjuntar hasta 10 imágenes.',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      _uri(''),
    );

    final headers = await _headers(autenticado: true);

    // MultipartRequest establece automáticamente el Content-Type
    // con su boundary. No debemos enviar application/json.
    headers.remove('Content-Type');

    request.headers.addAll(headers);

    request.fields.addAll({
      'sitio': id,
      'calificacion': calificacion.toString(),
      'comentario': texto,
    });

    // fromBytes para compatibilidad Web y Móvil, con contentType explícito
    // para que el backend no reciba application/octet-stream.
    for (final imagen in imagenes) {
      final bytes = await imagen.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'imagenes',
          bytes,
          filename: imagen.name.isNotEmpty ? imagen.name : 'resena_imagen.jpg',
          contentType: _tipoImagen(imagen),
        ),
      );
    }

    final enviada = await request.send();
    final respuesta = await http.Response.fromStream(enviada);
    final datos = _decodificar(respuesta);

    if (datos is Map && datos['resena'] is Map) {
      return SitioResenaModel.fromJson(
        Map<String, dynamic>.from(datos['resena'] as Map),
      );
    }

    if (datos is Map && datos['_id'] != null) {
      return SitioResenaModel.fromJson(
        Map<String, dynamic>.from(datos),
      );
    }

    throw Exception(
      'El servidor no devolvió la reseña creada.',
    );
  }

  Future<void> eliminar(String resenaId) async {
    final id = resenaId.trim();

    if (id.isEmpty) {
      throw Exception('La reseña no tiene un ID válido.');
    }

    final respuesta = await http.delete(
      _uri('/${Uri.encodeComponent(id)}'),
      headers: await _headers(autenticado: true),
    );

    _decodificar(respuesta);
  }
}