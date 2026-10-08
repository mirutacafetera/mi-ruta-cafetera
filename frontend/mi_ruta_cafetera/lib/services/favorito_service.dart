import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/sitio_turistico_model.dart';

class FavoritoItem {
  final String id;
  final SitioTuristicoModel sitio;

  const FavoritoItem({
    required this.id,
    required this.sitio,
  });
}

class FavoritoService {
  FavoritoService._();

  static final FavoritoService instance =
      FavoritoService._();

  // ============================================================
  // OBTENER FAVORITOS DE UN USUARIO
  // ============================================================

  Future<List<FavoritoItem>> obtenerFavoritos(
    String usuarioId, {
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/favoritos/$usuarioId',
      ),
      headers: _headers(token),
    ).timeout(
      const Duration(seconds: 10),
    );

    if (response.statusCode != 200) {
      final dynamic decoded =
          _decodificarRespuesta(
        response.body,
      );

      final mensaje = decoded is Map
          ? decoded['mensaje']?.toString()
          : null;

      throw Exception(
        mensaje ??
            'Error al obtener favoritos: '
                '${response.statusCode}',
      );
    }

    final dynamic decoded =
        _decodificarRespuesta(
      response.body,
    );

    if (decoded is! List) {
      return [];
    }

    final favoritos =
        <FavoritoItem>[];

    for (final item in decoded) {
      if (item is! Map) {
        continue;
      }

      final favorito =
          Map<String, dynamic>.from(item);

      final favoritoId =
          _extraerId(
        favorito['_id'] ??
            favorito['id'],
      );

      final sitioJson =
          favorito['sitio'];

      if (favoritoId == null ||
          sitioJson is! Map) {
        continue;
      }

      try {
        final sitio =
            SitioTuristicoModel.fromJson(
          Map<String, dynamic>.from(
            sitioJson,
          ),
        );

        favoritos.add(
          FavoritoItem(
            id: favoritoId,
            sitio: sitio,
          ),
        );
      } catch (_) {
        // Se ignora un favorito cuyo sitio
        // no pueda convertirse.
      }
    }

    return favoritos;
  }

  // ============================================================
  // AGREGAR FAVORITO
  // ============================================================

  Future<FavoritoItem?> agregarFavorito({
    required String usuarioId,
    required String sitioId,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/favoritos',
      ),
      headers: _headers(token),
      body: jsonEncode({
        // Se mantiene por compatibilidad con
        // el código existente.
        //
        // El backend ya NO lo utiliza como
        // autoridad. Utiliza req.usuario.id.
        'usuario': usuarioId,
        'sitio': sitioId,
      }),
    ).timeout(
      const Duration(seconds: 10),
    );

    final dynamic decoded =
        _decodificarRespuesta(
      response.body,
    );

    if (response.statusCode != 201) {
      final mensaje = decoded is Map
          ? decoded['mensaje']?.toString()
          : null;

      throw Exception(
        mensaje ??
            'No fue posible agregar el favorito.',
      );
    }

    if (decoded is! Map) {
      return null;
    }

    final favoritoJson =
        decoded['favorito'];

    if (favoritoJson is! Map) {
      return null;
    }

    final favorito =
        Map<String, dynamic>.from(
      favoritoJson,
    );

    final favoritoId =
        _extraerId(
      favorito['_id'] ??
          favorito['id'],
    );

    final sitioJson =
        favorito['sitio'];

    if (favoritoId == null ||
        sitioJson is! Map) {
      return null;
    }

    try {
      final sitio =
          SitioTuristicoModel.fromJson(
        Map<String, dynamic>.from(
          sitioJson,
        ),
      );

      return FavoritoItem(
        id: favoritoId,
        sitio: sitio,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // ELIMINAR FAVORITO
  // ============================================================

  Future<void> eliminarFavorito(
    String favoritoId, {
    String? token,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/favoritos/$favoritoId',
      ),
      headers: _headers(token),
    ).timeout(
      const Duration(seconds: 10),
    );

    if (response.statusCode != 200) {
      final dynamic decoded =
          _decodificarRespuesta(
        response.body,
      );

      final mensaje = decoded is Map
          ? decoded['mensaje']?.toString()
          : null;

      throw Exception(
        mensaje ??
            'No fue posible eliminar el favorito.',
      );
    }
  }

  // ============================================================
  // HEADERS
  // ============================================================

  Map<String, String> _headers(
    String? token,
  ) {
    final headers = <String, String>{
      'Content-Type':
          'application/json',
    };

    if (token != null &&
        token.trim().isNotEmpty) {
      headers['Authorization'] =
          'Bearer ${token.trim()}';
    }

    return headers;
  }

  // ============================================================
  // UTILIDADES
  // ============================================================

  dynamic _decodificarRespuesta(
    String body,
  ) {
    if (body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String? _extraerId(
    dynamic valor,
  ) {
    if (valor == null) {
      return null;
    }

    if (valor is String &&
        valor.isNotEmpty) {
      return valor;
    }

    return valor.toString().isNotEmpty
        ? valor.toString()
        : null;
  }
}