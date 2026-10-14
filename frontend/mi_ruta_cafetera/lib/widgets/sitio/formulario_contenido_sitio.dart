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

  // ============================================================
  // IMÁGENES
  // ============================================================

  Future<void> _seleccionarImagenPrincipal() async {
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
    try {
      final imagenes = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (imagenes.isEmpty || !mounted) return;

      setState(() => _imagenesSeleccionadas.addAll(imagenes));
    } catch (_) {
      _mostrarMensaje(
        'No fue posible seleccionar las imágenes.',
        esError: true,
      );
    }
  }

  void _eliminarImagenSeleccionada(int index) {
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
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
      ),
      child: Icon(
        icono,
        size: AppDimensions.iconLg,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _vistaPreviaImagen(
    XFile imagen, {
    double? alto,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusMd,
      ),
      child: SizedBox(
        width: double.infinity,
        height: alto,
        child: FutureBuilder(
          future: imagen.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
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
          const SizedBox(height: AppDimensions.spacingSm),
          Wrap(
            spacing: AppDimensions.spacingSm,
            children: [
              OutlinedButton.icon(
                onPressed:
                    _guardando ? null : _seleccionarImagenPrincipal,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Cambiar'),
              ),
              TextButton.icon(
                onPressed: _guardando
                    ? null
                    : () => setState(
                          () => _imagenPrincipalSeleccionada = null,
                        ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Quitar'),
              ),
            ],
          ),
        ],
      );
    }

    final existente =
        widget.contenidoExistente?.imagenPrincipal ?? '';

    if (existente.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMd,
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
          const SizedBox(height: AppDimensions.spacingSm),
          OutlinedButton.icon(
            onPressed:
                _guardando ? null : _seleccionarImagenPrincipal,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Reemplazar imagen principal'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _marcoImagenVacia(alto: 180),
        const SizedBox(height: AppDimensions.spacingSm),
        OutlinedButton.icon(
          onPressed:
              _guardando ? null : _seleccionarImagenPrincipal,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Seleccionar imagen principal'),
        ),
      ],
    );
  }

  Widget _construirGaleriaSeleccionada() {
    if (_imagenesSeleccionadas.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _imagenesSeleccionadas.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            _vistaPreviaImagen(_imagenesSeleccionadas[index]),
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: AppColors.coffeeDark.withValues(alpha: 0.75),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _guardando
                      ? null
                      : () => _eliminarImagenSeleccionada(index),
                  child: const Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: AppDimensions.iconSm,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _construirGaleriaExistente() {
    final imagenes = widget.contenidoExistente?.imagenes ?? [];

    if (imagenes.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imagenes.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusSm,
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
  }

  // ============================================================
  // SECCIONES DEL FORMULARIO
  // ============================================================

  Widget _tituloSeccion(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.secondary,
      ),
    );
  }

  Widget _tarjeta(Widget contenido) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXxl,
        ),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
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
          _tituloSeccion('Información del contenido'),
          const SizedBox(height: AppDimensions.spacingSm),
          const Text(
            'Completa la información que verán los visitantes.',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          TextField(
            controller: _tituloController,
            enabled: !_guardando,
            decoration: InputDecoration(
              labelText: 'Título',
              hintText: 'Ej. Experiencia del café especial',
              prefixIcon: const Icon(Icons.title_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          TextField(
            controller: _descripcionController,
            enabled: !_guardando,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: 'Descripción',
              hintText: 'Describe la experiencia turística...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
              ),
            ),
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
          _tituloSeccion('Imagen principal'),
          const SizedBox(height: AppDimensions.spacingSm),
          _construirImagenPrincipal(),
          const SizedBox(height: AppDimensions.spacingXl),
          _tituloSeccion('Galería de imágenes'),
          const SizedBox(height: AppDimensions.spacingSm),
          const Text(
            'Agrega las imágenes que aparecerán en el carrusel.',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          OutlinedButton.icon(
            onPressed: _guardando ? null : _seleccionarGaleria,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Seleccionar imágenes'),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _construirGaleriaSeleccionada(),
          if (_esEdicion &&
              (widget.contenidoExistente?.imagenes.isNotEmpty ??
                  false)) ...[
            const SizedBox(height: AppDimensions.spacingLg),
            _tituloSeccion('Imágenes actuales'),
            const SizedBox(height: AppDimensions.spacingSm),
            _construirGaleriaExistente(),
          ],
        ],
      ),
    );
  }

  Widget _construirAcciones() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cancelar = OutlinedButton(
          onPressed:
              _guardando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        );

        final guardar = ElevatedButton.icon(
          onPressed: _guardando ? null : _guardar,
          icon: _guardando
              ? const SizedBox(
                  width: AppDimensions.iconSm,
                  height: AppDimensions.iconSm,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save_outlined),
          label: Text(widget.textoBoton),
        );

        if (constraints.maxWidth < 390) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              guardar,
              const SizedBox(height: AppDimensions.spacingSm),
              cancelar,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cancelar),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(child: guardar),
          ],
        );
      },
    );
  }

  // ============================================================
  // VALIDACIÓN Y GUARDADO
  // ============================================================

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor:
            esError ? AppColors.error : AppColors.primary,
      ),
    );
  }

  // ============================================================
  // INTERFAZ PRINCIPAL
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final alto = MediaQuery.sizeOf(context).height;
    final compacto = MediaQuery.sizeOf(context).width < 600;

    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: EdgeInsets.all(
        compacto
            ? AppDimensions.spacingSm
            : AppDimensions.spacingLg,
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: alto * 0.92,
        ),
        child: Padding(
          padding: EdgeInsets.all(
            compacto
                ? AppDimensions.spacingMd
                : AppDimensions.spacingLg,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGreen,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: const Icon(
                      Icons.article_outlined,
                      color: AppColors.textOnDark,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Text(
                      widget.tituloDialogo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: _guardando
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _construirInformacion(),
                      const SizedBox(height: AppDimensions.spacingLg),
                      _construirSeccionImagenes(),
                      const SizedBox(height: AppDimensions.spacingLg),
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
              const Divider(height: AppDimensions.spacingLg),
              SafeArea(
                top: false,
                child: _construirAcciones(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}