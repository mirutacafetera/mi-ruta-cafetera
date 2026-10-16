import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/sitio/sitio_producto_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

typedef GuardarProductoCallback =
    Future<void> Function({
      required String nombre,
      required String descripcion,
      required double precio,
      required String categoria,
      required List<XFile> imagenes,
    });

class FormularioProductoSitio extends StatefulWidget {
  final SitioProductoModel? producto;
  final GuardarProductoCallback onGuardar;

  const FormularioProductoSitio({
    super.key,
    required this.producto,
    required this.onGuardar,
  });

  @override
  State<FormularioProductoSitio> createState() =>
      _FormularioProductoSitioState();
}

class _FormularioProductoSitioState extends State<FormularioProductoSitio> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _precioController;

  final List<XFile> _imagenes = [];
  final Map<String, Future<Uint8List>> _bytesImagenes = {};

  static const List<String> _categorias = [
    'Cafe',
    'Gastronomia',
    'Artesanias',
    'Dulces y postres',
    'Productos tipicos',
    'Otros',
  ];

  late String _categoria;
  bool _guardando = false;

  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();

    final producto = widget.producto;

    _nombreController = TextEditingController(text: producto?.nombre ?? '');

    _descripcionController = TextEditingController(
      text: producto?.descripcion ?? '',
    );

    _precioController = TextEditingController(
      text: producto != null ? producto.precio.toString() : '',
    );

    _categoria = producto != null && _categorias.contains(producto.categoria)
        ? producto.categoria
        : 'Cafe';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagenes() async {
    if (_guardando) return;

    final disponibles = 10 - _imagenes.length;

    if (disponibles <= 0) {
      _mostrarMensaje('Puedes seleccionar máximo 10 imágenes.');
      return;
    }

    try {
      final seleccionadas = await _imagePicker.pickMultiImage(imageQuality: 85);

      if (!mounted || seleccionadas.isEmpty) return;

      final rutasActuales = _imagenes.map((imagen) => imagen.path).toSet();

      final nuevas = seleccionadas
          .where((imagen) => !rutasActuales.contains(imagen.path))
          .take(disponibles)
          .toList();

      setState(() {
        _imagenes.addAll(nuevas);

        for (final imagen in nuevas) {
          _bytesImagenes[imagen.path] = imagen.readAsBytes();
        }
      });

      if (seleccionadas.length > nuevas.length) {
        _mostrarMensaje(
          'Se agregaron ${nuevas.length} imagen(es). '
          'El máximo es 10.',
        );
      }
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        'No fue posible seleccionar las imágenes: $error',
        esError: true,
      );
    }
  }

  Future<void> _guardar() async {
    if (_guardando || !_formKey.currentState!.validate()) {
      return;
    }

    if (!_esEdicion && _imagenes.isEmpty) {
      _mostrarMensaje(
        'Selecciona al menos una imagen para el producto.',
        esError: true,
      );
      return;
    }

    final precio = double.parse(
      _precioController.text.trim().replaceAll(',', '.'),
    );

    setState(() => _guardando = true);

    try {
      await widget.onGuardar(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        precio: precio,
        categoria: _categoria,
        imagenes: List<XFile>.from(_imagenes),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() => _guardando = false);

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: esError ? AppColors.error : AppColors.primary,
        ),
      );
  }

  Widget _campo({
    required String etiqueta,
    required TextEditingController controller,
    required String? Function(String?) validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? ayuda,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_guardando,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: etiqueta,
        helperText: ayuda,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    );
  }

  Widget _vistaImagen(XFile imagen) {
    final future = _bytesImagenes.putIfAbsent(
      imagen.path,
      () => imagen.readAsBytes(),
    );

    return FutureBuilder<Uint8List>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        }

        return Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      title: Text(
        _esEdicion ? 'Editar producto' : 'Nuevo producto',
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _campo(
                  etiqueta: 'Nombre del producto',
                  controller: _nombreController,
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'El nombre es obligatorio.';
                    }
                    if (valor.trim().length > 120) {
                      return 'Máximo 120 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                _campo(
                  etiqueta: 'Descripción',
                  controller: _descripcionController,
                  maxLines: 4,
                  validator: (valor) {
                    if ((valor ?? '').trim().length > 1500) {
                      return 'Máximo 1500 caracteres.';
                    }
                    return null;
                  },
                  ayuda: 'Describe el producto para los visitantes.',
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                _campo(
                  etiqueta: 'Precio (COP)',
                  controller: _precioController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (valor) {
                    final texto = (valor ?? '').trim().replaceAll(',', '.');
                    final precio = double.tryParse(texto);

                    if (texto.isEmpty || precio == null) {
                      return 'Ingresa un precio válido.';
                    }
                    if (precio < 0) {
                      return 'El precio no puede ser negativo.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                DropdownButtonFormField<String>(
                  initialValue: _categoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: _categorias
                      .map(
                        (categoria) => DropdownMenuItem(
                          value: categoria,
                          child: Text(categoria),
                        ),
                      )
                      .toList(),
                  onChanged: _guardando
                      ? null
                      : (valor) {
                          if (valor != null) {
                            setState(() => _categoria = valor);
                          }
                        },
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                Text(
                  'Fotografías del producto',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  _esEdicion
                      ? 'Puedes agregar nuevas imágenes. '
                            'La gestión de las imágenes existentes '
                            'se realizará en la siguiente integración.'
                      : 'Selecciona al menos una imagen. '
                            'Máximo 10 imágenes por producto.',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                OutlinedButton.icon(
                  onPressed: _guardando ? null : _seleccionarImagenes,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Seleccionar imágenes'),
                ),
                if (_imagenes.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _imagenes.length,
                    itemBuilder: (context, index) {
                      final imagen = _imagenes[index];

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                            child: _vistaImagen(imagen),
                          ),
                          if (index == 0)
                            const Positioned(
                              left: 4,
                              bottom: 4,
                              child: Chip(
                                label: Text(
                                  'Principal',
                                  style: TextStyle(fontSize: 10),
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              onPressed: _guardando
                                  ? null
                                  : () {
                                      setState(() {
                                        _imagenes.removeAt(index);
                                        _bytesImagenes.remove(imagen.path);
                                      });
                                    },
                              icon: const Icon(Icons.close),
                              color: Colors.white,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                              tooltip: 'Quitar imagen',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _guardando ? null : _guardar,
          icon: _guardando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_guardando ? 'Guardando...' : 'Guardar producto'),
        ),
      ],
    );
  }
}
