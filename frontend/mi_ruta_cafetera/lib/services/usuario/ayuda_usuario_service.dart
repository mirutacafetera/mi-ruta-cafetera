import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import 'usuario_sesion_service.dart';

// ============================================================
// AYUDA Y SOPORTE DEL USUARIO
// ============================================================
//
// Usa los endpoints existentes del backend (requieren sesión de
// usuario; la identidad sale del token, nunca se envía un id):
//
//   POST /ayuda   body: { asunto, mensaje }
//   GET  /ayuda   → lista de MIS reportes
//
// Los métodos devuelven un mapa con:
//   exito   bool
//   mensaje String
//   codigo  int?  (status HTTP: 400 datos, 401 sesión, 409
//                  reporte repetido, 429 demasiados envíos)
// ============================================================

/// Problema detectado al validar el formulario antes de enviarlo.
/// Los límites son los mismos que valida el servidor.
enum ErrorFormularioAyuda {
  asuntoLongitud,
  mensajeLongitud,
}

/// Un reporte de ayuda del usuario.
class ReporteAyuda {
  const ReporteAyuda({
    required this.id,
    required this.asunto,
    required this.mensaje,
    required this.estado,
    required this.respuestaAdmin,
    required this.creadoEn,
  });

  final String id;
  final String asunto;
  final String mensaje;

  /// pendiente | en_revision | resuelto
  final String estado;

  final String? respuestaAdmin;
  final DateTime? creadoEn;

  factory ReporteAyuda.desdeJson(Map<String, dynamic> json) {
    final respuesta = json['respuestaAdmin'];

    return ReporteAyuda(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      asunto: (json['asunto'] ?? '').toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      estado: (json['estado'] ?? 'pendiente').toString(),
      respuestaAdmin: respuesta is String && respuesta.trim().isNotEmpty
          ? respuesta.trim()
          : null,
      creadoEn: DateTime.tryParse((json['createdAt'] ?? '').toString())
          ?.toLocal(),
    );
  }
}

class AyudaUsuarioService {
  AyudaUsuarioService._();

  static const int asuntoMin = 3;
  static const int asuntoMax = 100;
  static const int mensajeMin = 10;
  static const int mensajeMax = 1000;

  /// Cliente HTTP reemplazable en pruebas.
  @visibleForTesting
  static http.Client? clientePruebas;

  static final http.Client _clienteReal = http.Client();

  static http.Client get _cliente => clientePruebas ?? _clienteReal;

  /// Valida el formulario con los mismos límites del servidor.
  /// Devuelve null si todo está bien.
  static ErrorFormularioAyuda? validar({
    required String asunto,
    required String mensaje,
  }) {
    final largoAsunto = asunto.trim().length;
    final largoMensaje = mensaje.trim().length;

    if (largoAsunto < asuntoMin || largoAsunto > asuntoMax) {
      return ErrorFormularioAyuda.asuntoLongitud;
    }

    if (largoMensaje < mensajeMin || largoMensaje > mensajeMax) {
      return ErrorFormularioAyuda.mensajeLongitud;
    }

    return null;
  }

  static Map<String, String> _cabeceras(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // ENVIAR REPORTE
  // ============================================================

  static Future<Map<String, dynamic>> enviarReporte({
    required String asunto,
    required String mensaje,
  }) async {
    final sesion = UsuarioSesionService.instance.sesionActual.value;

    if (sesion == null) {
      return _sinSesion();
    }

    try {
      final response = await _cliente
          .post(
            Uri.parse('${ApiConfig.baseUrl}/ayuda'),
            headers: _cabeceras(sesion.token),
            body: jsonEncode({
              'asunto': asunto.trim(),
              'mensaje': mensaje.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = _decodificar(response.body);

      if (response.statusCode == 201) {
        return {
          'exito': true,
          'mensaje': (data['mensaje'] ?? '').toString(),
          'codigo': response.statusCode,
        };
      }

      return _fallo(
        response.statusCode,
        data,
        'No fue posible enviar el reporte.',
      );
    } catch (e) {
      debugPrint('Error enviando reporte de ayuda: $e');
      return _errorConexion(e);
    }
  }

  // ============================================================
  // MIS REPORTES
  // ============================================================

  static Future<Map<String, dynamic>> misReportes() async {
    final sesion = UsuarioSesionService.instance.sesionActual.value;

    if (sesion == null) {
      return _sinSesion();
    }

    try {
      final response = await _cliente
          .get(
            Uri.parse('${ApiConfig.baseUrl}/ayuda'),
            headers: _cabeceras(sesion.token),
          )
          .timeout(const Duration(seconds: 15));

      final decodificado = _decodificarLibre(response.body);

      if (response.statusCode == 200 && decodificado is List) {
        final reportes = decodificado
            .whereType<Map>()
            .map(
              (item) => ReporteAyuda.desdeJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

        return {
          'exito': true,
          'mensaje': '',
          'codigo': response.statusCode,
          'reportes': reportes,
        };
      }

      return _fallo(
        response.statusCode,
        decodificado is Map<String, dynamic> ? decodificado : const {},
        'No fue posible cargar tus reportes.',
      );
    } catch (e) {
      debugPrint('Error consultando reportes de ayuda: $e');
      return _errorConexion(e);
    }
  }

  // ============================================================
  // AUXILIARES
  // ============================================================

  static dynamic _decodificarLibre(String cuerpo) {
    try {
      return jsonDecode(cuerpo);
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  static Map<String, dynamic> _decodificar(String cuerpo) {
    final data = _decodificarLibre(cuerpo);
    return data is Map<String, dynamic> ? data : const {};
  }

  static Map<String, dynamic> _fallo(
    int codigo,
    Map<String, dynamic> data,
    String porDefecto,
  ) {
    return {
      'exito': false,
      'mensaje': (data['mensaje'] ?? porDefecto).toString(),
      'codigo': codigo,
    };
  }

  static Map<String, dynamic> _sinSesion() {
    return {
      'exito': false,
      'mensaje': 'Debes iniciar sesión para continuar.',
      'codigo': 401,
    };
  }

  static Map<String, dynamic> _errorConexion(Object error) {
    String mensaje = 'No se pudo completar la operación.';

    if (error is http.ClientException) {
      mensaje = 'No se pudo conectar con el servidor. '
          'Verifica que el backend esté funcionando.';
    } else if (error is FormatException) {
      mensaje = 'El servidor devolvió una respuesta no válida.';
    } else if (error is Exception) {
      mensaje = 'Ocurrió un problema durante la solicitud. '
          'Inténtalo nuevamente.';
    }

    return {
      'exito': false,
      'mensaje': mensaje,
      'codigo': 0,
    };
  }
}
