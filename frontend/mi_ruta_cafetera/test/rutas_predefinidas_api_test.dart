import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mi_ruta_cafetera/controllers/mapa_ruta_controller.dart';
import 'package:mi_ruta_cafetera/models/ruta_model.dart';
import 'package:mi_ruta_cafetera/models/sitio_turistico_model.dart';
import 'package:mi_ruta_cafetera/services/routing_service.dart';
import 'package:mi_ruta_cafetera/widgets/mapa/mapa_estado_ruta.dart';

SitioTuristicoModel sitio(
  String id,
  double latitud,
  double longitud,
) {
  return SitioTuristicoModel(
    id: id,
    nombre: 'Sitio $id',
    descripcion: '',
    categoria: null,
    direccion: '',
    ciudad: 'Garzón',
    departamento: 'Huila',
    latitud: latitud,
    longitud: longitud,
    etiquetas: const [],
    activo: true,
  );
}

/// Servicio de rutas simulado: un tramo por cada par de puntos.
class RoutingFalso extends RoutingService {
  List<LatLng> recibidos = [];

  @override
  Future<RutaResultado> calcularRuta(List<LatLng> puntos) async {
    recibidos = puntos;

    return RutaResultado(
      puntos: puntos,
      distanciaMetros: 1000.0 * (puntos.length - 1),
      duracionSegundos: 600.0 * (puntos.length - 1),
      tramos: [
        for (var i = 0; i < puntos.length - 1; i++)
          TramoRuta(
            indice: i,
            distanciaMetros: 1000.0,
            duracionSegundos: 600.0,
          ),
      ],
    );
  }
}

Map<String, dynamic> jsonRuta(List<String> ids, {List<int?>? minutos}) {
  return {
    '_id': 'ruta1',
    'nombre': 'Ruta de prueba',
    'descripcion': 'Descripción',
    'tipo': 'predefinida',
    'activa': true,
    'tipoExperiencia': 'cafetera',
    'duracionPlanificadaMin': 300,
    // sitios populados, como los devuelve la API.
    'sitios': [
      for (final id in ids) {'_id': id, 'nombre': 'Sitio $id'},
    ],
    // Se entregan desordenadas a propósito.
    'paradas': [
      for (var i = ids.length - 1; i >= 0; i--)
        {
          'sitio': {'_id': ids[i], 'nombre': 'Sitio ${ids[i]}'},
          'orden': i + 1,
          'tipoActividad': 'cafe',
          'duracionMin': minutos == null ? 60 : minutos[i],
        },
    ],
  };
}

void main() {
  final ids = ['a', 'b', 'c', 'd', 'e'];
  final sitios = [
    sitio('a', 2.26, -75.57),
    sitio('b', 2.20, -75.60),
    sitio('c', 2.19, -75.62),
    sitio('d', 2.17, -75.65),
    sitio('e', 2.15, -75.69),
  ];

  group('RutaModel con itinerario', () {
    test('lee paradas ordenadas y duraciones', () {
      final ruta = RutaModel.fromJson(jsonRuta(ids));

      expect(ruta.tipo, 'predefinida');
      expect(ruta.sitios, ids);
      expect(ruta.paradas.map((p) => p.sitioId).toList(), ids);
      expect(ruta.paradas.map((p) => p.orden).toList(), [1, 2, 3, 4, 5]);
      expect(ruta.paradas.first.duracionMin, 60);
      expect(ruta.tipoExperiencia, 'cafetera');
      expect(ruta.duracionPlanificadaMin, 300);
    });

    test('una ruta personal sin paradas sigue funcionando', () {
      final ruta = RutaModel.fromJson({
        '_id': 'p1',
        'nombre': 'Mi ruta',
        'tipo': 'personalizada',
        'sitios': ['a', 'b'],
      });

      expect(ruta.paradas, isEmpty);
      expect(ruta.sitios, ['a', 'b']);
      expect(ruta.duracionPlanificadaMin, isNull);
    });
  });

  group('MapaRutaController con rutas predefinidas de la API', () {
    late RoutingFalso routing;
    late MapaRutaController controller;

    setUp(() {
      routing = RoutingFalso();
      controller = MapaRutaController(routingService: routing);
    });

    tearDown(() {
      controller.dispose();
    });

    test('devuelve los sitios en el orden de las paradas', () {
      final ruta = RutaModel.fromJson(jsonRuta(ids));

      final resultado = controller.sitiosDeRutaApi(
        ruta: ruta,
        sitios: sitios.reversed.toList(),
      );

      expect(resultado.map((s) => s.id).toList(), ids);
    });

    test('si falta un sitio, la ruta no se muestra incompleta', () {
      final ruta = RutaModel.fromJson(jsonRuta(ids));

      final resultado = controller.sitiosDeRutaApi(
        ruta: ruta,
        sitios: sitios.take(4).toList(),
      );

      expect(resultado, isEmpty);
    });

    test('seleccionarRutaApi admite más de 4 sitios y marca la ruta', () async {
      final ruta = RutaModel.fromJson(jsonRuta(ids));

      final ok = await controller.seleccionarRutaApi(
        ruta: ruta,
        sitios: sitios,
      );

      expect(ok, isTrue);
      expect(controller.sitiosSeleccionados.length, 5);
      expect(controller.esRutaPredefinida, isTrue);
      expect(controller.nombreRuta, 'Ruta de prueba');
    });

    test('cargarRutaApi con origen: no recorta, separa viaje y actividad', () async {
      final ruta = RutaModel.fromJson(jsonRuta(ids));
      const origen = LatLng(2.30, -75.55);

      final ok = await controller.cargarRutaApi(
        ruta: ruta,
        sitios: sitios,
        origen: origen,
      );

      expect(ok, isTrue);
      expect(routing.recibidos.length, 6);
      expect(routing.recibidos.first, origen);
      expect(controller.rutaGuardadaSitios.length, 5);
      expect(controller.tramoOrigen, isNotNull);
      expect(controller.tramosRuta.length, 4);
      expect(controller.esRutaPredefinida, isTrue);

      // Viaje (5 tramos de 10 min) y actividad (5 x 60 min) separados.
      expect(controller.duracionTotalMinutos, 50);
      expect(controller.duracionActividadesMinutos, 300);
      expect(controller.minutosActividadDeSitio('a'), 60);
    });

    test('cargarRutaApi sin origen conserva el aviso y no inventa un punto', () async {
      final ruta = RutaModel.fromJson(jsonRuta(ids));

      final ok = await controller.cargarRutaApi(
        ruta: ruta,
        sitios: sitios,
        avisoOrigen: 'Permiso denegado',
      );

      expect(ok, isTrue);
      expect(routing.recibidos.length, 5);
      expect(controller.origen, isNull);
      expect(controller.avisoOrigen, 'Permiso denegado');
    });

    test('el límite de 4 sitios se mantiene en rutas personales', () {
      controller.iniciar();

      for (var i = 0; i < MapaEstadoRuta.maxSitios; i++) {
        expect(controller.alternarSitio(sitios[i]), isTrue);
      }

      expect(controller.alternarSitio(sitios[4]), isFalse);
      expect(controller.esRutaPredefinida, isFalse);
    });

    test('una ruta personal posterior limpia el itinerario', () async {
      final ruta = RutaModel.fromJson(jsonRuta(ids));

      await controller.cargarRutaApi(ruta: ruta, sitios: sitios);
      expect(controller.duracionActividadesMinutos, 300);

      controller.iniciar();

      expect(controller.esRutaPredefinida, isFalse);
      expect(controller.duracionActividadesMinutos, isNull);
    });
  });
}
