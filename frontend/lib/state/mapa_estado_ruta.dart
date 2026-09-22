import 'package:flutter/foundation.dart';

import '../models/sitio_turistico_model.dart';

  class MapaEstadoRuta extends ChangeNotifier {
  static const int minSitios = 2;
  static const int maxSitios = 4;

  final List<SitioTuristicoModel> _sitiosSeleccionados = [];

  bool _modoCrearRuta = false;

  List<SitioTuristicoModel> get sitiosSeleccionados =>
      List.unmodifiable(_sitiosSeleccionados);

  bool get modoCrearRuta => _modoCrearRuta;

  int get cantidadSeleccionada => _sitiosSeleccionados.length;

  bool get puedeCalcular => cantidadSeleccionada >= minSitios;

  bool get limiteAlcanzado => cantidadSeleccionada >= maxSitios;

  bool estaSeleccionado(SitioTuristicoModel sitio) {
    return _sitiosSeleccionados.any(
      (item) => item.id == sitio.id,
    );
  }

  int numeroDeSitio(SitioTuristicoModel sitio) {
    final index = _sitiosSeleccionados.indexWhere(
      (item) => item.id == sitio.id,
    );

    return index == -1 ? 0 : index + 1;
  }

  void iniciar() {
    _modoCrearRuta = true;
    _sitiosSeleccionados.clear();
    notifyListeners();
  }

  void cancelar() {
    _modoCrearRuta = false;
    _sitiosSeleccionados.clear();
    notifyListeners();
  }

  bool alternarSitio(SitioTuristicoModel sitio) {
    final index = _sitiosSeleccionados.indexWhere(
      (item) => item.id == sitio.id,
    );

    if (index != -1) {
      _sitiosSeleccionados.removeAt(index);
      notifyListeners();
      return true;
    }

    if (limiteAlcanzado) {
      return false;
    }

    _sitiosSeleccionados.add(sitio);
    notifyListeners();
    return true;
  }

  void limpiarSeleccion() {
    if (_sitiosSeleccionados.isEmpty) {
      return;
    }

    _sitiosSeleccionados.clear();
    notifyListeners();
  }
}