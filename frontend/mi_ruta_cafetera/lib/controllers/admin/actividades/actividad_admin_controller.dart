
import 'package:flutter/material.dart';

import '../../../models/admin/admin_actividad_model.dart';
import '../../../services/admin/actividades/actividad_admin.dart';

class ActividadAdminController extends ChangeNotifier {
  List<ActividadAdminModel> actividades = [];

  bool cargando = false;
  bool procesando = false;
  String? error;
  String busqueda = '';

  List<ActividadAdminModel> get actividadesFiltradas {
    final texto = busqueda.trim().toLowerCase();

    if (texto.isEmpty) return actividades;

    return actividades.where((actividad) {
      return actividad.nombre.toLowerCase().contains(texto) ||
          actividad.nombreSitio.toLowerCase().contains(texto) ||
          actividad.ciudad.toLowerCase().contains(texto);
    }).toList();
  }

  int get totalPendientes => actividades
      .where((a) => a.estadoPublicacion == 'pendiente_revision')
      .length;

  int get totalAprobadas => actividades
      .where((a) => a.estadoPublicacion == 'aprobado')
      .length;

  int get totalRechazadas => actividades
      .where((a) => a.estadoPublicacion == 'rechazado')
      .length;

  Future<void> cargarActividades() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      actividades = await ActividadAdmin.obtenerActividadesPendientes();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  void buscar(String valor) {
    busqueda = valor;
    notifyListeners();
  }

  Future<String?> aprobarActividad(String id) async {
    if (procesando) {
      return 'Ya hay una operación en curso.';
    }

    procesando = true;
    notifyListeners();

    try {
      final mensaje = await ActividadAdmin.aprobarActividad(id);

      await cargarActividades();

      if (error != null) {
        return 'La actividad fue aprobada, pero no se pudo actualizar la lista: $error';
      }

      return mensaje;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      procesando = false;
      notifyListeners();
    }
  }

  Future<String?> rechazarActividad(
    String id,
    String motivo,
  ) async {
    if (procesando) {
      return 'Ya hay una operación en curso.';
    }

    if (motivo.trim().length < 3) {
      return 'El motivo debe tener al menos 3 caracteres.';
    }

    procesando = true;
    notifyListeners();

    try {
      final mensaje = await ActividadAdmin.rechazarActividad(
        id,
        motivo.trim(),
      );

      await cargarActividades();

      if (error != null) {
        return 'La actividad fue rechazada, pero no se pudo actualizar la lista: $error';
      }

      return mensaje;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      procesando = false;
      notifyListeners();
    }
  }
}
