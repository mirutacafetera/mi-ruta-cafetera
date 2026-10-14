
import 'dart:convert';

import 'package:http/http.dart' as http;

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
        .whereType<Map>()
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
  }) async {
    final texto = comentario.trim();

    if (sitioId.trim().isEmpty) {
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

    final respuesta = await http.post(
      _uri(''),
      headers: await _headers(autenticado: true),
      body: jsonEncode({
        'sitio': sitioId.trim(),
        'calificacion': calificacion,
        'comentario': texto,
      }),
    );

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
