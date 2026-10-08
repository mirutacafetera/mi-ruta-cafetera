import 'dart:io';

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
  required List<File> imagenes,
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

  final List<File> _imagenesSeleccionadas = [];

  bool _guardando = false;

  bool get _esEdicion => widget.actividad != null;

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

    final disponibles =
        10 - _imagenesSeleccionadas.length;

    if (disponibles <= 0) {
      _mostrarError(
        'Una actividad puede tener máximo 10 imágenes.',
      );
      return;
    }

    final seleccionadas =
        await _imagePicker.pickMultiImage(
      imageQuality: 85,
    );

    if (!mounted || seleccionadas.isEmpty) {
      return;
    }

    final nuevas = seleccionadas
        .take(disponibles)
        .map((imagen) => File(imagen.path))
        .toList();

    setState(() {
      _imagenesSeleccionadas.addAll(nuevas);
    });

    if (seleccionadas.length > disponibles) {
      _mostrarError(
        'Solo puedes agregar $disponibles imagen(es) más.',
      );
    }
  }

  void _eliminarImagenSeleccionada(int index) {
    if (_guardando) return;

    setState(() {
      _imagenesSeleccionadas.removeAt(index);
    });
  }

  Future<void> _guardar() async {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty) {
      _mostrarError(
        'El nombre de la actividad es obligatorio.',
      );
      return;
    }

    final precioTexto =
        _precioController.text.trim().replaceAll(',', '.');

    final precio = double.tryParse(precioTexto) ?? 0;

    if (precio < 0) {
      _mostrarError(
        'El precio no puede ser negativo.',
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      await widget.onGuardar(
        nombre: nombre,
        descripcion: _descripcionController.text.trim(),
        precio: precio,
        horario: _horarioController.text.trim(),
        duracion: _duracionController.text.trim(),
        imagenes: List<File>.from(
          _imagenesSeleccionadas,
        ),
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _guardando = false;
      });

      _mostrarError(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Widget _construirSeccionImagenes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceGreen,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(
              width: AppDimensions.spacingMd,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Imágenes de la actividad',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingXs,
                  ),
                  Text(
                    'Puedes seleccionar hasta 10 imágenes. '
                    'La primera será la principal.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        OutlinedButton.icon(
          onPressed:
              _guardando ? null : _seleccionarImagenes,
          icon: const Icon(
            Icons.add_photo_alternate_outlined,
          ),
          label: const Text(
            'Seleccionar imágenes',
          ),
        ),
        if (_imagenesSeleccionadas.isNotEmpty) ...[
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount: _imagenesSeleccionadas.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing:
                  AppDimensions.spacingSm,
              mainAxisSpacing:
                  AppDimensions.spacingSm,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final imagen =
                  _imagenesSeleccionadas[index];

              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                    child: Image.file(
                      imagen,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: AppDimensions.spacingXs,
                    right: AppDimensions.spacingXs,
                    child: Material(
                      color: Colors.black54,
                      borderRadius:
                          BorderRadius.circular(
                        AppDimensions.radiusPill,
                      ),
                      child: InkWell(
                        onTap: _guardando
                            ? null
                            : () =>
                                _eliminarImagenSeleccionada(
                                  index,
                                ),
                        borderRadius:
                            BorderRadius.circular(
                          AppDimensions.radiusPill,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      left: AppDimensions.spacingXs,
                      bottom: AppDimensions.spacingXs,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal:
                              AppDimensions.spacingSm,
                          vertical:
                              AppDimensions.spacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(
                            AppDimensions.radiusPill,
                          ),
                        ),
                        child: const Text(
                          'Principal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
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
          maxWidth: 600,
          maxHeight: 800,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppDimensions.spacingLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGreen,
                      borderRadius:
                          BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: const Icon(
                      Icons.local_activity_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(
                    width: AppDimensions.spacingMd,
                  ),
                  Expanded(
                    child: Text(
                      _esEdicion
                          ? 'Editar actividad'
                          : 'Nueva actividad',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _guardando
                        ? null
                        : () =>
                            Navigator.of(context).pop(),
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
                    children: [
                      TextField(
                        controller:
                            _nombreController,
                        enabled: !_guardando,
                        textInputAction:
                            TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          hintText:
                              'Ej. Tour de café especial',
                          prefixIcon: const Icon(
                            Icons.title_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingMd,
                      ),
                      TextField(
                        controller:
                            _descripcionController,
                        enabled: !_guardando,
                        maxLines: 4,
                        textInputAction:
                            TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          hintText:
                              'Describe la experiencia...',
                          alignLabelWithHint: true,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(
                              bottom: 48,
                            ),
                            child: Icon(
                              Icons.description_outlined,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingMd,
                      ),
                      TextField(
                        controller:
                            _precioController,
                        enabled: !_guardando,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Precio',
                          prefixText: r'$ ',
                          prefixIcon: const Icon(
                            Icons.attach_money_rounded,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingMd,
                      ),
                      TextField(
                        controller:
                            _horarioController,
                        enabled: !_guardando,
                        decoration: InputDecoration(
                          labelText: 'Horario',
                          hintText:
                              'Ej. 8:00 a. m. - 4:00 p. m.',
                          prefixIcon: const Icon(
                            Icons.schedule_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingMd,
                      ),
                      TextField(
                        controller:
                            _duracionController,
                        enabled: !_guardando,
                        decoration: InputDecoration(
                          labelText: 'Duración',
                          hintText: 'Ej. 2 horas',
                          prefixIcon: const Icon(
                            Icons.timer_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingLg,
                      ),
                      _construirSeccionImagenes(),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingLg,
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _guardando
                        ? null
                        : () =>
                            Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(
                    width: AppDimensions.spacingSm,
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        _guardando ? null : _guardar,
                    icon: _guardando
                        ? const SizedBox(
                            width:
                                AppDimensions.iconSm,
                            height:
                                AppDimensions.iconSm,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.save_outlined,
                          ),
                    label: Text(
                      _guardando
                          ? 'Guardando...'
                          : 'Guardar',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}