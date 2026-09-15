import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  // =====================================================
  // POSICIÓN ACTUAL
  // =====================================================

  Future<LatLng?> obtenerUbicacionActual() async {
    final disponible = await _verificarServicio();

    if (!disponible) {
      return null;
    }

    var permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      return null;
    }

    final posicion = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    return LatLng(
      posicion.latitude,
      posicion.longitude,
    );
  }

  // =====================================================
  // ESCUCHAR CAMBIOS DE UBICACIÓN
  // =====================================================

  Stream<LatLng> escucharUbicacion() async* {
    final disponible = await _verificarServicio();

    if (!disponible) {
      return;
    }

    var permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      return;
    }

    const configuracion = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    await for (final posicion
        in Geolocator.getPositionStream(
      locationSettings: configuracion,
    )) {
      yield LatLng(
        posicion.latitude,
        posicion.longitude,
      );
    }
  }

  // =====================================================
  // VERIFICAR SERVICIO
  // =====================================================

  Future<bool> _verificarServicio() async {
    return Geolocator.isLocationServiceEnabled();
  }
}