import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mi_ruta_cafetera/services/usuario/ayuda_usuario_service.dart';

// Pruebas de la validación y del análisis de respuestas de Ayuda y
// soporte. Usan un cliente HTTP simulado (package:http/testing.dart,
// ya incluido en la dependencia http): no tocan red ni el backend.
//
// Los métodos que envían a la red exigen una sesión de usuario; aquí
// solo se prueba lo que no depende de ella.

void main() {
  group('validar', () {
    test('acepta un formulario correcto', () {
      expect(
        AyudaUsuarioService.validar(
          asunto: 'No carga el mapa',
          mensaje: 'Se queda en blanco desde ayer.',
        ),
        isNull,
      );
    });

    test('rechaza asunto vacío, corto o demasiado largo', () {
      for (final asunto in ['', '  ', 'ab', 'a' * 101]) {
        expect(
          AyudaUsuarioService.validar(
            asunto: asunto,
            mensaje: 'Un mensaje suficientemente largo.',
          ),
          ErrorFormularioAyuda.asuntoLongitud,
          reason: 'asunto "$asunto"',
        );
      }
    });

    test('rechaza mensaje corto o demasiado largo', () {
      for (final mensaje in ['', 'corto', ' ' * 20, 'm' * 1001]) {
        expect(
          AyudaUsuarioService.validar(
            asunto: 'Asunto válido',
            mensaje: mensaje,
          ),
          ErrorFormularioAyuda.mensajeLongitud,
          reason: 'mensaje de ${mensaje.length} caracteres',
        );
      }
    });

    test('los límites exactos son válidos y se ignoran los espacios', () {
      expect(
        AyudaUsuarioService.validar(
          asunto: '  ${'a' * 100}  ',
          mensaje: '  ${'m' * 1000}  ',
        ),
        isNull,
      );
    });
  });

  group('ReporteAyuda.desdeJson', () {
    test('interpreta un reporte completo', () {
      final reporte = ReporteAyuda.desdeJson({
        '_id': 'r1',
        'asunto': 'Asunto',
        'mensaje': 'Mensaje',
        'estado': 'resuelto',
        'respuestaAdmin': ' Listo ',
        'createdAt': '2026-10-20T15:30:00.000Z',
      });

      expect(reporte.id, 'r1');
      expect(reporte.estado, 'resuelto');
      expect(reporte.respuestaAdmin, 'Listo');
      expect(reporte.creadoEn, isNotNull);
    });

    test('tolera campos ausentes o nulos', () {
      final reporte = ReporteAyuda.desdeJson({
        'asunto': 'Asunto',
        'respuestaAdmin': null,
        'createdAt': 'no-es-fecha',
      });

      expect(reporte.id, '');
      expect(reporte.estado, 'pendiente');
      expect(reporte.respuestaAdmin, isNull);
      expect(reporte.creadoEn, isNull);
    });
  });

  group('sin sesión', () {
    test('enviar y consultar devuelven 401 sin llamar a la red', () async {
      var llamadas = 0;

      AyudaUsuarioService.clientePruebas = MockClient((http.Request _) async {
        llamadas++;
        return http.Response(jsonEncode({}), 200);
      });

      final envio = await AyudaUsuarioService.enviarReporte(
        asunto: 'Asunto válido',
        mensaje: 'Un mensaje suficientemente largo.',
      );
      final lista = await AyudaUsuarioService.misReportes();

      expect(envio['exito'], false);
      expect(envio['codigo'], 401);
      expect(lista['exito'], false);
      expect(lista['codigo'], 401);
      expect(llamadas, 0);

      AyudaUsuarioService.clientePruebas = null;
    });
  });
}
