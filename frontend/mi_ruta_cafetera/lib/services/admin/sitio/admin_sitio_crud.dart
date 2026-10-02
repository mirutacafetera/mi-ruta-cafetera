import 'dart:convert';

import 'package:http/http.dart' as http;

class AdminSitioCrud {
  // ============================================================
  // CREAR SITIO TURÍSTICO Y SU CUENTA
  // ============================================================

  static Future<Map<String, dynamic>> crearSitio({
    required String baseUrl,

    // Token del administrador
    String? tokenAdmin,

    // Datos de la cuenta
    required String nombreCuenta,
    required String apellidoCuenta,
    required String correo,
    required String password,
    String telefonoCuenta = '',

    // Datos del sitio
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
    // ==========================================================
    // VALIDAR TOKEN DEL ADMINISTRADOR
    // ==========================================================

    final token = tokenAdmin?.trim() ?? '';

    if (token.isEmpty) {
      throw Exception(
        'No se encontró el token del administrador. '
        'Inicia sesión nuevamente.',
      );
    }

    // ==========================================================
    // CREAR SITIO TURÍSTICO
    // ==========================================================

    final responseSitio = await http
        .post(
          Uri.parse('$baseUrl/admin/sitios'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
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
        )
        .timeout(const Duration(seconds: 15));

    // ==========================================================
    // VALIDAR CREACIÓN DEL SITIO
    // ==========================================================

    if (responseSitio.statusCode != 201) {
      throw Exception(
        'Error al crear el sitio turístico: '
        '${responseSitio.statusCode} - ${responseSitio.body}',
      );
    }

    // ==========================================================
    // OBTENER SITIO CREADO
    // ==========================================================

    final dataSitio = jsonDecode(responseSitio.body);

    if (dataSitio is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta al crear el sitio no tiene '
        'el formato esperado.',
      );
    }

    final sitioCreado = dataSitio['sitio'];

    if (sitioCreado is! Map<String, dynamic>) {
      throw Exception('El servidor no devolvió el sitio creado.');
    }

    final sitioId = sitioCreado['_id']?.toString() ?? '';

    if (sitioId.isEmpty) {
      throw Exception('No se pudo obtener el ID del sitio creado.');
    }

    // ==========================================================
    // CREAR CUENTA DEL SITIO
    // ==========================================================

    final responseCuenta = await http
        .post(
          Uri.parse('$baseUrl/admin/authsitio/crear-cuenta-sitio'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'sitioId': sitioId,
            'nombre': nombreCuenta,
            'apellido': apellidoCuenta,
            'correo': correo,
            'password': password,
            'telefono': telefonoCuenta,
          }),
        )
        .timeout(const Duration(seconds: 15));

    // ==========================================================
    // VALIDAR RESPUESTA DE LA CUENTA
    // ==========================================================

    if (responseCuenta.statusCode != 201) {
      throw Exception(
        'El sitio turístico fue creado, pero no se pudo '
        'crear su cuenta.\n'
        'ID del sitio: $sitioId\n'
        'Error: ${responseCuenta.statusCode} - '
        '${responseCuenta.body}',
      );
    }

    // ==========================================================
    // OBTENER DATOS DE LA CUENTA
    // ==========================================================

    final dataCuenta = jsonDecode(responseCuenta.body);

    if (dataCuenta is! Map<String, dynamic>) {
      throw Exception(
        'El sitio fue creado, pero la respuesta de '
        'su cuenta no tiene el formato esperado.',
      );
    }

    // ==========================================================
    // RESULTADO
    // ==========================================================

    return {'sitio': sitioCreado, 'cuenta': dataCuenta['cuenta']};
  }

  // ============================================================
  // ACTUALIZAR SITIO TURÍSTICO
  // ============================================================

  static Future<void> actualizarSitio({
    required String baseUrl,
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

    final response = await http
        .put(
          Uri.parse('$baseUrl/admin/sitios/$id'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(datos),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Error al actualizar el sitio turístico: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }

  // ============================================================
  // ELIMINAR SITIO TURÍSTICO
  // ============================================================

  static Future<void> eliminarSitio(String baseUrl, String id) async {
    final response = await http
        .delete(
          Uri.parse('$baseUrl/admin/sitios/$id'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Error al eliminar el sitio turístico: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }
}
