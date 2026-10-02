import 'package:flutter/foundation.dart';

import '../../../services/admin/sitio/servicio_admin_sitio.dart';

class ListaSitios extends ChangeNotifier {
  List<Map<String, dynamic>> sitios = [];
  List<Map<String, dynamic>> categorias = [];

  bool cargando = true;
  String busqueda = '';

  Future<void> cargarDatos() async {
    cargando = true;
    notifyListeners();

    try {
      final datosSitios =
          await ServicioAdminSitio.obtenerSitios();

      final datosCategorias =
          await ServicioAdminSitio.obtenerCategorias();

      sitios = datosSitios
          .whereType<Map>()
          .map(
            (e) => Map<String, dynamic>.from(e),
          )
          .toList();

      categorias = datosCategorias
          .whereType<Map>()
          .map(
            (e) => Map<String, dynamic>.from(e),
          )
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
          '${sitio['nombre'] ?? ''}'.toLowerCase();

      final ciudad =
          '${sitio['ciudad'] ?? ''}'.toLowerCase();

      final direccion =
          '${sitio['direccion'] ?? ''}'.toLowerCase();

      final categoria =
          obtenerCategoria(sitio).toLowerCase();

      return nombre.contains(texto) ||
          ciudad.contains(texto) ||
          direccion.contains(texto) ||
          categoria.contains(texto);
    }).toList();
  }

  Future<void> eliminarSitio(String id) async {
    await ServicioAdminSitio.eliminarSitio(id);
    await cargarDatos();
  }

  String? obtenerId(Map<String, dynamic> sitio) {
    final id = sitio['_id'] ?? sitio['id'];

    if (id == null) {
      return null;
    }

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
      final encontrada = categorias.where(
        (item) => item['_id']?.toString() == categoria,
      );

      return encontrada.isNotEmpty
          ? '${encontrada.first['nombre'] ?? 'Sin categoría'}'
          : categoria;
    }

    if (categoria is Map) {
      return '${categoria['nombre'] ?? categoria['name'] ?? 'Sin categoría'}';
    }

    return categoria.toString();
  }

  bool estaActivo(Map<String, dynamic> sitio) {
    final activo = sitio['activo'];

    if (activo is bool) {
      return activo;
    }

    final texto = activo?.toString().toLowerCase().trim();

    return texto != 'false' &&
        texto != 'inactivo' &&
        texto != 'inactiva';
  }

  String? obtenerImagen(Map<String, dynamic> sitio) {
    final imagen = sitio['imagen'];

    if (imagen != null &&
        imagen.toString().trim().isNotEmpty) {
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