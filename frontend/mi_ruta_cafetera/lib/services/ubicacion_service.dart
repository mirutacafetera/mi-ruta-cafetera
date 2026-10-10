import 'package:geolocator/geolocator.dart';

/// Coordenadas del usuario.
class UbicacionUsuario {
  final double latitud;
  final double longitud;

  const UbicacionUsuario({
    required this.latitud,
    required this.longitud,
  });
}

enum EstadoUbicacion {
  disponible,
  servicioDesactivado,
  permisoDenegado,
  permisoBloqueado,
  error,
}

class ResultadoUbicacion {
  final EstadoUbicacion estado;
  final UbicacionUsuario? ubicacion;

  const ResultadoUbicacion(
    this.estado, [
    this.ubicacion,
  ]);

  String get mensaje {
    switch (estado) {
      case EstadoUbicacion.disponible:
        return '';
      case EstadoUbicacion.servicioDesactivado:
        return 'Activa la ubicación del dispositivo '
            'para ver el clima de tu zona.';
      case EstadoUbicacion.permisoDenegado:
        return 'Permite el acceso a tu ubicación '
            'para ver el clima de tu zona.';
      case EstadoUbicacion.permisoBloqueado:
        return 'El permiso de ubicación está bloqueado. '
            'Habilítalo en los ajustes de la aplicación.';
      case EstadoUbicacion.error:
        return 'No fue posible obtener tu ubicación.';
    }
  }
}

/// Obtiene la ubicación actual con el paquete geolocator,
/// el mismo que usa el mapa. Nunca lanza excepciones.
class UbicacionService {
  UbicacionService._();

  static Future<ResultadoUbicacion> obtener() async {
    try {
      final servicioActivo =
          await Geolocator.isLocationServiceEnabled();

      if (!servicioActivo) {
        return const ResultadoUbicacion(
          EstadoUbicacion.servicioDesactivado,
        );
      }

      var permiso = await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied) {
        return const ResultadoUbicacion(
          EstadoUbicacion.permisoDenegado,
        );
      }

      if (permiso == LocationPermission.deniedForever) {
        return const ResultadoUbicacion(
          EstadoUbicacion.permisoBloqueado,
        );
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );

      return ResultadoUbicacion(
        EstadoUbicacion.disponible,
        UbicacionUsuario(
          latitud: posicion.latitude,
          longitud: posicion.longitude,
        ),
      );
    } catch (_) {
      return const ResultadoUbicacion(EstadoUbicacion.error);
    }
  }
}