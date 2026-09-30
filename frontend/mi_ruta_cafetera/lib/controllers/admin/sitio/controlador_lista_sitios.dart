import 'package:flutter/foundation.dart';

import '../../../services/admin/sitio/admin_sitio_service.dart';

class ControladorListaSitios extends ChangeNotifier {
  List<Map<String, dynamic>> sitios = [];
  List<Map<String, dynamic>> categorias = [];

  bool cargando = true;
  String busqueda = '';

  Future<void> cargarDatos() async {
    cargando = true;
    notifyListeners();

    try {
      final respuestaSitios = await AdminSitioService.obtenerSitios();
      final respuestaCategorias =
          await AdminSitioService.obtenerCategorias();

      sitios = respuestaSitios
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      categorias = respuestaCategorias
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  void buscar(String texto) {
    busqueda = texto;
    notifyListeners();
  }

  void limpiarBusqueda() {
    busqueda = '';
    notifyListeners();
  }

  List<Map<String, dynamic>> get sitiosFiltrados {
    final texto = busqueda.trim().toLowerCase();

    if (texto.isEmpty) {
      return sitios;
    }

    return sitios.where((sitio) {
      final nombre =
          (sitio['nombre'] ?? '').toString().toLowerCase();

      final ciudad =
          (sitio['ciudad'] ?? '').toString().toLowerCase();

      final direccion =
          (sitio['direccion'] ?? '').toString().toLowerCase();

      final categoria = obtenerCategoria(sitio).toLowerCase();

      return nombre.contains(texto) ||
          ciudad.contains(texto) ||
          direccion.contains(texto) ||
          categoria.contains(texto);
    }).toList();
  }

  Future<void> eliminarSitio(String id) async {
    await AdminSitioService.eliminarSitio(id);
    await cargarDatos();
  }

  String? obtenerId(Map<String, dynamic> sitio) {
    final id = sitio['_id'] ?? sitio['id'];

    if (id == null) return null;

    if (id is Map) {
      return id[r'$oid']?.toString();
    }

    return id.toString();
  }

  String obtenerCategoria(Map<String, dynamic> sitio) {
    final categoria = sitio['categoria'];

    if (categoria == null) {
      return 'Sin categoría';
    }

    if (categoria is String) {
      final encontrada = categorias.cast<Map<String, dynamic>?>().firstWhere(
        (item) => item?['_id']?.toString() == categoria,
        orElse: () => null,
      );

      if (encontrada != null) {
        return (encontrada['nombre'] ?? 'Sin categoría').toString();
      }

      return categoria;
    }

    if (categoria is Map) {
      return (
        categoria['nombre'] ??
        categoria['name'] ??
        'Sin categoría'
      ).toString();
    }

    return categoria.toString();
  }

  bool estaActivo(Map<String, dynamic> sitio) {
    final activo = sitio['activo'];

    if (activo is bool) {
      return activo;
    }

    if (activo != null) {
      final texto = activo.toString().toLowerCase().trim();

      if (texto == 'true' || texto == 'activo' || texto == 'activa') {
        return true;
      }

      if (texto == 'false' ||
          texto == 'inactivo' ||
          texto == 'inactiva') {
        return false;
      }
    }

    return true;
  }

  String? obtenerImagen(Map<String, dynamic> sitio) {
    final imagen = sitio['imagen'];

    if (imagen != null && imagen.toString().trim().isNotEmpty) {
      return imagen.toString();
    }

    final imagenes = sitio['imagenes'];

    if (imagenes is List && imagenes.isNotEmpty) {
      final primera = imagenes.first;

      if (primera != null &&
          primera.toString().trim().isNotEmpty) {
        return primera.toString();
      }
    }

    return null;
  }

  @override
  void dispose() {
    sitios.clear();
    categorias.clear();
    super.dispose();
  }
}