import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/admin/cuenta_admin.dart';
import '../../../services/admin/cuenta/admin_cuenta.dart';

class FotoPerfilAdminControlador extends ChangeNotifier {
  String? _rutaFoto;
  bool _cargando = false;
  bool _inicializado = false;
  String? _error;

  Future<void>? _cargaEnCurso;

  String? get rutaFoto => _rutaFoto;
  bool get cargando => _cargando;
  bool get inicializado => _inicializado;
  String? get error => _error;

  // =====================================================
  // CARGAR FOTO DESDE EL SERVIDOR
  // =====================================================

  Future<void> cargarFoto({
    required String idAdministrador,
    bool forzarRecarga = false,
  }) async {
    if (idAdministrador.trim().isEmpty) {
      _error = 'No se pudo identificar al administrador.';
      notifyListeners();
      return;
    }

    if (_inicializado && !forzarRecarga) {
      return;
    }

    if (_cargaEnCurso != null) {
      await _cargaEnCurso;
      return;
    }

    final carga = _ejecutarCarga(idAdministrador);
    _cargaEnCurso = carga;

    try {
      await carga;
    } finally {
      _cargaEnCurso = null;
    }
  }

  Future<void> _ejecutarCarga(
    String idAdministrador,
  ) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final cuenta = await AdminServicioCuenta.obtenerCuenta(
        idAdministrador,
      );

      _rutaFoto = cuenta.fotoPerfil;
      _inicializado = true;

      debugPrint(
        'Foto del administrador cargada desde el servidor: $_rutaFoto',
      );
    } catch (e, stackTrace) {
      _error = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      debugPrint('Error al cargar la foto del administrador: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // =====================================================
  // SELECCIONAR Y SUBIR FOTO
  // =====================================================

  Future<bool> seleccionarFoto({
    required String idAdministrador,
  }) async {
    if (_cargando) {
      return false;
    }

    if (idAdministrador.trim().isEmpty) {
      _error = 'No se pudo identificar al administrador.';
      notifyListeners();
      return false;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final XFile? imagen = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (imagen == null) {
        return false;
      }

      final cuenta = await AdminServicioCuenta.subirFotoPerfil(
        idAdministrador: idAdministrador,
        imagen: imagen,
      );

      _rutaFoto = cuenta.fotoPerfil;
      _inicializado = true;

      if (_rutaFoto == null || _rutaFoto!.trim().isEmpty) {
        _error =
            'El servidor guardó la solicitud, pero no devolvió la URL de la foto.';
        return false;
      }

      debugPrint('Foto actualizada: $_rutaFoto');

      return true;
    } catch (e, stackTrace) {
      _error = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      debugPrint('Error al seleccionar o subir la foto: $e');
      debugPrintStack(stackTrace: stackTrace);

      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // =====================================================
  // ACTUALIZAR DESDE LOS DATOS DE LA CUENTA
  // =====================================================

  void actualizarDesdeCuenta(CuentaAdmin cuenta) {
    _rutaFoto = cuenta.fotoPerfil;
    _inicializado = true;
    _error = null;
    notifyListeners();
  }

  // =====================================================
  // LIMPIAR ERROR
  // =====================================================

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  // =====================================================
  // LIMPIAR DATOS AL CERRAR SESIÓN
  // =====================================================

  void limpiarFoto() {
    _rutaFoto = null;
    _inicializado = false;
    _error = null;
    notifyListeners();
  }
}