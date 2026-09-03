import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/admin/admin_sitio_service.dart';

class SitioFormSheet extends StatefulWidget {
  final Map<String, dynamic>? sitio;
  final List<Map<String, dynamic>> categorias;

  const SitioFormSheet({
    super.key,
    this.sitio,
    this.categorias = const [],
  });

  bool get esEdicion => sitio != null;

  @override
  State<SitioFormSheet> createState() =>
      _SitioFormSheetState();
}

class _SitioFormSheetState
    extends State<SitioFormSheet> {
  // =====================================================
  // FORMULARIO
  // =====================================================

  final _formKey = GlobalKey<FormState>();

  // =====================================================
  // CONTROLADORES
  // =====================================================

  final _correoController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _nombreController =
      TextEditingController();

  final _descripcionController =
      TextEditingController();

  final _direccionController =
      TextEditingController();

  final _ciudadController =
      TextEditingController();

  final _departamentoController =
      TextEditingController();

  final _latitudController =
      TextEditingController();

  final _longitudController =
      TextEditingController();

  final _telefonoController =
      TextEditingController();

  final _correosController =
      TextEditingController();

  final _sitioWebController =
      TextEditingController();

  final _horarioController =
      TextEditingController();

  final _precioDesdeController =
      TextEditingController();

  // =====================================================
  // IMAGE PICKER
  // =====================================================

  final ImagePicker _picker =
      ImagePicker();

  Uint8List? _imagenBytes;

  // =====================================================
  // VARIABLES
  // =====================================================

  String? _categoriaSeleccionada;

  bool _activo = true;
  bool _guardando = false;

  // =====================================================
  // IMÁGENES EXISTENTES
  // =====================================================

  final List<String> _imagenesExistentes = [];

  // =====================================================
  // INIT STATE
  // =====================================================

  @override
  void initState() {
    super.initState();

    final sitio = widget.sitio;

    if (sitio != null) {
      _cargarDatosSitio(sitio);
    } else {
      _ciudadController.text = 'Garzón';
      _departamentoController.text = 'Huila';
      _precioDesdeController.text = '0';
    }
  }

  // =====================================================
  // CARGAR DATOS DEL SITIO
  // =====================================================

  void _cargarDatosSitio(
    Map<String, dynamic> sitio,
  ) {
    _correoController.text =
        sitio['correo']?.toString() ?? '';

    _nombreController.text =
        sitio['nombre']?.toString() ?? '';

    _descripcionController.text =
        sitio['descripcion']?.toString() ?? '';

    _direccionController.text =
        sitio['direccion']?.toString() ?? '';

    _ciudadController.text =
        sitio['ciudad']?.toString() ?? 'Garzón';

    _departamentoController.text =
        sitio['departamento']?.toString() ?? 'Huila';

    _latitudController.text =
        sitio['latitud']?.toString() ?? '';

    _longitudController.text =
        sitio['longitud']?.toString() ?? '';

    _telefonoController.text =
        sitio['telefono']?.toString() ?? '';

    _correosController.text =
        sitio['correos']?.toString() ?? '';

    _sitioWebController.text =
        sitio['sitioWeb']?.toString() ?? '';

    _horarioController.text =
        sitio['horario']?.toString() ?? '';

    _precioDesdeController.text =
        sitio['precioDesde']?.toString() ?? '0';

    _activo = sitio['activo'] != false;

    // ===================================================
    // CATEGORÍA
    // ===================================================

    final categoria = sitio['categoria'];

    if (categoria is Map) {
      _categoriaSeleccionada =
          categoria['_id']?.toString();
    } else if (categoria != null) {
      _categoriaSeleccionada =
          categoria.toString();
    }

    // ===================================================
    // IMÁGENES
    // ===================================================

    final imagenes = sitio['imagenes'];

    if (imagenes is List) {
      _imagenesExistentes.addAll(
        imagenes.map(
          (imagen) => imagen.toString(),
        ),
      );
    }

    // ===================================================
    // IMAGEN PRINCIPAL
    // ===================================================

    final imagenPrincipal =
        sitio['imagen']?.toString() ?? '';

    if (imagenPrincipal.isNotEmpty &&
        !_imagenesExistentes
            .contains(imagenPrincipal)) {
      _imagenesExistentes.insert(
        0,
        imagenPrincipal,
      );
    }
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _departamentoController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _telefonoController.dispose();
    _correosController.dispose();
    _sitioWebController.dispose();
    _horarioController.dispose();
    _precioDesdeController.dispose();

    super.dispose();
  }

  // =====================================================
  // SELECCIONAR IMAGEN
  // =====================================================

  Future<void> _seleccionarImagen() async {
    try {
      final imagen =
          await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imagen == null) {
        return;
      }

      final bytes =
          await imagen.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(() {
        _imagenBytes = bytes;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      _mostrarMensaje(
        'No se pudo seleccionar la imagen.',
      );
    }
  }

  // =====================================================
  // GUARDAR
  // =====================================================

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ===================================================
    // CATEGORÍA
    // ===================================================

    if (_categoriaSeleccionada == null ||
        _categoriaSeleccionada!.isEmpty) {
      _mostrarMensaje(
        'Selecciona una categoría.',
      );
      return;
    }

    // ===================================================
    // LATITUD
    // ===================================================

    final latitud = double.tryParse(
      _latitudController.text.trim(),
    );

    // ===================================================
    // LONGITUD
    // ===================================================

    final longitud = double.tryParse(
      _longitudController.text.trim(),
    );

    if (latitud == null ||
        longitud == null) {
      _mostrarMensaje(
        'La latitud y longitud deben ser números válidos.',
      );
      return;
    }

    // ===================================================
    // PRECIO
    // ===================================================

    final precio =
        double.tryParse(
              _precioDesdeController
                  .text
                  .trim(),
            ) ??
            0;

    setState(() {
      _guardando = true;
    });

    try {
      // =================================================
      // IMÁGENES
      // =================================================

      final imagenes =
          List<String>.from(
        _imagenesExistentes,
      );

      final imagenPrincipal =
          imagenes.isNotEmpty
              ? imagenes.first
              : '';

      // =================================================
      // CREAR SITIO
      // =================================================

      if (!widget.esEdicion) {
        await AdminSitioService.crearSitio(
          correo:
              _correoController.text.trim(),
          password:
              _passwordController.text.trim(),
          nombre:
              _nombreController.text.trim(),
          descripcion:
              _descripcionController.text.trim(),
          categoria:
              _categoriaSeleccionada!,
          direccion:
              _direccionController.text.trim(),
          ciudad:
              _ciudadController.text.trim(),
          departamento:
              _departamentoController.text.trim(),
          latitud:
              latitud,
          longitud:
              longitud,
          activo:
              _activo,
          telefono:
              _telefonoController.text.trim(),
          correos:
              _correosController.text.trim(),
          sitioWeb:
              _sitioWebController.text.trim(),
          imagen:
              imagenPrincipal,
          imagenes:
              imagenes,
          horario:
              _horarioController.text.trim(),
          precioDesde:
              precio,
        );
      }

      // =================================================
      // ACTUALIZAR SITIO
      // =================================================

      else {
        final id =
            widget.sitio?['_id']
                    ?.toString() ??
                widget.sitio?['id']
                    ?.toString() ??
                '';

        if (id.isEmpty) {
          throw Exception(
            'No se encontró el ID del sitio turístico.',
          );
        }

        await AdminSitioService.actualizarSitio(
          id: id,
          correo:
              _correoController.text.trim(),
          password:
              _passwordController.text.trim(),
          nombre:
              _nombreController.text.trim(),
          descripcion:
              _descripcionController.text.trim(),
          categoria:
              _categoriaSeleccionada!,
          direccion:
              _direccionController.text.trim(),
          ciudad:
              _ciudadController.text.trim(),
          departamento:
              _departamentoController.text.trim(),
          latitud:
              latitud,
          longitud:
              longitud,
          activo:
              _activo,
          telefono:
              _telefonoController.text.trim(),
          correos:
              _correosController.text.trim(),
          sitioWeb:
              _sitioWebController.text.trim(),
          imagen:
              imagenPrincipal,
          imagenes:
              imagenes,
          horario:
              _horarioController.text.trim(),
          precioDesde:
              precio,
        );
      }

      // =================================================
      // ÉXITO
      // =================================================

      if (!mounted) {
        return;
      }

      _mostrarMensaje(
        widget.esEdicion
            ? 'Sitio turístico actualizado correctamente.'
            : 'Sitio turístico creado correctamente.',
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _mostrarMensaje(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  // =====================================================
  // MOSTRAR MENSAJE
  // =====================================================

  void _mostrarMensaje(
    String mensaje,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  // =====================================================
  // CAMPO DE TEXTO
  // =====================================================

  Widget _campoTexto(
    TextEditingController controller,
    String label, {
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool obligatorio = false,
    bool obscureText = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 15,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration:
            InputDecoration(
          labelText: label,
          border:
              const OutlineInputBorder(),
          prefixIcon:
              icon != null
                  ? Icon(icon)
                  : null,
        ),
        validator:
            obligatorio
                ? (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }

                    return null;
                  }
                : null,
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final esEdicion =
        widget.esEdicion;

    return SafeArea(
      child: Container(
        height:
            MediaQuery.of(context)
                    .size
                    .height *
                0.92,

        // =================================================
        // SOLO APARIENCIA
        // =================================================

        decoration:
            const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),

        clipBehavior:
            Clip.antiAlias,

        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom:
                MediaQuery.of(context)
                        .viewInsets
                        .bottom +
                    20,
          ),

          child:
              SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // ENCABEZADO
                  // =================================================

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          esEdicion
                              ? 'Editar sitio turístico'
                              : 'Nuevo sitio turístico',
                          style:
                              const TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        icon:
                            const Icon(
                          Icons.close,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // =================================================
                  // DATOS DE ACCESO
                  // =================================================

                  const Text(
                    'Datos de acceso',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _campoTexto(
                    _correoController,
                    'Correo',
                    icon:
                        Icons.email,
                    keyboardType:
                        TextInputType
                            .emailAddress,
                    obligatorio: true,
                  ),

                  _campoTexto(
                    _passwordController,
                    esEdicion
                        ? 'Nueva contraseña (opcional)'
                        : 'Contraseña',
                    icon:
                        Icons.lock,
                    obscureText:
                        true,
                    obligatorio:
                        !esEdicion,
                  ),

                  // =================================================
                  // INFORMACIÓN DEL SITIO
                  // =================================================

                  const SizedBox(
                    height: 5,
                  ),

                  const Text(
                    'Información del sitio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _campoTexto(
                    _nombreController,
                    'Nombre',
                    icon:
                        Icons.place,
                    obligatorio: true,
                  ),

                  _campoTexto(
                    _descripcionController,
                    'Descripción',
                    icon: Icons
                        .description,
                    maxLines: 4,
                    obligatorio: true,
                  ),

                  // =================================================
                  // CATEGORÍA
                  // =================================================

                  Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      bottom: 15,
                    ),
                    child:
                        DropdownButtonFormField<
                            String>(
                      value:
                          _categoriaSeleccionada,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Categoría',
                        border:
                            OutlineInputBorder(),
                        prefixIcon:
                            Icon(
                          Icons.category,
                        ),
                      ),
                      items: widget
                          .categorias
                          .map(
                        (categoria) {
                          final id =
                              categoria[
                                      '_id']
                                  ?.toString();

                          final nombre =
                              categoria[
                                          'nombre']
                                      ?.toString() ??
                                  'Sin nombre';

                          if (id == null ||
                              id.isEmpty) {
                            return null;
                          }

                          return DropdownMenuItem<
                              String>(
                            value: id,
                            child:
                                Text(nombre),
                          );
                        },
                      )
                          .whereType<
                              DropdownMenuItem<
                                  String>>()
                          .toList(),
                      onChanged:
                          (value) {
                        setState(() {
                          _categoriaSeleccionada =
                              value;
                        });
                      },
                      validator:
                          (value) {
                        if (value ==
                                null ||
                            value.isEmpty) {
                          return 'Selecciona una categoría';
                        }

                        return null;
                      },
                    ),
                  ),

                  // =================================================
                  // DIRECCIÓN
                  // =================================================

                  _campoTexto(
                    _direccionController,
                    'Dirección',
                    icon: Icons
                        .location_on,
                  ),

                  _campoTexto(
                    _ciudadController,
                    'Ciudad',
                    icon: Icons
                        .location_city,
                    obligatorio: true,
                  ),

                  _campoTexto(
                    _departamentoController,
                    'Departamento',
                    icon:
                        Icons.map,
                    obligatorio: true,
                  ),

                  // =================================================
                  // UBICACIÓN
                  // =================================================

                  const SizedBox(
                    height: 5,
                  ),

                  const Text(
                    'Ubicación',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                            _campoTexto(
                          _latitudController,
                          'Latitud',
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          obligatorio:
                              true,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child:
                            _campoTexto(
                          _longitudController,
                          'Longitud',
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          obligatorio:
                              true,
                        ),
                      ),
                    ],
                  ),

                  // =================================================
                  // CONTACTO
                  // =================================================

                  const SizedBox(
                    height: 5,
                  ),

                  const Text(
                    'Información de contacto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _campoTexto(
                    _telefonoController,
                    'Teléfono',
                    icon:
                        Icons.phone,
                    keyboardType:
                        TextInputType.phone,
                  ),

                  _campoTexto(
                    _correosController,
                    'Correo de contacto',
                    icon: Icons
                        .email_outlined,
                    keyboardType:
                        TextInputType
                            .emailAddress,
                  ),

                  _campoTexto(
                    _sitioWebController,
                    'Sitio web',
                    icon:
                        Icons.language,
                    keyboardType:
                        TextInputType.url,
                  ),

                  // =================================================
                  // INFORMACIÓN TURÍSTICA
                  // =================================================

                  const SizedBox(
                    height: 5,
                  ),

                  const Text(
                    'Información turística',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _campoTexto(
                    _horarioController,
                    'Horario',
                    icon:
                        Icons.schedule,
                  ),

                  _campoTexto(
                    _precioDesdeController,
                    'Precio desde',
                    icon: Icons
                        .attach_money,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  // =================================================
                  // ESTADO
                  // =================================================

                  SwitchListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    title:
                        const Text(
                      'Sitio activo',
                    ),
                    subtitle:
                        Text(
                      _activo
                          ? 'El sitio está activo'
                          : 'El sitio está inactivo',
                    ),
                    value: _activo,
                    onChanged:
                        (value) {
                      setState(() {
                        _activo =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // =================================================
                  // IMAGEN
                  // =================================================

                  const Text(
                    'Imagen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  GestureDetector(
                    onTap:
                        _seleccionarImagen,
                    child: Container(
                      width:
                          double.infinity,
                      height: 180,
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.grey.shade50,
                        border:
                            Border.all(
                          color:
                              Colors.grey.shade400,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                      child:
                          _imagenBytes !=
                                  null
                              ? ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                    12,
                                  ),
                                  child:
                                      Image.memory(
                                    _imagenBytes!,
                                    width:
                                        double.infinity,
                                    height:
                                        180,
                                    fit:
                                        BoxFit.cover,
                                  ),
                                )
                              : _imagenesExistentes
                                      .isNotEmpty
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(
                                        12,
                                      ),
                                      child:
                                          Image.network(
                                        _imagenesExistentes
                                            .first,
                                        width:
                                            double.infinity,
                                        height:
                                            180,
                                        fit:
                                            BoxFit.cover,
                                        errorBuilder:
                                            (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Center(
                                            child:
                                                Icon(
                                              Icons
                                                  .broken_image,
                                              size:
                                                  50,
                                              color:
                                                  Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        Icon(
                                          Icons
                                              .add_a_photo,
                                          size:
                                              45,
                                          color:
                                              Colors.grey,
                                        ),
                                        SizedBox(
                                          height:
                                              8,
                                        ),
                                        Text(
                                          'Seleccionar imagen',
                                        ),
                                      ],
                                    ),
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // =================================================
                  // BOTÓN GUARDAR
                  // =================================================

                  SizedBox(
                    width:
                        double.infinity,
                    height: 50,
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          _guardando
                              ? null
                              : _guardar,
                      icon: _guardando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                              ),
                            )
                          : const Icon(
                              Icons.save,
                            ),
                      label: Text(
                        _guardando
                            ? 'Guardando...'
                            : esEdicion
                                ? 'Guardar cambios'
                                : 'Crear sitio',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}