
import 'package:flutter/material.dart';

import '../../../models/categoria_model.dart';
import '../../../models/admin/sitio_admin_model.dart';
import '../../../services/admin/categoria/admin_categoria.dart';
import '../../../services/admin/sitio/servicio_admin_sitio.dart';

class CategoriaController extends ChangeNotifier {
  List<CategoriaModel> categorias = [];
  List<SitioAdminModel> sitios = [];

  bool cargando = false;
  bool guardando = false;

  String busqueda = '';
  String? error;

  // ============================================================
  // CATEGORÍAS FILTRADAS
  // ============================================================

  List<CategoriaModel> get categoriasFiltradas {
    final texto = busqueda.trim().toLowerCase();

    if (texto.isEmpty) {
      return categorias;
    }

    return categorias.where((categoria) {
      return categoria.nombre.toLowerCase().contains(texto) ||
          categoria.descripcion.toLowerCase().contains(texto);
    }).toList();
  }

  // ============================================================
  // CONTAR SITIOS POR CATEGORÍA
  // ============================================================

  int contarSitios(CategoriaModel categoria) {
    return sitios
        .where((sitio) => sitio.categoria?.id == categoria.id)
        .length;
  }

  // ============================================================
  // CARGAR CATEGORÍAS Y SITIOS
  // ============================================================

  Future<void> cargarDatos() async {
    if (cargando) return;

    cargando = true;
    error = null;
    notifyListeners();

    try {
      final resultados = await Future.wait([
        AdminCategoria.obtenerCategorias(),
        ServicioAdminSitio.obtenerSitios(),
      ]);

      categorias = List<CategoriaModel>.from(resultados[0]);
      sitios = List<SitioAdminModel>.from(resultados[1]);
    } catch (e) {
      error = 'Error al cargar categorías: $e';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  // ============================================================
  // BUSCAR CATEGORÍAS
  // ============================================================

  void buscar(String texto) {
    busqueda = texto;
    notifyListeners();
  }

  // ============================================================
  // CREAR O ACTUALIZAR CATEGORÍA
  // ============================================================

  Future<void> guardarCategoria({
    String? id,
    required String nombre,
    required String descripcion,
    required String icono,
    bool estado = true,
  }) async {
    if (guardando) return;

    guardando = true;
    error = null;
    notifyListeners();

    try {
      final nombreLimpio = nombre.trim();
      final descripcionLimpia = descripcion.trim();
      final iconoLimpio =
          icono.trim().isEmpty ? 'location_on' : icono.trim();

      if (id == null) {
        await AdminCategoria.crearCategoria(
          nombre: nombreLimpio,
          descripcion: descripcionLimpia,
          icono: iconoLimpio,
        );
      } else {
        await AdminCategoria.actualizarCategoria(
          id: id,
          nombre: nombreLimpio,
          descripcion: descripcionLimpia,
          icono: iconoLimpio,
          estado: estado,
        );
      }

      await cargarDatos();
    } catch (e) {
      error = 'No se pudo guardar la categoría: $e';
      rethrow;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  // ============================================================
  // ELIMINAR CATEGORÍA DEFINITIVAMENTE
  // ============================================================

  Future<void> eliminarCategoria(String id) async {
    if (guardando) return;

    guardando = true;
    error = null;
    notifyListeners();

    try {
      await AdminCategoria.eliminarCategoria(id);

      // Actualizar la lista después de eliminar.
      await cargarDatos();
    } catch (e) {
      error = 'No se pudo eliminar la categoría: $e';
      rethrow;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }
}
