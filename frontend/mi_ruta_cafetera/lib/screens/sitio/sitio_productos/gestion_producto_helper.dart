// ignore_for_file: prefer_initializing_formals
import 'package:image_picker/image_picker.dart';

import '../../../models/sitio/sitio_producto_model.dart';
import '../../../services/sitio/sitio_productos_service.dart';
import '../../../services/sitio/sitio_sesion_service.dart';

class GestionProductoHelper {
  GestionProductoHelper({
    required SitioProductosService productosService,
    required SitioSesionService sesionService,
    required bool Function() estaMontado,
    required void Function(bool valor) cambiarEstadoGuardado,
    required void Function(String mensaje, {bool esError}) mostrarMensaje,
  })  : _productosService = productosService,
        _sesionService = sesionService,
        _estaMontado = estaMontado,
        _cambiarEstadoGuardado = cambiarEstadoGuardado,
        _mostrarMensaje = mostrarMensaje;

  final SitioProductosService _productosService;
  final SitioSesionService _sesionService;
  final bool Function() _estaMontado;
  final void Function(bool valor) _cambiarEstadoGuardado;
  final void Function(String mensaje, {bool esError}) _mostrarMensaje;

  Future<Map<String, String>> obtenerSesionActiva() async {
    final sesion = await _sesionService.obtenerSesion();

    if (sesion == null || sesion.token.isEmpty || sesion.sitioId.isEmpty) {
      throw Exception('No se encontró una sesión activa del sitio.');
    }

    if (!sesion.activo) {
      throw Exception('La cuenta del sitio está inactiva.');
    }

    return {
      'token': sesion.token,
      'sitioId': sesion.sitioId,
    };
  }

  Future<List<SitioProductoModel>> cargarProductos({
    required String token,
    required String sitioId,
  }) async {
    return await _productosService.obtenerProductos(
      token: token,
      sitioId: sitioId,
    );
  }

  Future<void> guardarProducto({
    SitioProductoModel? producto,
    required String token,
    required String sitioId,
    required String nombre,
    required String descripcion,
    required double precio,
    required String categoria,
    required List<XFile> imagenes,
    required List<String> imagenesConservar,
    required String imagenPrincipalActual,
  }) async {
    if (token.isEmpty || sitioId.isEmpty) {
      throw Exception('No hay una sesión activa del sitio.');
    }

    if (_estaMontado()) {
      _cambiarEstadoGuardado(true);
    }

    try {
      final imagenesOriginales = <String>{
        if (producto != null && producto.imagenPrincipal.isNotEmpty)
          producto.imagenPrincipal,
        ...?producto?.imagenes,
      };

      late SitioProductoModel guardado;

      if (producto == null) {
        guardado = await _productosService.crearProducto(
          token: token,
          sitioId: sitioId,
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          categoria: categoria,
        );
      } else {
        guardado = await _productosService.actualizarProducto(
          token: token,
          sitioId: sitioId,
          productoId: producto.id,
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          categoria: categoria,
        );
      }

      if (imagenes.isNotEmpty) {
        guardado = await _productosService.subirImagenes(
          token: token,
          sitioId: sitioId,
          productoId: guardado.id,
          archivos: imagenes,
        );
      }

      Set<String> obtenerUrls(SitioProductoModel productoActual) {
        return {
          if (productoActual.imagenPrincipal.isNotEmpty)
            productoActual.imagenPrincipal,
          ...productoActual.imagenes.where((url) => url.isNotEmpty),
        };
      }

      var urlsDisponibles = obtenerUrls(guardado);

      final imagenesNuevas = urlsDisponibles
          .where((url) => !imagenesOriginales.contains(url))
          .toList();

      var principalDeseada = imagenPrincipalActual.trim();

      if (principalDeseada.isEmpty ||
          !urlsDisponibles.contains(principalDeseada)) {
        principalDeseada = '';

        for (final url in imagenesConservar) {
          if (urlsDisponibles.contains(url)) {
            principalDeseada = url;
            break;
          }
        }
      }

      if (principalDeseada.isEmpty && imagenesNuevas.isNotEmpty) {
        principalDeseada = imagenesNuevas.first;
      }

      if (principalDeseada.isEmpty && urlsDisponibles.isNotEmpty) {
        principalDeseada = urlsDisponibles.first;
      }

      if (principalDeseada.isEmpty) {
        throw Exception('El producto debe tener al menos una imagen.');
      }

      if (guardado.imagenPrincipal != principalDeseada) {
        if (!guardado.imagenes.contains(principalDeseada)) {
          throw Exception(
            'No se pudo establecer la imagen principal seleccionada.',
          );
        }

        guardado = await _productosService.establecerImagenPrincipal(
          token: token,
          sitioId: sitioId,
          productoId: guardado.id,
          url: principalDeseada,
        );

        urlsDisponibles = obtenerUrls(guardado);
      }

      if (producto != null) {
        final urlsPorEliminar = imagenesOriginales
            .where((url) => !imagenesConservar.contains(url))
            .toList();

        for (final url in urlsPorEliminar) {
          if (url == guardado.imagenPrincipal) {
            throw Exception(
              'No se puede eliminar una imagen que continúa siendo '
              'la principal. Selecciona otra imagen principal.',
            );
          }

          if (!urlsDisponibles.contains(url)) {
            continue;
          }

          guardado = await _productosService.eliminarImagen(
            token: token,
            sitioId: sitioId,
            productoId: guardado.id,
            url: url,
          );

          urlsDisponibles = obtenerUrls(guardado);
        }
      }

      if (_estaMontado()) {
        _mostrarMensaje(
          producto == null
              ? 'Producto creado correctamente.'
              : 'Producto actualizado correctamente.',
        );
      }
    } catch (error) {
      if (_estaMontado()) {
        _mostrarMensaje(
          error.toString().replaceFirst('Exception: ', ''),
          esError: true,
        );
      }
      rethrow;
    } finally {
      if (_estaMontado()) {
        _cambiarEstadoGuardado(false);
      }
    }
  }

  Future<void> enviarARevision({
    required String token,
    required String sitioId,
    required String productoId,
  }) async {
    await _productosService.enviarARevision(
      token: token,
      sitioId: sitioId,
      productoId: productoId,
    );
    if (_estaMontado()) {
      _mostrarMensaje('El producto fue enviado a revisión.');
    }
  }

  Future<void> eliminarProducto({
    required String token,
    required String sitioId,
    required String productoId,
  }) async {
    await _productosService.eliminarProducto(
      token: token,
      sitioId: sitioId,
      productoId: productoId,
    );
    if (_estaMontado()) {
      _mostrarMensaje('Producto eliminado correctamente.');
    }
  }
}