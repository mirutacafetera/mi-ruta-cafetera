
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/sitio/sitio_actividad_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

typedef GuardarActividadCallback = Future<void> Function({
  required String nombre,
  required String descripcion,
  required double precio,
  required String horario,
  required String duracion,
  required List<XFile> imagenes,
  required List<String> imagenesEliminar,
  required String imagenPrincipalUrl,
});

class FormularioActividadSitio extends StatefulWidget {
  final SitioActividadModel? actividad;
  final GuardarActividadCallback onGuardar;

  const FormularioActividadSitio({
    super.key,
    required this.actividad,
    required this.onGuardar,
  });

  @override
  State<FormularioActividadSitio> createState() =>
      _FormularioActividadSitioState();
}

class _FormularioActividadSitioState
    extends State<FormularioActividadSitio> {
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _precioController;
  late final TextEditingController _horarioController;
  late final TextEditingController _duracionController;

  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _imagenesSeleccionadas = [];
  final Map<String, Future<Uint8List>> _bytesImagenes = {};
  final List<String> _imagenesExistentes = [];
  final List<String> _imagenesEliminar = [];

  String _imagenPrincipalUrl = '';
  String? _imagenPrincipalNueva;
  bool _guardando = false;

  bool get _esEdicion => widget.actividad != null;

  @override
  void initState() {
    super.initState();

    final actividad = widget.actividad;

    _nombreController =
        TextEditingController(text: actividad?.nombre ?? '');
    _descripcionController =
        TextEditingController(text: actividad?.descripcion ?? '');
    _precioController = TextEditingController(
      text: actividad != null && actividad.precio > 0
          ? actividad.precio.toStringAsFixed(0)
          : '',
    );
    _horarioController =
        TextEditingController(text: actividad?.horario ?? '');
    _duracionController =
        TextEditingController(text: actividad?.duracion ?? '');

    if (actividad != null) {
      _imagenPrincipalUrl = actividad.imagenPrincipal;

      _imagenesExistentes.addAll([
        if (actividad.imagenPrincipal.isNotEmpty)
          actividad.imagenPrincipal,
        ...actividad.imagenes.where(
          (url) =>
              url.isNotEmpty && url != actividad.imagenPrincipal,
        ),
      ]);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _horarioController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagenes() async {
    if (_guardando) return;

    final totalActual =
        _imagenesExistentes.length - _imagenesEliminar.length +
        _imagenesSeleccionadas.length;
    final disponibles = 10 - totalActual;

    if (disponibles <= 0) {
      _mostrarError('Una actividad puede tener máximo 10 imágenes.');
      return;
    }

    try {
      final seleccionadas = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (!mounted || seleccionadas.isEmpty) return;

      final existentes = _imagenesSeleccionadas
          .map((imagen) => imagen.path)
          .toSet();

      final nuevas = seleccionadas
          .where((imagen) => !existentes.contains(imagen.path))
          .take(disponibles)
          .toList();

      setState(() {
        _imagenesSeleccionadas.addAll(nuevas);
        for (final imagen in nuevas) {
          _bytesImagenes[imagen.path] = imagen.readAsBytes();
        }

        _imagenPrincipalNueva ??=
            nuevas.isNotEmpty ? nuevas.first.path : null;
      });

      if (seleccionadas.length > nuevas.length) {
        _mostrarError(
          'Se agregaron ${nuevas.length} imagen(es). '
          'El máximo es 10 por actividad.',
        );
      }
    } catch (error) {
      if (!mounted) return;
      _mostrarError('No fue posible seleccionar las imágenes: $error');
    }
  }

  void _quitarImagenExistente(String url) {
    if (_guardando) return;

    setState(() {
      if (!_imagenesEliminar.contains(url)) {
        _imagenesEliminar.add(url);
      }

      if (_imagenPrincipalUrl == url) {
        _imagenPrincipalUrl = '';
      }
    });
  }

  void _restaurarImagenExistente(String url) {
    setState(() {
      _imagenesEliminar.remove(url);
      if (_imagenPrincipalUrl.isEmpty) {
        _imagenPrincipalUrl = url;
      }
    });
  }

  void _quitarImagenNueva(XFile imagen) {
    if (_guardando) return;

    setState(() {
      _imagenesSeleccionadas.remove(imagen);
      _bytesImagenes.remove(imagen.path);

      if (_imagenPrincipalNueva == imagen.path) {
        _imagenPrincipalNueva = _imagenesSeleccionadas.isNotEmpty
            ? _imagenesSeleccionadas.first.path
            : null;
      }
    });
  }

  Future<void> _guardar() async {
    if (_guardando) return;

    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      _mostrarError('El nombre de la actividad es obligatorio.');
      return;
    }

    final precioTexto =
        _precioController.text.trim().replaceAll(',', '.');
    final precio = double.tryParse(precioTexto) ?? 0;

    if (precio < 0) {
      _mostrarError('El precio no puede ser negativo.');
      return;
    }

    setState(() => _guardando = true);

    try {
      await widget.onGuardar(
        nombre: nombre,
        descripcion: _descripcionController.text.trim(),
        precio: precio,
        horario: _horarioController.text.trim(),
        duracion: _duracionController.text.trim(),
        imagenes: List<XFile>.from(_imagenesSeleccionadas),
        imagenesEliminar: List<String>.from(_imagenesEliminar),
        imagenPrincipalUrl: _imagenPrincipalUrl,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      _mostrarError(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: AppColors.error,
        ),
      );
  }

  Widget _vistaNueva(XFile imagen) {
    final bytes = _bytesImagenes.putIfAbsent(
      imagen.path,
      () => imagen.readAsBytes(),
    );

    return FutureBuilder<Uint8List>(
      future: bytes,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          );
        }

        return Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Icon(
            Icons.broken_image_outlined,
          ),
        );
      },
    );
  }

  Widget _miniatura({
    required Widget imagen,
    required bool principal,
    required VoidCallback alTocarPrincipal,
    required VoidCallback alQuitar,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: imagen,
        ),
        Positioned(
          left: 4,
          bottom: 4,
          child: Material(
            color: principal ? AppColors.primary : Colors.black54,
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            child: InkWell(
              onTap: _guardando ? null : alTocarPrincipal,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 5,
                ),
                child: Text(
                  principal ? 'Principal' : 'Hacer principal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 3,
          top: 3,
          child: IconButton(
            onPressed: _guardando ? null : alQuitar,
            tooltip: 'Quitar imagen',
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.close, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _construirSeccionImagenes() {
    final existentesVisibles = _imagenesExistentes
        .where((url) => !_imagenesEliminar.contains(url))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imágenes de la actividad',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          'Máximo 10 imágenes. Pulsa “Hacer principal” '
          'para elegir la imagen de portada.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        OutlinedButton.icon(
          onPressed: _guardando ? null : _seleccionarImagenes,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Seleccionar imágenes'),
        ),
        if (existentesVisibles.isNotEmpty ||
            _imagenesSeleccionadas.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacingMd),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                existentesVisibles.length + _imagenesSeleccionadas.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppDimensions.spacingSm,
              mainAxisSpacing: AppDimensions.spacingSm,
            ),
            itemBuilder: (context, index) {
              if (index < existentesVisibles.length) {
                final url = existentesVisibles[index];
                return _miniatura(
                  imagen: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                  principal: _imagenPrincipalUrl == url,
                  alTocarPrincipal: () {
                    setState(() {
                      _imagenPrincipalUrl = url;
                      _imagenPrincipalNueva = null;
                    });
                  },
                  alQuitar: () => _quitarImagenExistente(url),
                );
              }

              final imagen =
                  _imagenesSeleccionadas[index - existentesVisibles.length];

              return _miniatura(
                imagen: _vistaNueva(imagen),
                principal: _imagenPrincipalNueva == imagen.path &&
                    _imagenPrincipalUrl.isEmpty,
                alTocarPrincipal: () {
                  setState(() {
                    _imagenPrincipalNueva = imagen.path;
                    _imagenPrincipalUrl = '';
                  });
                },
                alQuitar: () => _quitarImagenNueva(imagen),
              );
            },
          ),
        ],
        if (_imagenesEliminar.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            '${_imagenesEliminar.length} imagen(es) se eliminarán al guardar.',
            style: TextStyle(color: AppColors.error),
          ),
          Wrap(
            spacing: 8,
            children: _imagenesEliminar
                .map(
                  (url) => ActionChip(
                    label: const Text('Restaurar imagen'),
                    onPressed: _guardando
                        ? null
                        : () => _restaurarImagenExistente(url),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 800,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_activity_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Text(
                      _esEdicion ? 'Editar actividad' : 'Nueva actividad',
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
              const SizedBox(height: AppDimensions.spacingLg),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _campo(_nombreController, 'Nombre'),
                      _campo(_descripcionController, 'Descripción',
                          maxLines: 4),
                      _campo(_precioController, 'Precio'),
                      _campo(_horarioController, 'Horario'),
                      _campo(_duracionController, 'Duración'),
                      const SizedBox(height: AppDimensions.spacingLg),
                      _construirSeccionImagenes(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              Row(
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
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_guardando ? 'Guardando...' : 'Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String etiqueta, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: TextField(
        controller: controller,
        enabled: !_guardando,
        maxLines: maxLines,
        keyboardType: etiqueta == 'Precio'
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
    );
  }
}
