import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AdminSitioCrud {
  AdminSitioCrud._();

  // ============================================================
  // CREAR SITIO TURÍSTICO
  // ============================================================

  static Future<Map<String, dynamic>> crearSitio({
    required String baseUrl,
    String? tokenAdmin,

    // ----------------------------------------------------------
    // CUENTA DEL SITIO
    // ----------------------------------------------------------

    required String nombreCuenta,
    required String apellidoCuenta,
    required String correo,
    required String password,
    String telefonoCuenta = '',

    // ----------------------------------------------------------
    // INFORMACIÓN DEL SITIO
    // ----------------------------------------------------------

    required String nombre,
    required String descripcion,
    required String categoria,
    String direccion = '',
    String ciudad = 'Garzón',
    String departamento = 'Huila',
    required double latitud,
    required double longitud,
    List<String> etiquetas = const [],
    bool activo = true,

    String telefono = '',
    String correos = '',
    String sitioWeb = '',

    // ----------------------------------------------------------
    // IMAGEN PRINCIPAL
    // ----------------------------------------------------------

    required Uint8List imagenBytes,
    String nombreImagen = 'imagen.jpg',

    // ----------------------------------------------------------
    // INFORMACIÓN TURÍSTICA
    // ----------------------------------------------------------

    String horario = '',
    double precioDesde = 0,
  }) async {
    // ==========================================================
    // VALIDAR TOKEN
    // ==========================================================

    final token = tokenAdmin?.trim() ?? '';

    if (token.isEmpty) {
      throw Exception(
        'No se encontró el token del administrador. '
        'Inicia sesión nuevamente.',
      );
    }

    // ==========================================================
    // VALIDAR IMAGEN
    // ==========================================================

    if (imagenBytes.isEmpty) {
      throw Exception(
        'La imagen principal es obligatoria.',
      );
    }

    // ==========================================================
    // CREAR PETICIÓN MULTIPART
    // ==========================================================

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/admin/sitios'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // ==========================================================
    // CAMPOS DEL SITIO
    // ==========================================================

    request.fields.addAll({
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'ciudad': ciudad,
      'departamento': departamento,
      'latitud': latitud.toString(),
      'longitud': longitud.toString(),
      'categoria': categoria,
      'etiquetas': jsonEncode(etiquetas),
      'activo': activo.toString(),
      'telefono': telefono,
      'correos': correos,
      'sitioWeb': sitioWeb,
      'horario': horario,
      'precioDesde': precioDesde.toString(),
    });

    // ==========================================================
    // IMAGEN PRINCIPAL
    // ==========================================================
    //
    // IMPORTANTE:
    // Indicamos explícitamente que la imagen enviada es JPEG.
    //
    // Esto evita que el backend reciba el archivo como:
    // application/octet-stream
    //
    // El backend espera:
    // image/jpeg
    // ==========================================================

    request.files.add(
      http.MultipartFile.fromBytes(
        'imagen',
        imagenBytes,
        filename: 'imagen.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    // ==========================================================
    // ENVIAR PETICIÓN
    // ==========================================================

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    // ==========================================================
    // VALIDAR RESPUESTA
    // ==========================================================

    if (response.statusCode != 201) {
      throw Exception(
        'Error al crear el sitio turístico: '
        '${response.statusCode} - ${response.body}',
      );
    }

    // ==========================================================
    // DECODIFICAR RESPUESTA
    // ==========================================================

    final dataSitio = jsonDecode(response.body);

    if (dataSitio is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta al crear el sitio no tiene '
        'el formato esperado.',
      );
    }

    // ==========================================================
    // OBTENER SITIO CREADO
    // ==========================================================

    final sitioCreado = dataSitio['sitio'];

    if (sitioCreado is! Map<String, dynamic>) {
      throw Exception(
        'El servidor no devolvió el sitio creado.',
      );
    }

    // ==========================================================
    // OBTENER ID DEL SITIO
    // ==========================================================

    final sitioId =
        sitioCreado['_id']?.toString() ?? '';

    if (sitioId.isEmpty) {
      throw Exception(
        'No se pudo obtener el ID del sitio creado.',
      );
    }

    // ==========================================================
    // CREAR CUENTA DEL SITIO
    // ==========================================================

    final responseCuenta = await http
        .post(
          Uri.parse(
            '$baseUrl/admin/authsitio/crear-cuenta-sitio',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'sitioId': sitioId,
            'nombre': nombreCuenta,
            'apellido': apellidoCuenta,
            'correo': correo.trim().toLowerCase(),
            'password': password,
            'telefono': telefonoCuenta,
          }),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    // ==========================================================
    // VALIDAR CUENTA
    // ==========================================================

    if (responseCuenta.statusCode != 201) {
      String mensaje =
          'No se pudo crear la cuenta del sitio.';

      try {
        final error = jsonDecode(
          responseCuenta.body,
        );

        if (error is Map<String, dynamic> &&
            error['mensaje'] != null) {
          mensaje = error['mensaje'].toString();
        }
      } catch (_) {}

      throw Exception(
        '$mensaje\nID del sitio: $sitioId',
      );
    }

    final dataCuenta = jsonDecode(
      responseCuenta.body,
    );

    if (dataCuenta is! Map<String, dynamic>) {
      throw Exception(
        'El sitio fue creado, pero la respuesta de '
        'su cuenta no tiene el formato esperado.',
      );
    }

    // ==========================================================
    // RESULTADO
    // ==========================================================

    return {
      'sitio': sitioCreado,
      'cuenta': dataCuenta['cuenta'],
    };
  }

  // ============================================================
  // ACTUALIZAR SITIO TURÍSTICO
  // ============================================================

  static Future<void> actualizarSitio({
    required String baseUrl,
    String? tokenAdmin,

    required String id,

    required String nombre,
    required String descripcion,
    required String categoria,

    String direccion = '',
    String ciudad = 'Garzón',
    String departamento = 'Huila',

    required double latitud,
    required double longitud,

    List<String> etiquetas = const [],

    bool activo = true,

    String telefono = '',
    String correos = '',
    String sitioWeb = '',

    // ----------------------------------------------------------
    // IMAGEN PRINCIPAL
    // ----------------------------------------------------------

    Uint8List? imagenBytes,
    String nombreImagen = 'imagen.jpg',

    // ----------------------------------------------------------
    // INFORMACIÓN TURÍSTICA
    // ----------------------------------------------------------

    String horario = '',
    double precioDesde = 0,
  }) async {
    // ==========================================================
    // VALIDAR TOKEN
    // ==========================================================

    final token = tokenAdmin?.trim() ?? '';

    if (token.isEmpty) {
      throw Exception(
        'No se encontró el token del administrador. '
        'Inicia sesión nuevamente.',
      );
    }

    // ==========================================================
    // CREAR PETICIÓN MULTIPART
    // ==========================================================

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/admin/sitios/$id'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // ==========================================================
    // CAMPOS DEL SITIO
    // ==========================================================

    request.fields.addAll({
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'ciudad': ciudad,
      'departamento': departamento,
      'latitud': latitud.toString(),
      'longitud': longitud.toString(),
      'categoria': categoria,
      'etiquetas': jsonEncode(etiquetas),
      'activo': activo.toString(),
      'telefono': telefono,
      'correos': correos,
      'sitioWeb': sitioWeb,
      'horario': horario,
      'precioDesde': precioDesde.toString(),
    });

    // ==========================================================
    // NUEVA IMAGEN PRINCIPAL
    // ==========================================================

    if (imagenBytes != null &&
        imagenBytes.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'imagen',
          imagenBytes,
          filename: 'imagen.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    // ==========================================================
    // ENVIAR PETICIÓN
    // ==========================================================

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    // ==========================================================
    // VALIDAR RESPUESTA
    // ==========================================================

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Error al actualizar el sitio turístico: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }

  // ============================================================
  // ELIMINAR SITIO TURÍSTICO
  // ============================================================

  static Future<void> eliminarSitio({
    required String baseUrl,
    required String id,
    String? tokenAdmin,
  }) async {
    // ==========================================================
    // VALIDAR TOKEN
    // ==========================================================

    final token = tokenAdmin?.trim() ?? '';

    if (token.isEmpty) {
      throw Exception(
        'No se encontró el token del administrador. '
        'Inicia sesión nuevamente.',
      );
    }

    // ==========================================================
    // ELIMINAR
    // ==========================================================

    final response = await http
        .delete(
          Uri.parse('$baseUrl/admin/sitios/$id'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(
          const Duration(seconds: 15),
        );

    // ==========================================================
    // VALIDAR RESPUESTA
    // ==========================================================

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Error al eliminar el sitio turístico: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }
}