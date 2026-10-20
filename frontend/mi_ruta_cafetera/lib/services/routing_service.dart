import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../config/api_config.dart';

/// Error controlado del cálculo de rutas.
///
/// Su texto ya está pensado para mostrarse al usuario.
class RoutingException implements Exception {
  final String mensaje;

  const RoutingException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Información de un tramo entre dos puntos consecutivos
/// de la ruta.
class TramoRuta {
  final int indice;
  final double distanciaMetros;
  final double duracionSegundos;

  const TramoRuta({
    required this.indice,
    required this.distanciaMetros,
    required this.duracionSegundos,
  });

  double get distanciaKm => distanciaMetros / 1000;

  double get duracionMinutos => duracionSegundos / 60;
}

/// Resultado completo de una ruta calculada por carretera.
class RutaResultado {
  final List<LatLng> puntos;

  final double distanciaMetros;

  final double duracionSegundos;

  /// Tramos entre cada par de puntos consecutivos.
  ///
  /// Ejemplo para 4 sitios:
  ///
  /// tramo 0 = sitio 1 → sitio 2
  /// tramo 1 = sitio 2 → sitio 3
  /// tramo 2 = sitio 3 → sitio 4
  final List<TramoRuta> tramos;

  const RutaResultado({
    required this.puntos,
    required this.distanciaMetros,
    required this.duracionSegundos,
    required this.tramos,
  });

  double get distanciaKm => distanciaMetros / 1000;

  double get duracionMinutos => duracionSegundos / 60;
}

class RoutingService {
  static const Duration _tiempoMaximo = Duration(seconds: 30);

  // ============================================================
  // CALCULAR RUTA
  // ============================================================

  /// Calcula una ruta real por carretera.
  ///
  /// Flujo: Flutter -> POST /api/rutas/calcular -> backend -> OSRM.
  ///
  /// Los puntos deben estar en el orden del recorrido:
  ///
  /// origen (opcional) -> sitio 1 -> sitio 2 -> ... -> sitio N
  ///
  /// La geometría devuelta sigue la red vial. Si el servicio de
  /// rutas falla NO se dibuja una línea recta ni se inventan
  /// distancias: se lanza una [RoutingException].
  Future<RutaResultado> calcularRuta(
    List<LatLng> puntos,
  ) async {
    if (puntos.length < 2) {
      throw const RoutingException(
        'Se necesitan al menos dos puntos para calcular una ruta.',
      );
    }

    for (var i = 0; i < puntos.length; i++) {
      final punto = puntos[i];

      final valido = punto.latitude.isFinite &&
          punto.longitude.isFinite &&
          punto.latitude >= -90 &&
          punto.latitude <= 90 &&
          punto.longitude >= -180 &&
          punto.longitude <= 180 &&
          !(punto.latitude == 0 && punto.longitude == 0);

      if (!valido) {
        throw RoutingException(
          'El punto ${i + 1} de la ruta tiene coordenadas inválidas.',
        );
      }
    }

    // ==========================================================
    // SOLICITAR RUTA AL BACKEND
    // ==========================================================

    final http.Response response;

    try {
      response = await http
          .post(
            Uri.parse(ApiConfig.calcularRutaUrl),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'puntos': puntos
                  .map(
                    (punto) => {
                      'latitud': punto.latitude,
                      'longitud': punto.longitude,
                    },
                  )
                  .toList(),
            }),
          )
          .timeout(_tiempoMaximo);
    } on TimeoutException {
      throw const RoutingException(
        'El servicio de rutas tardó demasiado en responder. '
        'Inténtalo de nuevo.',
      );
    } on http.ClientException {
      throw const RoutingException(
        'No hay conexión con el servidor. '
        'Revisa tu conexión e inténtalo de nuevo.',
      );
    } catch (_) {
      throw const RoutingException(
        'No fue posible comunicarse con el servicio de rutas.',
      );
    }

    // ==========================================================
    // DECODIFICAR RESPUESTA
    // ==========================================================

    dynamic decoded;

    try {
      decoded = response.body.trim().isEmpty
          ? null
          : jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode != 200) {
      final mensaje = decoded is Map
          ? (decoded['mensaje'] ?? decoded['message'])
          : null;

      throw RoutingException(
        mensaje?.toString() ??
            'El servicio de rutas respondió con el código '
                '${response.statusCode}.',
      );
    }

    if (decoded is! Map || decoded['ok'] != true) {
      throw const RoutingException(
        'El servicio de rutas devolvió una respuesta inválida.',
      );
    }

    final ruta = decoded['ruta'];

    if (ruta is! Map) {
      throw const RoutingException(
        'El servicio de rutas no devolvió ninguna ruta.',
      );
    }

    // ==========================================================
    // GEOMETRÍA REAL
    // ==========================================================

    final geometria = ruta['geometria'];

    final coordinates =
        geometria is Map ? geometria['coordinates'] : null;

    if (coordinates is! List || coordinates.length < 2) {
      throw const RoutingException(
        'La ruta no contiene una geometría válida.',
      );
    }

    final List<LatLng> puntosRuta = [];

    for (final item in coordinates) {
      if (item is List &&
          item.length >= 2 &&
          item[0] is num &&
          item[1] is num) {
        final longitud = (item[0] as num).toDouble();
        final latitud = (item[1] as num).toDouble();

        if (latitud.isFinite &&
            longitud.isFinite &&
            latitud.abs() <= 90 &&
            longitud.abs() <= 180) {
          puntosRuta.add(LatLng(latitud, longitud));
        }
      }
    }

    if (puntosRuta.length < 2) {
      throw const RoutingException(
        'La geometría de la ruta es insuficiente.',
      );
    }

    // ==========================================================
    // TOTALES
    // ==========================================================

    final distancia = ruta['distancia'];
    final duracion = ruta['duracion'];

    if (distancia is! num || duracion is! num) {
      throw const RoutingException(
        'La ruta no incluye distancia y duración.',
      );
    }

    // ==========================================================
    // TRAMOS
    // ==========================================================
    //
    // Una ruta con N puntos debe tener N - 1 tramos. Si el
    // servidor no los devuelve completos no se inventan.
    // ==========================================================

    final List<TramoRuta> tramos = [];

    final tramosJson = ruta['tramos'];

    if (tramosJson is List) {
      for (var i = 0; i < tramosJson.length; i++) {
        final tramo = tramosJson[i];

        if (tramo is! Map) {
          continue;
        }

        final distanciaTramo = tramo['distancia'];
        final duracionTramo = tramo['duracion'];

        if (distanciaTramo is! num || duracionTramo is! num) {
          continue;
        }

        tramos.add(
          TramoRuta(
            indice: i,
            distanciaMetros: distanciaTramo.toDouble(),
            duracionSegundos: duracionTramo.toDouble(),
          ),
        );
      }
    }

    if (tramos.length != puntos.length - 1) {
      throw const RoutingException(
        'El servidor no devolvió los tramos completos de la ruta. '
        'Verifica que el backend esté actualizado.',
      );
    }

    return RutaResultado(
      puntos: puntosRuta,
      distanciaMetros: distancia.toDouble(),
      duracionSegundos: duracion.toDouble(),
      tramos: tramos,
    );
  }
}
