import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../models/admin/resena_admin.dart';

class ResenaAdminService {
  static String get _url => '${ApiConfig.baseUrl}/admin/resenas';

  static Future<List<ResenaAdmin>> obtenerResenas() async {
    final respuesta = await http.get(Uri.parse(_url));

    debugPrint('URL: $_url');
    debugPrint('ESTADO: ${respuesta.statusCode}');
    debugPrint('RESPUESTA: ${respuesta.body}');

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error ${respuesta.statusCode}: ${respuesta.body}',
      );
    }

    final datos = jsonDecode(respuesta.body);

    if (datos is! List) {
      throw Exception('La respuesta de reseñas no es una lista');
    }

    return datos
        .map(
          (resena) => ResenaAdmin.fromJson(
            Map<String, dynamic>.from(resena),
          ),
        )
        .toList();
  }

  static Future<bool> cambiarEstado(String id, bool activo) async {
    final accion = activo ? 'activar' : 'desactivar';
    final respuesta = await http.put(Uri.parse('$_url/$id/$accion'));

    debugPrint('CAMBIAR ESTADO: ${respuesta.statusCode}');
    debugPrint('RESPUESTA: ${respuesta.body}');

    return respuesta.statusCode == 200;
  }

  static Future<bool> eliminarResena(String id) async {
    final respuesta = await http.delete(Uri.parse('$_url/$id'));

    debugPrint('ELIMINAR RESEÑA: ${respuesta.statusCode}');
    debugPrint('RESPUESTA: ${respuesta.body}');

    return respuesta.statusCode == 200;
  }
}