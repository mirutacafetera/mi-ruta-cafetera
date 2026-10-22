import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/sitio/sitio_contenido_model.dart';
import '../../services/sitio/sitio_contenido_service.dart';
import '../../services/sitio/sitio_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/sitio/audio_guia_borrador.dart';
import '../../widgets/sitio/formulario_contenido_sitio.dart';
import '../../widgets/sitio/tarjeta_contenido_sitio.dart';

class SitioContenidoScreen extends StatefulWidget {
  const SitioContenidoScreen({super.key});

  @override
  State<SitioContenidoScreen> createState() =>
      _SitioContenidoScreenState();
}

class _SitioContenidoScreenState extends State<SitioContenidoScreen> {
  final SitioContenidoService _contenidoService =
      SitioContenidoService();

  final SitioSesionService _sesionService = SitioSesionService();

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

      final contenidos = await _contenidoService.obtenerMisContenidos(
        token: sesion.token,
      );

      if (!mounted) return;

      setState(() {
        _contenidos = contenidos;
        _cargando = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Error al cargar contenidos: $error');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = _limpiarError(error);
      });
    }
  }

  String _limpiarError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _mostrarFormularioNuevo() {
    showDialog<bool>(
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
          required List<String> imagenesAConservar,
          List<AudioGuiaBorrador>? audiosNuevos,
          List<String>? audiosAEliminar,
        }) {
          return _crearContenido(
            titulo: titulo,
            descripcion: descripcion,
            imagenPrincipal: imagenPrincipal,
            imagenes: imagenes,
            audiosNuevos: audiosNuevos ?? [],
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
    List<AudioGuiaBorrador> audiosNuevos = const [],
  }) async {
    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception('No hay una sesión activa.');
      }

      final contenido = await _contenidoService.crearContenido(
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

      for (final audio in audiosNuevos) {
        if (audio.titulo.trim().isEmpty) {
          throw Exception('Cada audioguía debe tener un título.');
        }

        await _contenidoService.subirAudioGuia(
          token: sesion.token,
          contenidoId: contenido.id,
          archivo: audio.archivo,
          titulo: audio.titulo.trim(),
          descripcion: audio.descripcion.trim(),
        );
      }

      await _cargarContenidos();

      if (!mounted) return false;

      _mostrarMensaje('Contenido creado correctamente.');
      return true;
    } catch (error, stackTrace) {
      debugPrint('ERROR AL CREAR CONTENIDO: $error');
      debugPrint('$stackTrace');

      if (!mounted) return false;

      _mostrarMensaje(_limpiarError(error), esError: true);
      return false;
    }
  }

  void _mostrarFormularioEditar(SitioContenidoModel contenido) {
    showDialog<bool>(
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
          required List<String> imagenesAConservar,
          List<AudioGuiaBorrador>? audiosNuevos,
          List<String>? audiosAEliminar,
        }) {
          return _actualizarContenido(
            contenido,
            titulo: titulo,
            descripcion: descripcion,
            imagenPrincipal: imagenPrincipal,
            imagenes: imagenes,
            imagenesAConservar: imagenesAConservar,
            audiosNuevos: audiosNuevos ?? [],
            audiosAEliminar: audiosAEliminar ?? [],
          );
        },
      ),
    );
  }

  Future<bool> _actualizarContenido(
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
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception('No hay una sesión activa.');
      }

      await _contenidoService.actualizarContenido(
        token: sesion.token,
        contenidoId: contenido.id,
        titulo: titulo,
        descripcion: descripcion,
        imagenes: imagenesAConservar,
      );

      if (imagenPrincipal != null || imagenes.isNotEmpty) {
        await _contenidoService.subirImagenesContenido(
          token: sesion.token,
          contenidoId: contenido.id,
          imagenPrincipal: imagenPrincipal,
          imagenes: imagenes,
        );
      }

      for (final audioId in audiosAEliminar) {
        await _contenidoService.eliminarAudioGuia(
          token: sesion.token,
          contenidoId: contenido.id,
          audioId: audioId,
        );
      }

      for (final audio in audiosNuevos) {
        if (audio.titulo.trim().isEmpty) {
          throw Exception('Cada audioguía debe tener un título.');
        }

        await _contenidoService.subirAudioGuia(
          token: sesion.token,
          contenidoId: contenido.id,
          archivo: audio.archivo,
          titulo: audio.titulo.trim(),
          descripcion: audio.descripcion.trim(),
        );
      }

      await _cargarContenidos();

      if (!mounted) return false;

      _mostrarMensaje('Contenido actualizado correctamente.');
      return true;
    } catch (error, stackTrace) {
      debugPrint('ERROR AL ACTUALIZAR CONTENIDO: $error');
      debugPrint('$stackTrace');

      if (!mounted) return false;

      _mostrarMensaje(_limpiarError(error), esError: true);
      return false;
    }
  }

  Future<void> _enviarRevision(
    SitioContenidoModel contenido,
  ) async {
    if (contenido.estadoPublicacion == 'pendiente_revision') {
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

      _mostrarMensaje('Contenido enviado a revisión correctamente.');
    } catch (error, stackTrace) {
      debugPrint('ERROR AL ENVIAR A REVISIÓN: $error');
      debugPrint('$stackTrace');

      if (!mounted) return;

      _mostrarMensaje(_limpiarError(error), esError: true);
    }
  }

  Future<void> _eliminarContenido(
    SitioContenidoModel contenido,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.sitioSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.sitioErrorSoft,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.sitioError,
            size: 30,
          ),
        ),
        title: const Text(
          'Eliminar contenido',
          style: TextStyle(
            color: AppColors.sitioTextPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar '
          '"${contenido.titulo}"?\n\n'
          'Esta acción no se puede deshacer.',
          style: const TextStyle(
            color: AppColors.sitioTextSecondary,
            height: 1.5,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.sitioTextSecondary,
            ),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.sitioError,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception('No hay una sesión activa.');
      }

      await _contenidoService.eliminarContenido(
        token: sesion.token,
        contenidoId: contenido.id,
      );

      if (!mounted) return;

      setState(() {
        _contenidos.removeWhere(
          (item) => item.id == contenido.id,
        );
      });

      _mostrarMensaje('Contenido eliminado correctamente.');
    } catch (error, stackTrace) {
      debugPrint('ERROR AL ELIMINAR CONTENIDO: $error');
      debugPrint('$stackTrace');

      if (!mounted) return;

      _mostrarMensaje(_limpiarError(error), esError: true);
    }
  }

  Widget _estadoVacio() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(
            AppDimensions.sitioPagePadding,
          ),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 30,
            ),
            decoration: BoxDecoration(
              color: AppColors.sitioSurface,
              borderRadius: BorderRadius.circular(
                AppDimensions.sitioPanelCardRadius,
              ),
              border: Border.all(color: AppColors.sitioBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppColors.sitioSurfaceGreen,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.article_outlined,
                    size: 40,
                    color: AppColors.sitioPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aún no tienes contenido turístico',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.sitioTextPrimary,
                    fontSize: 19,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Crea contenido para presentar las experiencias '
                  'de tu sitio a los visitantes. Puedes agregar '
                  'descripciones, fotografías y audioguías.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.sitioTextSecondary,
                    height: 1.6,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _mostrarFormularioNuevo,
                    style: _estiloBotonPrincipal(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Crear contenido'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _estadoError() {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 440),
          margin: const EdgeInsets.all(
            AppDimensions.sitioPagePadding,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.sitioSurface,
            borderRadius: BorderRadius.circular(
              AppDimensions.sitioPanelCardRadius,
            ),
            border: Border.all(color: AppColors.sitioBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.sitioErrorSoft,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 32,
                  color: AppColors.sitioError,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No pudimos cargar tus contenidos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.sitioTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _error ?? 'Ocurrió un error inesperado.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.sitioTextSecondary,
                  height: 1.5,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _cargarContenidos,
                style: _estiloBotonPrincipal(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Intentar nuevamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirEncabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.sitioPrimaryDark,
            AppColors.sitioPrimary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boton = ElevatedButton.icon(
            onPressed: _mostrarFormularioNuevo,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sitioAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Nuevo contenido'),
          );

          final informacion = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.sitioAccent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contenido turístico',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Cuenta las historias de tu sitio con '
                      'descripciones, fotografías y audioguías.',
                      style: TextStyle(
                        color: Color(0xFFE3EAE4),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                informacion,
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: boton,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: informacion),
              const SizedBox(width: 16),
              boton,
            ],
          );
        },
      ),
    );
  }

  Widget _construirLista() {
    return RefreshIndicator(
      color: AppColors.sitioPrimary,
      backgroundColor: AppColors.sitioSurface,
      onRefresh: _cargarContenidos,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 4,
          bottom: AppDimensions.sitioSectionGap,
        ),
        itemCount: _contenidos.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (_, index) {
          final contenido = _contenidos[index];

          return TarjetaContenidoSitio(
            contenido: contenido,
            onEditar: () => _mostrarFormularioEditar(contenido),
            onEnviarRevision: () => _enviarRevision(contenido),
            onEliminar: () => _eliminarContenido(contenido),
          );
        },
      ),
    );
  }

  Widget _construirContenidoPrincipal() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.sitioPrimary,
        ),
      );
    }

    if (_error != null) return _estadoError();

    if (_contenidos.isEmpty) return _estadoVacio();

    return _construirLista();
  }

  void _mostrarMensaje(
    String mensaje, {
    bool esError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: esError
              ? AppColors.sitioError
              : AppColors.sitioPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  ButtonStyle _estiloBotonPrincipal() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.sitioPrimary,
      foregroundColor: AppColors.sitioTextOnPrimary,
      minimumSize: const Size(0, 46),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sitioBackground,
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.sitioPagePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construirEncabezado(),
            const SizedBox(height: AppDimensions.sitioSectionGap),
            Expanded(
              child: _construirContenidoPrincipal(),
            ),
          ],
        ),
      ),
    );
  }
}