import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../config/mapa_corredor.dart';
import '../l10n/textos.dart';

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
        return Textos.t('Activa la ubicación del dispositivo para ver el clima de tu zona.');
      case EstadoUbicacion.permisoDenegado:
        return Textos.t('Permite el acceso a tu ubicación para ver el clima de tu zona.');
      case EstadoUbicacion.permisoBloqueado:
        return Textos.t('El permiso de ubicación está bloqueado. Habilítalo en los ajustes de la aplicación.');
      case EstadoUbicacion.error:
        return Textos.t('No fue posible obtener tu ubicación.');
    }
  }
}

/// Punto de partida de una ruta calculada desde la ubicación real.
///
/// Si no se pudo usar la ubicación del usuario, [punto] es null y
/// [aviso] explica el motivo. Nunca se inventa una ubicación.
class OrigenRuta {
  final LatLng? punto;
  final String? aviso;

  const OrigenRuta({
    this.punto,
    this.aviso,
  });

  bool get disponible => punto != null;
}

/// Obtiene la ubicación actual con el paquete geolocator,
/// el mismo que usa el mapa. Nunca lanza excepciones.
///
/// Es la única implementación de geolocalización de la
/// aplicación: la usan el clima, el botón de ubicación del mapa
/// y el cálculo de rutas.
class UbicacionService {
  UbicacionService._();

  /// [precision] es medium por defecto (suficiente para el clima).
  /// El mapa y las rutas piden high para obtener el GPS real.
  static Future<ResultadoUbicacion> obtener({
    LocationAccuracy precision = LocationAccuracy.medium,
  }) async {
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
        locationSettings: LocationSettings(
          accuracy: precision,
          timeLimit: const Duration(seconds: 15),
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

  /// Obtiene el punto de partida para calcular una ruta.
  ///
  /// Usa la ubicación real del usuario únicamente si es válida y
  /// está dentro del corredor Garzón – Gigante. En cualquier otro
  /// caso devuelve un aviso claro y no un punto inventado.
  static Future<OrigenRuta> obtenerOrigenRuta() async {
    final resultado = await obtener(
      precision: LocationAccuracy.high,
    );

    switch (resultado.estado) {
      case EstadoUbicacion.servicioDesactivado:
        return OrigenRuta(
          aviso: Textos.t('La ubicación del dispositivo está desactivada. La ruta empieza en el primer sitio.'),
        );

      case EstadoUbicacion.permisoDenegado:
        return OrigenRuta(
          aviso: Textos.t('No diste permiso de ubicación. La ruta empieza en el primer sitio.'),
        );

      case EstadoUbicacion.permisoBloqueado:
        return OrigenRuta(
          aviso: Textos.t('El permiso de ubicación está bloqueado. La ruta empieza en el primer sitio.'),
        );

      case EstadoUbicacion.error:
        return OrigenRuta(
          aviso: Textos.t('No fue posible obtener tu ubicación. La ruta empieza en el primer sitio.'),
        );

      case EstadoUbicacion.disponible:
        break;
    }

    final ubicacion = resultado.ubicacion;

    if (ubicacion == null) {
      return OrigenRuta(
        aviso: Textos.t('No fue posible obtener tu ubicación. La ruta empieza en el primer sitio.'),
      );
    }

    final punto = LatLng(
      ubicacion.latitud,
      ubicacion.longitud,
    );

    if (!MapaCorredor.contienePunto(punto)) {
      final km = MapaCorredor.distanciaAlCentroKm(punto);

      return OrigenRuta(
        aviso: Textos.t('Estás fuera del corredor Garzón–Gigante (a unos {0} km). La ruta empieza en el primer sitio.', [km.round()]),
      );
    }

    return OrigenRuta(punto: punto);
  }
}
