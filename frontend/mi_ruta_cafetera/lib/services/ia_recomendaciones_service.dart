import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/clima_model.dart';
import '../models/ia_recomendacion_model.dart';
import 'ubicacion_service.dart';

/// Error legible para el usuario.
class IaException implements Exception {
  final String mensaje;

  /// True cuando el token venció o no es válido.
  final bool sesionInvalida;

  const IaException(
    this.mensaje, {
    this.sesionInvalida = false,
  });

  @override
  String toString() => mensaje;
}

/// Pide recomendaciones al backend (POST /api/v1/ai/recommendations).
///
/// La clave de Groq nunca llega a la app: solo se envía el token
/// de sesión del usuario.
class IaRecomendacionesService {
  IaRecomendacionesService._();

  static Future<IaRespuesta> obtener({
    required String token,
    UbicacionUsuario? ubicacion,
    ClimaModel? clima,
    String? categoria,
  }) async {
    final cuerpo = <String, dynamic>{
      'hora': DateTime.now().toUtc().toIso8601String(),
      if (ubicacion != null) 'lat': ubicacion.latitud,
      if (ubicacion != null) 'lng': ubicacion.longitud,
      if (clima != null) 'clima': clima.toJsonIa(),
      if (categoria != null && categoria.isNotEmpty)
        'categoria': categoria,
    };

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.recomendacionesIaUrl),
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
        return IaRespuesta.fromJson(data);
      }

      final mensaje = data?['mensaje']?.toString();

      if (response.statusCode == 401) {
        throw IaException(
          mensaje ?? 'Tu sesión expiró. Inicia sesión nuevamente.',
          sesionInvalida: true,
        );
      }

      if (response.statusCode == 429) {
        throw IaException(
          mensaje ??
              'Has pedido muchas recomendaciones seguidas. '
                  'Intenta de nuevo en unos minutos.',
        );
      }

      throw IaException(
        mensaje ??
            'No fue posible obtener recomendaciones '
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
        'No fue posible obtener recomendaciones.',
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