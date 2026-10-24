import 'package:flutter/foundation.dart';

import '../../../models/admin/cuenta_admin.dart';
import '../../../services/admin/cuenta/admin_cuenta.dart';
import 'foto_perfil_admin_controlador.dart';

class CuentaAdminController extends ChangeNotifier {
  CuentaAdmin? _cuenta;
  bool _cargando = false;
  bool _guardando = false;
  String? _error;

  FotoPerfilAdminControlador? _fotoPerfilControlador;

  CuentaAdmin? get cuenta => _cuenta;
  bool get cargando => _cargando;
  bool get guardando => _guardando;
  String? get error => _error;

  // =====================================================
  // VINCULAR CONTROLADOR DE FOTO
  // =====================================================

  void vincularControladorFoto(
    FotoPerfilAdminControlador controlador,
  ) {
    _fotoPerfilControlador = controlador;

    if (_cuenta != null) {
      controlador.actualizarDesdeCuenta(_cuenta!);
    }
  }

  // =====================================================
  // CARGAR CUENTA
  // =====================================================

  Future<void> cargarCuenta(String idAdministrador) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _cuenta = await AdminServicioCuenta.obtenerCuenta(
        idAdministrador,
      );

      if (_cuenta != null) {
        _fotoPerfilControlador?.actualizarDesdeCuenta(_cuenta!);
      }
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

  // =====================================================
  // ACTUALIZAR DATOS PERSONALES
  // =====================================================

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

      if (_cuenta != null) {
        _fotoPerfilControlador?.actualizarDesdeCuenta(_cuenta!);
      }

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

  // =====================================================
  // LIMPIAR ERROR
  // =====================================================

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  // =====================================================
  // LIMPIAR CUENTA
  // =====================================================

  void limpiarCuenta() {
    _cuenta = null;
    _error = null;
    _cargando = false;
    _guardando = false;

    _fotoPerfilControlador?.limpiarFoto();

    notifyListeners();
  }
}