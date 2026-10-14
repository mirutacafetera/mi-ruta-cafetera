import 'package:flutter/material.dart';

import '../../../models/admin/reserva_admin_model.dart';
import '../../../services/admin/reserva/reserva_admin.dart';
import '../../../services/admin/admin_servicio_autenticacion.dart';

class ReservaAdminController extends ChangeNotifier {
  List<ReservaAdminModel> reservas = [];

  bool cargando = false;
  bool guardando = false;
  String? error;

  String get token => (AdminServicioAutenticacion.tokenAdmin ?? '').trim();

  Future<void> cargarReservas() async {
    if (token.isEmpty) {
      error = 'No hay una sesión administrativa activa.';
      notifyListeners();
      return;
    }

    cargando = true;
    error = null;
    notifyListeners();

    try {
      reservas = await ReservaAdminService.obtenerReservas(
        token: token,
      );
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarEstado({
    required String id,
    required String estado,
  }) async {
    if (token.isEmpty) {
      error = 'No hay una sesión administrativa activa.';
      notifyListeners();
      return false;
    }

    guardando = true;
    error = null;
    notifyListeners();

    try {
      final reservaActualizada =
          await ReservaAdminService.actualizarEstado(
        token: token,
        id: id,
        estado: estado,
      );

      final indice = reservas.indexWhere(
        (reserva) => reserva.id == id,
      );

      if (indice != -1) {
        reservas[indice] = reservaActualizada;
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

  void limpiarError() {
    error = null;
    notifyListeners();
  }
}