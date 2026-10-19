import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

import 'package:mi_ruta_cafetera/config/mapa_corredor.dart';
import 'package:mi_ruta_cafetera/controllers/mapa_ruta_controller.dart';
import 'package:mi_ruta_cafetera/data/rutas_predefinidas.dart';
import 'package:mi_ruta_cafetera/models/sitio_turistico_model.dart';
import 'package:mi_ruta_cafetera/services/routing_service.dart';

SitioTuristicoModel sitio(
  String id,
  String ciudad,
  double latitud,
  double longitud, {
  bool activo = true,
}) {
  return SitioTuristicoModel(
    id: id,
    nombre: 'Sitio $id',
    descripcion: '',
    categoria: null,
    direccion: '',
    ciudad: ciudad,
    departamento: 'Huila',
    latitud: latitud,
    longitud: longitud,
    etiquetas: const [],
    activo: activo,
  );
}

/// Servicio de rutas simulado: devuelve un tramo por cada par de
/// puntos y registra los puntos recibidos.
class RoutingFalso extends RoutingService {
  List<LatLng> recibidos = [];
  Object? error;

  @override
  Future<RutaResultado> calcularRuta(List<LatLng> puntos) async {
    recibidos = puntos;

    if (error != null) {
      throw error!;
    }

    return RutaResultado(
      puntos: puntos,
      distanciaMetros: 1000.0 * (puntos.length - 1),
      duracionSegundos: 60.0 * (puntos.length - 1),
      tramos: [
        for (var i = 0; i < puntos.length - 1; i++)
          TramoRuta(
            indice: i,
            distanciaMetros: 1000.0 * (i + 1),
            duracionSegundos: 60.0 * (i + 1),
          ),
      ],
    );
  }
}

