
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../models/categoria_model.dart';
import '../admin_servicio_autenticacion.dart';

class AdminCategoria {
  AdminCategoria._();

  // ============================================================
  // CONFIGURACIÓN
  // ============================================================

  static String get baseUrl => ApiConfig.baseUrl;

  static String? get tokenAdmin =>
      AdminServicioAutenticacion.tokenAdmin;

  // ============================================================
  // OBTENER TODAS LAS CATEGORÍAS
  // ============================================================

  static Future<List<CategoriaModel>> obtenerCategorias() async {
    final token = tokenAdmin?.trim() ?? '';

    if (token.isEmpty) {
      throw Exception(
        'No se encontró el token del administrador. '
        'Inicia sesión nuevamente.',
      );
    }

    final response = await http
        .get(
          Uri.parse('$baseUrl/categorias-sitios'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener las categorías: '
        '${response.statusCode} - ${response.body}',
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is! List) {
      throw Exception(
        'La respuesta del servidor no tiene el formato '
        'esperado para categorías.',
      );
    }

    return data
        .whereType<Map>()
        .map(
          (item) => CategoriaModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // ============================================================
  // OBTENER UNA CATEGORÍA
  // ============================================================

  static Future<CategoriaModel> obtenerCategoria(String id) async {
    final token = tokenAdmin?.trim() ?? '';

    if (token.isEmpty) {
      throw Exception(
        'No se encontró el token del administrador. '
        'Inicia sesión nuevamente.',
      );
    }

    final response = await http
        .get(
          Uri.parse('$baseUrl/categorias-sitios/$id'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener la categoría: '
        '${response.statusCode} - ${response.body}',
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta del servidor no tiene el formato esperado.',
      );
    }

    return CategoriaModel.fromJson(data);
  }

  // ============================================================
  // CREAR CATEGORÍA
  // ============================================================

  static Future<CategoriaModel> crearCategoria({
    required String nombre,
    String descripcion = '',
    String icono = 'location_on',
  }) async {
    final token = tokenAdmin?.trim() ?? '';

    if (token.isEmpty) {
      throw Exception(
        'No se encontró el token del administrador. '
        'Inicia sesión nuevamente.',
      );
    }

    final response = await http
        .post(
          Uri.parse('$baseUrl/categorias-sitios'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'nombre': nombre.trim(),
            'descripcion': descripcion.trim(),
            'icono': icono.trim().isEmpty
                ? 'location_on'
                : icono.trim(),
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 201) {
      throw Exception(
        _obtenerMensajeError(
          response,
          'Error al crear la categoría',
        ),
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta al crear la categoría '
        'no tiene el formato esperado.',
      );
    }

    final categoria = data['categoria'];

    if (categoria is! Map<String, dynamic>) {
      throw Exception(
        'El servidor no devolvió la categoría creada.',
      );
    }

    return CategoriaModel.fromJson(categoria);
  }

  // ============================================================
  // ACTUALIZAR CATEGORÍA
  // ============================================================

  static Future<CategoriaModel> actualizarCategoria({
    required String id,
    required String nombre,
    String descripcion = '',
    String icono = 'location_on',
    bool estado = true,
  }) async {
    final token = tokenAdmin?.trim() ?? '';

    if (token.isEmpty) {
      throw Exception(
        'No se encontró el token del administrador. '
        'Inicia sesión nuevamente.',
      );
    }

    final response = await http
        .put(
          Uri.parse('$baseUrl/categorias-sitios/$id'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'nombre': nombre.trim(),
            'descripcion': descripcion.trim(),
            'icono': icono.trim().isEmpty
                ? 'location_on'
                : icono.trim(),
            'estado': estado,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        _obtenerMensajeError(
          response,
          'Error al actualizar la categoría',
        ),
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta al actualizar la categoría '
        'no tiene el formato esperado.',
      );
    }

    final categoria = data['categoria'];

    if (categoria is! Map<String, dynamic>) {
      throw Exception(
        'El servidor no devolvió la categoría actualizada.',
      );
    }

    return CategoriaModel.fromJson(categoria);
  }

  // ============================================================
  // ELIMINAR CATEGORÍA DEFINITIVAMENTE
  // ============================================================

  static Future<void> eliminarCategoria(String id) async {
    final token = tokenAdmin?.trim() ?? '';

    if (token.isEmpty) {
      throw Exception(
        'No se encontró el token del administrador. '
        'Inicia sesión nuevamente.',
      );
    }

    final response = await http
        .delete(
          Uri.parse('$baseUrl/categorias-sitios/$id'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        _obtenerMensajeError(
          response,
          'Error al eliminar la categoría',
        ),
      );
    }
  }

  // ============================================================
  // OBTENER MENSAJE DE ERROR
  // ============================================================

  static String _obtenerMensajeError(
    http.Response response,
    String mensajePorDefecto,
  ) {
    try {
      final dynamic data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        final mensaje = data['mensaje'];

        if (mensaje != null &&
            mensaje.toString().trim().isNotEmpty) {
          return mensaje.toString();
        }

        final error = data['error'];

        if (error != null &&
            error.toString().trim().isNotEmpty) {
          return error.toString();
        }
      }
    } catch (_) {
      // La respuesta no contiene JSON válido.
    }

    return '$mensajePorDefecto: ${response.statusCode}';
  }
}
