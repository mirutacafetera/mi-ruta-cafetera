import 'package:flutter/material.dart';

import '../../../models/admin/reporte_sitio_admin.dart';
import '../../../services/admin/reporte/admin_reportes_sitios_service.dart';

class ReportesSitiosController extends ChangeNotifier {
  List<ReporteSitioAdmin> reportes = [];

  bool cargando = false;
  bool guardando = false;
  String busqueda = '';
  String estadoSeleccionado = 'todos';
  String tipoSeleccionado = 'todos';
  String? error;

  List<ReporteSitioAdmin> get reportesFiltrados {
    final texto = busqueda.toLowerCase().trim();

    return reportes.where((reporte) {
      final coincideTexto =
          reporte.asunto.toLowerCase().contains(texto) ||
          reporte.mensaje.toLowerCase().contains(texto) ||
          reporte.nombreSitio.toLowerCase().contains(texto);

      final coincideEstado =
          estadoSeleccionado == 'todos' || reporte.estado == estadoSeleccionado;

      final coincideTipo =
          tipoSeleccionado == 'todos' ||
          reporte.tipoReporte == tipoSeleccionado;

      return coincideTexto && coincideEstado && coincideTipo;
    }).toList();
  }

  int contarEstado(String estado) =>
      reportes.where((r) => r.estado == estado).length;

  void cambiarBusqueda(String valor) {
    busqueda = valor;
    notifyListeners();
  }

  void cambiarEstado(String valor) {
    estadoSeleccionado = valor;
    notifyListeners();
  }

  void cambiarTipo(String valor) {
    tipoSeleccionado = valor;
    notifyListeners();
  }

  Future<void> cargarReportes() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      reportes = await AdminReportesSitiosService.obtenerReportes();
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
      await AdminReportesSitiosService.responderReporte(
        id: id,
        estado: estado,
        respuestaAdmin: respuestaAdmin,
      );

      // Recargamos para mantener el listado sincronizado con el servidor.
      reportes = await AdminReportesSitiosService.obtenerReportes();
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
