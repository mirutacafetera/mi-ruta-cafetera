import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/admin/admin_producto_model.dart';
import 'admin_sesion_service.dart';

class AdminProductosService {
  AdminProductosService._();

  static Future<String> _obtenerToken() async {
    final token = await AdminSesionService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception('La sesión del administrador ha expirado.');
    }

    return token;
  }

  static Map<String, String> _headers(String token) {
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Future<List<AdminProductoModel>> obtenerPendientes() async {
    final token = await _obtenerToken();

    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/admin/productos/pendientes'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw _crearError(response);
    }

    final data = jsonDecode(response.body);

    if (data is! Map || data['productos'] is! List) {
      throw Exception('La respuesta de productos no es válida.');
    }

    return (data['productos'] as List)
        .whereType<Map>()
        .map(
          (producto) =>
              AdminProductoModel.fromJson(Map<String, dynamic>.from(producto)),
        )
        .toList();
  }

  static Future<AdminProductoModel> obtenerProducto(String productoId) async {
    final token = await _obtenerToken();

    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/admin/productos/$productoId'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw _crearError(response);
    }

    final data = jsonDecode(response.body);

    if (data is! Map || data['producto'] is! Map) {
      throw Exception('La respuesta del producto no es válida.');
    }

    return AdminProductoModel.fromJson(
      Map<String, dynamic>.from(data['producto']),
    );
  }

  static Future<AdminProductoModel> aprobarProducto(String productoId) async {
    final token = await _obtenerToken();

    final response = await http
        .put(
          Uri.parse('${ApiConfig.baseUrl}/admin/productos/$productoId/aprobar'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw _crearError(response);
    }

    return _leerProducto(response);
  }

  static Future<AdminProductoModel> rechazarProducto({
    required String productoId,
    required String motivoRechazo,
  }) async {
    final token = await _obtenerToken();

    final response = await http
        .put(
          Uri.parse(
            '${ApiConfig.baseUrl}/admin/productos/$productoId/rechazar',
          ),
          headers: {..._headers(token), 'Content-Type': 'application/json'},
          body: jsonEncode({'motivoRechazo': motivoRechazo.trim()}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw _crearError(response);
    }

    return _leerProducto(response);
  }

  static AdminProductoModel _leerProducto(http.Response response) {
    final data = jsonDecode(response.body);

    if (data is! Map || data['producto'] is! Map) {
      throw Exception('La respuesta del servidor no es válida.');
    }

    return AdminProductoModel.fromJson(
      Map<String, dynamic>.from(data['producto']),
    );
  }

  static Exception _crearError(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map) {
        return Exception(
          data['mensaje']?.toString() ??
              data['error']?.toString() ??
              'No fue posible completar la operación.',
        );
      }
    } catch (_) {
      // Se usa el mensaje genérico cuando la respuesta no es JSON.
    }

    return Exception(
      'Error ${response.statusCode}: no fue posible completar la operación.',
    );
  }
}
