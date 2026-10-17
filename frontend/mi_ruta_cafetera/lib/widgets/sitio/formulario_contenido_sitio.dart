
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/sitio/sitio_contenido_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import 'audio_guia_borrador.dart';
import 'seccion_audioguias.dart';

typedef GuardarContenidoCallback = Future<bool> Function({
  required String titulo,
  required String descripcion,
  XFile? imagenPrincipal,
  required List<XFile> imagenes,
  List<AudioGuiaBorrador>? audiosNuevos,
  List<String>? audiosAEliminar,
});

class FormularioContenidoSitio extends StatefulWidget {
  final String tituloDialogo;
  final String textoBoton;
  final SitioContenidoModel? contenidoExistente;
  final GuardarContenidoCallback onGuardar;

  const FormularioContenidoSitio({
    super.key,
    required this.tituloDialogo,
    required this.textoBoton,
    required this.contenidoExistente,
    required this.onGuardar,
  });

  @override
  State<FormularioContenidoSitio> createState() =>
      _FormularioContenidoSitioState();
}

class _FormularioContenidoSitioState
    extends State<FormularioContenidoSitio> {
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _tituloController;
  late final TextEditingController _descripcionController;

  XFile? _imagenPrincipalSeleccionada;
  final List<XFile> _imagenesSeleccionadas = [];

  final List<AudioGuiaBorrador> _audiosNuevos = [];
  final Set<String> _audiosAEliminar = {};

  bool _guardando = false;

  bool get _esEdicion => widget.contenidoExistente != null;

  @override
  void initState() {
    super.initState();

    _tituloController = TextEditingController(
      text: widget.contenidoExistente?.titulo ?? '',
    );

    _descripcionController = TextEditingController(
      text: widget.contenidoExistente?.descripcion ?? '',
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagenPrincipal() async {
    if (_guardando) return;

    try {
      final imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imagen == null || !mounted) return;

      setState(() => _imagenPrincipalSeleccionada = imagen);
    } catch (_) {
      _mostrarMensaje(
        'No fue posible seleccionar la imagen.',
        esError: true,
      );
    }
  }

  Future<void> _seleccionarGaleria() async {
    if (_guardando) return;

    try {
      final imagenes = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (imagenes.isEmpty || !mounted) return;

      setState(() {
        final rutasActuales =
            _imagenesSeleccionadas.map((imagen) => imagen.path).toSet();

        _imagenesSeleccionadas.addAll(
          imagenes.where(
            (imagen) => !rutasActuales.contains(imagen.path),
          ),
        );
      });
    } catch (_) {
      _mostrarMensaje(
        'No fue posible seleccionar las imágenes.',
        esError: true,
      );
    }
  }

  void _eliminarImagenSeleccionada(int index) {
    if (_guardando) return;

    setState(() => _imagenesSeleccionadas.removeAt(index));
  }

  Widget _marcoImagenVacia({
    double? alto,
    IconData icono = Icons.image_outlined,
  }) {
    return Container(
      width: double.infinity,
      height: alto,
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceGreen,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioFormRadius,
        ),
      ),
      child: Icon(
        icono,
        size: 38,
        color: AppColors.sitioPrimary,
      ),
    );
  }

  Widget _vistaPreviaImagen(
    XFile imagen, {
    double? alto,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AppDimensions.sitioFormRadius,
      ),
      child: SizedBox(
        width: double.infinity,
        height: alto,
        child: FutureBuilder(
          future: imagen.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.sitioPrimary,
                  strokeWidth: 2,
                ),
              );
            }

            if (!snapshot.hasData) {
              return _marcoImagenVacia(
                alto: alto,
                icono: Icons.broken_image_outlined,
              );
            }

            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _marcoImagenVacia(
                alto: alto,
                icono: Icons.broken_image_outlined,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _construirImagenPrincipal() {
    final seleccionada = _imagenPrincipalSeleccionada;

    if (seleccionada != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _vistaPreviaImagen(seleccionada, alto: 210),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _guardando ? null : _seleccionarImagenPrincipal,
                style: _estiloBotonSecundario(),
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                label: const Text('Cambiar portada'),
              ),
              TextButton.icon(
                onPressed: _guardando
                    ? null
                    : () => setState(
                          () => _imagenPrincipalSeleccionada = null,
                        ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.sitioError,
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Descartar nueva'),
              ),
            ],
          ),
        ],
      );
    }

    final existente =
        widget.contenidoExistente?.imagenPrincipal.trim() ?? '';

    if (existente.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppDimensions.sitioFormRadius,
            ),
            child: Image.network(
              existente,
              width: double.infinity,
              height: 210,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _marcoImagenVacia(
                alto: 210,
                icono: Icons.broken_image_outlined,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _guardando ? null : _seleccionarImagenPrincipal,
            style: _estiloBotonSecundario(),
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: const Text('Reemplazar portada'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _marcoImagenVacia(alto: 180),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _guardando ? null : _seleccionarImagenPrincipal,
            style: _estiloBotonSecundario(),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Seleccionar portada'),
          ),
        ),
      ],
    );
  }

  Widget _construirGaleriaSeleccionada() {
    if (_imagenesSeleccionadas.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 22,
        ),
        decoration: BoxDecoration(
          color: AppColors.sitioSurfaceSoft,
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
          border: Border.all(
            color: AppColors.sitioBorder,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.collections_outlined,
              size: 30,
              color: AppColors.sitioTextSecondary,
            ),
            SizedBox(height: 8),
            Text(
              'Todavía no has agregado imágenes nuevas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.sitioTextSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = constraints.maxWidth < 300
            ? 2
            : constraints.maxWidth < 460
                ? 3
                : 4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _imagenesSeleccionadas.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.88,
          ),
          itemBuilder: (context, index) {
            return Stack(
              fit: StackFit.expand,
              children: [
                _vistaPreviaImagen(_imagenesSeleccionadas[index]),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    tooltip: 'Quitar imagen',
                    onPressed: _guardando
                        ? null
                        : () => _eliminarImagenSeleccionada(index),
                    constraints: const BoxConstraints(
                      minWidth: 34,
                      minHeight: 34,
                    ),
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.sitioPrimaryDark
                          .withValues(alpha: 0.88),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _construirGaleriaExistente() {
    final imagenes = widget.contenidoExistente?.imagenes ?? [];

    if (imagenes.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = constraints.maxWidth < 300
            ? 2
            : constraints.maxWidth < 460
                ? 3
                : 4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: imagenes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.88,
          ),
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(
                AppDimensions.sitioItemImageRadius,
              ),
              child: Image.network(
                imagenes[index],
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _marcoImagenVacia(
                  icono: Icons.broken_image_outlined,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _tituloSeccion(
    String titulo, {
    IconData? icono,
  }) {
    return Row(
      children: [
        if (icono != null) ...[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.sitioSurfaceGreen,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icono,
              size: 19,
              color: AppColors.sitioPrimary,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w800,
              color: AppColors.sitioTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tarjeta(Widget contenido) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.sitioPanelCardPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurface,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        border: Border.all(
          color: AppColors.sitioBorder,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: contenido,
    );
  }

  Widget _construirInformacion() {
    return _tarjeta(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion(
            'Información del contenido',
            icono: Icons.description_outlined,
          ),
          const SizedBox(height: 9),
          const Text(
            'Completa la información que verán los visitantes.',
            style: TextStyle(
              color: AppColors.sitioTextSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _campo(
            controller: _tituloController,
            etiqueta: 'Título',
            pista: 'Ej. Experiencia del café especial',
            icono: Icons.title_rounded,
            maxLength: 120,
          ),
          const SizedBox(height: 14),
          _campo(
            controller: _descripcionController,
            etiqueta: 'Descripción',
            pista: 'Describe la experiencia turística...',
            icono: Icons.notes_rounded,
            maxLines: 5,
            maxLength: 1500,
          ),
        ],
      ),
    );
  }

  Widget _construirSeccionImagenes() {
    return _tarjeta(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion(
            'Imagen principal',
            icono: Icons.image_outlined,
          ),
          const SizedBox(height: 12),
          _construirImagenPrincipal(),
          const SizedBox(height: 24),
          _tituloSeccion(
            'Galería de imágenes',
            icono: Icons.photo_library_outlined,
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega fotografías complementarias para mostrar '
            'mejor la experiencia.',
            style: TextStyle(
              color: AppColors.sitioTextSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _guardando ? null : _seleccionarGaleria,
              style: _estiloBotonSecundario(),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Agregar fotografías'),
            ),
          ),
          const SizedBox(height: 14),
          _construirGaleriaSeleccionada(),
          if (_esEdicion &&
              (widget.contenidoExistente?.imagenes.isNotEmpty ?? false)) ...[
            const SizedBox(height: 22),
            _tituloSeccion(
              'Imágenes actuales',
              icono: Icons.collections_outlined,
            ),
            const SizedBox(height: 12),
            _construirGaleriaExistente(),
          ],
        ],
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String etiqueta,
    required String pista,
    required IconData icono,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      enabled: !_guardando,
      minLines: maxLines == 1 ? 1 : maxLines,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(
        color: AppColors.sitioTextPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: pista,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: maxLines == 1
            ? Icon(
                icono,
                color: AppColors.sitioPrimary,
                size: 20,
              )
            : null,
        filled: true,
        fillColor: AppColors.sitioSurfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        labelStyle: const TextStyle(
          color: AppColors.sitioTextSecondary,
          fontSize: 13,
        ),
        hintStyle: const TextStyle(
          color: AppColors.sitioTextSecondary,
          fontSize: 12,
        ),
        counterStyle: const TextStyle(
          color: AppColors.sitioTextSecondary,
          fontSize: 11,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.sitioBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.sitioPrimary,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.sitioDivider,
          ),
        ),
      ),
    );
  }

  Widget _construirAcciones() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cancelar = OutlinedButton(
          onPressed: _guardando
              ? null
              : () => Navigator.of(context).pop(),
          style: _estiloBotonSecundario(),
          child: const Text('Cancelar'),
        );

        final guardar = ElevatedButton.icon(
          onPressed: _guardando ? null : _guardar,
          style: _estiloBotonPrincipal(),
          icon: _guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_outlined, size: 19),
          label: Text(
            _guardando ? 'Guardando...' : widget.textoBoton,
            overflow: TextOverflow.ellipsis,
          ),
        );

        if (constraints.maxWidth < 390) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              guardar,
              const SizedBox(height: 8),
              cancelar,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cancelar),
            const SizedBox(width: 12),
            Expanded(child: guardar),
          ],
        );
      },
    );
  }

  bool _validarFormulario() {
    if (_tituloController.text.trim().length < 2) {
      _mostrarMensaje(
        'El título debe tener al menos 2 caracteres.',
        esError: true,
      );
      return false;
    }

    if (_descripcionController.text.trim().length < 10) {
      _mostrarMensaje(
        'La descripción debe tener al menos 10 caracteres.',
        esError: true,
      );
      return false;
    }

    for (final audio in _audiosNuevos) {
      if (audio.titulo.trim().length < 2) {
        _mostrarMensaje(
          'Cada audioguía debe tener un título válido.',
          esError: true,
        );
        return false;
      }
    }

    return true;
  }

  Future<void> _guardar() async {
    if (_guardando || !_validarFormulario()) return;

    setState(() => _guardando = true);

    try {
      final resultado = await widget.onGuardar(
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        imagenPrincipal: _imagenPrincipalSeleccionada,
        imagenes: List<XFile>.from(_imagenesSeleccionadas),
        audiosNuevos: List<AudioGuiaBorrador>.from(_audiosNuevos),
        audiosAEliminar: List<String>.from(_audiosAEliminar),
      );

      if (!mounted) return;

      if (resultado) {
        Navigator.of(context).pop();
        return;
      }
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );
    }

    if (!mounted) return;
    setState(() => _guardando = false);
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
        horizontal: 16,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  ButtonStyle _estiloBotonSecundario() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.sitioPrimary,
      side: const BorderSide(
        color: AppColors.sitioBorder,
      ),
      minimumSize: const Size(0, 44),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alto = MediaQuery.sizeOf(context).height;
    final compacto = MediaQuery.sizeOf(context).width < 600;

    return Dialog(
      backgroundColor: AppColors.sitioBackground,
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: compacto ? 10 : 24,
        vertical: compacto ? 12 : 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: alto * 0.92,
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 10, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.sitioPrimaryDark,
                    AppColors.sitioPrimary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Icon(
                      _esEdicion
                          ? Icons.edit_note_rounded
                          : Icons.auto_stories_rounded,
                      color: AppColors.sitioAccent,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tituloDialogo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _esEdicion
                              ? 'Actualiza la historia de tu sitio'
                              : 'Comparte las experiencias de tu sitio',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: _guardando
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(
                        alpha: 0.10,
                      ),
                    ),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  compacto ? 12 : 18,
                ),
                child: Column(
                  children: [
                    _construirInformacion(),
                    const SizedBox(height: 16),
                    _construirSeccionImagenes(),
                    const SizedBox(height: 16),
                    SeccionAudioguias(
                      audiosNuevos: _audiosNuevos,
                      audiosExistentes:
                          widget.contenidoExistente?.audioGuias ?? [],
                      audiosAEliminar: _audiosAEliminar,
                      deshabilitado: _guardando,
                      onAudiosNuevosChanged: (audios) {
                        setState(() {
                          _audiosNuevos
                            ..clear()
                            ..addAll(audios);
                        });
                      },
                      onAudiosAEliminarChanged: (ids) {
                        setState(() {
                          _audiosAEliminar
                            ..clear()
                            ..addAll(ids);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(compacto ? 12 : 16),
              decoration: const BoxDecoration(
                color: AppColors.sitioSurface,
                border: Border(
                  top: BorderSide(
                    color: AppColors.sitioDivider,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: _construirAcciones(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
