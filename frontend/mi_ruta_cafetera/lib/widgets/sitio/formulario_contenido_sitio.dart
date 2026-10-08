import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/sitio/sitio_contenido_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

typedef GuardarContenidoCallback = Future<bool> Function({
  required String titulo,
  required String descripcion,
  XFile? imagenPrincipal,
  required List<XFile> imagenes,
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
    try {
      final imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imagen == null || !mounted) return;

      setState(() {
        _imagenPrincipalSeleccionada = imagen;
      });
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

      setState(() {
        _imagenesSeleccionadas.addAll(imagenes);
      });
    } catch (_) {
      _mostrarMensaje(
        'No fue posible seleccionar las imágenes.',
        esError: true,
      );
    }
  }

  void _eliminarImagenSeleccionada(int index) {
    setState(() {
      _imagenesSeleccionadas.removeAt(index);
    });
  }

  bool _validarFormulario() {
    final titulo = _tituloController.text.trim();
    final descripcion = _descripcionController.text.trim();

    if (titulo.length < 2) {
      _mostrarMensaje(
        'El título es obligatorio.',
        esError: true,
      );
      return false;
    }

    if (descripcion.length < 10) {
      _mostrarMensaje(
        'La descripción debe tener al menos 10 caracteres.',
        esError: true,
      );
      return false;
    }

    return true;
  }

  Future<void> _guardar() async {
    if (!_validarFormulario()) return;

    setState(() {
      _guardando = true;
    });

    try {
      final resultado = await widget.onGuardar(
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        imagenPrincipal: _imagenPrincipalSeleccionada,
        imagenes: _imagenesSeleccionadas,
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

    setState(() {
      _guardando = false;
    });
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
                onPressed: _guardando
                    ? null
                    : _seleccionarImagenPrincipal,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Cambiar'),
              ),
              TextButton.icon(
                onPressed: _guardando
                    ? null
                    : () {
                        setState(() {
                          _imagenPrincipalSeleccionada = null;
                        });
                      },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Quitar'),
              ),
            ],
          ),
        ],
      );
    }

    final existente =
        widget.contenidoExistente?.imagenPrincipal;

    if (existente != null && existente.isNotEmpty) {
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
            onPressed: _guardando
                ? null
                : _seleccionarImagenPrincipal,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Reemplazar imagen principal'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _marcoImagenVacia(
          alto: 180,
          icono: Icons.image_outlined,
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        OutlinedButton.icon(
          onPressed: _guardando
              ? null
              : _seleccionarImagenPrincipal,
          icon: const Icon(
            Icons.add_photo_alternate_outlined,
          ),
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
        childAspectRatio: 1,
      ),
      itemBuilder: (_, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            _vistaPreviaImagen(
              _imagenesSeleccionadas[index],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: AppColors.coffeeDark.withValues(
                  alpha: 0.75,
                ),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _guardando
                      ? null
                      : () {
                          _eliminarImagenSeleccionada(index);
                        },
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
    final imagenes =
        widget.contenidoExistente?.imagenes ?? [];

    if (imagenes.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imagenes.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, index) {
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
          builder: (_, snapshot) {
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

  Widget _construirInformacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información del contenido',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
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
          minLines: 5,
          maxLines: 8,
          decoration: InputDecoration(
            labelText: 'Descripción',
            hintText: 'Describe la experiencia turística...',
            alignLabelWithHint: true,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 70),
              child: Icon(Icons.description_outlined),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirSeccionImagenes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imagen principal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        const Text(
          'Será la imagen principal que representará este contenido.',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        _construirImagenPrincipal(),
        const SizedBox(height: AppDimensions.spacingXl),
        const Text(
          'Galería de imágenes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          _esEdicion
              ? 'Puedes agregar nuevas imágenes al carrusel.'
              : 'Selecciona las imágenes que formarán el carrusel.',
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        OutlinedButton.icon(
          onPressed:
              _guardando ? null : _seleccionarGaleria,
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Seleccionar imágenes'),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        _construirGaleriaSeleccionada(),
        if (_esEdicion) ...[
          const SizedBox(height: AppDimensions.spacingLg),
          const Text(
            'Imágenes actuales',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          _construirGaleriaExistente(),
        ],
      ],
    );
  }

  Widget _construirAcciones() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _guardando
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        ElevatedButton.icon(
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 720,
          maxHeight: 850,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppDimensions.spacingLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(
                    width: AppDimensions.spacingMd,
                  ),
                  Expanded(
                    child: Text(
                      widget.tituloDialogo,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _guardando
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(
                height: AppDimensions.spacingLg,
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _construirInformacion(),
                      const SizedBox(
                        height: AppDimensions.spacingXl,
                      ),
                      _construirSeccionImagenes(),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingLg,
              ),
              _construirAcciones(),
            ],
          ),
        ),
      ),
    );
  }
}