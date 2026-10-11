import 'package:flutter/foundation.dart';

import '../../../models/admin/sitio_admin_model.dart';
import '../../../services/admin/sitio/servicio_admin_sitio.dart';

class ListaSitios extends ChangeNotifier {
  List<SitioAdminModel> sitios = [];
  List<Map<String, dynamic>> categorias = [];

  bool cargando = true;
  String busqueda = '';

  Future<void> cargarDatos() async {
    cargando = true;
    notifyListeners();

    try {
      final datosSitios = await ServicioAdminSitio.obtenerSitios();

      final datosCategorias =
          await ServicioAdminSitio.obtenerCategorias();

      sitios = datosSitios;

      categorias = datosCategorias
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

  List<SitioAdminModel> get sitiosFiltrados {
    final texto = busqueda.trim().toLowerCase();

    if (texto.isEmpty) {
      return sitios;
    }

    return sitios.where((sitio) {
      final nombre = sitio.nombre.toLowerCase();
      final ciudad = sitio.ciudad.toLowerCase();
      final direccion = sitio.direccion.toLowerCase();
      final categoria = obtenerCategoria(sitio).toLowerCase();

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

  String? obtenerId(SitioAdminModel sitio) {
    return sitio.id.isEmpty ? null : sitio.id;
  }

  String obtenerCategoria(SitioAdminModel sitio) {
    if (sitio.categoria == null) {
      return 'Sin categoría';
    }

    if (sitio.categoria!.nombre.isNotEmpty) {
      return sitio.categoria!.nombre;
    }

    final categoriaId = sitio.categoria!.id;

    final encontrada = categorias.where((item) {
      final id = item['_id'] ?? item['id'];

      if (id is Map) {
        return id[r'$oid']?.toString() == categoriaId;
      }

      return id?.toString() == categoriaId;
    });

    if (encontrada.isNotEmpty) {
      return '${encontrada.first['nombre'] ?? 'Sin categoría'}';
    }

    return 'Sin categoría';
  }

  bool estaActivo(SitioAdminModel sitio) {
    return sitio.activo;
  }

  String? obtenerImagen(SitioAdminModel sitio) {
    if (sitio.imagen.trim().isNotEmpty) {
      return sitio.imagen;
    }

    if (sitio.imagenes.isNotEmpty &&
        sitio.imagenes.first.trim().isNotEmpty) {
      return sitio.imagenes.first;
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