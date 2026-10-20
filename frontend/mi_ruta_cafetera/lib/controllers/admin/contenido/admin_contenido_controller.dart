
import 'package:flutter/foundation.dart';

import '../../../models/admin/admin_contenido_model.dart';
import '../../../services/admin/contenido/admin_contenido.dart';

class AdminContenidoController extends ChangeNotifier {
  List<AdminContenidoModel> _contenidos = [];

  bool _cargando = false;
  bool _guardando = false;
  String _busqueda = '';
  String? _error;

  final Set<String> _contenidosProcesando = {};

  // ============================================================
  // GETTERS
  // ============================================================

  List<AdminContenidoModel> get contenidos =>
      List.unmodifiable(_contenidos);

  bool get cargando => _cargando;

  bool get guardando => _guardando;

  String get busqueda => _busqueda;

  String? get error => _error;

  Set<String> get contenidosEnProcesamiento =>
      Set.unmodifiable(_contenidosProcesando);

  int get totalContenidos => _contenidos.length;

  int get totalPendientes => _contenidos
      .where(
        (contenido) =>
            contenido.estadoPublicacion == 'pendiente_revision',
      )
      .length;

  int get totalAceptados => _contenidos
      .where(
        (contenido) => contenido.estadoPublicacion == 'aprobado',
      )
      .length;

  int get totalRechazados => _contenidos
      .where(
        (contenido) => contenido.estadoPublicacion == 'rechazado',
      )
      .length;

  int get contenidosActivos =>
      _contenidos.where((contenido) => contenido.activo).length;

  int get contenidosInactivos =>
      _contenidos.where((contenido) => !contenido.activo).length;

  List<AdminContenidoModel> get contenidosFiltrados {
    final consulta = _busqueda.trim().toLowerCase();

    if (consulta.isEmpty) {
      return List.unmodifiable(_contenidos);
    }

    return _contenidos.where((contenido) {
      return contenido.titulo.toLowerCase().contains(consulta) ||
          contenido.descripcion.toLowerCase().contains(consulta) ||
          contenido.sitioNombre.toLowerCase().contains(consulta) ||
          contenido.ciudad.toLowerCase().contains(consulta) ||
          contenido.departamento.toLowerCase().contains(consulta);
    }).toList();
  }

  // ============================================================
  // CARGAR CONTENIDOS
  // ============================================================

  Future<void> cargarContenidos() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _contenidos = await AdminContenido.obtenerContenidos();
    } catch (e) {
      _error = _mensajeError(e);
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // ============================================================
  // BÚSQUEDA
  // ============================================================

  void cambiarBusqueda(String valor) {
    _busqueda = valor;
    notifyListeners();
  }

  void limpiarBusqueda() {
    _busqueda = '';
    notifyListeners();
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  // ============================================================
  // CONSULTAR UN CONTENIDO
  // ============================================================

  Future<AdminContenidoModel?> obtenerContenido(String id) async {
    try {
      _error = null;
      return await AdminContenido.obtenerContenido(id);
    } catch (e) {
      _error = _mensajeError(e);
      notifyListeners();
      return null;
    }
  }

  // ============================================================
  // EDITAR CONTENIDO
  // ============================================================

  Future<bool> actualizarContenido({
    required String id,
    required Map<String, dynamic> datos,
  }) async {
    return _ejecutarOperacion(
      id: id,
      operacion: () async {
        final actualizado = await AdminContenido.actualizarContenido(
          id: id,
          datos: datos,
        );

        _reemplazarContenido(actualizado);
      },
    );
  }

  // ============================================================
  // APROBAR CONTENIDO
  // ============================================================

  Future<bool> aprobarContenido(String id) async {
    return _ejecutarOperacion(
      id: id,
      operacion: () async {
        final actualizado = await AdminContenido.aprobarContenido(id);
        _reemplazarContenido(actualizado);
      },
    );
  }

  // ============================================================
  // RECHAZAR CONTENIDO
  // ============================================================

  Future<bool> rechazarContenido({
    required String id,
    required String motivoRechazo,
  }) async {
    return _ejecutarOperacion(
      id: id,
      operacion: () async {
        final actualizado = await AdminContenido.rechazarContenido(
          id: id,
          motivoRechazo: motivoRechazo,
        );

        _reemplazarContenido(actualizado);
      },
    );
  }

  // ============================================================
  // ACTIVAR CONTENIDO
  // ============================================================

  Future<bool> activarContenido(String id) async {
    return _ejecutarOperacion(
      id: id,
      operacion: () async {
        await AdminContenido.activarContenido(id);
        await _recargarListaSinInterrumpirOperacion();
      },
    );
  }

  // ============================================================
  // DESACTIVAR CONTENIDO
  // ============================================================

  Future<bool> desactivarContenido(String id) async {
    return _ejecutarOperacion(
      id: id,
      operacion: () async {
        await AdminContenido.desactivarContenido(id);
        await _recargarListaSinInterrumpirOperacion();
      },
    );
  }

  // ============================================================
  // ELIMINAR CONTENIDO
  // ============================================================

  Future<bool> eliminarContenido(String id) async {
    return _ejecutarOperacion(
      id: id,
      operacion: () async {
        await AdminContenido.eliminarContenido(id);
        _contenidos.removeWhere((contenido) => contenido.id == id);
      },
    );
  }

  // ============================================================
  // EJECUTAR OPERACIONES
  // ============================================================

  Future<bool> _ejecutarOperacion({
    required String id,
    required Future<void> Function() operacion,
  }) async {
    if (_contenidosProcesando.contains(id)) {
      return false;
    }

    _contenidosProcesando.add(id);
    _guardando = true;
    _error = null;
    notifyListeners();

    try {
      await operacion();
      return true;
    } catch (e) {
      _error = _mensajeError(e);
      return false;
    } finally {
      _contenidosProcesando.remove(id);
      _guardando = _contenidosProcesando.isNotEmpty;
      notifyListeners();
    }
  }

  // ============================================================
  // RECARGAR LISTA DESPUÉS DE ACTIVAR O DESACTIVAR
  // ============================================================

  Future<void> _recargarListaSinInterrumpirOperacion() async {
    final contenidosActualizados =
        await AdminContenido.obtenerContenidos();

    _contenidos = contenidosActualizados;
  }

  // ============================================================
  // REEMPLAZAR CONTENIDO EN LA LISTA
  // ============================================================

  void _reemplazarContenido(AdminContenidoModel actualizado) {
    final indice = _contenidos.indexWhere(
      (contenido) => contenido.id == actualizado.id,
    );

    if (indice != -1) {
      _contenidos[indice] = actualizado;
    }
  }

  // ============================================================
  // MENSAJES DE ERROR
  // ============================================================

  String _mensajeError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
