import 'package:flutter_test/flutter_test.dart';
import 'package:mi_ruta_cafetera/models/sitio/sitio_notificacion_model.dart';
import 'package:mi_ruta_cafetera/models/sitio/sitio_reserva_model.dart';
import 'package:mi_ruta_cafetera/models/usuario/reserva_usuario_model.dart';

void main() {
  group('ReservaUsuarioModel', () {
    test('lee una reserva con sitio y actividad poblados', () {
      final r = ReservaUsuarioModel.fromJson({
        '_id': 'r1',
        'sitio': {'_id': 's1', 'nombre': 'Finca La Esperanza'},
        'actividad': {'_id': 'a1', 'nombre': 'Tour del café'},
        'fecha': '2026-11-01T17:00:00.000Z',
        'cantidadPersonas': 3,
        'precioUnitario': 50000,
        'precioTotal': 150000,
        'estado': 'Confirmada',
        'observaciones': 'Con niños',
        'respuestaSitio': 'Te llamaremos',
      });

      expect(r.id, 'r1');
      expect(r.nombreSitio, 'Finca La Esperanza');
      expect(r.nombreActividad, 'Tour del café');
      expect(r.cantidadPersonas, 3);
      expect(r.precioTotal, 150000);
      expect(r.estado, 'confirmada');
      expect(r.estadoLegible, 'Confirmada');
      expect(r.sePuedeCancelar, isTrue);
      expect(r.respuestaSitio, 'Te llamaremos');
    });

    test('usa el nombre guardado de la actividad y tolera ids sueltos', () {
      final r = ReservaUsuarioModel.fromJson({
        '_id': 'r2',
        'sitio': 's1',
        'actividad': 'a1',
        'actividadNombre': 'Cabalgata',
      });

      expect(r.nombreActividad, 'Cabalgata');
      expect(r.sitioId, 's1');
      expect(r.actividadId, 'a1');
      expect(r.estado, 'pendiente');
      expect(r.cantidadPersonas, 0);
    });

    test('solo se cancelan las pendientes o confirmadas', () {
      for (final estado in ['rechazada', 'cancelada', 'completada']) {
        final r = ReservaUsuarioModel.fromJson({'_id': 'x', 'estado': estado});
        expect(r.sePuedeCancelar, isFalse, reason: estado);
      }
    });
  });

  group('SitioReservaModel', () {
    test('lee el nuevo estado rechazada, el nombre guardado y la respuesta',
        () {
      final r = SitioReservaModel.fromJson({
        '_id': 'r3',
        'usuario': {'nombre': 'Ana', 'correo': 'ana@correo.com'},
        'actividad': {'nombre': 'Original'},
        'actividadNombre': 'Nombre guardado',
        'estado': 'rechazada',
        'respuestaSitio': 'Sin cupo',
        'cantidadPersonas': 2,
      });

      expect(r.estado, 'rechazada');
      expect(r.nombreActividad, 'Nombre guardado');
      expect(r.respuestaSitio, 'Sin cupo');
      expect(r.cantidadPersonas, 2);
    });
  });

  group('SitioNotificacionModel', () {
    test('lee una notificación de reserva nueva', () {
      final n = SitioNotificacionModel.fromJson({
        '_id': 'n1',
        'titulo': 'Nueva solicitud de reserva',
        'mensaje': 'Tour: 2 personas',
        'tipo': 'reserva_nueva',
        'leida': false,
        'reserva': 'r1',
        'createdAt': '2026-10-19T15:00:00.000Z',
      });

      expect(n.id, 'n1');
      expect(n.leida, isFalse);
      expect(n.reservaId, 'r1');
      expect(n.creadaEn, isNotNull);
    });
  });
}
