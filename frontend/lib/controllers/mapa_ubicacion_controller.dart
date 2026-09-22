import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_service.dart';

class MapaUbicacionController extends ChangeNotifier {
  final LocationService _locationService = LocationService.instance;

  LatLng? _ubicacionActual;
  StreamSubscription<LatLng>? _suscripcion;

  bool _cargando = false;
  bool _siguiendoUsuario = false;
  String? _error;

  // =====================================================
  // GETTERS
  // =====================================================

  LatLng? get ubicacionActual => _ubicacionActual;

  bool get cargando => _cargando;

  bool get siguiendoUsuario => _siguiendoUsuario;

  String? get error => _error;

  bool get tieneUbicacion => _ubicacionActual != null;

  // =====================================================
  // OBTENER UBICACIÓN
  // =====================================================

  Future<LatLng?> obtenerUbicacion() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final ubicacion =
          await _locationService.obtenerUbicacionActual();

      if (ubicacion == null) {
        _error =
            'No fue posible obtener la ubicación actual.';
        return null;
      }

      _ubicacionActual = ubicacion;

      return ubicacion;
    } catch (e) {
      _error =
          'No fue posible obtener la ubicación actual.';
      return null;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // =====================================================
  // SEGUIMIENTO CONTINUO
  // =====================================================

  Future<void> iniciarSeguimiento() async {
    await detenerSeguimiento();

    _siguiendoUsuario = true;
    _error = null;
    notifyListeners();

    _suscripcion =
        _locationService.escucharUbicacion().listen(
      (ubicacion) {
        _ubicacionActual = ubicacion;
        notifyListeners();
      },
      onError: (_) {
        _error =
            'No fue posible actualizar la ubicación.';
        notifyListeners();
      },
    );
  }

  // =====================================================
  // DETENER SEGUIMIENTO
  // =====================================================

  Future<void> detenerSeguimiento() async {
    await _suscripcion?.cancel();
    _suscripcion = null;

    if (_siguiendoUsuario) {
      _siguiendoUsuario = false;
      notifyListeners();
    }
  }

  // =====================================================
  // LIMPIAR
  // =====================================================

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}