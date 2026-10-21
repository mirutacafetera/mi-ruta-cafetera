
import 'package:flutter/material.dart';

import '../../../models/admin/reporte_admin.dart';
import '../../../services/admin/reporte/admin_reporte.dart';

class ReporteController extends ChangeNotifier {
  List<ReporteAdmin> reportes = [];

  bool cargando = false;
  bool guardando = false;

  String busqueda = '';
  String estadoSeleccionado = 'todos';
  String? error;

  List<ReporteAdmin> get reportesFiltrados {
    final texto = busqueda.toLowerCase().trim();

    return reportes.where((reporte) {
      final coincideBusqueda =
          reporte.asunto.toLowerCase().contains(texto) ||
          reporte.mensaje.toLowerCase().contains(texto) ||
          reporte.nombreCompleto.toLowerCase().contains(texto) ||
          reporte.correoUsuario.toLowerCase().contains(texto);

      final coincideEstado = estadoSeleccionado == 'todos' ||
          reporte.estado == estadoSeleccionado;

      return coincideBusqueda && coincideEstado;
    }).toList();
  }

  int contarPorEstado(String estado) {
    return reportes.where((reporte) => reporte.estado == estado).length;
  }

  void cambiarBusqueda(String valor) {
    busqueda = valor;
    notifyListeners();
  }

  void cambiarEstadoFiltro(String estado) {
    estadoSeleccionado = estado;
    notifyListeners();
  }

  Future<void> cargarReportes() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      reportes = await AdminReporteService.obtenerReportes();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<bool> responderReporte({
    required String id,
    required String estado,
    required String respuestaAdmin,
  }) async {
    guardando = true;
    error = null;
    notifyListeners();

    try {
      final actualizado = await AdminReporteService.responderReporte(
        id: id,
        estado: estado,
        respuestaAdmin: respuestaAdmin,
      );

      final indice = reportes.indexWhere(
        (reporte) => reporte.id == id,
      );

      if (indice != -1) {
        final anterior = reportes[indice];

        reportes[indice] = ReporteAdmin(
          id: actualizado.id,
          asunto: actualizado.asunto,
          mensaje: actualizado.mensaje,
          estado: actualizado.estado,
          respuestaAdmin: actualizado.respuestaAdmin,
          usuarioId: actualizado.usuarioId ?? anterior.usuarioId,
          nombreUsuario: actualizado.nombreUsuario.isNotEmpty
              ? actualizado.nombreUsuario
              : anterior.nombreUsuario,
          apellidoUsuario: actualizado.apellidoUsuario.isNotEmpty
              ? actualizado.apellidoUsuario
              : anterior.apellidoUsuario,
          correoUsuario: actualizado.correoUsuario.isNotEmpty
              ? actualizado.correoUsuario
              : anterior.correoUsuario,
          createdAt: actualizado.createdAt ?? anterior.createdAt,
          updatedAt: actualizado.updatedAt ?? anterior.updatedAt,
        );
      }

      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }
}
