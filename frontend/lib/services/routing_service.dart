import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RutaResultado {
  final List<LatLng> puntos;
  final double distanciaMetros;
  final double duracionSegundos;

  const RutaResultado({
    required this.puntos,
    required this.distanciaMetros,
    required this.duracionSegundos,
  });

  double get distanciaKm => distanciaMetros / 1000;

  double get duracionMinutos => duracionSegundos / 60;
}

class RoutingService {
  static const String _baseUrl =
      'https://router.project-osrm.org';

  /// Calcula una ruta real por carretera utilizando OSRM.
  ///
  /// Los puntos deben estar en el orden:
  ///
  /// inicio -> parada 1 -> parada 2 -> destino
  ///
  /// OSRM se encarga de encontrar las calles y carreteras
  /// disponibles entre los puntos.
  Future<RutaResultado> calcularRuta(
    List<LatLng> puntos,
  ) async {
    if (puntos.length < 2) {
      throw Exception(
        'Se necesitan al menos dos puntos para calcular una ruta.',
      );
    }

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

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
          },
        )
        .timeout(
          const Duration(seconds: 20),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'OSRM respondió con código ${response.statusCode}.',
      );
    }

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

    return RutaResultado(
      puntos: puntosRuta,
      distanciaMetros:
          (route['distance'] as num).toDouble(),
      duracionSegundos:
          (route['duration'] as num).toDouble(),
    );
  }
}