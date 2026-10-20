import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/usuario/reserva_usuario_model.dart';
import 'usuario_sesion_service.dart';

// ============================================================
// RESERVAS DEL USUARIO
// ============================================================
//
// Endpoints existentes del backend (todos exigen sesión de usuario):
//   GET  /api/reservas
//   POST /api/reservas
//   PUT  /api/reservas/:id/cancelar
// ============================================================

class ReservaUsuarioService {
  ReservaUsuarioService._();

  static final ReservaUsuarioService instance =
      ReservaUsuarioService._();

  /// Clave única por intento de solicitud. Si la persona toca "Enviar"
  /// dos veces o la red se repite, el servidor no crea otra reserva.
  static String nuevaClaveSolicitud() {
    final azar = Random.secure();
    final sufijo = List.generate(
      8,
      (_) => azar.nextInt(36).toRadixString(36),
    ).join();

    return 'rc-${DateTime.now().millisecondsSinceEpoch}-$sufijo';
  }

  String _token() {
    final sesion = UsuarioSesionService.instance.sesionActual.value;

    if (sesion == null || sesion.token.isEmpty) {
      throw Exception('Inicia sesión para gestionar tus reservas.');
    }

    return sesion.token;
  }

  Map<String, String> _cabeceras() {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_token()}',
    };
  }

  dynamic _decodificar(http.Response respuesta) {
    try {
      return jsonDecode(respuesta.body);
    } catch (_) {
      return null;
    }
  }

  Exception _error(http.Response respuesta, String porDefecto) {
    if (respuesta.statusCode == 401) {
      return Exception(
        'Tu sesión expiró. Inicia sesión nuevamente.',
      );
    }

    if (respuesta.statusCode == 403) {
      return Exception('Tu cuenta no tiene permiso para esta acción.');
    }

    final datos = _decodificar(respuesta);

    if (datos is Map && datos['mensaje'] != null) {
      return Exception(datos['mensaje'].toString());
    }

    return Exception(porDefecto);
  }

  // ============================================================
  // LISTAR
  // ============================================================

  Future<List<ReservaUsuarioModel>> obtenerReservas() async {
    final respuesta = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/reservas'),
      headers: _cabeceras(),
    );

    if (respuesta.statusCode != 200) {
      throw _error(respuesta, 'No se pudieron cargar tus reservas.');
    }

    final datos = _decodificar(respuesta);

    if (datos is! List) {
      throw Exception('El servidor no devolvió una lista de reservas.');
    }

    return datos
        .whereType<Map>()
        .map(
          (r) => ReservaUsuarioModel.fromJson(
            Map<String, dynamic>.from(r),
          ),
        )
        .toList();
  }

  // ============================================================
  // CREAR SOLICITUD
  // ============================================================
  //
  // El servidor calcula el precio y deduce el sitio desde la
  // actividad; aquí solo se envía lo que decide la persona.
  // ============================================================

  Future<String> crearSolicitud({
    required String actividadId,
    required DateTime fecha,
    required int cantidadPersonas,
    required String observaciones,
    required String claveSolicitud,
  }) async {
    final mediodia = DateTime(fecha.year, fecha.month, fecha.day, 12);

    final respuesta = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/reservas'),
      headers: {
        ..._cabeceras(),
        'Idempotency-Key': claveSolicitud,
      },
      body: jsonEncode({
        'actividad': actividadId,
        'fecha': mediodia.toUtc().toIso8601String(),
        'cantidadPersonas': cantidadPersonas,
        'observaciones': observaciones.trim(),
        'claveSolicitud': claveSolicitud,
      }),
    );

    if (respuesta.statusCode != 200 && respuesta.statusCode != 201) {
      throw _error(respuesta, 'No se pudo enviar la solicitud.');
    }

    final datos = _decodificar(respuesta);

    if (datos is Map && datos['mensaje'] != null) {
      return datos['mensaje'].toString();
    }

    return 'Solicitud enviada.';
  }

  // ============================================================
  // CANCELAR
  // ============================================================

  Future<void> cancelar(String reservaId) async {
    final respuesta = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/reservas/'
        '${Uri.encodeComponent(reservaId)}/cancelar',
      ),
      headers: _cabeceras(),
    );

    if (respuesta.statusCode != 200) {
      throw _error(respuesta, 'No se pudo cancelar la reserva.');
    }
  }
}
