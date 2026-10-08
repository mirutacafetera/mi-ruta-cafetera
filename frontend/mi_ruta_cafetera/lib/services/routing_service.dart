import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

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
  static const String _baseUrl =
      'https://router.project-osrm.org';

  // ============================================================
  // CALCULAR RUTA
  // ============================================================

  /// Calcula una ruta real por carretera utilizando OSRM.
  ///
  /// Los puntos deben estar en el orden:
  ///
  /// inicio -> parada 1 -> parada 2 -> destino
  ///
  /// OSRM encuentra las calles y carreteras disponibles
  /// entre los puntos.
  Future<RutaResultado> calcularRuta(
    List<LatLng> puntos,
  ) async {
    if (puntos.length < 2) {
      throw Exception(
        'Se necesitan al menos dos puntos para calcular una ruta.',
      );
    }

    // ==========================================================
    // CONSTRUIR COORDENADAS PARA OSRM
    // ==========================================================

    final coordenadas = puntos
        .map(
          (punto) =>
              '${punto.longitude},${punto.latitude}',
        )
        .join(';');

    final uri = Uri.parse(
      '$_baseUrl/route/v1/driving/$coordenadas'
      '?overview=full'
      '&geometries=geojson'
      '&steps=true',
    );

    // ==========================================================
    // SOLICITAR RUTA
    // ==========================================================

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
          },
        )
        .timeout(
          const Duration(
            seconds: 20,
          ),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'OSRM respondió con código '
        '${response.statusCode}.',
      );
    }

    // ==========================================================
    // PROCESAR RESPUESTA
    // ==========================================================

    final Map<String, dynamic> data =
        jsonDecode(response.body);

    if (data['code'] != 'Ok') {
      throw Exception(
        'No fue posible calcular la ruta.',
      );
    }

    final routes = data['routes'];

    if (routes is! List || routes.isEmpty) {
      throw Exception(
        'OSRM no devolvió ninguna ruta.',
      );
    }

    final route =
        Map<String, dynamic>.from(routes.first);

    // ==========================================================
    // OBTENER GEOMETRÍA
    // ==========================================================

    final geometry = route['geometry'];

    if (geometry is! Map) {
      throw Exception(
        'La respuesta de OSRM no contiene geometría.',
      );
    }

    final coordinates =
        geometry['coordinates'];

    if (coordinates is! List ||
        coordinates.isEmpty) {
      throw Exception(
        'La ruta no contiene coordenadas.',
      );
    }

    // ==========================================================
    // CONVERTIR COORDENADAS A LATLNG
    // ==========================================================

    final List<LatLng> puntosRuta = [];

    for (final item in coordinates) {
      if (item is List && item.length >= 2) {
        final longitude =
            (item[0] as num).toDouble();

        final latitude =
            (item[1] as num).toDouble();

        puntosRuta.add(
          LatLng(
            latitude,
            longitude,
          ),
        );
      }
    }

    if (puntosRuta.length < 2) {
      throw Exception(
        'La geometría de la ruta es insuficiente.',
      );
    }

    // ==========================================================
    // OBTENER TRAMOS
    // ==========================================================

    final List<TramoRuta> tramos = [];

    final legs = route['legs'];

    if (legs is List) {
      for (
        var i = 0;
        i < legs.length;
        i++
      ) {
        final leg = legs[i];

        if (leg is! Map) {
          continue;
        }

        final distancia =
            leg['distance'];

        final duracion =
            leg['duration'];

        if (distancia is! num ||
            duracion is! num) {
          continue;
        }

        tramos.add(
          TramoRuta(
            indice: i,
            distanciaMetros:
                distancia.toDouble(),
            duracionSegundos:
                duracion.toDouble(),
          ),
        );
      }
    }

    // ==========================================================
    // VALIDAR TRAMOS
    // ==========================================================

    //
    // Una ruta con N puntos debe tener N - 1 tramos.
    //
    // Si OSRM no devuelve los legs correctamente, no
    // inventamos distancias ni tiempos.
    //
    final cantidadTramosEsperada =
        puntos.length - 1;

    if (tramos.length != cantidadTramosEsperada) {
      throw Exception(
        'OSRM no devolvió los tramos completos '
        'de la ruta.',
      );
    }

    // ==========================================================
    // RESULTADO
    // ==========================================================

    return RutaResultado(
      puntos: puntosRuta,
      distanciaMetros:
          (route['distance'] as num).toDouble(),
      duracionSegundos:
          (route['duration'] as num).toDouble(),
      tramos: tramos,
    );
  }
}