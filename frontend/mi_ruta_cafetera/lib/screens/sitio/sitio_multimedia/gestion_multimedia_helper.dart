
import 'package:image_picker/image_picker.dart';

import '../../../models/sitio/sitio_multimedia_model.dart';
import '../../../services/sitio/sitio_multimedia_service.dart';
import '../../../services/sitio/sitio_sesion_service.dart';

// ignore_for_file: prefer_initializing_formals

class GestionMultimediaHelper {
  GestionMultimediaHelper({
    required SitioMultimediaService multimediaService,
    required SitioSesionService sesionService,
  })  : _multimediaService = multimediaService,
        _sesionService = sesionService;

  final SitioMultimediaService _multimediaService;
  final SitioSesionService _sesionService;

  Future<Map<String, String>> obtenerCredenciales() async {
    final sesion = await _sesionService.obtenerSesion();

    if (sesion == null ||
        sesion.token.isEmpty ||
        sesion.sitioId.isEmpty) {
      throw Exception('No hay una sesión de sitio disponible.');
    }

    return {
      'token': sesion.token,
      'sitioId': sesion.sitioId,
    };
  }

  Future<List<SitioMultimediaModel>> cargarMultimedia({
    required String token,
    required String sitioId,
  }) async {
    final multimedia = await _multimediaService.obtenerMultimedia(
      token: token,
      sitioId: sitioId,
    );

    return multimedia
        .where(
          (item) =>
              item.tipo == 'imagen' &&
              item.activo &&
              item.url.isNotEmpty,
        )
        .toList();
  }

  Future<SitioMultimediaModel> subirImagen({
    required String token,
    required XFile imagen,
    required String titulo,
    required String descripcion,
  }) {
    return _multimediaService.subirImagen(
      token: token,
      archivo: imagen,
      titulo: titulo,
      descripcion: descripcion,
    );
  }
}
