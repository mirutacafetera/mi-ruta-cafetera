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

  int get totalUsuarios =>
      _usuarios.where((usuario) => !usuario.eliminado).length;

  int get usuariosActivos => _usuarios
      .where((usuario) => !usuario.eliminado && usuario.activo)
      .length;

  int get usuariosInactivos => _usuarios
      .where((usuario) => !usuario.eliminado && !usuario.activo)
      .length;

  int get usuariosEliminados =>
      _usuarios.where((usuario) => usuario.eliminado).length;

  int get correosVerificados => _usuarios
      .where((usuario) => !usuario.eliminado && usuario.correoVerificado)
      .length;

  // USUARIOS FILTRADOS

  List<UsuarioAdmin> get usuariosFiltrados {
    final consulta = _busqueda.trim().toLowerCase();

    return _usuarios.where((usuario) {
      final nombre = usuario.nombreCompleto.toLowerCase();
      final correo = usuario.correoMostrado.toLowerCase();
      final nombreOriginal =
          (usuario.usuarioNombreEliminado ?? '').toLowerCase();

      final coincideBusqueda = consulta.isEmpty ||
          nombre.contains(consulta) ||
          correo.contains(consulta) ||
          nombreOriginal.contains(consulta);

      final coincideEstado = switch (_filtroEstado) {
        'activos' => !usuario.eliminado && usuario.activo,
        'inactivos' => !usuario.eliminado && !usuario.activo,
        'eliminados' => usuario.eliminado,
        _ => true,
      };

      return coincideBusqueda && coincideEstado;
    }).toList();
  }

  // CARGAR USUARIOS

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

  // BUSCAR

  void buscar(String texto) {
    _busqueda = texto;
    notifyListeners();
  }

  // FILTRAR

  void filtrarPorEstado(String estado) {
    _filtroEstado = estado;
    notifyListeners();
  }

  // BUSCAR POR ID

  UsuarioAdmin? buscarUsuarioPorId(String id) {
    for (final usuario in _usuarios) {
      if (usuario.id == id) return usuario;
    }

    return null;
  }

  // ACTIVAR O DESACTIVAR

  Future<bool> cambiarEstadoUsuario(UsuarioAdmin usuario) async {
    if (_procesando || usuario.eliminado) return false;

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

  // ELIMINAR USUARIO

  Future<bool> eliminarUsuario(String id) async {
    if (_procesando) return false;

    final usuario = buscarUsuarioPorId(id);

    if (usuario == null || usuario.eliminado) {
      _error = 'El usuario no existe o ya fue eliminado.';
      notifyListeners();
      return false;
    }

    _procesando = true;
    _error = null;
    notifyListeners();

    try {
      await AdminUsuarioService.eliminarUsuario(id);

      // No quitarlo de la lista: el backend debe devolver
      // la cuenta anonimizada para contarla como eliminada.
      await cargarUsuarios();

      return true;
    } catch (e) {
      _error = _limpiarError(e);
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  // REEMPLAZAR USUARIO

  void _reemplazarUsuario(UsuarioAdmin actualizado) {
    final indice = _usuarios.indexWhere(
      (usuario) => usuario.id == actualizado.id,
    );

    if (indice != -1) {
      _usuarios[indice] = actualizado;
    }
  }

  // LIMPIAR ERROR

  String _limpiarError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  // LIMPIAR DATOS

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