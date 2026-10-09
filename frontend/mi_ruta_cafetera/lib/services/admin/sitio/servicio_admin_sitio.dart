import 'dart:typed_data';

import '../admin_servicio_autenticacion.dart';
import 'admin_sitio_consultas.dart';
import 'admin_sitio_crud.dart';

import '../../../config/api_config.dart';

class ServicioAdminSitio {
  static String get baseUrl {
    return ApiConfig.baseUrl;
  }

  // ============================================================
  // CONSULTAS
  // ============================================================

  static Future<List<dynamic>> obtenerSitios() {
    return AdminSitioConsultas.obtenerSitios(baseUrl);
  }

  static Future<List<dynamic>> obtenerCategorias() {
    return AdminSitioConsultas.obtenerCategorias(baseUrl);
  }

  static Future<Map<String, dynamic>> obtenerSitio(
    String id,
  ) {
    return AdminSitioConsultas.obtenerSitio(
      baseUrl,
      id,
    );
  }

  // ============================================================
  // CREAR SITIO TURÍSTICO
  // ============================================================

  static Future<Map<String, dynamic>> crearSitio({
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
  }) {
    return AdminSitioCrud.crearSitio(
      // Configuración
      baseUrl: baseUrl,
      tokenAdmin:
          AdminServicioAutenticacion.tokenAdmin,

      // --------------------------------------------------------
      // CUENTA
      // --------------------------------------------------------

      nombreCuenta: nombreCuenta,
      apellidoCuenta: apellidoCuenta,
      correo: correo,
      password: password,
      telefonoCuenta: telefonoCuenta,

      // --------------------------------------------------------
      // SITIO
      // --------------------------------------------------------

      nombre: nombre,
      descripcion: descripcion,
      categoria: categoria,
      direccion: direccion,
      ciudad: ciudad,
      departamento: departamento,
      latitud: latitud,
      longitud: longitud,
      etiquetas: etiquetas,
      activo: activo,
      telefono: telefono,
      correos: correos,
      sitioWeb: sitioWeb,

      // --------------------------------------------------------
      // IMAGEN PRINCIPAL
      // --------------------------------------------------------

      imagenBytes: imagenBytes,
      nombreImagen: nombreImagen,

      // --------------------------------------------------------
      // INFORMACIÓN TURÍSTICA
      // --------------------------------------------------------

      horario: horario,
      precioDesde: precioDesde,
    );
  }

  // ============================================================
  // ACTUALIZAR SITIO TURÍSTICO
  // ============================================================

  static Future<void> actualizarSitio({
    required String id,

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

    Uint8List? imagenBytes,
    String nombreImagen = 'imagen.jpg',

    // ----------------------------------------------------------
    // INFORMACIÓN TURÍSTICA
    // ----------------------------------------------------------

    String horario = '',
    double precioDesde = 0,
  }) {
    return AdminSitioCrud.actualizarSitio(
      // Configuración
      baseUrl: baseUrl,
      tokenAdmin:
          AdminServicioAutenticacion.tokenAdmin,

      id: id,

      // --------------------------------------------------------
      // SITIO
      // --------------------------------------------------------

      nombre: nombre,
      descripcion: descripcion,
      categoria: categoria,
      direccion: direccion,
      ciudad: ciudad,
      departamento: departamento,
      latitud: latitud,
      longitud: longitud,
      etiquetas: etiquetas,
      activo: activo,
      telefono: telefono,
      correos: correos,
      sitioWeb: sitioWeb,

      // --------------------------------------------------------
      // IMAGEN PRINCIPAL
      // --------------------------------------------------------

      imagenBytes: imagenBytes,
      nombreImagen: nombreImagen,

      // --------------------------------------------------------
      // INFORMACIÓN TURÍSTICA
      // --------------------------------------------------------

      horario: horario,
      precioDesde: precioDesde,
    );
  }

  // ============================================================
  // ELIMINAR SITIO TURÍSTICO
  // ============================================================

  static Future<void> eliminarSitio(
    String id,
  ) {
    return AdminSitioCrud.eliminarSitio(
      baseUrl: baseUrl,
      id: id,
      tokenAdmin:
          AdminServicioAutenticacion.tokenAdmin,
    );
  }
}