import 'package:flutter/foundation.dart';

import '../../../models/admin/historial_revision_ia_model.dart';
import '../../../services/admin/chatbot/admin_historial_revision_ia_service.dart';

class AdminHistorialRevisionIAController extends ChangeNotifier {
  List<HistorialRevisionIAModel> historial = [];

  bool cargando = false;
  String? error;

  String tipoSolicitud = 'contenido';
  String? decision;

  int pagina = 1;
  int limite = 20;
  int total = 0;
  int totalPaginas = 0;

  bool _disposed = false;

  bool get tieneHistorial => historial.isNotEmpty;

  bool get puedeIrPaginaAnterior => pagina > 1;

  bool get puedeIrPaginaSiguiente => pagina < totalPaginas;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notificar() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> cargarHistorial() async {
    if (cargando) return;

    cargando = true;
    error = null;
    _notificar();

    try {
      final respuesta =
          await AdminHistorialRevisionIAService.obtenerHistorial(
        tipoSolicitud: tipoSolicitud,
        pagina: pagina,
        limite: limite,
        decision: decision,
      );

      historial = respuesta['historial']
          as List<HistorialRevisionIAModel>;

      final paginacion =
          respuesta['paginacion'] as Map<String, dynamic>;

      total = _convertirEntero(paginacion['total']);
      totalPaginas = _convertirEntero(
        paginacion['totalPaginas'],
      );

      pagina = _convertirEntero(
        paginacion['pagina'],
        valorPredeterminado: pagina,
      );
      limite = _convertirEntero(
        paginacion['limite'],
        valorPredeterminado: limite,
      );
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      historial = [];
      total = 0;
      totalPaginas = 0;
    } finally {
      cargando = false;
      _notificar();
    }
  }

  Future<void> cambiarTipoSolicitud(String nuevoTipo) async {
    if (tipoSolicitud == nuevoTipo) return;

    tipoSolicitud = nuevoTipo;
    pagina = 1;

    await cargarHistorial();
  }

  Future<void> cambiarDecision(String? nuevaDecision) async {
    if (decision == nuevaDecision) return;

    decision = nuevaDecision;
    pagina = 1;

    await cargarHistorial();
  }

  Future<void> irPaginaAnterior() async {
    if (!puedeIrPaginaAnterior || cargando) return;

    pagina--;
    await cargarHistorial();
  }

  Future<void> irPaginaSiguiente() async {
    if (!puedeIrPaginaSiguiente || cargando) return;

    pagina++;
    await cargarHistorial();
  }

  Future<void> cambiarLimite(int nuevoLimite) async {
    if (nuevoLimite < 1 || limite == nuevoLimite) return;

    limite = nuevoLimite;
    pagina = 1;

    await cargarHistorial();
  }

  Future<void> recargar() async {
    await cargarHistorial();
  }

  int _convertirEntero(
    dynamic valor, {
    int valorPredeterminado = 0,
  }) {
    if (valor is int) return valor;
    return int.tryParse(valor?.toString() ?? '') ??
        valorPredeterminado;
  }
}