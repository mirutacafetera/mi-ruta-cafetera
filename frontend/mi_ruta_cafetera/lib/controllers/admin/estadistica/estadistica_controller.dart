
import 'package:flutter/foundation.dart';

import '../../../models/admin/estadistica_model.dart';
import '../../../services/admin/estadistica/admin_estadisticas.dart';

class EstadisticaController extends ChangeNotifier {
  ResumenEstadisticasModel? estadisticas;

  bool cargando = false;
  String? error;

  static const int anioInicio = 2026;

  int anioSeleccionado = DateTime.now().year < anioInicio
      ? anioInicio
      : DateTime.now().year;

  List<int> get aniosDisponibles {
    final actual = DateTime.now().year;

    return List.generate(
      actual - anioInicio + 1,
      (indice) => anioInicio + indice,
    );
  }

  List<EstadisticaMensualModel> get estadisticasMensuales =>
      estadisticas?.mensuales ?? [];

  Future<void> cargarEstadisticas({int? anio}) async {
    if (anio != null) {
      anioSeleccionado = anio;
    }

    cargando = true;
    error = null;
    notifyListeners();

    try {
      estadisticas = await AdminEstadisticas.obtenerEstadisticas(
        anio: anioSeleccionado,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> seleccionarAnio(int anio) async {
    if (!aniosDisponibles.contains(anio)) return;
    if (anio == anioSeleccionado && estadisticas != null) return;

    await cargarEstadisticas(anio: anio);
  }

  Future<void> actualizarEstadisticas() async {
    await cargarEstadisticas();
  }
}
