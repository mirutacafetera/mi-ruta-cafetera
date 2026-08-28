import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../config/api_config.dart';
import '../models/sitio_turistico_model.dart';

class RutaResultado {
  final List<LatLng> puntos;
  final double distanciaMetros;
  final double duracionSegundos;

  const RutaResultado({
    required this.puntos,
    required this.distanciaMetros,
    required this.duracionSegundos,
  });

  double get distanciaKm {
    return distanciaMetros / 1000;
  }

  double get duracionMinutos {
    return duracionSegundos / 60;
  }
}

class RoutingService {
  Future<RutaResultado> calcularRuta(
    List<SitioTuristicoModel> sitios,
  ) async {
    if (sitios.length < 2) {
      throw Exception(
        'Se necesitan mínimo 2 sitios.',
      );
    }

    final puntos = sitios.map(
      (sitio) => {
        'latitud': sitio.latitud,
        'longitud': sitio.longitud,
      },
    ).toList();

    final response = await http
        .post(
          Uri.parse(
            ApiConfig.calcularRutaUrl,
          ),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'puntos': puntos,
          }),
        )
        .timeout(
          const Duration(seconds: 60),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'El servidor respondió '
        '${response.statusCode}: '
        '${response.body}',
      );
    }

    final dynamic decoded =
        jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Respuesta inválida del servidor.',
      );
    }

    final data =
        Map<String, dynamic>.from(decoded);

    if (data['ok'] != true) {
      throw Exception(
        data['mensaje']?.toString() ??
            'No fue posible calcular la ruta.',
      );
    }

    final dynamic rutaData =
        data['ruta'];

    if (rutaData is! Map) {
      throw Exception(
        'El servidor no devolvió la ruta.',
      );
    }

    final ruta =
        Map<String, dynamic>.from(rutaData);

    final dynamic geometria =
        ruta['geometria'] ??
        ruta['geometry'];

    if (geometria is! Map) {
      throw Exception(
        'La ruta no contiene geometría.',
      );
    }

    final dynamic coordinates =
        geometria['coordinates'];

    if (coordinates is! List) {
      throw Exception(
        'La geometría no contiene coordenadas.',
      );
    }

    final List<LatLng> puntosRuta = [];

    for (final item in coordinates) {
      if (item is List && item.length >= 2) {
        final longitud =
            _toDouble(item[0]);

        final latitud =
            _toDouble(item[1]);

        if (_coordenadaValida(
          latitud,
          longitud,
        )) {
          puntosRuta.add(
            LatLng(
              latitud,
              longitud,
            ),
          );
        }
      }
    }

    if (puntosRuta.length < 2) {
      throw Exception(
        'La geometría de carretera es insuficiente.',
      );
    }

    return RutaResultado(
      puntos: puntosRuta,
      distanciaMetros: _toDouble(
        ruta['distancia'] ??
            ruta['distance'],
      ),
      duracionSegundos: _toDouble(
        ruta['duracion'] ??
            ruta['duration'],
      ),
    );
  }

  double _toDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }

  bool _coordenadaValida(
    double latitud,
    double longitud,
  ) {
    return latitud >= -90 &&
        latitud <= 90 &&
        longitud >= -180 &&
        longitud <= 180 &&
        !(latitud == 0 && longitud == 0);
  }
}