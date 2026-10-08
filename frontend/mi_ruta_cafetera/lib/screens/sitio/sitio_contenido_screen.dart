import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/sitio/sitio_contenido_model.dart';
import '../../services/sitio/sitio_contenido_service.dart';
import '../../services/sitio/sitio_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/sitio/formulario_contenido_sitio.dart';
import '../../widgets/sitio/tarjeta_contenido_sitio.dart';

class SitioContenidoScreen extends StatefulWidget {
  const SitioContenidoScreen({super.key});

  @override
  State<SitioContenidoScreen> createState() =>
      _SitioContenidoScreenState();
}

class _SitioContenidoScreenState
    extends State<SitioContenidoScreen> {
  final SitioContenidoService _contenidoService =
      SitioContenidoService();
  final SitioSesionService _sesionService =
      SitioSesionService();

  List<SitioContenidoModel> _contenidos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarContenidos();
  }

  Future<void> _cargarContenidos() async {
    if (mounted) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }

    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception('No hay una sesión activa.');
      }

      final contenidos =
          await _contenidoService.obtenerMisContenidos(
        token: sesion.token,
      );

      if (!mounted) return;

      setState(() {
        _contenidos = contenidos;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = error.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  void _mostrarFormularioNuevo() {
    showDialog(
      context: context,
      builder: (_) => FormularioContenidoSitio(
        tituloDialogo: 'Nuevo contenido',
        textoBoton: 'Crear contenido',
        contenidoExistente: null,
        onGuardar: ({
          required String titulo,
          required String descripcion,
          XFile? imagenPrincipal,
          required List<XFile> imagenes,
        }) {
          return _crearContenido(
            titulo: titulo,
            descripcion: descripcion,
            imagenPrincipal: imagenPrincipal,
            imagenes: imagenes,
          );
        },
      ),
    );
  }

  void _mostrarFormularioEditar(
    SitioContenidoModel contenido,
  ) {
    showDialog(
      context: context,
      builder: (_) => FormularioContenidoSitio(
        tituloDialogo: 'Editar contenido',
        textoBoton: 'Guardar cambios',
        contenidoExistente: contenido,
        onGuardar: ({
          required String titulo,
          required String descripcion,
          XFile? imagenPrincipal,
          required List<XFile> imagenes,
        }) {
          return _actualizarContenido(
            contenido,
            titulo: titulo,
            descripcion: descripcion,
            imagenPrincipal: imagenPrincipal,
            imagenes: imagenes,
          );
        },
      ),
    );
  }

  Future<bool> _crearContenido({
    required String titulo,
    required String descripcion,
    XFile? imagenPrincipal,
    required List<XFile> imagenes,
  }) async {
    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception('No hay una sesión activa.');
      }

      final contenido =
          await _contenidoService.crearContenido(
        token: sesion.token,
        titulo: titulo,
        descripcion: descripcion,
      );

      if (imagenPrincipal != null || imagenes.isNotEmpty) {
        await _contenidoService.subirImagenesContenido(
          token: sesion.token,
          contenidoId: contenido.id,
          imagenPrincipal: imagenPrincipal,
          imagenes: imagenes,
        );
      }

      await _cargarContenidos();

      if (!mounted) return false;

      _mostrarMensaje(
        'Contenido creado correctamente.',
      );

      return true;
    } catch (error) {
      if (!mounted) return false;

      _mostrarMensaje(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        esError: true,
      );

      return false;
    }
  }

  Future<bool> _actualizarContenido(
    SitioContenidoModel contenido, {
    required String titulo,
    required String descripcion,
    XFile? imagenPrincipal,
    required List<XFile> imagenes,
  }) async {
    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception('No hay una sesión activa.');
      }

      await _contenidoService.actualizarContenido(
        token: sesion.token,
        contenidoId: contenido.id,
        titulo: titulo,
        descripcion: descripcion,
        imagenPrincipal: contenido.imagenPrincipal,
        imagenes: contenido.imagenes,
        audioGuias: contenido.audioGuias,
      );

      if (imagenPrincipal != null || imagenes.isNotEmpty) {
        await _contenidoService.subirImagenesContenido(
          token: sesion.token,
          contenidoId: contenido.id,
          imagenPrincipal: imagenPrincipal,
          imagenes: imagenes,
        );
      }

      await _cargarContenidos();

      if (!mounted) return false;

      _mostrarMensaje(
        'Contenido actualizado correctamente.',
      );

      return true;
    } catch (error) {
      if (!mounted) return false;

      _mostrarMensaje(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        esError: true,
      );

      return false;
    }
  }

  Future<void> _enviarRevision(
    SitioContenidoModel contenido,
  ) async {
    if (contenido.estadoPublicacion ==
        'pendiente_revision') {
      return;
    }

    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception('No hay una sesión activa.');
      }

      await _contenidoService.enviarContenidoRevision(
        token: sesion.token,
        contenidoId: contenido.id,
      );

      await _cargarContenidos();

      if (!mounted) return;

      _mostrarMensaje(
        'Contenido enviado a revisión correctamente.',
      );
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        esError: true,
      );
    }
  }

  Future<void> _cambiarEstado(
    SitioContenidoModel contenido,
  ) async {
    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception('No hay una sesión activa.');
      }

      final estabaActivo = contenido.activo;

      if (estabaActivo) {
        await _contenidoService.desactivarContenido(
          token: sesion.token,
          contenidoId: contenido.id,
        );
      } else {
        await _contenidoService.activarContenido(
          token: sesion.token,
          contenidoId: contenido.id,
        );
      }

      await _cargarContenidos();

      if (!mounted) return;

      _mostrarMensaje(
        estabaActivo
            ? 'Contenido desactivado.'
            : 'Contenido activado.',
      );
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        esError: true,
      );
    }
  }

  Widget _estadoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.surfaceGreen,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusXl,
                ),
              ),
              child: const Icon(
                Icons.article_outlined,
                size: AppDimensions.iconLg,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            const Text(
              'Aún no tienes contenido turístico',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: AppDimensions.spacingSm,
            ),
            const Text(
              'Crea contenido para presentar las '
              'experiencias de tu sitio a los visitantes.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AppDimensions.spacingLg,
            ),
            ElevatedButton.icon(
              onPressed: _mostrarFormularioNuevo,
              icon: const Icon(Icons.add),
              label: const Text('Crear contenido'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppDimensions.iconLg,
              color: AppColors.error,
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            Text(
              _error ?? 'Ocurrió un error inesperado.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            ElevatedButton.icon(
              onPressed: _cargarContenidos,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirEncabezado() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boton = ElevatedButton.icon(
          onPressed: _mostrarFormularioNuevo,
          icon: const Icon(Icons.add),
          label: const Text('Nuevo contenido'),
        );

        final titulo = const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contenido turístico',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Administra la información que quieres '
              'presentar sobre las experiencias de tu sitio.',
            ),
          ],
        );

        if (constraints.maxWidth < 650) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titulo,
              const SizedBox(
                height: AppDimensions.spacingMd,
              ),
              SizedBox(
                width: double.infinity,
                child: boton,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contenido turístico',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Administra la información que quieres '
                    'presentar sobre las experiencias de tu sitio.',
                  ),
                ],
              ),
            ),
            boton,
          ],
        );
      },
    );
  }

  Widget _construirLista() {
    return RefreshIndicator(
      onRefresh: _cargarContenidos,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          bottom: AppDimensions.spacingXl,
        ),
        itemCount: _contenidos.length,
        itemBuilder: (_, index) {
          final contenido = _contenidos[index];

          return TarjetaContenidoSitio(
            contenido: contenido,
            onEditar: () {
              _mostrarFormularioEditar(contenido);
            },
            onEnviarRevision: () {
              _enviarRevision(contenido);
            },
            onCambiarEstado: () {
              _cambiarEstado(contenido);
            },
          );
        },
      ),
    );
  }

  Widget _construirContenidoPrincipal() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _estadoError();
    }

    if (_contenidos.isEmpty) {
      return _estadoVacio();
    }

    return _construirLista();
  }

  void _mostrarMensaje(
    String mensaje, {
    bool esError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor:
            esError ? AppColors.error : AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirEncabezado(),
          const SizedBox(
            height: AppDimensions.spacingLg,
          ),
          Expanded(
            child: _construirContenidoPrincipal(),
          ),
        ],
      ),
    );
  }
}