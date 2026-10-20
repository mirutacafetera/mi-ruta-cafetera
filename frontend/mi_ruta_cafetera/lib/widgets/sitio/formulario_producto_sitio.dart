
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/sitio/sitio_producto_model.dart';
import '../../theme/app_colors.dart';

typedef GuardarProductoCallback = Future<void> Function({
  required String nombre,
  required String descripcion,
  required double precio,
  required String categoria,
  required List<XFile> imagenes,
  required List<String> imagenesConservar,
  required String imagenPrincipalActual,
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

  late List<String> _imagenesExistentes;
  late String _imagenPrincipal;

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

  int get _cantidadImagenes =>
      _imagenesExistentes.length + _imagenes.length;

  @override
  void initState() {
    super.initState();

    final producto = widget.producto;

    _nombreController = TextEditingController(
      text: producto?.nombre ?? '',
    );

    _descripcionController = TextEditingController(
      text: producto?.descripcion ?? '',
    );

    _precioController = TextEditingController(
      text: producto != null ? producto.precio.toString() : '',
    );

    _categoria = producto != null &&
            _categorias.contains(producto.categoria)
        ? producto.categoria
        : 'Cafe';

    _imagenPrincipal = producto?.imagenPrincipal ?? '';

    _imagenesExistentes = [
      if (_imagenPrincipal.isNotEmpty) _imagenPrincipal,
      ...?producto?.imagenes,
    ].toList();
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

    final disponibles = 10 - _cantidadImagenes;

    if (disponibles <= 0) {
      _mostrarMensaje('Puedes seleccionar máximo 10 imágenes.');
      return;
    }

    try {
      final seleccionadas = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

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
          'Se agregaron ${nuevas.length} imagen(es). El máximo es 10.',
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

  void _quitarImagenExistente(String url) {
    if (_guardando) return;

    setState(() {
      _imagenesExistentes.remove(url);

      if (_imagenPrincipal == url) {
        _imagenPrincipal = _imagenesExistentes.isNotEmpty
            ? _imagenesExistentes.first
            : '';
      }
    });
  }

  void _establecerPrincipal(String url) {
    if (_guardando) return;

    setState(() {
      _imagenPrincipal = url;
    });
  }

  void _quitarImagenNueva(int index) {
    if (_guardando) return;

    final imagen = _imagenes[index];

    setState(() {
      _imagenes.removeAt(index);
      _bytesImagenes.remove(imagen.path);
    });
  }

  Future<void> _guardar() async {
    if (_guardando || !_formKey.currentState!.validate()) {
      return;
    }

    if (_cantidadImagenes == 0) {
      _mostrarMensaje(
        'El producto debe conservar al menos una imagen.',
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
        imagenesConservar: List<String>.from(_imagenesExistentes),
        imagenPrincipalActual: _imagenPrincipal,
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
          behavior: SnackBarBehavior.floating,
          content: Text(mensaje),
          backgroundColor: esError
              ? AppColors.sitioError
              : AppColors.sitioPrimary,
        ),
      );
  }

  InputDecoration _decoracionCampo({
    required String etiqueta,
    String? ayuda,
    Widget? prefijo,
  }) {
    return InputDecoration(
      labelText: etiqueta,
      helperText: ayuda,
      prefixIcon: prefijo,
      filled: true,
      fillColor: AppColors.sitioSurface,
      labelStyle: const TextStyle(
        color: AppColors.sitioTextSecondary,
      ),
      helperStyle: const TextStyle(
        color: AppColors.sitioTextSecondary,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.sitioBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.sitioBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.sitioPrimary,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.sitioError,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.sitioError,
          width: 1.5,
        ),
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
    IconData? icono,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_guardando,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: AppColors.sitioTextPrimary,
        fontSize: 14,
      ),
      decoration: _decoracionCampo(
        etiqueta: etiqueta,
        ayuda: ayuda,
        prefijo: icono == null
            ? null
            : Icon(
                icono,
                color: AppColors.sitioPrimary,
                size: 21,
              ),
      ),
    );
  }

  Widget _encabezadoSeccion({
    required IconData icono,
    required String titulo,
    required String subtitulo,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.sitioSurfaceGreen,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icono,
            color: AppColors.sitioPrimary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: AppColors.sitioTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitulo,
                style: const TextStyle(
                  color: AppColors.sitioTextSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tarjetaExistente(String url) {
    final esPrincipal = url == _imagenPrincipal;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: esPrincipal
              ? AppColors.sitioAccent
              : AppColors.sitioBorder,
          width: esPrincipal ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.sitioSurfaceGreen,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.sitioTextSecondary,
                  ),
                );
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return Container(
                  color: AppColors.sitioSurfaceSoft,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.sitioPrimary,
                  ),
                );
              },
            ),
            Positioned(
              left: 5,
              bottom: 5,
              child: Material(
                color: esPrincipal
                    ? AppColors.sitioPrimary
                    : AppColors.sitioSurface,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: _guardando
                      ? null
                      : () => _establecerPrincipal(url),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          esPrincipal
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 13,
                          color: esPrincipal
                              ? AppColors.sitioAccent
                              : AppColors.sitioPrimary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          esPrincipal ? 'Principal' : 'Elegir',
                          style: TextStyle(
                            color: esPrincipal
                                ? AppColors.sitioTextOnPrimary
                                : AppColors.sitioTextPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 3,
              top: 3,
              child: IconButton(
                tooltip: 'Quitar imagen',
                onPressed: _guardando
                    ? null
                    : () => _quitarImagenExistente(url),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                ),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  minimumSize: const Size(32, 32),
                  maximumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vistaImagenNueva(XFile imagen) {
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
              color: AppColors.sitioPrimary,
              strokeWidth: 2,
            ),
          );
        }

        return Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.sitioTextSecondary,
              ),
            );
          },
        );
      },
    );
  }

  Widget _tarjetaImagenNueva(XFile imagen, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: AppColors.sitioSurfaceSoft,
            child: _vistaImagenNueva(imagen),
          ),
          Positioned(
            left: 5,
            bottom: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.sitioPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Nueva',
                style: TextStyle(
                  color: AppColors.sitioTextOnPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            right: 3,
            top: 3,
            child: IconButton(
              tooltip: 'Quitar imagen nueva',
              onPressed: _guardando
                  ? null
                  : () => _quitarImagenNueva(index),
              icon: const Icon(
                Icons.close_rounded,
                size: 18,
              ),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                minimumSize: const Size(32, 32),
                maximumSize: const Size(32, 32),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccionImagenes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.sitioBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _encabezadoSeccion(
            icono: Icons.photo_library_outlined,
            titulo: 'Fotografías del producto',
            subtitulo: 'Elige la imagen principal y administra la galería.',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$_cantidadImagenes de 10 imágenes',
                  style: const TextStyle(
                    color: AppColors.sitioTextPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${_cantidadImagenes * 10}%',
                style: const TextStyle(
                  color: AppColors.sitioPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _cantidadImagenes / 10,
              minHeight: 6,
              backgroundColor: AppColors.sitioBorder,
              color: AppColors.sitioPrimary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _guardando || _cantidadImagenes >= 10
                  ? null
                  : _seleccionarImagenes,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Seleccionar fotografías'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.sitioPrimary,
                side: const BorderSide(color: AppColors.sitioPrimary),
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_imagenesExistentes.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Imágenes guardadas',
              style: const TextStyle(
                color: AppColors.sitioTextPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final columnas = constraints.maxWidth >= 460 ? 4 : 3;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnas,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.92,
                  ),
                  itemCount: _imagenesExistentes.length,
                  itemBuilder: (context, index) {
                    return _tarjetaExistente(
                      _imagenesExistentes[index],
                    );
                  },
                );
              },
            ),
          ],
          if (_imagenes.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Imágenes nuevas',
              style: TextStyle(
                color: AppColors.sitioTextPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final columnas = constraints.maxWidth >= 460 ? 4 : 3;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnas,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.92,
                  ),
                  itemCount: _imagenes.length,
                  itemBuilder: (context, index) {
                    return _tarjetaImagenNueva(
                      _imagenes[index],
                      index,
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.sizeOf(context).width;
    final anchoDialogo = anchoPantalla >= 900
        ? 680.0
        : anchoPantalla >= 600
            ? 560.0
            : anchoPantalla - 32;

    return Dialog(
      backgroundColor: AppColors.sitioSurface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: anchoDialogo,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 20, 16, 20),
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
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _esEdicion
                          ? Icons.edit_outlined
                          : Icons.inventory_2_outlined,
                      color: AppColors.sitioAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _esEdicion ? 'Editar producto' : 'Nuevo producto',
                          style: const TextStyle(
                            color: AppColors.sitioTextOnPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _esEdicion
                              ? 'Actualiza la información de tu catálogo.'
                              : 'Presenta un producto de tu experiencia cafetera.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: _guardando
                        ? null
                        : () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _encabezadoSeccion(
                        icono: Icons.description_outlined,
                        titulo: 'Información del producto',
                        subtitulo:
                            'Cuéntales a los visitantes qué hace especial tu producto.',
                      ),
                      const SizedBox(height: 18),
                      _campo(
                        etiqueta: 'Nombre del producto',
                        controller: _nombreController,
                        icono: Icons.sell_outlined,
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
                      const SizedBox(height: 16),
                      _campo(
                        etiqueta: 'Descripción',
                        controller: _descripcionController,
                        icono: Icons.notes_rounded,
                        maxLines: 4,
                        validator: (valor) {
                          if ((valor ?? '').trim().length > 1500) {
                            return 'Máximo 1500 caracteres.';
                          }
                          return null;
                        },
                        ayuda: 'Describe el producto para los visitantes.',
                      ),
                      const SizedBox(height: 16),
                      _campo(
                        etiqueta: 'Precio en pesos colombianos',
                        controller: _precioController,
                        icono: Icons.payments_outlined,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (valor) {
                          final texto =
                              (valor ?? '').trim().replaceAll(',', '.');
                          final precio = double.tryParse(texto);

                          if (texto.isEmpty || precio == null) {
                            return 'Ingresa un precio válido.';
                          }
                          if (precio < 0) {
                            return 'El precio no puede ser negativo.';
                          }
                          return null;
                        },
                        ayuda: 'Ejemplo: 15000',
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _categoria,
                        isExpanded: true,
                        decoration: _decoracionCampo(
                          etiqueta: 'Categoría',
                          prefijo: const Icon(
                            Icons.category_outlined,
                            color: AppColors.sitioPrimary,
                          ),
                        ),
                        dropdownColor: AppColors.sitioSurface,
                        style: const TextStyle(
                          color: AppColors.sitioTextPrimary,
                          fontSize: 14,
                        ),
                        items: _categorias.map((categoria) {
                          return DropdownMenuItem(
                            value: categoria,
                            child: Text(categoria),
                          );
                        }).toList(),
                        onChanged: _guardando
                            ? null
                            : (valor) {
                                if (valor != null) {
                                  setState(() => _categoria = valor);
                                }
                              },
                      ),
                      const SizedBox(height: 24),
                      _seccionImagenes(),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: const BoxDecoration(
                color: AppColors.sitioSurfaceSoft,
                border: Border(
                  top: BorderSide(color: AppColors.sitioDivider),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final botones = [
                    OutlinedButton(
                      onPressed: _guardando
                          ? null
                          : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.sitioTextSecondary,
                        side: const BorderSide(
                          color: AppColors.sitioBorder,
                        ),
                        minimumSize: const Size(0, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _guardando ? null : _guardar,
                      icon: _guardando
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined, size: 19),
                      label: Text(
                        _guardando ? 'Guardando...' : 'Guardar producto',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sitioPrimary,
                        foregroundColor: AppColors.sitioTextOnPrimary,
                        minimumSize: const Size(0, 46),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ];

                  if (constraints.maxWidth < 420) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        botones[1],
                        const SizedBox(height: 8),
                        botones[0],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: botones[0]),
                      const SizedBox(width: 10),
                      Expanded(flex: 2, child: botones[1]),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
