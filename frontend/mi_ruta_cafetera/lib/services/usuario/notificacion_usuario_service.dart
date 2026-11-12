import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/usuario/notificacion_usuario_model.dart';
import 'usuario_sesion_service.dart';

/// Notificaciones del usuario con sesión.
///
/// Usa los endpoints de /api/notificaciones (requieren token).
/// [noLeidas] alimenta el contador de la campana.
class NotificacionUsuarioService {
  NotificacionUsuarioService._();

  static final NotificacionUsuarioService instance =
      NotificacionUsuarioService._();

  final ValueNotifier<int> noLeidas = ValueNotifier<int>(0);

  static const Duration _tiempoMaximo = Duration(seconds: 10);

  String? get _token =>
      UsuarioSesionService.instance.sesionActual.value?.token;

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Uri _uri(String ruta) =>
      Uri.parse('${ApiConfig.baseUrl}/notificaciones$ruta');

  // ============================================================
  // LISTAR
  // ============================================================

  Future<List<NotificacionUsuarioModel>> obtener() async {
    final token = _token;

    if (token == null) {
      return [];
    }

    final response = await http
        .get(_uri(''), headers: _headers(token))
        .timeout(_tiempoMaximo);

    final decoded = _decodificar(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        decoded is Map
            ? (decoded['mensaje'] ?? 'No se pudieron cargar las notificaciones')
                .toString()
            : 'No se pudieron cargar las notificaciones',
      );
    }

    if (decoded is! List) {
      return [];
    }

    final lista = <NotificacionUsuarioModel>[];

    for (final item in decoded) {
      if (item is Map) {
        lista.add(
          NotificacionUsuarioModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        );
      }
    }

    noLeidas.value = lista.where((n) => !n.leida).length;

    return lista;
  }

  // ============================================================
  // CONTADOR DE NO LEÍDAS
  // ============================================================

  Future<void> actualizarContador() async {
    final token = _token;

    if (token == null) {
      noLeidas.value = 0;
      return;
    }

    try {
      final response = await http
          .get(_uri('/no-leidas/total'), headers: _headers(token))
          .timeout(_tiempoMaximo);

      if (response.statusCode != 200) {
        return;
      }

      final decoded = _decodificar(response.body);

      if (decoded is Map) {
        noLeidas.value =
            int.tryParse(decoded['total']?.toString() ?? '') ?? 0;
      }
    } catch (_) {
      // Sin conexión: se conserva el último valor.
    }
  }

  // ============================================================
  // MARCAR COMO LEÍDA
  // ============================================================

  Future<void> marcarLeida(String id) async {
    final token = _token;

    if (token == null) {
      return;
    }

    final response = await http
        .put(_uri('/$id/leida'), headers: _headers(token))
        .timeout(_tiempoMaximo);

    if (response.statusCode != 200) {
      throw Exception('No se pudo marcar la notificación');
    }

    if (noLeidas.value > 0) {
      noLeidas.value = noLeidas.value - 1;
    }
  }

  Future<void> marcarTodasLeidas() async {
    final token = _token;

    if (token == null) {
      return;
    }

    final response = await http
        .put(_uri('/leidas/todas'), headers: _headers(token))
        .timeout(_tiempoMaximo);

    if (response.statusCode != 200) {
      throw Exception('No se pudieron marcar las notificaciones');
    }

    noLeidas.value = 0;
  }

  /// Se llama al cerrar sesión.
  void limpiar() {
    noLeidas.value = 0;
  }

  dynamic _decodificar(String cuerpo) {
    if (cuerpo.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(cuerpo);
    } catch (_) {
      return null;
    }
  }
}
