import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  required String? imagenPrincipalNueva,
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

  int get _imagenesConservadas => _imagenesExistentes
      .where((url) => !_imagenesEliminar.contains(url))
      .length;

  int get _totalImagenes =>
      _imagenesConservadas + _imagenesSeleccionadas.length;

  @override
  void initState() {
    super.initState();

    final actividad = widget.actividad;

    _nombreController = TextEditingController(
      text: actividad?.nombre ?? '',
    );
    _descripcionController = TextEditingController(
      text: actividad?.descripcion ?? '',
    );
    _precioController = TextEditingController(
      text: actividad != null && actividad.precio > 0
          ? actividad.precio.toStringAsFixed(0)
          : '',
    );
    _horarioController = TextEditingController(
      text: actividad?.horario ?? '',
    );
    _duracionController = TextEditingController(
      text: actividad?.duracion ?? '',
    );

    if (actividad != null) {
      _imagenPrincipalUrl = actividad.imagenPrincipal.trim();

      _imagenesExistentes.addAll({
        if (_imagenPrincipalUrl.isNotEmpty) _imagenPrincipalUrl,
        ...actividad.imagenes.where((url) => url.trim().isNotEmpty),
      });
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

    final disponibles = 10 - _totalImagenes;

    if (disponibles <= 0) {
      _mostrarError('Una actividad puede tener máximo 10 imágenes.');
      return;
    }

    try {
      final seleccionadas = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (!mounted || seleccionadas.isEmpty) return;

      final rutasActuales =
          _imagenesSeleccionadas.map((imagen) => imagen.path).toSet();

      final nuevas = seleccionadas
          .where((imagen) => !rutasActuales.contains(imagen.path))
          .take(disponibles)
          .toList();

      setState(() {
        _imagenesSeleccionadas.addAll(nuevas);

        for (final imagen in nuevas) {
          _bytesImagenes[imagen.path] = imagen.readAsBytes();
        }

        if (_imagenPrincipalUrl.isEmpty &&
            _imagenPrincipalNueva == null &&
            nuevas.isNotEmpty) {
          _imagenPrincipalNueva = nuevas.first.path;
        }
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

        final restantes = _imagenesExistentes
            .where((item) => !_imagenesEliminar.contains(item))
            .toList();

        if (restantes.isNotEmpty) {
          _imagenPrincipalUrl = restantes.first;
          _imagenPrincipalNueva = null;
        } else if (_imagenesSeleccionadas.isNotEmpty) {
          _imagenPrincipalNueva = _imagenesSeleccionadas.first.path;
        } else {
          _imagenPrincipalNueva = null;
        }
      }
    });
  }

  void _restaurarImagenExistente(String url) {
    if (_guardando) return;

    setState(() {
      _imagenesEliminar.remove(url);

      if (_imagenPrincipalUrl.isEmpty &&
          _imagenPrincipalNueva == null) {
        _imagenPrincipalUrl = url;
      }
    });
  }

  void _establecerPrincipalExistente(String url) {
    if (_guardando || _imagenesEliminar.contains(url)) return;

    setState(() {
      _imagenPrincipalUrl = url;
      _imagenPrincipalNueva = null;
    });
  }

  void _establecerPrincipalNueva(XFile imagen) {
    if (_guardando) return;

    setState(() {
      _imagenPrincipalNueva = imagen.path;
      _imagenPrincipalUrl = '';
    });
  }

  void _quitarImagenNueva(XFile imagen) {
    if (_guardando) return;

    setState(() {
      _imagenesSeleccionadas.remove(imagen);
      _bytesImagenes.remove(imagen.path);

      if (_imagenPrincipalNueva == imagen.path) {
        _imagenPrincipalNueva = null;

        final existentes = _imagenesExistentes
            .where((url) => !_imagenesEliminar.contains(url))
            .toList();

        if (existentes.isNotEmpty) {
          _imagenPrincipalUrl = existentes.first;
        } else if (_imagenesSeleccionadas.isNotEmpty) {
          _imagenPrincipalNueva = _imagenesSeleccionadas.first.path;
        }
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

    if (nombre.length > 120) {
      _mostrarError('El nombre no puede superar los 120 caracteres.');
      return;
    }

    final descripcion = _descripcionController.text.trim();

    if (descripcion.length > 1500) {
      _mostrarError('La descripción no puede superar los 1500 caracteres.');
      return;
    }

    final precioTexto =
        _precioController.text.trim().replaceAll(',', '.');
    final precio =
        precioTexto.isEmpty ? 0.0 : double.tryParse(precioTexto);

    if (precio == null || !precio.isFinite || precio < 0) {
      _mostrarError('Ingresa un precio válido que no sea negativo.');
      return;
    }

    if (_totalImagenes == 0) {
      _mostrarError('La actividad debe conservar al menos una imagen.');
      return;
    }

    if (_totalImagenes > 10) {
      _mostrarError('Una actividad puede tener máximo 10 imágenes.');
      return;
    }

    if (_imagenPrincipalUrl.isEmpty &&
        _imagenPrincipalNueva == null) {
      final existentes = _imagenesExistentes
          .where((url) => !_imagenesEliminar.contains(url))
          .toList();

      if (existentes.isNotEmpty) {
        _imagenPrincipalUrl = existentes.first;
      } else if (_imagenesSeleccionadas.isNotEmpty) {
        _imagenPrincipalNueva = _imagenesSeleccionadas.first.path;
      }
    }

    setState(() => _guardando = true);

    try {
      await widget.onGuardar(
        nombre: nombre,
        descripcion: descripcion,
        precio: precio,
        horario: _horarioController.text.trim(),
        duracion: _duracionController.text.trim(),
        imagenes: List<XFile>.from(_imagenesSeleccionadas),
        imagenesEliminar: List<String>.from(_imagenesEliminar),
        imagenPrincipalUrl: _imagenPrincipalUrl,
        imagenPrincipalNueva: _imagenPrincipalNueva,
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
          backgroundColor: AppColors.sitioError,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        if (snapshot.hasError) {
          return const _ImagenActividadVacia();
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.sitioPrimary,
            ),
          );
        }

        return Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _ImagenActividadVacia(),
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
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioItemImageRadius,
          ),
          child: imagen,
        ),
        Positioned(
          left: 4,
          right: 4,
          bottom: 4,
          child: Material(
            color: principal
                ? AppColors.sitioAccent
                : AppColors.sitioPrimaryDark.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(
              AppDimensions.sitioStatusRadius,
            ),
            child: InkWell(
              onTap: _guardando ? null : alTocarPrincipal,
              borderRadius: BorderRadius.circular(
                AppDimensions.sitioStatusRadius,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (principal) ...[
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                    ],
                    Flexible(
                      child: Text(
                        principal ? 'Portada' : 'Elegir portada',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
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
            onPressed: _guardando ? null : alQuitar,
            tooltip: 'Quitar imagen',
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.sitioPrimaryDark.withValues(
                alpha: 0.85,
              ),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.close_rounded, size: 17),
          ),
        ),
      ],
    );
  }

  Widget _construirSeccionImagenes() {
    final existentesVisibles = _imagenesExistentes
        .where((url) => !_imagenesEliminar.contains(url))
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceSoft,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioFormRadius,
        ),
        border: Border.all(color: AppColors.sitioBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.sitioSurfaceGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.sitioPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fotografías de la actividad',
                      style: const TextStyle(
                        color: AppColors.sitioTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_totalImagenes de 10 imágenes',
                      style: const TextStyle(
                        color: AppColors.sitioTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Elige las fotografías que quieres conservar y selecciona '
            'cuál será la portada de esta actividad.',
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
              onPressed: _guardando || _totalImagenes >= 10
                  ? null
                  : _seleccionarImagenes,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.sitioPrimary,
                side: const BorderSide(color: AppColors.sitioPrimary),
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Seleccionar fotografías'),
            ),
          ),
          if (existentesVisibles.isNotEmpty ||
              _imagenesSeleccionadas.isNotEmpty) ...[
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final columnas = constraints.maxWidth < 300
                    ? 2
                    : constraints.maxWidth < 460
                        ? 3
                        : 4;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: existentesVisibles.length +
                      _imagenesSeleccionadas.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnas,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.88,
                  ),
                  itemBuilder: (context, index) {
                    if (index < existentesVisibles.length) {
                      final url = existentesVisibles[index];

                      return _miniatura(
                        imagen: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const _ImagenActividadVacia(),
                        ),
                        principal: _imagenPrincipalUrl == url,
                        alTocarPrincipal: () =>
                            _establecerPrincipalExistente(url),
                        alQuitar: () => _quitarImagenExistente(url),
                      );
                    }

                    final indiceNueva =
                        index - existentesVisibles.length;
                    final imagen = _imagenesSeleccionadas[indiceNueva];

                    return _miniatura(
                      imagen: _vistaNueva(imagen),
                      principal: _imagenPrincipalNueva == imagen.path &&
                          _imagenPrincipalUrl.isEmpty,
                      alTocarPrincipal: () =>
                          _establecerPrincipalNueva(imagen),
                      alQuitar: () => _quitarImagenNueva(imagen),
                    );
                  },
                );
              },
            ),
          ],
          if (_imagenesEliminar.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.sitioWarningSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.sitioWarning,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_imagenesEliminar.length} imagen(es) se '
                      'eliminarán al guardar.',
                      style: const TextStyle(
                        color: AppColors.sitioWarning,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _imagenesEliminar
                  .map(
                    (url) => ActionChip(
                      avatar: const Icon(
                        Icons.undo_rounded,
                        size: 16,
                      ),
                      label: const Text('Restaurar imagen'),
                      backgroundColor: AppColors.sitioSurface,
                      side: const BorderSide(
                        color: AppColors.sitioBorder,
                      ),
                      onPressed: _guardando
                          ? null
                          : () => _restaurarImagenExistente(url),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.sitioBackground,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 800,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
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
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Icon(
                      _esEdicion
                          ? Icons.edit_note_rounded
                          : Icons.add_business_rounded,
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
                          _esEdicion
                              ? 'Editar actividad'
                              : 'Nueva actividad',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _esEdicion
                              ? 'Actualiza los detalles de tu experiencia'
                              : 'Comparte una experiencia con tus visitantes',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _guardando
                        ? null
                        : () => Navigator.of(context).pop(),
                    tooltip: 'Cerrar',
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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _encabezadoSeccion(
                      'Información general',
                      'Cuéntales a los visitantes qué pueden disfrutar.',
                      Icons.description_outlined,
                    ),
                    const SizedBox(height: 16),
                    _campo(
                      _nombreController,
                      'Nombre de la actividad',
                      pista: 'Ej. Recorrido por el cafetal',
                      icono: Icons.local_activity_outlined,
                      maxLength: 120,
                    ),
                    _campo(
                      _descripcionController,
                      'Descripción',
                      pista: 'Describe en qué consiste la experiencia',
                      icono: Icons.notes_rounded,
                      maxLines: 4,
                      maxLength: 1500,
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 380) {
                          return Column(
                            children: [
                              _campo(
                                _precioController,
                                'Precio',
                                pista: '0',
                                icono: Icons.payments_outlined,
                                esPrecio: true,
                              ),
                              _campo(
                                _horarioController,
                                'Horario',
                                pista: 'Ej. 8:00 a. m. - 4:00 p. m.',
                                icono: Icons.schedule_rounded,
                              ),
                              _campo(
                                _duracionController,
                                'Duración',
                                pista: 'Ej. 2 horas',
                                icono: Icons.timer_outlined,
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _campo(
                                    _precioController,
                                    'Precio',
                                    pista: '0',
                                    icono: Icons.payments_outlined,
                                    esPrecio: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _campo(
                                    _duracionController,
                                    'Duración',
                                    pista: 'Ej. 2 horas',
                                    icono: Icons.timer_outlined,
                                  ),
                                ),
                              ],
                            ),
                            _campo(
                              _horarioController,
                              'Horario',
                              pista: 'Ej. 8:00 a. m. - 4:00 p. m.',
                              icono: Icons.schedule_rounded,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _encabezadoSeccion(
                      'Galería de imágenes',
                      'Agrega fotografías y elige la portada.',
                      Icons.photo_library_outlined,
                    ),
                    const SizedBox(height: 14),
                    _construirSeccionImagenes(),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.sitioSurface,
                border: Border(
                  top: BorderSide(color: AppColors.sitioDivider),
                ),
              ),
              child: SafeArea(
                top: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compacto = constraints.maxWidth < 340;

                    if (compacto) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton(
                            onPressed: _guardando
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: _estiloBotonSecundario(),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _guardando ? null : _guardar,
                            style: _estiloBotonPrincipal(),
                            icon: _iconoGuardar(),
                            label: Text(
                              _guardando ? 'Guardando...' : 'Guardar actividad',
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _guardando
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: _estiloBotonSecundario(),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _guardando ? null : _guardar,
                            style: _estiloBotonPrincipal(),
                            icon: _iconoGuardar(),
                            label: Text(
                              _guardando ? 'Guardando...' : 'Guardar actividad',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encabezadoSeccion(
    String titulo,
    String descripcion,
    IconData icono,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.sitioSurfaceGreen,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icono,
            color: AppColors.sitioPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: 11),
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
              const SizedBox(height: 3),
              Text(
                descripcion,
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

  Widget _campo(
    TextEditingController controller,
    String etiqueta, {
    String? pista,
    IconData? icono,
    int maxLines = 1,
    int? maxLength,
    bool esPrecio = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        enabled: !_guardando,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: esPrecio
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        inputFormatters: esPrecio
            ? [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*[,.]?\d{0,2}'),
                ),
              ]
            : null,
        style: const TextStyle(
          color: AppColors.sitioTextPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: etiqueta,
          hintText: pista,
          prefixIcon: icono == null
              ? null
              : Icon(
                  icono,
                  color: AppColors.sitioPrimary,
                  size: 20,
                ),
          filled: true,
          fillColor: AppColors.sitioSurface,
          counterStyle: const TextStyle(
            color: AppColors.sitioTextSecondary,
            fontSize: 11,
          ),
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
      ),
    );
  }

  ButtonStyle _estiloBotonPrincipal() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.sitioPrimary,
      foregroundColor: AppColors.sitioTextOnPrimary,
      disabledBackgroundColor:
          AppColors.sitioPrimary.withValues(alpha: 0.45),
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
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
      side: const BorderSide(color: AppColors.sitioBorder),
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _iconoGuardar() {
    if (_guardando) {
      return const SizedBox(
        width: 17,
        height: 17,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }

    return const Icon(Icons.save_outlined, size: 19);
  }
}

class _ImagenActividadVacia extends StatelessWidget {
  const _ImagenActividadVacia();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sitioSurfaceGreen,
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_activity_outlined,
        size: 34,
        color: AppColors.sitioPrimary,
      ),
    );
  }
}
