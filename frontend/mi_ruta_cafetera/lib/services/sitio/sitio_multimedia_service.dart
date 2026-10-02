import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../config/api_config.dart';
import '../../models/sitio/sitio_multimedia_model.dart';

class SitioMultimediaService {
  // ============================================================
  // OBTENER MULTIMEDIA
  // ============================================================

  Future<List<SitioMultimediaModel>> obtenerMultimedia({
    required String token,
    required String sitioId,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/sitiosturisticos/multimedia/$sitioId',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is! List) {
        return [];
      }

      return data
          .map(
            (item) => SitioMultimediaModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    try {
      final data = jsonDecode(response.body);

      throw Exception(
        data['mensaje']?.toString() ??
            'No fue posible obtener la galería.',
      );
    } catch (_) {
      throw Exception(
        'No fue posible obtener la galería.',
      );
    }
  }

  // ============================================================
  // SUBIR IMAGEN
  // ============================================================

  Future<SitioMultimediaModel> subirImagen({
    required String token,
    required XFile archivo,
    String titulo = '',
    String descripcion = '',
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/sitiosturisticos/multimedia',
    );

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.headers['Authorization'] =
        'Bearer $token';

    // Convertimos el XFile a bytes.
    // Esto funciona en Web, Android e iOS.
    final bytes = await archivo.readAsBytes();

    request.files.add(
      http.MultipartFile.fromBytes(
        'imagen',
        bytes,
        filename: archivo.name,
      ),
    );

    request.fields['titulo'] = titulo;
    request.fields['descripcion'] =
        descripcion;
    request.fields['idioma'] = 'es';

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      return SitioMultimediaModel.fromJson(
        Map<String, dynamic>.from(
          data['multimedia'],
        ),
      );
    }

    try {
      final data = jsonDecode(response.body);

      throw Exception(
        data['mensaje']?.toString() ??
            'No fue posible subir la imagen.',
      );
    } catch (_) {
      throw Exception(
        'No fue posible subir la imagen.',
      );
    }
  }
}