import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/sitio/sitio_notificacion_model.dart';
import '../../models/sitio/sitio_reserva_model.dart';
import 'sitio_sesion_service.dart';

class SitioReservasService {
  SitioReservasService._();

  static final SitioReservasService instance =
      SitioReservasService._();

  final SitioSesionService _sesionService = SitioSesionService();

  Future<List<SitioReservaModel>> obtenerReservas() async {
    final sesion = await _sesionService.obtenerSesion();

    if (sesion == null || sesion.token.isEmpty) {
      throw Exception(
        'No hay una sesión activa del sitio. Inicia sesión nuevamente.',
      );
    }

    final sitioId = sesion.sitioId.trim();

    if (sitioId.isEmpty) {
      throw Exception(
        'La sesión no tiene un sitio turístico asociado.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/sitiosturisticos/reservas/'
      '${Uri.encodeComponent(sitioId)}',
    );

    final respuesta = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${sesion.token}',
      },
    );

    final dynamic datos;

    try {
      datos = jsonDecode(respuesta.body);
    } catch (_) {
      throw Exception(
        'El servidor devolvió una respuesta que no es JSON.',
      );
    }

    if (respuesta.statusCode == 401) {
      throw Exception(
        'La sesión ha expirado. Inicia sesión nuevamente.',
      );
    }

    if (respuesta.statusCode == 403) {
      throw Exception(
        'La cuenta no tiene permiso para consultar las reservas de este sitio.',
      );
    }

    if (respuesta.statusCode != 200) {
      final mensaje = datos is Map
          ? datos['mensaje']?.toString()
          : null;

      throw Exception(
        mensaje ?? 'No se pudieron obtener las reservas.',
      );
    }

    if (datos is! List) {
      throw Exception(
        'El servidor no devolvió una lista de reservas.',
      );
    }

    return datos
        .whereType<Map>()
        .map(
          (reserva) => SitioReservaModel.fromJson(
            Map<String, dynamic>.from(reserva),
          ),
        )
        .toList();
  }

  Future<void> actualizarEstado({
    required String reservaId,
    required String estado,
    String motivo = '',
  }) async {
    final sesion = await _sesionService.obtenerSesion();

    if (sesion == null || sesion.token.isEmpty) {
      throw Exception(
        'No hay una sesión activa del sitio.',
      );
    }

    final sitioId = sesion.sitioId.trim();

    if (sitioId.isEmpty) {
      throw Exception(
        'La sesión no tiene un sitio turístico asociado.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/sitiosturisticos/reservas/'
      '${Uri.encodeComponent(sitioId)}/'
      '${Uri.encodeComponent(reservaId)}/estado',
    );

    final respuesta = await http.put(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${sesion.token}',
      },
      body: jsonEncode({
        'estado': estado,
        if (motivo.trim().isNotEmpty) 'motivo': motivo.trim(),
      }),
    );

    if (respuesta.statusCode == 401) {
      throw Exception(
        'La sesión ha expirado. Inicia sesión nuevamente.',
      );
    }

    if (respuesta.statusCode == 403) {
      throw Exception(
        'No tienes permiso para modificar esta reserva.',
      );
    }

    if (respuesta.statusCode != 200) {
      String mensaje = 'No se pudo actualizar la reserva.';

      try {
        final datos = jsonDecode(respuesta.body);

        if (datos is Map && datos['mensaje'] != null) {
          mensaje = datos['mensaje'].toString();
        }
      } catch (_) {}

      throw Exception(mensaje);
    }
  }

  // ============================================================
  // NOTIFICACIONES DEL ESTABLECIMIENTO
  // ============================================================
  //
  // GET /api/sitiosturisticos/reservas/notificaciones
  // PUT /api/sitiosturisticos/reservas/notificaciones/:id/leida
  // ============================================================

  Future<List<SitioNotificacionModel>> obtenerNotificaciones() async {
    final sesion = await _sesionService.obtenerSesion();

    if (sesion == null || sesion.token.isEmpty) {
      throw Exception(
        'No hay una sesión activa del sitio. Inicia sesión nuevamente.',
      );
    }

    final respuesta = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/reservas/notificaciones',
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${sesion.token}',
      },
    );

    if (respuesta.statusCode != 200) {
      throw Exception('No se pudieron obtener las notificaciones.');
    }

    final datos = jsonDecode(respuesta.body);

    if (datos is! List) {
      throw Exception('Respuesta inesperada del servidor.');
    }

    return datos
        .whereType<Map>()
        .map(
          (n) => SitioNotificacionModel.fromJson(
            Map<String, dynamic>.from(n),
          ),
        )
        .toList();
  }

  Future<void> marcarNotificacionLeida(String id) async {
    final sesion = await _sesionService.obtenerSesion();

    if (sesion == null || sesion.token.isEmpty) {
      throw Exception('No hay una sesión activa del sitio.');
    }

    final respuesta = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/reservas/notificaciones/'
        '${Uri.encodeComponent(id)}/leida',
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${sesion.token}',
      },
    );

    if (respuesta.statusCode != 200) {
      throw Exception('No se pudo marcar la notificación.');
    }
  }
}
