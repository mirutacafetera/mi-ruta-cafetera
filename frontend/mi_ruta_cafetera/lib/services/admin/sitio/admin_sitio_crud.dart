import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AdminSitioCrud {
  // ============================================================
  // CREAR SITIO TURÍSTICO + CUENTA DEL SITIO
  // ============================================================

  static Future<Map<String, dynamic>> crearSitio({
    required String baseUrl,
    String? tokenAdmin,

    // ------------------------------------------------------------
    // DATOS DE LA CUENTA
    // ------------------------------------------------------------
    required String nombreCuenta,
    required String apellidoCuenta,
    required String correo,
    required String password,
    String telefonoCuenta = '',

    // ------------------------------------------------------------
    // DATOS DEL SITIO
    // ------------------------------------------------------------
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

    // ------------------------------------------------------------
    // INFORMACIÓN ADICIONAL
    // ------------------------------------------------------------
    String telefono = '',
    String correos = '',
    String sitioWeb = '',
    String imagen = '',
    List<String> imagenes = const [],
    String horario = '',
    double precioDesde = 0,
  }) async {
    // ============================================================
    // VALIDAR TOKEN
    // ============================================================

    final token = tokenAdmin?.trim() ?? '';

    if (token.isEmpty) {
      throw Exception(
        'No se encontró el token del administrador. '
        'Inicia sesión nuevamente.',
      );
    }

    // ============================================================
    // INFORMACIÓN INICIAL
    // ============================================================

    debugPrint('========================================');
    debugPrint('🚀 INICIANDO CREACIÓN DEL SITIO');
    debugPrint('========================================');
    debugPrint('🌐 BASE URL: $baseUrl');
    debugPrint('🏞️ SITIO: $nombre');
    debugPrint('📂 CATEGORÍA: $categoria');
    debugPrint('👤 CUENTA: $nombreCuenta $apellidoCuenta');
    debugPrint('📧 CORREO: $correo');
    debugPrint('========================================');

    // ============================================================
    // 1. CREAR SITIO TURÍSTICO
    // ============================================================

    final urlSitio = '$baseUrl/admin/sitios';

    debugPrint('📤 CREANDO SITIO TURÍSTICO');
    debugPrint('🌐 URL: $urlSitio');

    late http.Response responseSitio;

    try {
      responseSitio = await http
          .post(
            Uri.parse(urlSitio),
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
    } catch (e) {
      debugPrint('❌ ERROR DE CONEXIÓN AL CREAR SITIO');
      debugPrint('$e');

      throw Exception(
        'No se pudo conectar con el servidor para crear el sitio.',
      );
    }

    // ============================================================
    // RESPUESTA DEL SITIO
    // ============================================================

    debugPrint('========================================');
    debugPrint('📥 RESPUESTA CREAR SITIO');
    debugPrint('📊 STATUS: ${responseSitio.statusCode}');
    debugPrint('📄 BODY: ${responseSitio.body}');
    debugPrint('========================================');

    if (responseSitio.statusCode != 201) {
      throw Exception(
        'Error al crear el sitio turístico: '
        '${responseSitio.statusCode} - ${responseSitio.body}',
      );
    }

    // ============================================================
    // DECODIFICAR RESPUESTA
    // ============================================================

    late dynamic dataSitio;

    try {
      dataSitio = jsonDecode(responseSitio.body);
    } catch (e) {
      debugPrint('❌ ERROR DECODIFICANDO RESPUESTA DEL SITIO');
      debugPrint('$e');

      throw Exception(
        'El servidor devolvió una respuesta inválida '
        'al crear el sitio.',
      );
    }

    if (dataSitio is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta al crear el sitio no tiene '
        'el formato esperado.',
      );
    }

    // ============================================================
    // OBTENER SITIO CREADO
    // ============================================================

    final sitioCreado = dataSitio['sitio'];

    if (sitioCreado is! Map<String, dynamic>) {
      debugPrint('❌ NO SE ENCONTRÓ EL SITIO EN LA RESPUESTA');
      debugPrint('📄 RESPUESTA: $dataSitio');

      throw Exception(
        'El servidor no devolvió el sitio creado.',
      );
    }

    // ============================================================
    // OBTENER ID DEL SITIO
    // ============================================================

    final sitioId = sitioCreado['_id']?.toString() ?? '';

    debugPrint('========================================');
    debugPrint('✅ SITIO TURÍSTICO CREADO');
    debugPrint('🆔 ID DEL SITIO: $sitioId');
    debugPrint('========================================');

    if (sitioId.isEmpty) {
      throw Exception(
        'No se pudo obtener el ID del sitio creado.',
      );
    }

    // ============================================================
    // 2. CREAR CUENTA DEL SITIO
    // ============================================================

    final urlCuenta =
        '$baseUrl/admin/authsitio/crear-cuenta-sitio';

    debugPrint('========================================');
    debugPrint('📤 CREANDO CUENTA DEL SITIO');
    debugPrint('========================================');
    debugPrint('🌐 URL: $urlCuenta');
    debugPrint('🆔 sitioId: $sitioId');
    debugPrint('👤 nombre: $nombreCuenta');
    debugPrint('👤 apellido: $apellidoCuenta');
    debugPrint('📧 correo: $correo');
    debugPrint('📱 telefono: $telefonoCuenta');
    debugPrint('========================================');

    late http.Response responseCuenta;

    try {
      responseCuenta = await http
          .post(
            Uri.parse(urlCuenta),
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
    } catch (e) {
      debugPrint('========================================');
      debugPrint('❌ ERROR DE CONEXIÓN AL CREAR CUENTA');
      debugPrint('$e');
      debugPrint('========================================');

      throw Exception(
        'El sitio fue creado, pero no se pudo conectar '
        'con el servidor para crear su cuenta.',
      );
    }

    // ============================================================
    // RESPUESTA DE LA CUENTA
    // ============================================================

    debugPrint('========================================');
    debugPrint('📥 RESPUESTA CREAR CUENTA');
    debugPrint('========================================');
    debugPrint('📊 STATUS: ${responseCuenta.statusCode}');
    debugPrint('📄 BODY: ${responseCuenta.body}');
    debugPrint('========================================');

    // ============================================================
    // VALIDAR CREACIÓN DE CUENTA
    // ============================================================

    if (responseCuenta.statusCode != 201) {
      throw Exception(
        'El sitio turístico fue creado, pero no se pudo '
        'crear su cuenta.\n\n'
        'ID del sitio: $sitioId\n\n'
        'Error: ${responseCuenta.statusCode}\n'
        '${responseCuenta.body}',
      );
    }

    // ============================================================
    // DECODIFICAR RESPUESTA DE CUENTA
    // ============================================================

    late dynamic dataCuenta;

    try {
      dataCuenta = jsonDecode(responseCuenta.body);
    } catch (e) {
      debugPrint('❌ ERROR DECODIFICANDO RESPUESTA DE CUENTA');
      debugPrint('$e');

      throw Exception(
        'El sitio fue creado, pero la respuesta de su cuenta '
        'no tiene un formato válido.',
      );
    }

    if (dataCuenta is! Map<String, dynamic>) {
      throw Exception(
        'El sitio fue creado, pero la respuesta de su cuenta '
        'no tiene el formato esperado.',
      );
    }

    // ============================================================
    // CUENTA CREADA
    // ============================================================

    final cuentaCreada = dataCuenta['cuenta'];

    debugPrint('========================================');
    debugPrint('✅ CUENTA DEL SITIO CREADA');
    debugPrint('📄 CUENTA: $cuentaCreada');
    debugPrint('========================================');

    // ============================================================
    // PROCESO COMPLETADO
    // ============================================================

    debugPrint('========================================');
    debugPrint('🎉 SITIO Y CUENTA CREADOS CORRECTAMENTE');
    debugPrint('========================================');

    return {
      'sitio': sitioCreado,
      'cuenta': cuentaCreada,
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
    String imagen = '',
    List<String> imagenes = const [],
    String horario = '',
    double precioDesde = 0,
  }) async {
    // ============================================================
    // VALIDAR TOKEN
    // ============================================================

    final token = tokenAdmin?.trim() ?? '';

    if (token.isEmpty) {
      throw Exception(
        'No se encontró el token del administrador. '
        'Inicia sesión nuevamente.',
      );
    }

    // ============================================================
    // URL
    // ============================================================

    final url = '$baseUrl/admin/sitios/$id';

    debugPrint('========================================');
    debugPrint('✏️ ACTUALIZANDO SITIO');
    debugPrint('🌐 URL: $url');
    debugPrint('🆔 ID: $id');
    debugPrint('========================================');

    // ============================================================
    // PETICIÓN
    // ============================================================

    final response = await http
        .put(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'nombre': nombre,
            'descripcion': descripcion,
            'categoria': categoria,
            'direccion': direccion,
            'ciudad': ciudad,
            'departamento': departamento,
            'latitud': latitud,
            'longitud': longitud,
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

    // ============================================================
    // RESPUESTA
    // ============================================================

    debugPrint('========================================');
    debugPrint('📥 RESPUESTA ACTUALIZAR SITIO');
    debugPrint('📊 STATUS: ${response.statusCode}');
    debugPrint('📄 BODY: ${response.body}');
    debugPrint('========================================');

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Error al actualizar el sitio: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }

  // ============================================================
  // ELIMINAR SITIO TURÍSTICO
  // ============================================================

  static Future<void> eliminarSitio(
    String baseUrl,
    String id, {
    String? tokenAdmin,
  }) async {
    // ============================================================
    // VALIDAR TOKEN
    // ============================================================

    final token = tokenAdmin?.trim() ?? '';

    if (token.isEmpty) {
      throw Exception(
        'No se encontró el token del administrador. '
        'Inicia sesión nuevamente.',
      );
    }

    // ============================================================
    // URL
    // ============================================================

    final url = '$baseUrl/admin/sitios/$id';

    debugPrint('========================================');
    debugPrint('🗑️ ELIMINANDO SITIO');
    debugPrint('🌐 URL: $url');
    debugPrint('🆔 ID: $id');
    debugPrint('========================================');

    // ============================================================
    // PETICIÓN
    // ============================================================

    final response = await http
        .delete(
          Uri.parse(url),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    // ============================================================
    // RESPUESTA
    // ============================================================

    debugPrint('========================================');
    debugPrint('📥 RESPUESTA ELIMINAR SITIO');
    debugPrint('📊 STATUS: ${response.statusCode}');
    debugPrint('📄 BODY: ${response.body}');
    debugPrint('========================================');

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Error al eliminar el sitio: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }
}