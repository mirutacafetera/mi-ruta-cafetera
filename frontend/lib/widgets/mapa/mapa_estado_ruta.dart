import 'package:flutter/foundation.dart';

import '../../models/sitio_turistico_model.dart';

class MapaEstadoRuta extends ChangeNotifier {
  final List<SitioTuristicoModel> _sitiosSeleccionados = [];

  bool _modoCrearRuta = false;

  List<SitioTuristicoModel> get sitiosSeleccionados =>
      List.unmodifiable(_sitiosSeleccionados);

  bool get modoCrearRuta => _modoCrearRuta;

  int get cantidadSeleccionada =>
      _sitiosSeleccionados.length;

  bool get puedeCalcular =>
      _sitiosSeleccionados.length >= 2;

  bool get limiteAlcanzado =>
      _sitiosSeleccionados.length >= 4;

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

  bool alternarSitio(
    SitioTuristicoModel sitio,
  ) {
    final index = _sitiosSeleccionados.indexWhere(
      (item) => item.id == sitio.id,
    );

    if (index != -1) {
      _sitiosSeleccionados.removeAt(index);
      notifyListeners();
      return true;
    }

    if (_sitiosSeleccionados.length >= 4) {
      return false;
    }

    _sitiosSeleccionados.add(sitio);
    notifyListeners();

    return true;
  }

  void limpiarSeleccion() {
    _sitiosSeleccionados.clear();
    notifyListeners();
  }
}