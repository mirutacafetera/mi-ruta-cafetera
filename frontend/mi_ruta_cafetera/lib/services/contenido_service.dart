import '../models/contenido_model.dart';
import '../models/sitio/sitio_contenido_model.dart';
import 'sitio/sitio_contenido_service.dart';

class ContenidoService {
  ContenidoService._();

  static final ContenidoService instance = ContenidoService._();

  final SitioContenidoService _service = SitioContenidoService();

  Future<List<ContenidoModel>> obtenerContenidosPorSitio(
    String sitioId,
  ) async {
    final contenidos =
        await _service.obtenerContenidosPublicos(
      sitioId: sitioId,
    );

    return contenidos
        .map(_convertirContenido)
        .toList();
  }

  ContenidoModel _convertirContenido(
    SitioContenidoModel contenido,
  ) {
    return ContenidoModel(
      id: contenido.id,
      sitioId: contenido.sitio,
      titulo: contenido.titulo,
      descripcion: contenido.descripcion,
      imagenPrincipal: contenido.imagenPrincipal,
      imagenes: contenido.imagenes,
      audioGuias: contenido.audioGuias
          .map(
            (audio) => AudioGuiaModel(
              id: audio.id,
              titulo: audio.titulo,
              descripcion: audio.descripcion,
              url: audio.url,
              duracion: audio.duracion,
            ),
          )
          .toList(),
      estadoPublicacion: contenido.estadoPublicacion,
      motivoRechazo: contenido.motivoRechazo,
      revisadoPor: contenido.revisadoPor.isEmpty
          ? null
          : contenido.revisadoPor,
      revisadoAt: contenido.revisadoAt,
      activo: contenido.activo,
      creadoEn: contenido.createdAt,
      actualizadoEn: contenido.updatedAt,
    );
  }
}
