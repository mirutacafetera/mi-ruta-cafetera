import 'package:flutter/material.dart';

import '../../../models/categoria_model.dart';
import '../../../models/admin/sitio_admin_model.dart';
import '../../../services/admin/sitio/servicio_admin_sitio.dart';

class SitiosCategoriaController extends ChangeNotifier {
  SitiosCategoriaController({
    required this.categoria,
  });

  final CategoriaModel categoria;

  List<SitioAdminModel> sitios = [];

  bool cargando = false;
  String busqueda = '';
  String? error;

  List<SitioAdminModel> get sitiosFiltrados {
    final texto = busqueda.trim().toLowerCase();

    return sitios.where((sitio) {
      if (sitio.categoria?.id != categoria.id) {
        return false;
      }

      if (texto.isEmpty) {
        return true;
      }

      return sitio.nombre.toLowerCase().contains(texto) ||
          sitio.ciudad.toLowerCase().contains(texto);
    }).toList();
  }

  int get totalSitios {
    return sitios
        .where((sitio) => sitio.categoria?.id == categoria.id)
        .length;
  }

  Future<void> cargarSitios() async {
    if (cargando) return;

    cargando = true;
    error = null;
    notifyListeners();

    try {
      final resultado = await ServicioAdminSitio.obtenerSitios();

      sitios = List<SitioAdminModel>.from(resultado);
    } catch (e) {
      error = 'No fue posible cargar los sitios: $e';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  void buscar(String texto) {
    busqueda = texto;
    notifyListeners();
  }


}
