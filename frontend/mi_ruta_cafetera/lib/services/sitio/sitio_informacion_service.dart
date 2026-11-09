import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../config/api_config.dart';
import '../../models/sitio/sitio_informacion_model.dart';

class SitioInformacionService {
  Future<SitioInformacionModel> obtenerInformacion(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/informacion',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return SitioInformacionModel.fromJson(
        Map<String, dynamic>.from(data['sitio']),
      );
    }

    try {
      final data = jsonDecode(response.body);

      throw Exception(
        data['mensaje']?.toString() ??
            'No fue posible obtener la información del sitio.',
      );
    } catch (_) {
      throw Exception(
        'No fue posible obtener la información del sitio.',
      );
    }
  }

  Future<SitioInformacionModel> actualizarInformacion({
    required String token,
    required SitioInformacionModel sitio,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/informacion',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(sitio.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return SitioInformacionModel.fromJson(
        Map<String, dynamic>.from(data['sitio']),
      );
    }

    try {
      final data = jsonDecode(response.body);

      throw Exception(
        data['mensaje']?.toString() ??
            'No fue posible actualizar la información.',
      );
    } catch (_) {
      throw Exception(
        'No fue posible actualizar la información.',
      );
    }
  }

  Future<SitioInformacionModel> subirImagenPrincipal({
    required String token,
    required XFile imagen,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/informacion/imagen',
      ),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes(
        'imagen',
        await imagen.readAsBytes(),
        filename: imagen.name,
      ),
    );

    final respuesta = await request.send();
    final response = await http.Response.fromStream(respuesta);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return SitioInformacionModel.fromJson(
        Map<String, dynamic>.from(data['sitio']),
      );
    }

    String mensaje = 'No fue posible subir la imagen principal.';

    try {
      final data = jsonDecode(response.body);
      mensaje = data['mensaje']?.toString() ?? mensaje;
    } catch (_) {
      // Se conserva el mensaje predeterminado.
    }

    throw Exception(mensaje);
  }

  // ======================================================
  // ELIMINAR IMAGEN PRINCIPAL DEL SITIO
  // ======================================================

  Future<SitioInformacionModel> eliminarImagenPrincipal({
    required String token,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/informacion/imagen',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return SitioInformacionModel.fromJson(
        Map<String, dynamic>.from(data['sitio']),
      );
    }

    String mensaje = 'No fue posible eliminar la imagen principal.';

    try {
      final data = jsonDecode(response.body);
      mensaje = data['mensaje']?.toString() ?? mensaje;
    } catch (_) {
      // Se conserva el mensaje predeterminado.
    }

    throw Exception(mensaje);
  }
}