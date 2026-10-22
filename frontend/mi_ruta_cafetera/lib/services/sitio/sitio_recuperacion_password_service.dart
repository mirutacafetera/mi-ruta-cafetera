import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

class SitioRecuperacionPasswordService {
  Future<String> solicitarCodigo({
    required String correo,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitios/auth/recuperar-password',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'correo': correo.trim().toLowerCase(),
      }),
    );

    final data = _decodificarRespuesta(response);

    if (response.statusCode == 200) {
      return data['mensaje']?.toString() ??
          'Código de recuperación enviado al correo.';
    }

    throw Exception(
      data['mensaje']?.toString() ??
          'No fue posible solicitar el código.',
    );
  }

  Future<String> verificarCodigo({
    required String correo,
    required String codigo,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitios/auth/verificar-codigo-recuperacion',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'correo': correo.trim().toLowerCase(),
        'codigo': codigo.trim(),
      }),
    );

    final data = _decodificarRespuesta(response);

    if (response.statusCode == 200) {
      final token = data['tokenRecuperacion']?.toString();

      if (token == null || token.isEmpty) {
        throw Exception(
          'El servidor no devolvió el token de recuperación.',
        );
      }

      return token;
    }

    throw Exception(
      data['mensaje']?.toString() ??
          'No fue posible verificar el código.',
    );
  }

  Future<String> restablecerPassword({
    required String tokenRecuperacion,
    required String nuevaPassword,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitios/auth/restablecer-password',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tokenRecuperacion': tokenRecuperacion,
        'nuevaPassword': nuevaPassword,
      }),
    );

    final data = _decodificarRespuesta(response);

    if (response.statusCode == 200) {
      return data['mensaje']?.toString() ??
          'Contraseña restablecida correctamente.';
    }

    throw Exception(
      data['mensaje']?.toString() ??
          'No fue posible restablecer la contraseña.',
    );
  }

  Map<String, dynamic> _decodificarRespuesta(
    http.Response response,
  ) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // La respuesta no contiene JSON válido.
    }

    return {};
  }
}
