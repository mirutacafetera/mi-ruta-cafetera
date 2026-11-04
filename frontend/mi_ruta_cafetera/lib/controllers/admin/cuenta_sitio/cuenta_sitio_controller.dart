
import 'package:flutter/foundation.dart';

import '../../../config/api_config.dart';
import '../../../models/admin/cuenta_sitio_model.dart';
import '../../../models/admin/sitio_admin_model.dart';
import '../../../services/admin/cuenta_sitio/cuenta_sitio.dart';
import '../../../services/admin/sitio/admin_sitio_consultas.dart';

class CuentaSitioController extends ChangeNotifier {
  List<CuentaSitioModel> cuentas = [];
  List<SitioAdminModel> sitios = [];

  bool cargando = false;
  bool guardando = false;
  String? error;
  String busqueda = '';
  String filtro = 'Todos';
  String _token = '';

  // =====================================================
  // SITIOS FILTRADOS
  // =====================================================

  List<SitioAdminModel> get sitiosFiltrados {
    final consulta = busqueda.trim().toLowerCase();

    return sitios.where((sitio) {
      final cuenta = cuentaDeSitio(sitio.id);

      final coincideBusqueda = consulta.isEmpty ||
          sitio.nombre.toLowerCase().contains(consulta) ||
          sitio.ciudad.toLowerCase().contains(consulta) ||
          sitio.direccion.toLowerCase().contains(consulta) ||
          (cuenta != null &&
              (cuenta.nombreCompleto.toLowerCase().contains(consulta) ||
                  cuenta.correo.toLowerCase().contains(consulta) ||
                  cuenta.telefono.toLowerCase().contains(consulta)));

      if (!coincideBusqueda) return false;

      switch (filtro) {
        case 'Con cuenta':
          return cuenta != null;
        case 'Sin cuenta':
          return cuenta == null;
        case 'Activas':
          return cuenta != null && cuenta.activo;
        case 'Inactivas':
          return cuenta != null && !cuenta.activo;
        default:
          return true;
      }
    }).toList();
  }

  // =====================================================
  // SITIOS CON Y SIN CUENTA
  // =====================================================

  List<SitioAdminModel> get sitiosConCuenta =>
      sitios.where((sitio) => cuentaDeSitio(sitio.id) != null).toList();

  List<SitioAdminModel> get sitiosSinCuenta =>
      sitios.where((sitio) => cuentaDeSitio(sitio.id) == null).toList();

  // =====================================================
  // ESTADÍSTICAS
  // =====================================================

  int get totalSitios => sitios.length;
  int get totalCuentas => cuentas.length;
  int get totalConCuenta => sitiosConCuenta.length;
  int get totalSinCuenta => sitiosSinCuenta.length;
  int get cuentasActivas => cuentas.where((c) => c.activo).length;
  int get cuentasInactivas => cuentas.where((c) => !c.activo).length;

  // =====================================================
  // OBTENER CUENTA DE UN SITIO
  // =====================================================

  CuentaSitioModel? cuentaDeSitio(String sitioId) {
    for (final cuenta in cuentas) {
      if (cuenta.sitioId == sitioId) return cuenta;
    }
    return null;
  }

  // =====================================================
  // BÚSQUEDA Y FILTROS
  // =====================================================

  void cambiarBusqueda(String valor) {
    busqueda = valor;
    notifyListeners();
  }

  void cambiarFiltro(String valor) {
    filtro = valor;
    notifyListeners();
  }

  // =====================================================
  // CARGAR DATOS
  // =====================================================

  Future<void> cargarDatos({required String token}) async {
    if (cargando) return;

    _token = token;
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final resultados = await Future.wait([
        CuentaSitio.obtenerCuentas(token: _token),
        AdminSitioConsultas.obtenerSitios(ApiConfig.baseUrl),
      ]);

      final cuentasActualizadas =
          resultados[0] as List<CuentaSitioModel>;

      final sitiosActualizados =
          resultados[1] as List<SitioAdminModel>;

      cuentas = cuentasActualizadas;
      sitios = sitiosActualizados;
    } catch (e) {
      error = e.toString();
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarCuentas({required String token}) async {
    await cargarDatos(token: token);
  }

  // =====================================================
  // CREAR CUENTA
  // =====================================================

  Future<CuentaSitioModel> crearCuenta({
    required String sitioId,
    required String nombre,
    required String apellido,
    required String correo,
    required String password,
    required String telefono,
  }) async {
    guardando = true;
    error = null;
    notifyListeners();

    try {
      final cuenta = await CuentaSitio.crearCuenta(
        token: _token,
        sitioId: sitioId,
        nombre: nombre,
        apellido: apellido,
        correo: correo,
        password: password,
        telefono: telefono,
      );

      await cargarDatos(token: _token);

      return cuenta;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  // =====================================================
  // VERIFICAR CORREO DE LA CUENTA DEL SITIO
  // =====================================================

  Future<Map<String, dynamic>> verificarCorreo({
    required String correo,
    required String codigo,
  }) async {
    guardando = true;
    error = null;
    notifyListeners();

    try {
      final respuesta = await CuentaSitio.verificarCorreo(
        correo: correo,
        codigo: codigo,
      );

      await cargarDatos(token: _token);

      return respuesta;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  // =====================================================
  // ACTUALIZAR CUENTA
  // =====================================================

  Future<void> actualizarCuenta({
    required String cuentaId,
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
  }) async {
    guardando = true;
    error = null;
    notifyListeners();

    try {
      await CuentaSitio.actualizarCuenta(
        token: _token,
        cuentaId: cuentaId,
        nombre: nombre,
        apellido: apellido,
        correo: correo,
        telefono: telefono,
      );

      await cargarDatos(token: _token);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  // =====================================================
  // CAMBIAR ESTADO DE LA CUENTA
  // =====================================================

  Future<void> cambiarEstado({
    required String cuentaId,
    required bool activo,
  }) async {
    guardando = true;
    error = null;
    notifyListeners();

    try {
      await CuentaSitio.cambiarEstado(
        token: _token,
        cuentaId: cuentaId,
        activo: activo,
      );

      await cargarDatos(token: _token);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  // =====================================================
  // ELIMINAR SITIO Y CUENTA
  // =====================================================

  Future<void> eliminarSitioYCuenta({
    required String sitioId,
  }) async {
    guardando = true;
    error = null;
    notifyListeners();

    try {
      await CuentaSitio.eliminarSitioYCuenta(
        token: _token,
        sitioId: sitioId,
      );

      await cargarDatos(token: _token);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  // =====================================================
  // LIMPIAR ERROR
  // =====================================================

  void limpiarError() {
    error = null;
    notifyListeners();
  }
}
