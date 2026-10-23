
import 'package:flutter/foundation.dart';

import '../../../services/admin/cuenta/foto_perfil_admin.dart';

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

  Future<void> cargarFoto() async {
    if (_inicializado) return;

    if (_cargaEnCurso != null) {
      await _cargaEnCurso;
      return;
    }

    final carga = _ejecutarCarga();
    _cargaEnCurso = carga;

    try {
      await carga;
    } finally {
      _cargaEnCurso = null;
    }
  }

  Future<void> _ejecutarCarga() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _rutaFoto = await FotoPerfilAdmin.obtenerRuta();
      _inicializado = true;

      debugPrint('Foto admin cargada: $_rutaFoto');
    } catch (e, stackTrace) {
      _error = 'No se pudo cargar la foto de perfil.';
      debugPrint('Error cargando foto: $e');
      debugPrintStack(stackTrace: stackTrace);
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

      debugPrint('Nueva foto admin: $_rutaFoto');
      return true;
    } catch (e, stackTrace) {
      _error = 'No se pudo seleccionar la foto.';
      debugPrint('Error seleccionando foto: $e');
      debugPrintStack(stackTrace: stackTrace);
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
    } catch (e, stackTrace) {
      _error = 'No se pudo eliminar la foto.';
      debugPrint('Error eliminando foto: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
