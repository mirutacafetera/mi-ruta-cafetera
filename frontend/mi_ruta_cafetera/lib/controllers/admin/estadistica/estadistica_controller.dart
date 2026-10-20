
import 'package:flutter/foundation.dart';

import '../../../models/admin/estadistica_model.dart';
import '../../../services/admin/estadistica/admin_estadisticas.dart';

class EstadisticaController extends ChangeNotifier {
  ResumenEstadisticasModel? estadisticas;

  bool cargando = false;
  String? error;

  Future<void> cargarEstadisticas() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      estadisticas = await AdminEstadisticas.obtenerEstadisticas();
    } catch (e) {
      error = e.toString();
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> actualizarEstadisticas() async {
    await cargarEstadisticas();
  }
}
