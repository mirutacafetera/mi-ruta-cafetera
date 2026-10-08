import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/ruta_model.dart';

class RutaService {
  // ============================================================
  // OBTENER RUTAS PREDEFINIDAS
  // ============================================================

  Future<List<RutaModel>> obtenerRutasPredefinidas() async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.rutasUrl}/predefinidas',
      ),
      headers: _headers(),
    );

    final decoded = _decodificarRespuesta(
      response.body,
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      final mensaje = _obtenerMensaje(decoded);

      throw Exception(
        mensaje ??
            'Error al obtener las rutas predefinidas '
            '(${response.statusCode}).',
      );
    }

    final data = _extraerLista(decoded);

    return data
        .whereType<Map>()
        .map(
          (item) => RutaModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // ============================================================
  // OBTENER RUTAS DE UN USUARIO
  // ============================================================

  Future<List<RutaModel>> obtenerRutasPorUsuario(
    String usuarioId, {
    String? token,
  }) async {
    final id = usuarioId.trim();

    if (id.isEmpty) {
      throw Exception(
        'No se recibió el identificador del usuario.',
      );
    }

    if (!_tieneToken(token)) {
      throw Exception(
        'No se recibió el token de autenticación.',
      );
    }

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.rutasUrl}/$id',
      ),
      headers: _headers(token),
    );

    final decoded = _decodificarRespuesta(
      response.body,
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      final mensaje = _obtenerMensaje(decoded);

      throw Exception(
        mensaje ??
            'Error al obtener las rutas del usuario '
            '(${response.statusCode}).',
      );
    }

    final data = _extraerLista(decoded);

    return data
        .whereType<Map>()
        .map(
          (item) => RutaModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // ============================================================
  // CREAR RUTA
  // ============================================================

  Future<RutaModel> crearRuta({
    required String usuarioId,
    required String nombre,
    required List<String> sitios,
    String descripcion = '',
    String tipo = 'personalizada',
    bool activa = true,
    String? token,
  }) async {
    final idUsuario = usuarioId.trim();
    final nombreRuta = nombre.trim();
    final tipoRuta = tipo.trim().isEmpty
        ? 'personalizada'
        : tipo.trim();

    if (idUsuario.isEmpty) {
      throw Exception(
        'No se recibió el identificador del usuario.',
      );
    }

    if (!_tieneToken(token)) {
      throw Exception(
        'No se recibió el token de autenticación.',
      );
    }

    if (nombreRuta.isEmpty) {
      throw Exception(
        'El nombre de la ruta es obligatorio.',
      );
    }

    if (sitios.isEmpty || sitios.length > 4) {
      throw Exception(
        'La ruta debe contener entre 1 y 4 sitios.',
      );
    }

    final sitiosNormalizados = sitios
        .map((sitio) => sitio.trim())
        .where((sitio) => sitio.isNotEmpty)
        .toList();

    if (sitiosNormalizados.length != sitios.length) {
      throw Exception(
        'La ruta contiene identificadores de sitios inválidos.',
      );
    }

    final response = await http.post(
      Uri.parse(
        ApiConfig.rutasUrl,
      ),
      headers: _headers(token),
      body: jsonEncode({
        'usuario': idUsuario,
        'nombre': nombreRuta,
        'descripcion': descripcion.trim(),
        'sitios': sitiosNormalizados,
        'tipo': tipoRuta,
        'activa': activa,
      }),
    );

    final decoded = _decodificarRespuesta(
      response.body,
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      final mensaje = _obtenerMensaje(decoded);

      throw Exception(
        mensaje ??
            'No fue posible crear la ruta '
            '(${response.statusCode}).',
      );
    }

    final data = _extraerObjeto(
      decoded,
      claves: const [
        'ruta',
        'data',
      ],
    );

    if (data == null) {
      throw Exception(
        'El servidor no devolvió la ruta creada.',
      );
    }

    return RutaModel.fromJson(data);
  }

  // ============================================================
  // ELIMINAR RUTA
  // ============================================================

  Future<void> eliminarRuta(
    String rutaId, {
    String? token,
  }) async {
    final id = rutaId.trim();

    if (id.isEmpty) {
      throw Exception(
        'No se recibió el identificador de la ruta.',
      );
    }

    if (!_tieneToken(token)) {
      throw Exception(
        'No se recibió el token de autenticación.',
      );
    }

    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.rutasUrl}/$id',
      ),
      headers: _headers(token),
    );

    final decoded = _decodificarRespuesta(
      response.body,
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      final mensaje = _obtenerMensaje(decoded);

      throw Exception(
        mensaje ??
            'Error al eliminar la ruta '
            '(${response.statusCode}).',
      );
    }
  }

  // ============================================================
  // HEADERS
  // ============================================================

  Map<String, String> _headers([
    String? token,
  ]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_tieneToken(token)) {
      headers['Authorization'] =
          'Bearer ${token!.trim()}';
    }

    return headers;
  }

  // ============================================================
  // VALIDAR TOKEN
  // ============================================================

  bool _tieneToken(String? token) {
    return token != null &&
        token.trim().isNotEmpty;
  }

  // ============================================================
  // DECODIFICAR RESPUESTA
  // ============================================================

  dynamic _decodificarRespuesta(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // EXTRAER LISTA
  // ============================================================

  List<dynamic> _extraerLista(
    dynamic decoded,
  ) {
    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map) {
      final data =
          decoded['rutas'] ??
          decoded['data'] ??
          decoded['results'] ??
          [];

      if (data is List) {
        return data;
      }
    }

    return [];
  }

  // ============================================================
  // EXTRAER OBJETO
  // ============================================================

  Map<String, dynamic>? _extraerObjeto(
    dynamic decoded, {
    required List<String> claves,
  }) {
    if (decoded is Map) {
      for (final clave in claves) {
        final valor = decoded[clave];

        if (valor is Map) {
          return Map<String, dynamic>.from(
            valor,
          );
        }
      }

      return Map<String, dynamic>.from(
        decoded,
      );
    }

    return null;
  }

  // ============================================================
  // EXTRAER MENSAJE
  // ============================================================

  String? _obtenerMensaje(
    dynamic decoded,
  ) {
    if (decoded is Map) {
      final mensaje =
          decoded['mensaje'] ??
          decoded['message'] ??
          decoded['error'];

      if (mensaje != null) {
        return mensaje.toString();
      }
    }

    return null;
  }
}