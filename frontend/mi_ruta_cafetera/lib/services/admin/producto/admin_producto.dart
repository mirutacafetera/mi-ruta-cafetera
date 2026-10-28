
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../models/admin/admin_producto_model.dart';
import '../../../config/api_config.dart';

class AdminProducto {
  AdminProducto._();

  static String get _baseUrl => '${ApiConfig.baseUrl}/admin/productos';

  static Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static dynamic _procesarRespuesta(http.Response respuesta) {
    dynamic datos;

    try {
      datos = jsonDecode(respuesta.body);
    } catch (_) {
      datos = null;
    }

    if (respuesta.statusCode >= 200 &&
        respuesta.statusCode < 300) {
      return datos;
    }

    String mensaje = 'Error al procesar la solicitud';

    if (datos is Map) {
      mensaje =
          (datos['mensaje'] ?? datos['error'] ?? mensaje).toString();
    }

    throw Exception(mensaje);
  }

  // ============================================================
  // OBTENER PRODUCTOS PENDIENTES
  // GET /api/admin/productos/pendientes
  // ============================================================

  static Future<List<AdminProductoModel>> obtenerProductosPendientes({
    required String token,
  }) async {
    final respuesta = await http.get(
      Uri.parse('$_baseUrl/pendientes'),
      headers: _headers(token),
    );

    return _obtenerListaProductos(respuesta);
  }

  // ============================================================
  // OBTENER PRODUCTOS POR ESTADO
  // GET /api/admin/productos/estado/:estado
  // ============================================================

  static Future<List<AdminProductoModel>> obtenerProductosPorEstado({
    required String estado,
    required String token,
  }) async {
    const estadosPermitidos = {
      'aprobado',
      'rechazado',
    };

    if (!estadosPermitidos.contains(estado)) {
      throw Exception('El estado solicitado no es válido.');
    }

    final respuesta = await http.get(
      Uri.parse(
        '$_baseUrl/estado/${Uri.encodeComponent(estado)}',
      ),
      headers: _headers(token),
    );

    return _obtenerListaProductos(respuesta);
  }

  // ============================================================
  // PROCESAR LISTA DE PRODUCTOS
  // ============================================================

  static List<AdminProductoModel> _obtenerListaProductos(
    http.Response respuesta,
  ) {
    final datos = _procesarRespuesta(respuesta);

    if (datos is! Map || datos['productos'] is! List) {
      throw Exception(
        'La respuesta del servidor no contiene una lista de productos válida.',
      );
    }

    return (datos['productos'] as List)
        .whereType<Map>()
        .map(
          (producto) => AdminProductoModel.fromJson(
            Map<String, dynamic>.from(producto),
          ),
        )
        .toList();
  }

  // ============================================================
  // OBTENER UN PRODUCTO POR ID
  // GET /api/admin/productos/:id
  // ============================================================

  static Future<AdminProductoModel> obtenerProducto({
    required String id,
    required String token,
  }) async {
    final respuesta = await http.get(
      Uri.parse('$_baseUrl/${Uri.encodeComponent(id)}'),
      headers: _headers(token),
    );

    final datos = _procesarRespuesta(respuesta);

    if (datos is! Map || datos['producto'] is! Map) {
      throw Exception(
        'El servidor no devolvió la información del producto.',
      );
    }

    return AdminProductoModel.fromJson(
      Map<String, dynamic>.from(datos['producto'] as Map),
    );
  }

  // ============================================================
  // APROBAR PRODUCTO
  // PUT /api/admin/productos/:id/aprobar
  // ============================================================

  static Future<AdminProductoModel> aprobarProducto({
    required String id,
    required String token,
  }) async {
    final respuesta = await http.put(
      Uri.parse(
        '$_baseUrl/${Uri.encodeComponent(id)}/aprobar',
      ),
      headers: _headers(token),
    );

    final datos = _procesarRespuesta(respuesta);

    if (datos is! Map || datos['producto'] is! Map) {
      throw Exception(
        'El servidor no devolvió el producto aprobado.',
      );
    }

    return AdminProductoModel.fromJson(
      Map<String, dynamic>.from(datos['producto'] as Map),
    );
  }

  // ============================================================
  // RECHAZAR PRODUCTO
  // PUT /api/admin/productos/:id/rechazar
  // ============================================================

  static Future<AdminProductoModel> rechazarProducto({
    required String id,
    required String motivoRechazo,
    required String token,
  }) async {
    if (motivoRechazo.trim().length < 3) {
      throw Exception(
        'Debes indicar un motivo de rechazo de al menos 3 caracteres.',
      );
    }

    final respuesta = await http.put(
      Uri.parse(
        '$_baseUrl/${Uri.encodeComponent(id)}/rechazar',
      ),
      headers: _headers(token),
      body: jsonEncode({
        'motivoRechazo': motivoRechazo.trim(),
      }),
    );

    final datos = _procesarRespuesta(respuesta);

    if (datos is! Map || datos['producto'] is! Map) {
      throw Exception(
        'El servidor no devolvió el producto rechazado.',
      );
    }

    return AdminProductoModel.fromJson(
      Map<String, dynamic>.from(datos['producto'] as Map),
    );
  }

  // ============================================================
  // ELIMINAR PRODUCTO
  // DELETE /api/admin/productos/:id
  // ============================================================

  static Future<void> eliminarProducto({
    required String id,
    required String token,
  }) async {
    final respuesta = await http.delete(
      Uri.parse('$_baseUrl/${Uri.encodeComponent(id)}'),
      headers: _headers(token),
    );

    _procesarRespuesta(respuesta);
  }
}
