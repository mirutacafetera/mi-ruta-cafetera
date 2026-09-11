import 'package:flutter/foundation.dart';

import 'admin_sitio_consultas.dart';
import 'admin_sitio_crud.dart';

class AdminSitioService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    return 'http://10.0.2.2:3000/api';
  }

  // =========================
  // CONSULTAS
  // =========================

  static Future<List<dynamic>> obtenerSitios() {
    return AdminSitioConsultas.obtenerSitios(baseUrl);
  }

  static Future<List<dynamic>> obtenerCategorias() {
    return AdminSitioConsultas.obtenerCategorias(baseUrl);
  }

  static Future<Map<String, dynamic>> obtenerSitio(String id) {
    return AdminSitioConsultas.obtenerSitio(
      baseUrl,
      id,
    );
  }

  // =========================
  // CRUD
  // =========================

  static Future<Map<String, dynamic>> crearSitio({
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
  }) {
    return AdminSitioCrud.crearSitio(
      baseUrl: baseUrl,
      nombreCuenta: nombreCuenta,
      apellidoCuenta: apellidoCuenta,
      correo: correo,
      password: password,
      telefonoCuenta: telefonoCuenta,
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
      imagen: imagen,
      imagenes: imagenes,
      horario: horario,
      precioDesde: precioDesde,
    );
  }

  static Future<void> actualizarSitio({
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
  }) {
    return AdminSitioCrud.actualizarSitio(
      baseUrl: baseUrl,
      id: id,
      correo: correo,
      password: password,
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
      imagen: imagen,
      imagenes: imagenes,
      horario: horario,
      precioDesde: precioDesde,
    );
  }

  static Future<void> eliminarSitio(String id) {
    return AdminSitioCrud.eliminarSitio(
      baseUrl,
      id,
    );
  }
}