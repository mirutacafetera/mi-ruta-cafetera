import 'dart:convert';

import 'package:http/http.dart' as http;

class AdminSitioCrud {
  // =========================
  // CREAR
  // =========================

  static Future<Map<String, dynamic>> crearSitio({
    required String baseUrl,
    required String nombreCuenta,
    required String apellidoCuenta,
    required String correo,
    required String password,
    String telefonoCuenta = '',
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
    String imagen = '',
    List<String> imagenes = const [],
    String horario = '',
    double precioDesde = 0,
  }) async {
    final responseSitio = await http.post(
      Uri.parse('$baseUrl/admin/sitios'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'direccion': direccion,
        'ciudad': ciudad,
        'departamento': departamento,
        'latitud': latitud,
        'longitud': longitud,
        'categoria': categoria,
        'etiquetas': etiquetas,
        'activo': activo,
        'telefono': telefono,
        'correos': correos,
        'sitioWeb': sitioWeb,
        'imagen': imagen,
        'imagenes': imagenes,
        'horario': horario,
        'precioDesde': precioDesde,
      }),
    );

    if (responseSitio.statusCode != 201) {
      throw Exception(
        'Error al crear el sitio turístico: '
        '${responseSitio.statusCode} - ${responseSitio.body}',
      );
    }

    final dataSitio = jsonDecode(responseSitio.body);

    if (dataSitio is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta al crear el sitio no tiene '
        'el formato esperado.',
      );
    }

    final sitioCreado = dataSitio['sitio'];

    if (sitioCreado is! Map<String, dynamic>) {
      throw Exception(
        'El servidor no devolvió el sitio creado.',
      );
    }

    final sitioId = sitioCreado['_id']?.toString() ?? '';

    if (sitioId.isEmpty) {
      throw Exception(
        'No se pudo obtener el ID del sitio creado.',
      );
    }

    // Crear cuenta del sitio
    final responseCuenta = await http.post(
      Uri.parse('$baseUrl/admin/authsitio/cuenta'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sitioId': sitioId,
        'nombre': nombreCuenta,
        'apellido': apellidoCuenta,
        'correo': correo,
        'password': password,
        'telefono': telefonoCuenta,
      }),
    );

    if (responseCuenta.statusCode != 201) {
      throw Exception(
        'El sitio fue creado, pero no se pudo crear '
        'su cuenta: ${responseCuenta.statusCode} - '
        '${responseCuenta.body}',
      );
    }

    final dataCuenta = jsonDecode(
      responseCuenta.body,
    );

    return {
      'sitio': sitioCreado,
      'cuenta': dataCuenta is Map<String, dynamic>
          ? dataCuenta['cuenta']
          : null,
    };
  }

  // =========================
  // ACTUALIZAR
  // =========================

  static Future<void> actualizarSitio({
    required String baseUrl,
    required String id,
    String? correo,
    String? password,
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
    String imagen = '',
    List<String> imagenes = const [],
    String horario = '',
    double precioDesde = 0,
  }) async {
    final datos = {
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'ciudad': ciudad,
      'departamento': departamento,
      'latitud': latitud,
      'longitud': longitud,
      'categoria': categoria,
      'etiquetas': etiquetas,
      'activo': activo,
      'telefono': telefono,
      'correos': correos,
      'sitioWeb': sitioWeb,
      'imagen': imagen,
      'imagenes': imagenes,
      'horario': horario,
      'precioDesde': precioDesde,
    };

    final response = await http.put(
      Uri.parse('$baseUrl/admin/sitios/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(datos),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al actualizar el sitio turístico: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }

  // =========================
  // ELIMINAR
  // =========================

  static Future<void> eliminarSitio(
    String baseUrl,
    String id,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/sitios/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al eliminar el sitio turístico: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }
}