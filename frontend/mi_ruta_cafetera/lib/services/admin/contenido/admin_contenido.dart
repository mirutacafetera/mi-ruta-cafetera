
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../models/admin/admin_contenido_model.dart';
import '../admin_servicio_autenticacion.dart';

class AdminContenido {
  AdminContenido._();

  static String get _url => '${ApiConfig.baseUrl}/admin/contenido';

  // ============================================================
  // HEADERS Y AUTENTICACIÓN
  // ============================================================

  static Future<Map<String, String>> _obtenerHeaders() async {
    await AdminServicioAutenticacion.cargarToken();

    final token = AdminServicioAutenticacion.tokenAdmin;

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // PROCESAMIENTO DE RESPUESTAS
  // ============================================================

  static dynamic _decodificarRespuesta(http.Response respuesta) {
    final cuerpo = respuesta.body.trim();

    if (cuerpo.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(cuerpo);
    } on FormatException {
      throw Exception('El servidor devolvió una respuesta no válida.');
    }
  }

  static void _validarRespuesta(http.Response respuesta) {
    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      final datos = _decodificarRespuesta(respuesta);

      final mensaje = datos is Map
          ? (datos['mensaje'] ??
                  datos['error'] ??
                  'Error al comunicarse con el servidor.')
              .toString()
          : 'Error al comunicarse con el servidor.';

      throw Exception(mensaje);
    }
  }

  static AdminContenidoModel _leerContenido(dynamic datos) {
    if (datos is! Map) {
      throw Exception('No se encontró la información del contenido.');
    }

    return AdminContenidoModel.fromJson(
      Map<String, dynamic>.from(datos),
    );
  }

  static AdminContenidoModel _leerContenidoDeRespuesta(
    dynamic datos,
  ) {
    if (datos is! Map || datos['contenido'] is! Map) {
      throw Exception('No se pudo obtener el contenido actualizado.');
    }

    return _leerContenido(datos['contenido']);
  }

  // ============================================================
  // OBTENER CONTENIDOS
  // GET /api/admin/contenido
  // GET /api/admin/contenido?estado=pendiente_revision
  // ============================================================

  static Future<List<AdminContenidoModel>> obtenerContenidos({
    String? estado,
  }) async {
    final uri = Uri.parse(_url).replace(
      queryParameters: estado == null || estado.isEmpty
          ? null
          : {'estado': estado},
    );

    final respuesta = await http.get(
      uri,
      headers: await _obtenerHeaders(),
    );

    _validarRespuesta(respuesta);

    final datos = _decodificarRespuesta(respuesta);

    if (datos is! List) {
      throw Exception(
        'La respuesta del servidor no contiene una lista de contenidos.',
      );
    }

    return datos
        .whereType<Map>()
        .map(
          (contenido) => AdminContenidoModel.fromJson(
            Map<String, dynamic>.from(contenido),
          ),
        )
        .toList();
  }

  // ============================================================
  // OBTENER UN CONTENIDO POR ID
  // GET /api/admin/contenido/:id
  // ============================================================

  static Future<AdminContenidoModel> obtenerContenido(
    String id,
  ) async {
    final respuesta = await http.get(
      Uri.parse('$_url/$id'),
      headers: await _obtenerHeaders(),
    );

    _validarRespuesta(respuesta);

    return _leerContenido(_decodificarRespuesta(respuesta));
  }

  // ============================================================
  // ACTUALIZAR CONTENIDO
  // PUT /api/admin/contenido/:id
  // ============================================================

  static Future<AdminContenidoModel> actualizarContenido({
    required String id,
    required Map<String, dynamic> datos,
  }) async {
    final respuesta = await http.put(
      Uri.parse('$_url/$id'),
      headers: await _obtenerHeaders(),
      body: jsonEncode(datos),
    );

    _validarRespuesta(respuesta);

    return _leerContenidoDeRespuesta(
      _decodificarRespuesta(respuesta),
    );
  }

  // ============================================================
  // APROBAR CONTENIDO
  // PUT /api/admin/contenido/:id/aprobar
  // ============================================================

  static Future<AdminContenidoModel> aprobarContenido(
    String id,
  ) async {
    final respuesta = await http.put(
      Uri.parse('$_url/$id/aprobar'),
      headers: await _obtenerHeaders(),
    );

    _validarRespuesta(respuesta);

    return _leerContenidoDeRespuesta(
      _decodificarRespuesta(respuesta),
    );
  }

  // ============================================================
  // RECHAZAR CONTENIDO
  // PUT /api/admin/contenido/:id/rechazar
  // ============================================================

  static Future<AdminContenidoModel> rechazarContenido({
    required String id,
    required String motivoRechazo,
  }) async {
    final respuesta = await http.put(
      Uri.parse('$_url/$id/rechazar'),
      headers: await _obtenerHeaders(),
      body: jsonEncode({
        'motivoRechazo': motivoRechazo.trim(),
      }),
    );

    _validarRespuesta(respuesta);

    return _leerContenidoDeRespuesta(
      _decodificarRespuesta(respuesta),
    );
  }

  // ============================================================
  // DESACTIVAR CONTENIDO APROBADO
  // PUT /api/admin/contenido/:id/desactivar
  // ============================================================

  static Future<void> desactivarContenido(String id) async {
    final respuesta = await http.put(
      Uri.parse('$_url/$id/desactivar'),
      headers: await _obtenerHeaders(),
    );

    _validarRespuesta(respuesta);
  }

  // ============================================================
  // ACTIVAR CONTENIDO APROBADO
  // PUT /api/admin/contenido/:id/activar
  // ============================================================

  static Future<void> activarContenido(String id) async {
    final respuesta = await http.put(
      Uri.parse('$_url/$id/activar'),
      headers: await _obtenerHeaders(),
    );

    _validarRespuesta(respuesta);
  }

  // ============================================================
  // ELIMINAR CONTENIDO
  // DELETE /api/admin/contenido/:id
  // ============================================================

  static Future<void> eliminarContenido(String id) async {
    final respuesta = await http.delete(
      Uri.parse('$_url/$id'),
      headers: await _obtenerHeaders(),
    );

    _validarRespuesta(respuesta);
  }
}
