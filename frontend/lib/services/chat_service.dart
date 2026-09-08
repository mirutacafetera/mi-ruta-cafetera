import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ChatService {
  // ============================================================
  // URL DEL CHAT
  // ============================================================

  static String get chatUrl {
    return ApiConfig.chatUrl;
  }

  // ============================================================
  // ENVIAR MENSAJE A GROQ
  // ============================================================

  static Future<String> enviarMensaje(String mensaje) async {
    try {
      final response = await http
          .post(
            Uri.parse(chatUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'mensaje': mensaje,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
          );

      // ==========================================================
      // RESPUESTA EXITOSA
      // ==========================================================

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body.isEmpty) {
          throw Exception(
            'El servidor no devolvió ninguna respuesta.',
          );
        }

        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          final respuesta = data['respuesta'];

          if (respuesta != null &&
              respuesta.toString().trim().isNotEmpty) {
            return respuesta.toString();
          }
        }

        throw Exception(
          'La respuesta del servidor no tiene el formato esperado.',
        );
      }

      // ==========================================================
      // ERROR DEL BACKEND
      // ==========================================================

      String mensajeError =
          'Error del servidor (${response.statusCode})';

      try {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          if (data['mensaje'] != null) {
            mensajeError =
                data['mensaje'].toString();
          } else if (data['error'] != null) {
            mensajeError =
                data['error'].toString();
          }
        }
      } catch (_) {
        // Si la respuesta no es JSON,
        // conservamos el mensaje genérico.
      }

      throw Exception(mensajeError);
    } on http.ClientException {
      throw Exception(
        'No fue posible conectarse con el servidor.',
      );
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
          'El servidor tardó demasiado en responder.',
        );
      }

      rethrow;
    }
  }
}