import 'package:flutter/material.dart';
import '../../../models/admin/resena_admin.dart';
import '../../../services/admin/resena/resena_admin.dart';

class ResenaAdminController extends ChangeNotifier {
  List<ResenaAdmin> resenas = [];
  bool cargando = false;
  String? error;
  String busqueda = '';
  String filtroEstado = 'Todas';

  List<ResenaAdmin> get resenasFiltradas {
    return resenas.where((resena) {
      final texto = '${resena.usuario} ${resena.sitio} ${resena.comentario}'.toLowerCase();
      final coincideBusqueda = texto.contains(busqueda.toLowerCase());
      final coincideEstado = filtroEstado == 'Todas' ||
          (filtroEstado == 'Activas' && resena.activo) ||
          (filtroEstado == 'Inactivas' && !resena.activo);

      return coincideBusqueda && coincideEstado;
    }).toList();
  }

  int get totalResenas => resenas.length;
  int get resenasActivas => resenas.where((r) => r.activo).length;
  int get resenasInactivas => resenas.where((r) => !r.activo).length;

  void cambiarBusqueda(String valor) {
    busqueda = valor;
    notifyListeners();
  }

  void cambiarFiltro(String valor) {
    filtroEstado = valor;
    notifyListeners();
  }

  Future<void> cargarResenas() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      resenas = await ResenaAdminService.obtenerResenas();
    } catch (e) {
      error = 'No se pudieron cargar las reseñas';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<bool> cambiarEstado(ResenaAdmin resena) async {
    try {
      final actualizado = await ResenaAdminService.cambiarEstado(
        resena.id,
        !resena.activo,
      );

      if (actualizado) await cargarResenas();
      return actualizado;
    } catch (e) {
      error = 'No se pudo cambiar el estado de la reseña';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarResena(String id) async {
    try {
      final eliminada = await ResenaAdminService.eliminarResena(id);

      if (eliminada) await cargarResenas();
      return eliminada;
    } catch (e) {
      error = 'No se pudo eliminar la reseña';
      notifyListeners();
      return false;
    }
  }
}