void main() {
  group('MapaCorredor', () {
    test('contiene Garzón, Gigante y el centro del corredor', () {
      expect(MapaCorredor.contienePunto(MapaCorredor.garzon), isTrue);
      expect(MapaCorredor.contienePunto(MapaCorredor.gigante), isTrue);
      expect(MapaCorredor.contienePunto(MapaCorredor.centro), isTrue);
    });

    test('rechaza coordenadas erróneas', () {
      expect(MapaCorredor.contiene(0, 0), isFalse);
      // Signo de la longitud perdido: Asia.
      expect(MapaCorredor.contiene(2.19, 75.62), isFalse);
      // Latitud y longitud intercambiadas.
      expect(MapaCorredor.contiene(-75.62, 2.19), isFalse);
      // Cerca del círculo polar.
      expect(MapaCorredor.contiene(60, -160), isFalse);
      expect(MapaCorredor.contiene(double.nan, -75.6), isFalse);
    });

    test('enAreaTuristica del sitio usa el corredor', () {
      expect(sitio('1', 'Garzón', 2.196, -75.6277).enAreaTuristica, isTrue);
      expect(sitio('2', 'X', 2.196, 75.6277).enAreaTuristica, isFalse);
      expect(sitio('3', 'X', 0, 0).enAreaTuristica, isFalse);
    });
  });

  group('MapaRutaController', () {
    late RoutingFalso routing;
    late MapaRutaController controller;

    final a = sitio('a', 'Garzón', 2.196, -75.6277);
    final b = sitio('b', 'Gigante', 2.3866, -75.5459);

    setUp(() {
      routing = RoutingFalso();
      controller = MapaRutaController(routingService: routing);
      controller.iniciar();
      controller.alternarSitio(a);
      controller.alternarSitio(b);
    });

    tearDown(() {
      controller.dispose();
    });

    test('con origen: ruta = origen + sitios, tramo de origen separado', () async {
      const origen = LatLng(2.25, -75.6);

      final ok = await controller.calcularRuta(origen: origen);

      expect(ok, isTrue);
      expect(routing.recibidos.length, 3);
      expect(routing.recibidos.first, origen);
      expect(controller.origen, origen);
      expect(controller.tramoOrigen, isNotNull);
      expect(controller.tramoOrigen!.distanciaMetros, 1000);
      // tramosRuta conserva "un tramo entre cada par de sitios".
      expect(controller.tramosRuta.length, 1);
      expect(controller.tramosRuta.first.indice, 0);
      expect(controller.tramosRuta.first.distanciaMetros, 2000);
      expect(controller.avisoOrigen, isNull);
    });

    test('sin origen: usa solo los sitios y conserva el aviso', () async {
      final ok = await controller.calcularRuta(
        avisoOrigen: 'Permiso denegado',
      );

      expect(ok, isTrue);
      expect(routing.recibidos.length, 2);
      expect(controller.origen, isNull);
      expect(controller.tramoOrigen, isNull);
      expect(controller.tramosRuta.length, 1);
      expect(controller.avisoOrigen, 'Permiso denegado');
    });

    test('el error del servicio no simula una ruta', () async {
      routing.error = const RoutingException('Servicio caído');

      final ok = await controller.calcularRuta();

      expect(ok, isFalse);
      expect(controller.rutaResultado, isNull);
      expect(controller.rutaGuardada, isFalse);
      expect(controller.mensaje, contains('Servicio caído'));
    });

    test('rechaza sitios con coordenadas fuera del corredor', () async {
      controller.iniciar();
      controller.alternarSitio(a);
      controller.alternarSitio(sitio('c', 'X', 2.19, 75.6));

      final ok = await controller.calcularRuta();

      expect(ok, isFalse);
      expect(routing.recibidos, isEmpty);
    });

    test('confirmar muestra la ruta y marcarRutaPersistida evita duplicados', () async {
      await controller.calcularRuta();

      expect(controller.mostrarRutaGuardada, isFalse);
      expect(controller.rutaPersistidaId, isNull);

      controller.confirmarRuta();
      expect(controller.mostrarRutaGuardada, isTrue);

      controller.marcarRutaPersistida(id: 'r1', nombre: 'Mi ruta');
      expect(controller.rutaPersistidaId, 'r1');
      expect(controller.nombreRuta, 'Mi ruta');
    });

    test('cargarRutaGuardada respeta el orden recibido y no guarda nada', () async {
      final ok = await controller.cargarRutaGuardada(
        nombre: 'Guardada',
        sitios: [b, a],
        rutaId: 'xyz',
      );

      expect(ok, isTrue);
      expect(controller.rutaGuardadaSitios.map((s) => s.id).toList(), ['b', 'a']);
      expect(controller.mostrarRutaGuardada, isTrue);
      expect(controller.rutaPersistidaId, 'xyz');
    });

    test('plantilla de corredor: reparte entre municipios en orden y descarta inválidos', () {
      final gigante = [
        sitio('g1', 'Gigante', 2.38, -75.54),
        sitio('g2', 'Gigante', 2.39, -75.55),
        sitio('g3', 'Gigante', 2.40, -75.56),
      ];
      final garzon = [
        sitio('z1', 'Garzón', 2.19, -75.62),
        sitio('z2', 'Garzón', 2.20, -75.63),
      ];
      final invalido = sitio('bad', 'Garzón', 2.19, 75.62);
      final inactivo = sitio('off', 'Garzón', 2.19, -75.62, activo: false);

      final plantilla = RutasPredefinidas.todas.firstWhere(
        (r) => r.id == 'corredor_gigante_garzon',
      );

      final elegidos = controller.seleccionarSitiosParaRutaPredefinida(
        ruta: plantilla,
        sitios: [...garzon, invalido, inactivo, ...gigante],
      );

      expect(elegidos.map((s) => s.id).toList(), ['g1', 'g2', 'z1', 'z2']);
    });

    test('plantilla sin sitios suficientes no inventa ruta', () async {
      final plantilla = RutasPredefinidas.todas.firstWhere(
        (r) => r.id == 'corredor_gigante_garzon',
      );

      final ok = await controller.cargarRutaPredefinida(
        ruta: plantilla,
        sitios: [sitio('solo', 'Gigante', 2.38, -75.54)],
      );

      expect(ok, isFalse);
      expect(controller.rutaResultado, isNull);
    });
  });

  group('RoutingService', () {
    final puntos = [
      const LatLng(2.25, -75.6),
      MapaCorredor.garzon,
      MapaCorredor.gigante,
    ];

    Map<String, dynamic> respuestaOk({int tramos = 2}) => {
          'ok': true,
          'ruta': {
            'distancia': 30000,
            'duracion': 2400,
            'geometria': {
              'type': 'LineString',
              'coordinates': [
                [-75.6, 2.25],
                [-75.62, 2.2],
                [-75.5459, 2.3866],
              ],
            },
            'tramos': [
              for (var i = 0; i < tramos; i++)
                {'distancia': 1000.0 * (i + 1), 'duracion': 100.0},
            ],
          },
        };

    Future<T> conCliente<T>(
      MockClient cliente,
      Future<T> Function() accion,
    ) {
      return http.runWithClient(accion, () => cliente);
    }

    test('lee geometría de carretera, totales y tramos', () async {
      late http.Request recibida;

      final cliente = MockClient((request) async {
        recibida = request;
        return http.Response(jsonEncode(respuestaOk()), 200);
      });

      final r = await conCliente(
        cliente,
        () => RoutingService().calcularRuta(puntos),
      );

      expect(recibida.method, 'POST');
      expect(recibida.url.path, endsWith('/rutas/calcular'));
      expect(jsonDecode(recibida.body)['puntos'].length, 3);
      expect(r.puntos.length, 3);
      expect(r.puntos.first, const LatLng(2.25, -75.6));
      expect(r.distanciaKm, 30);
      expect(r.tramos.length, 2);
    });

    test('muestra el mensaje del servidor en errores HTTP', () async {
      final cliente = MockClient((_) async {
        return http.Response(
          jsonEncode({'ok': false, 'mensaje': 'Sin ruta'}),
          502,
        );
      });

      expect(
        conCliente(cliente, () => RoutingService().calcularRuta(puntos)),
        throwsA(
          isA<RoutingException>().having((e) => e.mensaje, 'mensaje', 'Sin ruta'),
        ),
      );
    });

    test('tramos incompletos no se inventan', () async {
      final cliente = MockClient((_) async {
        return http.Response(jsonEncode(respuestaOk(tramos: 1)), 200);
      });

      expect(
        conCliente(cliente, () => RoutingService().calcularRuta(puntos)),
        throwsA(isA<RoutingException>()),
      );
    });

    test('respuesta sin geometría o no JSON falla', () async {
      for (final cuerpo in ['no es json', jsonEncode({'ok': true, 'ruta': {}})]) {
        final cliente = MockClient((_) async => http.Response(cuerpo, 200));

        await expectLater(
          conCliente(cliente, () => RoutingService().calcularRuta(puntos)),
          throwsA(isA<RoutingException>()),
        );
      }
    });

    test('sin conexión devuelve un mensaje claro', () async {
      final cliente = MockClient((_) async {
        throw http.ClientException('sin red');
      });

      expect(
        conCliente(cliente, () => RoutingService().calcularRuta(puntos)),
        throwsA(
          isA<RoutingException>().having(
            (e) => e.mensaje,
            'mensaje',
            contains('conexión'),
          ),
        ),
      );
    });

    test('coordenadas inválidas se rechazan antes de llamar a la red', () async {
      var llamadas = 0;

      final cliente = MockClient((_) async {
        llamadas++;
        return http.Response('{}', 200);
      });

      await expectLater(
        conCliente(
          cliente,
          () => RoutingService().calcularRuta(
            const [LatLng(0, 0), LatLng(2.2, -75.6)],
          ),
        ),
        throwsA(isA<RoutingException>()),
      );

      expect(llamadas, 0);
    });
  });
}
