import 'package:flutter/foundation.dart';

import '../../../models/admin/cuenta_admin.dart';
import '../../../services/admin/cuenta/admin_cuenta.dart';

class CuentaAdminController extends ChangeNotifier {
  CuentaAdmin? _cuenta;
  bool _cargando = false;
  bool _guardando = false;
  String? _error;

  CuentaAdmin? get cuenta => _cuenta;
  bool get cargando => _cargando;
  bool get guardando => _guardando;
  String? get error => _error;

  Future<void> cargarCuenta(String idAdministrador) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _cuenta = await AdminServicioCuenta.obtenerCuenta(
        idAdministrador,
      );
    } catch (e) {
      _error = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarCuenta({
    required String idAdministrador,
    required String nombre,
    required String apellido,
    required String telefono,
  }) async {
    _guardando = true;
    _error = null;
    notifyListeners();

    try {
      _cuenta = await AdminServicioCuenta.actualizarCuenta(
        idAdministrador: idAdministrador,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
      );

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void limpiarCuenta() {
    _cuenta = null;
    _error = null;
    _cargando = false;
    _guardando = false;
    notifyListeners();
  }
}