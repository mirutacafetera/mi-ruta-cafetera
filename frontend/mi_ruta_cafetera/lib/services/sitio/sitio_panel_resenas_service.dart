
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../models/sitio/sitio_resena_model.dart';
import '../../models/sitio/sitio_sesion_model.dart';
import 'sitio_sesion_service.dart';

class SitioPanelResenasService {
  SitioPanelResenasService._();

  static final SitioPanelResenasService instance =
      SitioPanelResenasService._();

  final SitioSesionService _sesionService = SitioSesionService();

  Uri _uri(String ruta) {
    return Uri.parse(
      '${ApiConfig.baseUrl}/sitiosturisticos/resenas$ruta',
    );
  }

  Future<SitioSesionModel> _obtenerSesionValida() async {
    final sesion = await _sesionService.obtenerSesion();

    if (sesion == null ||
        sesion.token.isEmpty ||
        sesion.sitioId.isEmpty ||
        !sesion.activo) {
      throw Exception(
        'Inicia sesión con una cuenta activa del establecimiento.',
      );
    }

    return sesion;
  }

  Future<dynamic> _solicitar(
    String ruta,
    SitioSesionModel sesion,
  ) async {
    final uri = _uri(ruta);

    debugPrint('===== SOLICITUD DE RESEÑAS DEL SITIO =====');
    debugPrint('URL: $uri');
    debugPrint('ID del sitio: ${sesion.sitioId}');

    final respuesta = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${sesion.token}',
      },
    );

    dynamic datos;

    try {
      datos = respuesta.body.isEmpty
          ? null
          : jsonDecode(respuesta.body);
    } catch (_) {
      throw Exception(
        'El servidor devolvió una respuesta no válida '
        '(HTTP ${respuesta.statusCode}).',
      );
    }

    debugPrint('Estado HTTP: ${respuesta.statusCode}');

    if (respuesta.statusCode < 200 ||
        respuesta.statusCode >= 300) {
      final mensaje = datos is Map
          ? datos['mensaje'] ??
              datos['error'] ??
              'No se pudieron cargar las reseñas.'
          : 'No se pudieron cargar las reseñas.';

      throw Exception(
        'HTTP ${respuesta.statusCode}: $mensaje',
      );
    }

    return datos;
  }

  List<dynamic> _extraerLista(dynamic datos) {
    if (datos is List) {
      return datos;
    }

    if (datos is Map) {
      if (datos['resenas'] is List) {
        return datos['resenas'] as List;
      }

      if (datos['datos'] is List) {
        return datos['datos'] as List;
      }
    }

    return const [];
  }

  Future<List<SitioResenaModel>> obtenerResenas() async {
    final sesion = await _obtenerSesionValida();

    final datos = await _solicitar(
      '/${Uri.encodeComponent(sesion.sitioId)}',
      sesion,
    );

    final lista = _extraerLista(datos);

    debugPrint('Reseñas recibidas del servidor: ${lista.length}');

    final resenas = <SitioResenaModel>[];

    for (final elemento in lista) {
      if (elemento is! Map) continue;

      try {
        final resena = SitioResenaModel.fromJson(
          Map<String, dynamic>.from(elemento),
        );

        if (resena.activo) {
          resenas.add(resena);
        }
      } catch (error) {
        debugPrint('No se pudo interpretar una reseña: $error');
      }
    }

    debugPrint('Reseñas válidas para mostrar: ${resenas.length}');

    return resenas;
  }

  Future<Map<String, dynamic>> obtenerPromedio() async {
    final sesion = await _obtenerSesionValida();

    final datos = await _solicitar(
      '/${Uri.encodeComponent(sesion.sitioId)}/promedio',
      sesion,
    );

    if (datos is Map) {
      final resultado = Map<String, dynamic>.from(datos);

      if (resultado['datos'] is Map) {
        return Map<String, dynamic>.from(
          resultado['datos'] as Map,
        );
      }

      return resultado;
    }

    return {
      'promedio': 0,
      'total': 0,
    };
  }
}
