
import 'package:flutter/foundation.dart';

import '../../../services/admin/cuenta/foto_perfil_admin.dart';

class FotoPerfilAdminControlador extends ChangeNotifier {
  String? _rutaFoto;
  bool _cargando = false;
  bool _inicializado = false;
  String? _error;

  String? get rutaFoto => _rutaFoto;
  bool get cargando => _cargando;
  bool get inicializado => _inicializado;
  String? get error => _error;

  Future<void> cargarFoto() async {
    if (_cargando) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _rutaFoto = await FotoPerfilAdmin.obtenerRuta();
      _inicializado = true;
    } catch (e) {
      _error = 'No se pudo cargar la foto de perfil.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> seleccionarFoto() async {
    if (_cargando) return false;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final nuevaRuta =
          await FotoPerfilAdmin.seleccionarYGuardar();

      if (nuevaRuta == null) return false;

      _rutaFoto = nuevaRuta;
      _inicializado = true;

      return true;
    } catch (e) {
      _error = 'No se pudo seleccionar la foto.';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarFoto() async {
    if (_cargando) return false;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await FotoPerfilAdmin.eliminarFoto();
      _rutaFoto = null;
      _inicializado = true;

      return true;
    } catch (e) {
      _error = 'No se pudo eliminar la foto.';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
