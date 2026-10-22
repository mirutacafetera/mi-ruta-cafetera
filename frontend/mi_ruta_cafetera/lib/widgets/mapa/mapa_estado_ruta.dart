import 'package:flutter/foundation.dart';

import '../../models/sitio_turistico_model.dart';

class MapaEstadoRuta extends ChangeNotifier {
  // =====================================================
  // CONFIGURACIÓN DE LA RUTA
  // =====================================================

  static const int minSitios = 2;
  static const int maxSitios = 4;

  // Las rutas predefinidas de la API pueden tener hasta 9 paradas
  // (9 paradas + el origen del usuario = 10 puntos, el máximo que
  // admite el cálculo de rutas del backend).
  static const int maxSitiosPredefinida = 9;

  // =====================================================
  // ESTADO INTERNO
  // =====================================================

  final List<SitioTuristicoModel> _sitiosSeleccionados = [];

  bool _modoCrearRuta = false;
  int _limiteSitios = maxSitios;

  // =====================================================
  // GETTERS
  // =====================================================

  List<SitioTuristicoModel> get sitiosSeleccionados =>
      List.unmodifiable(_sitiosSeleccionados);

  bool get modoCrearRuta => _modoCrearRuta;

  int get cantidadSeleccionada =>
      _sitiosSeleccionados.length;

  bool get puedeCalcular =>
      cantidadSeleccionada >= minSitios;

  /// Límite de sitios vigente: [maxSitios] para rutas personales o
  /// [maxSitiosPredefinida] cuando se abre una ruta predefinida.
  int get limiteSitios => _limiteSitios;

  bool get limiteAlcanzado =>
      cantidadSeleccionada >= _limiteSitios;

  // =====================================================
  // CONSULTAS DE SELECCIÓN
  // =====================================================

  bool estaSeleccionado(
    SitioTuristicoModel sitio,
  ) {
    return _sitiosSeleccionados.any(
      (item) => item.id == sitio.id,
    );
  }

  int numeroDeSitio(
    SitioTuristicoModel sitio,
  ) {
    final index = _sitiosSeleccionados.indexWhere(
      (item) => item.id == sitio.id,
    );

    return index == -1 ? 0 : index + 1;
  }

  // =====================================================
  // CONTROL DEL MODO CREAR RUTA
  // =====================================================

  void iniciar({int limite = maxSitios}) {
    _modoCrearRuta = true;
    _limiteSitios = limite;
    _sitiosSeleccionados.clear();
    notifyListeners();
  }

  void cancelar() {
    _modoCrearRuta = false;
    _limiteSitios = maxSitios;
    _sitiosSeleccionados.clear();
    notifyListeners();
  }

  // =====================================================
  // SELECCIÓN / DESELECCIÓN DE SITIOS
  // =====================================================

  bool alternarSitio(
    SitioTuristicoModel sitio,
  ) {
    final index = _sitiosSeleccionados.indexWhere(
      (item) => item.id == sitio.id,
    );

    // ---------------------------------------------------
    // Si ya está seleccionado, se elimina.
    // ---------------------------------------------------

    if (index != -1) {
      _sitiosSeleccionados.removeAt(index);
      notifyListeners();
      return true;
    }

    // ---------------------------------------------------
    // No permite superar el máximo establecido.
    // ---------------------------------------------------

    if (limiteAlcanzado) {
      return false;
    }

    // ---------------------------------------------------
    // Agrega el sitio a la selección.
    // ---------------------------------------------------

    _sitiosSeleccionados.add(sitio);
    notifyListeners();

    return true;
  }

  // =====================================================
  // LIMPIAR SELECCIÓN
  // =====================================================

  void limpiarSeleccion() {
    if (_sitiosSeleccionados.isEmpty) {
      return;
    }

    _sitiosSeleccionados.clear();
    notifyListeners();
  }
}

