
import 'package:flutter/foundation.dart';

import '../../../models/admin/admin_producto_model.dart';
import '../../../services/admin/producto/admin_producto.dart';

class ProductoController extends ChangeNotifier {
  final String token;

  ProductoController({required this.token});

  static const String estadoPendiente = 'pendiente_revision';
  static const String estadoAprobado = 'aprobado';
  static const String estadoRechazado = 'rechazado';

  List<AdminProductoModel> _productosPendientes = [];
  List<AdminProductoModel> _productosAceptados = [];
  List<AdminProductoModel> _productosRechazados = [];

  bool _cargando = false;
  bool _actualizando = false;

  String _estadoSeleccionado = estadoPendiente;
  String _busqueda = '';
  String? _error;

  final Set<String> _productosProcesando = {};

  List<AdminProductoModel> get productos {
    switch (_estadoSeleccionado) {
      case estadoAprobado:
        return List.unmodifiable(_productosAceptados);
      case estadoRechazado:
        return List.unmodifiable(_productosRechazados);
      default:
        return List.unmodifiable(_productosPendientes);
    }
  }

  // Todos los productos, sin importar su estado.
  List<AdminProductoModel> get todosLosProductos {
    return List.unmodifiable([
      ..._productosPendientes,
      ..._productosAceptados,
      ..._productosRechazados,
    ]);
  }

  bool get cargando => _cargando;
  bool get actualizando => _actualizando;
  String get busqueda => _busqueda;
  String get estadoSeleccionado => _estadoSeleccionado;
  String? get error => _error;

  Set<String> get productosProcesando =>
      Set.unmodifiable(_productosProcesando);

  int get totalPendientes => _productosPendientes.length;
  int get totalAceptados => _productosAceptados.length;
  int get totalRechazados => _productosRechazados.length;

  List<AdminProductoModel> get productosFiltrados {
    final consulta = _busqueda.trim().toLowerCase();

    if (consulta.isEmpty) return productos;

    return productos.where((producto) {
      return producto.nombre.toLowerCase().contains(consulta) ||
          producto.categoria.toLowerCase().contains(consulta) ||
          producto.sitioNombre.toLowerCase().contains(consulta) ||
          producto.ciudad.toLowerCase().contains(consulta) ||
          producto.departamento.toLowerCase().contains(consulta);
    }).toList();
  }

  Future<void> seleccionarEstado(String estado) async {
    if (estado != estadoPendiente &&
        estado != estadoAprobado &&
        estado != estadoRechazado) {
      return;
    }

    if (_estadoSeleccionado == estado) return;

    _estadoSeleccionado = estado;
    _busqueda = '';
    _error = null;

    notifyListeners();

    await cargarProductosPendientes();
  }

  Future<void> cargarProductosPendientes({
    bool mostrarCarga = true,
  }) async {
    if (_cargando || _actualizando) return;

    _error = null;

    if (mostrarCarga) {
      _cargando = true;
    } else {
      _actualizando = true;
    }

    notifyListeners();

    try {
      final resultados = await Future.wait([
        AdminProducto.obtenerProductosPendientes(
          token: token,
        ),
        AdminProducto.obtenerProductosPorEstado(
          estado: estadoAprobado,
          token: token,
        ),
        AdminProducto.obtenerProductosPorEstado(
          estado: estadoRechazado,
          token: token,
        ),
      ]);

      _productosPendientes = resultados[0];
      _productosAceptados = resultados[1];
      _productosRechazados = resultados[2];
    } catch (e) {
      _error = _limpiarError(e);
    } finally {
      _cargando = false;
      _actualizando = false;
      notifyListeners();
    }
  }

  Future<void> actualizarProductos() async {
    await cargarProductosPendientes(
      mostrarCarga: false,
    );
  }

  void cambiarBusqueda(String valor) {
    _busqueda = valor;
    notifyListeners();
  }

  void limpiarBusqueda() {
    _busqueda = '';
    notifyListeners();
  }

  Future<bool> aprobarProducto(String productoId) async {
    if (_productosProcesando.contains(productoId)) {
      return false;
    }

    _productosProcesando.add(productoId);
    _error = null;
    notifyListeners();

    try {
      await AdminProducto.aprobarProducto(
        id: productoId,
        token: token,
      );

      _productosPendientes.removeWhere(
        (producto) => producto.id == productoId,
      );

      await _recargarEstadosDespuesDeRevision();

      return true;
    } catch (e) {
      _error = _limpiarError(e);
      return false;
    } finally {
      _productosProcesando.remove(productoId);
      notifyListeners();
    }
  }

  Future<bool> rechazarProducto({
    required String productoId,
    required String motivoRechazo,
  }) async {
    if (_productosProcesando.contains(productoId)) {
      return false;
    }

    if (motivoRechazo.trim().length < 3) {
      _error = 'Debes escribir un motivo de rechazo válido.';
      notifyListeners();
      return false;
    }

    _productosProcesando.add(productoId);
    _error = null;
    notifyListeners();

    try {
      await AdminProducto.rechazarProducto(
        id: productoId,
        motivoRechazo: motivoRechazo.trim(),
        token: token,
      );

      _productosPendientes.removeWhere(
        (producto) => producto.id == productoId,
      );

      await _recargarEstadosDespuesDeRevision();

      return true;
    } catch (e) {
      _error = _limpiarError(e);
      return false;
    } finally {
      _productosProcesando.remove(productoId);
      notifyListeners();
    }
  }

  // ============================================================
  // ELIMINAR PRODUCTO
  // ============================================================

  Future<bool> eliminarProducto(String productoId) async {
    if (_productosProcesando.contains(productoId)) {
      return false;
    }

    _productosProcesando.add(productoId);
    _error = null;
    notifyListeners();

    try {
      await AdminProducto.eliminarProducto(
        id: productoId,
        token: token,
      );

      _productosPendientes.removeWhere(
        (producto) => producto.id == productoId,
      );

      _productosAceptados.removeWhere(
        (producto) => producto.id == productoId,
      );

      _productosRechazados.removeWhere(
        (producto) => producto.id == productoId,
      );

      return true;
    } catch (e) {
      _error = _limpiarError(e);
      return false;
    } finally {
      _productosProcesando.remove(productoId);
      notifyListeners();
    }
  }

  Future<void> _recargarEstadosDespuesDeRevision() async {
    final resultados = await Future.wait([
      AdminProducto.obtenerProductosPendientes(
        token: token,
      ),
      AdminProducto.obtenerProductosPorEstado(
        estado: estadoAprobado,
        token: token,
      ),
      AdminProducto.obtenerProductosPorEstado(
        estado: estadoRechazado,
        token: token,
      ),
    ]);

    _productosPendientes = resultados[0];
    _productosAceptados = resultados[1];
    _productosRechazados = resultados[2];
  }

  Future<AdminProductoModel?> obtenerProducto(
    String productoId,
  ) async {
    try {
      final producto = todosLosProductos.where(
        (elemento) => elemento.id == productoId,
      );

      if (producto.isNotEmpty) {
        return producto.first;
      }

      return await AdminProducto.obtenerProducto(
        id: productoId,
        token: token,
      );
    } catch (e) {
      _error = _limpiarError(e);
      notifyListeners();
      return null;
    }
  }

  bool estaProcesando(String productoId) {
    return _productosProcesando.contains(productoId);
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  String _limpiarError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .trim();
  }
}
