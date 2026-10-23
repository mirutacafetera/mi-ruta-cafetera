// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/sitio/sitio_contenido_model.dart';
import '../../../services/sitio/sitio_contenido_service.dart';
import '../../../services/sitio/sitio_sesion_service.dart';
import '../../../widgets/sitio/audio_guia_borrador.dart';

class GestionContenidoHelper {
  GestionContenidoHelper({
    required SitioContenidoService contenidoService,
    required SitioSesionService sesionService,
    required bool Function() estaMontado,
    required Future<void> Function() recargarContenidos,
    required void Function(String mensaje, {bool esError}) mostrarMensaje,
    required void Function(String contenidoId) quitarContenido,
  })  : _contenidoService = contenidoService,
        _sesionService = sesionService,
        _estaMontado = estaMontado,
        _recargarContenidos = recargarContenidos,
        _mostrarMensaje = mostrarMensaje,
        _quitarContenido = quitarContenido;

  final SitioContenidoService _contenidoService;
  final SitioSesionService _sesionService;
  final bool Function() _estaMontado;
  final Future<void> Function() _recargarContenidos;
  final void Function(String mensaje, {bool esError}) _mostrarMensaje;
  final void Function(String contenidoId) _quitarContenido;

  String _limpiarError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  Future<String> _obtenerToken() async {
    final sesion = await _sesionService.obtenerSesion();

    if (sesion == null || sesion.token.isEmpty) {
      throw Exception('No hay una sesión activa.');
    }

    return sesion.token;
  }

  Future<bool> crearContenido({
    required String titulo,
    required String descripcion,
    XFile? imagenPrincipal,
    required List<XFile> imagenes,
    List<AudioGuiaBorrador> audiosNuevos = const [],
  }) async {
    try {
      final token = await _obtenerToken();

      final contenido = await _contenidoService.crearContenido(
        token: token,
        titulo: titulo,
        descripcion: descripcion,
      );

      if (imagenPrincipal != null || imagenes.isNotEmpty) {
        await _contenidoService.subirImagenesContenido(
          token: token,
          contenidoId: contenido.id,
          imagenPrincipal: imagenPrincipal,
          imagenes: imagenes,
        );
      }

      for (final audio in audiosNuevos) {
        if (audio.titulo.trim().isEmpty) {
          throw Exception('Cada audioguía debe tener un título.');
        }

        await _contenidoService.subirAudioGuia(
          token: token,
          contenidoId: contenido.id,
          archivo: audio.archivo,
          titulo: audio.titulo.trim(),
          descripcion: audio.descripcion.trim(),
        );
      }

      await _recargarContenidos();

      if (!_estaMontado()) return false;

      _mostrarMensaje('Contenido creado correctamente.');
      return true;
    } catch (error, stackTrace) {
      debugPrint('ERROR AL CREAR CONTENIDO: $error');
      debugPrint('$stackTrace');

      if (!_estaMontado()) return false;

      _mostrarMensaje(_limpiarError(error), esError: true);
      return false;
    }
  }

  Future<bool> actualizarContenido(
    SitioContenidoModel contenido, {
    required String titulo,
    required String descripcion,
    XFile? imagenPrincipal,
    required List<XFile> imagenes,
    required List<String> imagenesAConservar,
    List<AudioGuiaBorrador> audiosNuevos = const [],
    List<String> audiosAEliminar = const [],
  }) async {
    try {
      final token = await _obtenerToken();

      await _contenidoService.actualizarContenido(
        token: token,
        contenidoId: contenido.id,
        titulo: titulo,
        descripcion: descripcion,
        imagenes: imagenesAConservar,
      );

      if (imagenPrincipal != null || imagenes.isNotEmpty) {
        await _contenidoService.subirImagenesContenido(
          token: token,
          contenidoId: contenido.id,
          imagenPrincipal: imagenPrincipal,
          imagenes: imagenes,
        );
      }

      for (final audioId in audiosAEliminar) {
        await _contenidoService.eliminarAudioGuia(
          token: token,
          contenidoId: contenido.id,
          audioId: audioId,
        );
      }

      for (final audio in audiosNuevos) {
        if (audio.titulo.trim().isEmpty) {
          throw Exception('Cada audioguía debe tener un título.');
        }

        await _contenidoService.subirAudioGuia(
          token: token,
          contenidoId: contenido.id,
          archivo: audio.archivo,
          titulo: audio.titulo.trim(),
          descripcion: audio.descripcion.trim(),
        );
      }

      await _recargarContenidos();

      if (!_estaMontado()) return false;

      _mostrarMensaje('Contenido actualizado correctamente.');
      return true;
    } catch (error, stackTrace) {
      debugPrint('ERROR AL ACTUALIZAR CONTENIDO: $error');
      debugPrint('$stackTrace');

      if (!_estaMontado()) return false;

      _mostrarMensaje(_limpiarError(error), esError: true);
      return false;
    }
  }

  Future<void> enviarRevision(SitioContenidoModel contenido) async {
    if (contenido.estadoPublicacion == 'pendiente_revision') return;

    try {
      final token = await _obtenerToken();

      await _contenidoService.enviarContenidoRevision(
        token: token,
        contenidoId: contenido.id,
      );

      await _recargarContenidos();

      if (!_estaMontado()) return;

      _mostrarMensaje('Contenido enviado a revisión correctamente.');
    } catch (error, stackTrace) {
      debugPrint('ERROR AL ENVIAR A REVISIÓN: $error');
      debugPrint('$stackTrace');

      if (!_estaMontado()) return;

      _mostrarMensaje(_limpiarError(error), esError: true);
    }
  }

  Future<void> eliminarContenido(SitioContenidoModel contenido) async {
    try {
      final token = await _obtenerToken();

      await _contenidoService.eliminarContenido(
        token: token,
        contenidoId: contenido.id,
      );

      if (!_estaMontado()) return;

      _quitarContenido(contenido.id);
      _mostrarMensaje('Contenido eliminado correctamente.');
    } catch (error, stackTrace) {
      debugPrint('ERROR AL ELIMINAR CONTENIDO: $error');
      debugPrint('$stackTrace');

      if (!_estaMontado()) return;

      _mostrarMensaje(_limpiarError(error), esError: true);
    }
  }
}