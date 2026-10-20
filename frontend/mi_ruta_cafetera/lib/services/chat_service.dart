import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/chat_model.dart';
import '../models/clima_model.dart';
import 'ia_recomendaciones_service.dart';
import 'ubicacion_service.dart';

/// Chat con el asistente (backend: POST /api/chat).
///
/// Requiere la sesión del usuario: el backend rechaza las
/// peticiones sin token. La clave de Groq nunca llega a la app.
/// Los errores se lanzan como [IaException], la misma excepción
/// que usan las recomendaciones de IA.
class ChatService {
  ChatService._();

  /// Turnos previos que se reenvían para dar contexto.
  static const int _maxHistorial = 6;

  // ============================================================
  // ENVIAR MENSAJE A GROQ
  // ============================================================

  static Future<ChatRespuesta> enviar({
    required String token,
    required String mensaje,
    List<ChatMensaje> historial = const [],
    UbicacionUsuario? ubicacion,
    ClimaModel? clima,
  }) async {
    final turnos = historial
        .where((turno) => !turno.esError && turno.texto.isNotEmpty)
        .toList();

    final recientes = turnos.length > _maxHistorial
        ? turnos.sublist(turnos.length - _maxHistorial)
        : turnos;

    final cuerpo = <String, dynamic>{
      'mensaje': mensaje,
      if (recientes.isNotEmpty)
        'historial': recientes
            .map((turno) => turno.toHistorialJson())
            .toList(),
      if (ubicacion != null) 'lat': ubicacion.latitud,
      if (ubicacion != null) 'lng': ubicacion.longitud,
      if (clima != null) 'clima': clima.toJsonIa(),
    };

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.chatUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(cuerpo),
          )
          .timeout(const Duration(seconds: 45));

      final data = _decodificar(response.body);

      if (response.statusCode == 200 && data != null) {
        return ChatRespuesta.fromJson(data);
      }

      final mensajeServidor = data?['mensaje']?.toString();

      if (response.statusCode == 401) {
        throw IaException(
          mensajeServidor ??
              'Tu sesión expiró. Inicia sesión nuevamente.',
          sesionInvalida: true,
        );
      }

      if (response.statusCode == 403) {
        throw IaException(
          mensajeServidor ??
              'El asistente está disponible para usuarios registrados.',
        );
      }

      if (response.statusCode == 429) {
        throw IaException(
          mensajeServidor ??
              'Has enviado muchos mensajes seguidos. '
                  'Intenta de nuevo en unos minutos.',
        );
      }

      throw IaException(
        mensajeServidor ??
            'El asistente no está disponible en este momento '
                '(${response.statusCode}).',
      );
    } on IaException {
      rethrow;
    } on TimeoutException {
      throw const IaException(
        'El asistente tardó demasiado en responder. '
        'Intenta de nuevo.',
      );
    } on http.ClientException {
      throw const IaException(
        'No fue posible conectarse con el servidor.',
      );
    } on FormatException {
      throw const IaException(
        'La respuesta del servidor no tiene el formato esperado.',
      );
    } catch (_) {
      throw const IaException(
        'No fue posible enviar tu mensaje.',
      );
    }
  }

  static Map<String, dynamic>? _decodificar(String cuerpo) {
    if (cuerpo.isEmpty) {
      return null;
    }

    try {
      final data = jsonDecode(cuerpo);

      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }
}
