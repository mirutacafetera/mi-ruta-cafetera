import 'package:image_picker/image_picker.dart';

import '../../../models/sitio/sitio_actividad_model.dart';
import '../../../services/sitio/sitio_actividades_service.dart';

class GestionActividadHelper {
  GestionActividadHelper({
    required this.servicio,
    required this.obtenerToken,
    required this.obtenerSitioId,
    required this.estaMontado,
    required this.cambiarEstadoGuardado,
    required this.mostrarMensaje,
  });

  final SitioActividadesService servicio;
  final String Function() obtenerToken;
  final String Function() obtenerSitioId;
  final bool Function() estaMontado;
  final void Function(bool valor) cambiarEstadoGuardado;
  final void Function(String mensaje, {bool esError}) mostrarMensaje;

  Future<void> guardarActividad({
    SitioActividadModel? actividad,
    required String nombre,
    required String descripcion,
    required double precio,
    required String horario,
    required String duracion,
    required List<XFile> imagenes,
    required List<String> imagenesEliminar,
    required String imagenPrincipalUrl,
    required String? imagenPrincipalNueva,
  }) async {
    final token = obtenerToken();
    final sitioId = obtenerSitioId();

    if (token.isEmpty || sitioId.isEmpty) {
      throw Exception('No hay una sesión activa del sitio.');
    }

    if (estaMontado()) cambiarEstadoGuardado(true);

    try {
      final imagenesOriginales = <String>{
        if (actividad != null && actividad.imagenPrincipal.isNotEmpty)
          actividad.imagenPrincipal,
        ...?actividad?.imagenes,
      };

      late SitioActividadModel guardada;

      if (actividad == null) {
        guardada = await servicio.crearActividad(
          token: token,
          sitioId: sitioId,
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          horario: horario,
          duracion: duracion,
        );
      } else {
        guardada = await servicio.actualizarActividad(
          token: token,
          sitioId: sitioId,
          actividadId: actividad.id,
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          horario: horario,
          duracion: duracion,
        );
      }

      if (imagenes.isNotEmpty) {
        guardada = await servicio.subirImagenes(
          token: token,
          sitioId: sitioId,
          actividadId: guardada.id,
          archivos: imagenes,
        );
      }

      List<String> obtenerUrls(SitioActividadModel item) => {
            if (item.imagenPrincipal.isNotEmpty) item.imagenPrincipal,
            ...item.imagenes.where((url) => url.isNotEmpty),
          }.toList();

      var urlsDisponibles = obtenerUrls(guardada);
      final urlsNuevas = urlsDisponibles
          .where((url) => !imagenesOriginales.contains(url))
          .toList();
      var principalDeseada = imagenPrincipalUrl.trim();

      if (imagenPrincipalNueva != null) {
        final indiceSeleccionado = imagenes.indexWhere(
          (imagen) => imagen.path == imagenPrincipalNueva,
        );
        if (indiceSeleccionado < 0) {
          throw Exception(
            'No se encontró la fotografía seleccionada como portada.',
          );
        }
        if (indiceSeleccionado >= urlsNuevas.length) {
          throw Exception(
            'El servidor no devolvió una URL para la fotografía elegida. '
            'No se eliminarán las imágenes existentes.',
          );
        }
        principalDeseada = urlsNuevas[indiceSeleccionado];
      }

      if (principalDeseada.isEmpty ||
          imagenesEliminar.contains(principalDeseada) ||
          !urlsDisponibles.contains(principalDeseada)) {
        principalDeseada = '';
        for (final url in urlsDisponibles) {
          if (!imagenesEliminar.contains(url)) {
            principalDeseada = url;
            break;
          }
        }
      }

      if (principalDeseada.isEmpty) {
        throw Exception('La actividad debe conservar al menos una imagen.');
      }

      if (guardada.imagenPrincipal != principalDeseada) {
        if (!guardada.imagenes.contains(principalDeseada)) {
          throw Exception(
            'La imagen elegida como portada no está disponible '
            'en la galería del servidor.',
          );
        }
        guardada = await servicio.establecerImagenPrincipal(
          token: token,
          sitioId: sitioId,
          actividadId: guardada.id,
          url: principalDeseada,
        );
        urlsDisponibles = obtenerUrls(guardada);
      }

      for (final url in imagenesEliminar.toSet()) {
        if (url == guardada.imagenPrincipal) {
          throw Exception(
            'No se puede eliminar la imagen principal actual. '
            'Selecciona otra portada antes de continuar.',
          );
        }
        if (!urlsDisponibles.contains(url)) continue;
        guardada = await servicio.eliminarImagen(
          token: token,
          sitioId: sitioId,
          actividadId: guardada.id,
          url: url,
        );
        urlsDisponibles = obtenerUrls(guardada);
      }

      if (estaMontado()) {
        mostrarMensaje(
          actividad == null
              ? 'Actividad creada correctamente.'
              : 'Actividad actualizada correctamente.',
        );
      }
    } catch (error) {
      if (estaMontado()) {
        mostrarMensaje(
          error.toString().replaceFirst('Exception: ', ''),
          esError: true,
        );
      }
      rethrow;
    } finally {
      if (estaMontado()) cambiarEstadoGuardado(false);
    }
  }
}