import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/api_config.dart';
import '../../models/sitio/sitio_producto_model.dart';

class SitioProductosService {
  // ============================================================
  // PRODUCTOS PUBLICADOS: ACCESO PÚBLICO
  // ============================================================

  Future<List<SitioProductoModel>> obtenerProductosPublicos({
    required String sitioId,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/sitiosturisticos/productos/$sitioId'),
    );

    if (response.statusCode != 200) {
      throw _crearError(response);
    }

    final lista = _extraerListaProductos(response);

    return lista
        .map(_convertirProducto)
        .where(
          (producto) =>
              producto.activo && producto.estadoPublicacion == 'aprobado',
        )
        .toList();
  }

  // ============================================================
  // PRODUCTOS DEL PROPIETARIO
  // ============================================================

  Future<List<SitioProductoModel>> obtenerProductos({
    required String token,
    required String sitioId,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/productos/'
        '$sitioId/propietario',
      ),
      headers: _crearHeaders(token),
    );

    if (response.statusCode != 200) {
      throw _crearError(response);
    }

    final lista = _extraerListaProductos(response);

    return lista.map(_convertirProducto).toList();
  }

  // ============================================================
  // CREAR PRODUCTO
  // ============================================================

  Future<SitioProductoModel> crearProducto({
    required String token,
    required String sitioId,
    required String nombre,
    required String descripcion,
    required double precio,
    required String categoria,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/sitiosturisticos/productos/$sitioId'),
      headers: _crearHeaders(token),
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'categoria': categoria,
      }),
    );

    if (response.statusCode != 201) {
      throw _crearError(response);
    }

    return _extraerProducto(response);
  }

  // ============================================================
  // ACTUALIZAR PRODUCTO
  // ============================================================

  Future<SitioProductoModel> actualizarProducto({
    required String token,
    required String sitioId,
    required String productoId,
    required String nombre,
    required String descripcion,
    required double precio,
    required String categoria,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/productos/'
        '$sitioId/$productoId',
      ),
      headers: _crearHeaders(token),
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'categoria': categoria,
      }),
    );

    if (response.statusCode != 200) {
      throw _crearError(response);
    }

    return _extraerProducto(response);
  }

  // ============================================================
  // SUBIR IMÁGENES
  // ============================================================

  Future<SitioProductoModel> subirImagenes({
    required String token,
    required String sitioId,
    required String productoId,
    required List<XFile> archivos,
  }) async {
    if (archivos.isEmpty) {
      throw Exception('Debes seleccionar al menos una imagen.');
    }

    if (archivos.length > 10) {
      throw Exception('Puedes seleccionar máximo 10 imágenes por carga.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/productos/'
        '$sitioId/$productoId/imagenes',
      ),
    );

    request.headers['Authorization'] = 'Bearer $token';

    for (final archivo in archivos) {
      final nombre = archivo.name.toLowerCase();
      final MediaType tipo;

      if (nombre.endsWith('.jpg') || nombre.endsWith('.jpeg')) {
        tipo = MediaType('image', 'jpeg');
      } else if (nombre.endsWith('.png')) {
        tipo = MediaType('image', 'png');
      } else if (nombre.endsWith('.webp')) {
        tipo = MediaType('image', 'webp');
      } else {
        throw Exception(
          'Formato no permitido: ${archivo.name}. '
          'Usa JPG, JPEG, PNG o WEBP.',
        );
      }

      final bytes = await archivo.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception(
          'La imagen "${archivo.name}" está vacía '
          'o no se pudo leer.',
        );
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'imagenes',
          bytes,
          filename: archivo.name,
          contentType: tipo,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      throw _crearError(response);
    }

    return _extraerProducto(response);
  }

  // ============================================================
  // ELIMINAR IMAGEN DE GALERÍA
  // ============================================================

  Future<SitioProductoModel> eliminarImagen({
    required String token,
    required String sitioId,
    required String productoId,
    required String url,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/productos/'
        '$sitioId/$productoId/imagenes',
      ),
      headers: _crearHeaders(token),
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode != 200) {
      throw _crearError(response);
    }

    return _extraerProducto(response);
  }

  // ============================================================
  // ESTABLECER IMAGEN PRINCIPAL
  // ============================================================

  Future<SitioProductoModel> establecerImagenPrincipal({
    required String token,
    required String sitioId,
    required String productoId,
    required String url,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/productos/'
        '$sitioId/$productoId/imagen-principal',
      ),
      headers: _crearHeaders(token),
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode != 200) {
      throw _crearError(response);
    }

    return _extraerProducto(response);
  }

  // ============================================================
  // ENVIAR PRODUCTO A REVISIÓN
  // ============================================================

  Future<SitioProductoModel> enviarARevision({
    required String token,
    required String sitioId,
    required String productoId,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/productos/'
        '$sitioId/$productoId/enviar-revision',
      ),
      headers: _crearHeaders(token),
    );

    if (response.statusCode != 200) {
      throw _crearError(response);
    }

    return _extraerProducto(response);
  }

  // ============================================================
  // ELIMINAR PRODUCTO
  // ============================================================

  Future<void> eliminarProducto({
    required String token,
    required String sitioId,
    required String productoId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/productos/'
        '$sitioId/$productoId',
      ),
      headers: _crearHeaders(token),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw _crearError(response);
    }
  }

  // ============================================================
  // EXTRAER LISTA DE PRODUCTOS
  // Acepta una lista directa o { "productos": [...] }.
  // ============================================================

  List<dynamic> _extraerListaProductos(http.Response response) {
    final dynamic data;

    try {
      data = jsonDecode(response.body);
    } on FormatException {
      throw Exception('El servidor devolvió una respuesta JSON no válida.');
    }

    if (data is List) {
      return data;
    }

    if (data is Map && data['productos'] is List) {
      return data['productos'] as List<dynamic>;
    }

    throw Exception(
      'La respuesta del servidor no contiene una lista de productos.',
    );
  }

  // ============================================================
  // EXTRAER UN PRODUCTO
  // Acepta { "producto": {...} }.
  // ============================================================

  SitioProductoModel _extraerProducto(http.Response response) {
    final dynamic data;

    try {
      data = jsonDecode(response.body);
    } on FormatException {
      throw Exception('El servidor devolvió una respuesta JSON no válida.');
    }

    if (data is! Map || data['producto'] is! Map) {
      throw Exception(
        'La respuesta del servidor no contiene el producto esperado.',
      );
    }

    return _convertirProducto(data['producto']);
  }

  SitioProductoModel _convertirProducto(dynamic data) {
    if (data is! Map) {
      throw Exception('El servidor devolvió un producto no válido.');
    }

    return SitioProductoModel.fromJson(Map<String, dynamic>.from(data));
  }

  // ============================================================
  // ENCABEZADOS
  // ============================================================

  Map<String, String> _crearHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // MANEJO DE ERRORES
  // ============================================================

  Exception _crearError(http.Response response) {
    try {
      final dynamic data = jsonDecode(response.body);

      if (data is Map) {
        final mensaje =
            data['mensaje']?.toString() ?? data['error']?.toString();

        if (mensaje != null && mensaje.trim().isNotEmpty) {
          return Exception(mensaje);
        }
      }
    } on FormatException {
      // Si la respuesta no es JSON, se informa el código HTTP.
    }

    return Exception(
      'Error ${response.statusCode}: '
      'No fue posible completar la operación.',
    );
  }
}
