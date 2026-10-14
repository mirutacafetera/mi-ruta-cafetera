import 'package:flutter/foundation.dart';

import '../../../models/admin/usuario_admin.dart';
import '../../../services/admin/usuario/admin_usuario.dart';

class UsuarioAdminController extends ChangeNotifier {
  List<UsuarioAdmin> _usuarios = [];

  bool _cargando = false;
  bool _procesando = false;

  String _busqueda = '';
  String _filtroEstado = 'todos';
  String? _error;

  List<UsuarioAdmin> get usuarios => List.unmodifiable(_usuarios);

  bool get cargando => _cargando;
  bool get procesando => _procesando;

  String get busqueda => _busqueda;
  String get filtroEstado => _filtroEstado;
  String? get error => _error;

  int get totalUsuarios => _usuarios.length;

  int get usuariosActivos =>
      _usuarios.where((usuario) => usuario.activo).length;

  int get usuariosInactivos =>
      _usuarios.where((usuario) => !usuario.activo).length;

  int get correosVerificados =>
      _usuarios.where((usuario) => usuario.correoVerificado).length;

  // ============================================================
  // USUARIOS FILTRADOS POR NOMBRE, CORREO Y ESTADO
  // ============================================================

  List<UsuarioAdmin> get usuariosFiltrados {
    final consulta = _busqueda.trim().toLowerCase();

    return _usuarios.where((usuario) {
      final nombre = usuario.nombreCompleto.toLowerCase();
      final correo = usuario.correo.toLowerCase();

      final coincideBusqueda = consulta.isEmpty ||
          nombre.contains(consulta) ||
          correo.contains(consulta);

      final coincideEstado = switch (_filtroEstado) {
        'activos' => usuario.activo,
        'inactivos' => !usuario.activo,
        _ => true,
      };

      return coincideBusqueda && coincideEstado;
    }).toList();
  }

  // ============================================================
  // CARGAR USUARIOS
  // ============================================================

  Future<void> cargarUsuarios() async {
    if (_cargando) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _usuarios = await AdminUsuarioService.obtenerUsuarios();
    } catch (e) {
      _error = _limpiarError(e);
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // ============================================================
  // BUSCAR USUARIOS
  // ============================================================

  void buscar(String texto) {
    _busqueda = texto;
    notifyListeners();
  }

  // ============================================================
  // FILTRAR POR ESTADO
  // ============================================================

  void filtrarPorEstado(String estado) {
    _filtroEstado = estado;
    notifyListeners();
  }

  // ============================================================
  // BUSCAR USUARIO POR ID
  // ============================================================

  UsuarioAdmin? buscarUsuarioPorId(String id) {
    for (final usuario in _usuarios) {
      if (usuario.id == id) {
        return usuario;
      }
    }

    return null;
  }

  // ============================================================
  // ACTIVAR O DESACTIVAR USUARIO
  // ============================================================

  Future<bool> cambiarEstadoUsuario(UsuarioAdmin usuario) async {
    if (_procesando) return false;

    _procesando = true;
    _error = null;
    notifyListeners();

    try {
      final actualizado = usuario.activo
          ? await AdminUsuarioService.desactivarUsuario(usuario.id)
          : await AdminUsuarioService.activarUsuario(usuario.id);

      _reemplazarUsuario(actualizado);
      return true;
    } catch (e) {
      _error = _limpiarError(e);
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  // ============================================================
  // ELIMINAR USUARIO
  // ============================================================

  Future<bool> eliminarUsuario(String id) async {
    if (_procesando) return false;

    _procesando = true;
    _error = null;
    notifyListeners();

    try {
      await AdminUsuarioService.eliminarUsuario(id);

      _usuarios.removeWhere((usuario) => usuario.id == id);
      return true;
    } catch (e) {
      _error = _limpiarError(e);
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  // ============================================================
  // ACTUALIZAR USUARIO EN LA LISTA
  // ============================================================

  void _reemplazarUsuario(UsuarioAdmin actualizado) {
    final indice = _usuarios.indexWhere(
      (usuario) => usuario.id == actualizado.id,
    );

    if (indice != -1) {
      _usuarios[indice] = actualizado;
    }
  }

  // ============================================================
  // LIMPIAR MENSAJE DE ERROR
  // ============================================================

  String _limpiarError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  // ============================================================
  // LIMPIAR DATOS
  // ============================================================

  void limpiarDatos() {
    _usuarios = [];
    _busqueda = '';
    _filtroEstado = 'todos';
    _error = null;
    _cargando = false;
    _procesando = false;
    notifyListeners();
  }
}