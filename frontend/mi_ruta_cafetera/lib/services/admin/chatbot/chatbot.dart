
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../models/admin/mensaje_chatbot.dart';

class ChatbotServicio {
  ChatbotServicio._();

  static Future<MensajeChatbot> enviarMensaje({
    required String mensaje,
    required String token,
  }) async {
    final tokenLimpio = token.trim();
    final mensajeLimpio = mensaje.trim();

    if (tokenLimpio.isEmpty) {
      throw Exception(
        'No se encontró el token del administrador. '
        'Inicia sesión nuevamente.',
      );
    }

    if (mensajeLimpio.isEmpty) {
      throw Exception('Escribe un mensaje antes de enviarlo.');
    }

    // ApiConfig.baseUrl ya incluye /api.
    // La ruta protegida del administrador es /api/admin/chatbot.
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/admin/chatbot',
    );

    try {
      final respuesta = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $tokenLimpio',
            },
            body: jsonEncode({
              'mensaje': mensajeLimpio,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final dynamic resultado = jsonDecode(respuesta.body);

      if (resultado is! Map<String, dynamic>) {
        throw Exception(
          'El servidor devolvió una respuesta inválida.',
        );
      }

      if (respuesta.statusCode >= 200 &&
          respuesta.statusCode < 300) {
        final contenido = resultado['respuesta'];

        if (contenido == null ||
            contenido.toString().trim().isEmpty) {
          throw Exception(
            'El chatbot no devolvió una respuesta.',
          );
        }

        return MensajeChatbot.asistente(
          contenido.toString(),
        );
      }

      if (respuesta.statusCode == 401 ||
          respuesta.statusCode == 403) {
        throw Exception(
          'Tu sesión no es válida o no tienes permisos '
          'de administrador. Inicia sesión nuevamente.',
        );
      }

      throw Exception(
        resultado['mensaje']?.toString() ??
            'Error del servidor: ${respuesta.statusCode}',
      );
    
    } on FormatException {
      throw Exception(
        'El servidor devolvió una respuesta inválida.',
      );
    } on http.ClientException {
      throw Exception(
        'No fue posible conectar con el servidor.',
      );
    }
  }
}

