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
  State<SitioFormSheet> createState() => _SitioFormSheetState();
}

class _SitioFormSheetState extends State<SitioFormSheet> {
  // =====================================================
  // COLORES
  // =====================================================

  static const Color verdePrincipal = Color(0xFF31572C);
  static const Color verdeOscuro = Color(0xFF1B4332);
  static const Color crema = Color(0xFFF8F5EF);
  static const Color cafe = Color(0xFF795548);
  static const Color grisTexto = Color(0xFF6B6B6B);
  static const Color grisBorde = Color(0xFFE1E1E1);

  // =====================================================
  // FORMULARIO
  // =====================================================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // =====================================================
  // CUENTA
  // =====================================================

  final TextEditingController _nombreCuentaController =
      TextEditingController();

  final TextEditingController _apellidoCuentaController =
      TextEditingController();

  final TextEditingController _correoController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _telefonoCuentaController =
      TextEditingController();

  // =====================================================
  // SITIO
  // =====================================================

  final TextEditingController _nombreController =
      TextEditingController();

  final TextEditingController _descripcionController =
      TextEditingController();

  final TextEditingController _direccionController =
      TextEditingController();

  final TextEditingController _ciudadController =
      TextEditingController();

  final TextEditingController _departamentoController =
      TextEditingController();

  final TextEditingController _latitudController =
      TextEditingController();

  final TextEditingController _longitudController =
      TextEditingController();

  final TextEditingController _telefonoController =
      TextEditingController();

  final TextEditingController _correosController =
      TextEditingController();

  final TextEditingController _sitioWebController =
      TextEditingController();

  final TextEditingController _horarioController =
      TextEditingController();

  final TextEditingController _precioDesdeController =
      TextEditingController();

  final TextEditingController _etiquetasController =
      TextEditingController();

  // =====================================================
  // IMAGEN
  // =====================================================

  final ImagePicker _picker = ImagePicker();

  Uint8List? _imagenBytes;

  final List<String> _imagenesExistentes = [];

  // =====================================================
  // ESTADO
  // =====================================================

  String? _categoriaSeleccionada;

  bool _activo = true;

  bool _guardando = false;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {
    super.initState();

    if (widget.sitio != null) {
      _cargarDatosSitio(widget.sitio!);
    } else {
      _ciudadController.text = 'Garzón';
      _departamentoController.text = 'Huila';
      _precioDesdeController.text = '0';
    }
  }

  // =====================================================
  // CARGAR SITIO
  // =====================================================

  void _cargarDatosSitio(Map<String, dynamic> sitio) {
    // -----------------------------------------------------
    // CUENTA
    // -----------------------------------------------------

    final dynamic cuenta = sitio['cuenta'];

    if (cuenta is Map) {
      _nombreCuentaController.text =
          cuenta['nombre']?.toString() ?? '';

      _apellidoCuentaController.text =
          cuenta['apellido']?.toString() ?? '';

      _correoController.text =
          cuenta['correo']?.toString() ?? '';

      _telefonoCuentaController.text =
          cuenta['telefono']?.toString() ?? '';
    } else {
      _nombreCuentaController.text =
          sitio['nombreCuenta']?.toString() ?? '';

      _apellidoCuentaController.text =
          sitio['apellidoCuenta']?.toString() ?? '';

      _correoController.text =
          sitio['correo']?.toString() ?? '';

      _telefonoCuentaController.text =
          sitio['telefonoCuenta']?.toString() ?? '';
    }

    // Nunca cargar contraseña
    _passwordController.clear();

    // -----------------------------------------------------
    // SITIO
    // -----------------------------------------------------

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

    // -----------------------------------------------------
    // ETIQUETAS
    // -----------------------------------------------------

    final dynamic etiquetas = sitio['etiquetas'];

    if (etiquetas is List) {
      _etiquetasController.text = etiquetas
          .map((elemento) => elemento.toString())
          .join(', ');
    } else {
      _etiquetasController.text =
          etiquetas?.toString() ?? '';
    }

    // -----------------------------------------------------
    // ESTADO
    // -----------------------------------------------------

    _activo = sitio['activo'] != false;

    // -----------------------------------------------------
    // CATEGORÍA
    // -----------------------------------------------------

    final dynamic categoria = sitio['categoria'];

    if (categoria is Map) {
      _categoriaSeleccionada =
          categoria['_id']?.toString();
    } else if (categoria != null) {
      _categoriaSeleccionada =
          categoria.toString();
    }

    // -----------------------------------------------------
    // IMÁGENES
    // -----------------------------------------------------

    final dynamic imagenes = sitio['imagenes'];

    if (imagenes is List) {
      for (final imagen in imagenes) {
        final String url = imagen.toString();

        if (url.isNotEmpty) {
          _imagenesExistentes.add(url);
        }
      }
    }

    // -----------------------------------------------------
    // IMAGEN PRINCIPAL
    // -----------------------------------------------------

    final String imagenPrincipal =
        sitio['imagen']?.toString() ?? '';

    if (imagenPrincipal.isNotEmpty &&
        !_imagenesExistentes.contains(imagenPrincipal)) {
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
    _nombreCuentaController.dispose();
    _apellidoCuentaController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _telefonoCuentaController.dispose();

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
    _etiquetasController.dispose();

    super.dispose();
  }

  // =====================================================
  // SELECCIONAR IMAGEN
  // =====================================================

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imagen == null) {
        return;
      }

      final Uint8List bytes =
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
  // OBTENER ETIQUETAS
  // =====================================================

  List<String> _obtenerEtiquetas() {
    return _etiquetasController.text
        .split(',')
        .map(
          (String etiqueta) => etiqueta.trim(),
        )
        .where(
          (String etiqueta) => etiqueta.isNotEmpty,
        )
        .toList();
  }

  // =====================================================
  // GUARDAR
  // =====================================================

  Future<void> _guardar() async {
    // -----------------------------------------------------
    // VALIDAR FORMULARIO
    // -----------------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // -----------------------------------------------------
    // VALIDAR CATEGORÍA
    // -----------------------------------------------------

    if (_categoriaSeleccionada == null ||
        _categoriaSeleccionada!.isEmpty) {
      _mostrarMensaje(
        'Selecciona una categoría.',
      );
      return;
    }

    // -----------------------------------------------------
    // LATITUD
    // -----------------------------------------------------

    final double? latitud = double.tryParse(
      _latitudController.text.trim().replaceAll(',', '.'),
    );

    // -----------------------------------------------------
    // LONGITUD
    // -----------------------------------------------------

    final double? longitud = double.tryParse(
      _longitudController.text.trim().replaceAll(',', '.'),
    );

    if (latitud == null || longitud == null) {
      _mostrarMensaje(
        'La latitud y longitud deben ser números válidos.',
      );
      return;
    }

    // -----------------------------------------------------
    // PRECIO
    // -----------------------------------------------------

    final double precio =
        double.tryParse(
          _precioDesdeController.text
              .trim()
              .replaceAll(',', '.'),
        ) ??
        0;

    // -----------------------------------------------------
    // ETIQUETAS
    // -----------------------------------------------------

    final List<String> etiquetas =
        _obtenerEtiquetas();

    // -----------------------------------------------------
    // VALIDAR CUENTA AL CREAR
    // -----------------------------------------------------

    if (!widget.esEdicion) {
      if (_nombreCuentaController.text
              .trim()
              .isEmpty ||
          _apellidoCuentaController.text
              .trim()
              .isEmpty ||
          _correoController.text
              .trim()
              .isEmpty ||
          _passwordController.text
              .trim()
              .isEmpty) {
        _mostrarMensaje(
          'Completa los datos obligatorios de la cuenta.',
        );
        return;
      }
    }

    // -----------------------------------------------------
    // ACTIVAR CARGANDO
    // -----------------------------------------------------

    setState(() {
      _guardando = true;
    });

    try {
      // ---------------------------------------------------
      // IMÁGENES
      // ---------------------------------------------------

      final List<String> imagenes =
          List<String>.from(
        _imagenesExistentes,
      );

      final String imagenPrincipal =
          imagenes.isNotEmpty
              ? imagenes.first
              : '';

      // ===================================================
      // CREAR SITIO
      // ===================================================

      if (!widget.esEdicion) {
        await AdminSitioService.crearSitio(
          nombreCuenta:
              _nombreCuentaController.text.trim(),

          apellidoCuenta:
              _apellidoCuentaController.text.trim(),

          correo:
              _correoController.text.trim(),

          password:
              _passwordController.text.trim(),

          telefonoCuenta:
              _telefonoCuentaController.text.trim(),

          nombre:
              _nombreController.text.trim(),

          descripcion:
              _descripcionController.text.trim(),

          categoria:
              _categoriaSeleccionada!,

          etiquetas:
              etiquetas,

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

      // ===================================================
      // EDITAR SITIO
      // ===================================================

      else {
        final String id =
            widget.sitio?['_id']?.toString() ??
            widget.sitio?['id']?.toString() ??
            '';

        if (id.isEmpty) {
          throw Exception(
            'No se encontró el ID del sitio turístico.',
          );
        }

        await AdminSitioService.actualizarSitio(
          id: id,

          nombre:
              _nombreController.text.trim(),

          descripcion:
              _descripcionController.text.trim(),

          categoria:
              _categoriaSeleccionada!,

          etiquetas:
              etiquetas,

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

      // -----------------------------------------------------
      // ÉXITO
      // -----------------------------------------------------

      if (!mounted) {
        return;
      }

      _mostrarMensaje(
        widget.esEdicion
            ? 'Sitio actualizado correctamente.'
            : 'Sitio y cuenta creados correctamente.',
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
  // MENSAJE
  // =====================================================

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
      ),
    );
  }

  // =====================================================
  // TÍTULO DE SECCIÓN
  // =====================================================

  Widget _tituloSeccion(
    IconData icono,
    String titulo,
    String subtitulo,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  verdePrincipal.withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              icono,
              color: verdePrincipal,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                    color: verdeOscuro,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: grisTexto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // CAMPO
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
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: TextFormField(
        controller: controller,
        maxLines:
            obscureText ? 1 : maxLines,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF333333),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: grisTexto,
            fontSize: 14,
          ),
          floatingLabelStyle:
              const TextStyle(
            color: verdePrincipal,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: cafe,
                  size: 21,
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: grisBorde,
            ),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: grisBorde,
            ),
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: verdePrincipal,
              width: 2,
            ),
          ),
          errorBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
          focusedErrorBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 2,
            ),
          ),
        ),
        validator: obligatorio
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
  // TARJETA
  // =====================================================

  Widget _tarjetaSeccion({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 18,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset:
                const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // =====================================================
  // IMAGEN
  // =====================================================

  Widget _widgetImagen() {
    if (_imagenBytes != null) {
      return GestureDetector(
        onTap: _seleccionarImagen,
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(18),
          child: Image.memory(
            _imagenBytes!,
            width: double.infinity,
            height: 190,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (_imagenesExistentes.isNotEmpty) {
      return GestureDetector(
        onTap: _seleccionarImagen,
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(18),
          child: Image.network(
            _imagenesExistentes.first,
            width: double.infinity,
            height: 190,
            fit: BoxFit.cover,
            errorBuilder:
                (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
            ) {
              return _placeholderImagen();
            },
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _seleccionarImagen,
      child: _placeholderImagen(),
    );
  }

  // =====================================================
  // PLACEHOLDER
  // =====================================================

  Widget _placeholderImagen() {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F0),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: grisBorde,
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color:
                  verdePrincipal.withOpacity(
                0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_a_photo_rounded,
              color: verdePrincipal,
              size: 30,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Agregar imagen',
            style: TextStyle(
              fontWeight:
                  FontWeight.w600,
              color: verdeOscuro,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Toca aquí para seleccionar una foto',
            style: TextStyle(
              fontSize: 12,
              color: grisTexto,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final bool esEdicion =
        widget.esEdicion;

    return SafeArea(
      child: Container(
        height:
            MediaQuery.of(context)
                    .size
                    .height *
                0.94,
        decoration:
            const BoxDecoration(
          color: crema,
          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        clipBehavior:
            Clip.antiAlias,
        child: Column(
          children: [
            // =================================================
            // ENCABEZADO
            // =================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                18,
                12,
                18,
              ),
              decoration:
                  const BoxDecoration(
                color: verdeOscuro,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration:
                        BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: Icon(
                      esEdicion
                          ? Icons
                              .edit_location_alt_rounded
                          : Icons
                              .add_location_alt_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          esEdicion
                              ? 'Editar sitio turístico'
                              : 'Nuevo sitio turístico',
                          style:
                              const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          esEdicion
                              ? 'Actualiza la información del sitio'
                              : 'Registra un nuevo lugar turístico',
                          style:
                              TextStyle(
                            fontSize: 12,
                            color: Colors.white
                                .withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: _guardando
                        ? null
                        : () {
                            Navigator.pop(
                              context,
                            );
                          },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // CONTENIDO
            // =================================================

            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  18,
                  16,
                  30,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // =================================================
                      // DATOS DE ACCESO
                      // =================================================

                      _tarjetaSeccion(
                        child: Column(
                          children: [
                            _tituloSeccion(
                              Icons.person_outline_rounded,
                              'Datos de acceso',
                              esEdicion
                                  ? 'Información del responsable'
                                  : 'Cuenta que administrará este sitio',
                            ),

                            _campoTexto(
                              _nombreCuentaController,
                              'Nombre del responsable',
                              icon:
                                  Icons.person_rounded,
                              obligatorio:
                                  !esEdicion,
                            ),

                            _campoTexto(
                              _apellidoCuentaController,
                              'Apellido del responsable',
                              icon:
                                  Icons.person_outline_rounded,
                              obligatorio:
                                  !esEdicion,
                            ),

                            _campoTexto(
                              _correoController,
                              'Correo de acceso',
                              icon:
                                  Icons.email_rounded,
                              keyboardType:
                                  TextInputType.emailAddress,
                              obligatorio:
                                  !esEdicion,
                            ),

                            _campoTexto(
                              _passwordController,
                              esEdicion
                                  ? 'Nueva contraseña (opcional)'
                                  : 'Contraseña',
                              icon:
                                  Icons.lock_rounded,
                              obscureText:
                                  true,
                              obligatorio:
                                  !esEdicion,
                            ),

                            _campoTexto(
                              _telefonoCuentaController,
                              'Teléfono de la cuenta',
                              icon:
                                  Icons.phone_rounded,
                              keyboardType:
                                  TextInputType.phone,
                            ),
                          ],
                        ),
                      ),

                      // =================================================
                      // INFORMACIÓN DEL SITIO
                      // =================================================

                      _tarjetaSeccion(
                        child: Column(
                          children: [
                            _tituloSeccion(
                              Icons.place_outlined,
                              'Información del sitio',
                              'Datos principales del lugar turístico',
                            ),

                            _campoTexto(
                              _nombreController,
                              'Nombre del sitio',
                              icon:
                                  Icons.place_rounded,
                              obligatorio:
                                  true,
                            ),

                            _campoTexto(
                              _descripcionController,
                              'Descripción',
                              icon:
                                  Icons.description_rounded,
                              maxLines: 4,
                              obligatorio:
                                  true,
                            ),

                            // CATEGORÍA
                            Padding(
                              padding:
                                  const EdgeInsets.only(
                                bottom: 14,
                              ),
                              child:
                                  DropdownButtonFormField<
                                      String>(
                                value:
                                    _categoriaSeleccionada,
                                isExpanded: true,
                                decoration:
                                    InputDecoration(
                                  labelText:
                                      'Categoría',
                                  filled: true,
                                  fillColor:
                                      Colors.white,
                                  prefixIcon:
                                      const Icon(
                                    Icons
                                        .category_rounded,
                                    color: cafe,
                                  ),
                                  contentPadding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                    borderSide:
                                        const BorderSide(
                                      color:
                                          grisBorde,
                                    ),
                                  ),
                                  enabledBorder:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                    borderSide:
                                        const BorderSide(
                                      color:
                                          grisBorde,
                                    ),
                                  ),
                                  focusedBorder:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                    borderSide:
                                        const BorderSide(
                                      color:
                                          verdePrincipal,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                items: widget
                                    .categorias
                                    .map(
                                  (
                                    Map<String, dynamic>
                                        categoria,
                                  ) {
                                    final String?
                                        id =
                                        categoria[
                                                '_id']
                                            ?.toString();

                                    final String
                                        nombre =
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
                                      child: Text(
                                        nombre,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                      ),
                                    );
                                  },
                                )
                                    .whereType<
                                        DropdownMenuItem<
                                            String>>()
                                    .toList(),
                                onChanged:
                                    (String? value) {
                                  setState(() {
                                    _categoriaSeleccionada =
                                        value;
                                  });
                                },
                                validator:
                                    (String? value) {
                                  if (value ==
                                          null ||
                                      value.isEmpty) {
                                    return 'Selecciona una categoría';
                                  }

                                  return null;
                                },
                              ),
                            ),

                            _campoTexto(
                              _etiquetasController,
                              'Etiquetas',
                              icon:
                                  Icons.local_offer_rounded,
                            ),

                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFF3F6F0,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),
                              ),
                              child: const Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Icon(
                                    Icons
                                        .info_outline_rounded,
                                    size: 17,
                                    color:
                                        verdePrincipal,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Separa las etiquetas con comas. Ejemplo: café, naturaleza, aventura.',
                                      style:
                                          TextStyle(
                                        fontSize: 11,
                                        color:
                                            grisTexto,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // =================================================
                      // UBICACIÓN
                      // =================================================

                      _tarjetaSeccion(
                        child: Column(
                          children: [
                            _tituloSeccion(
                              Icons.map_outlined,
                              'Ubicación',
                              'Indica dónde se encuentra el sitio',
                            ),

                            _campoTexto(
                              _direccionController,
                              'Dirección',
                              icon:
                                  Icons.location_on_rounded,
                            ),

                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Expanded(
                                  child:
                                      _campoTexto(
                                    _ciudadController,
                                    'Ciudad',
                                    icon:
                                        Icons.location_city_rounded,
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
                                    _departamentoController,
                                    'Departamento',
                                    icon:
                                        Icons.map_rounded,
                                    obligatorio:
                                        true,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Expanded(
                                  child:
                                      _campoTexto(
                                    _latitudController,
                                    'Latitud',
                                    icon:
                                        Icons.explore_rounded,
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
                                    icon:
                                        Icons.explore_outlined,
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
                          ],
                        ),
                      ),

                      // =================================================
                      // CONTACTO
                      // =================================================

                      _tarjetaSeccion(
                        child: Column(
                          children: [
                            _tituloSeccion(
                              Icons.contact_phone_outlined,
                              'Información de contacto',
                              'Datos para comunicarse con el sitio',
                            ),

                            _campoTexto(
                              _telefonoController,
                              'Teléfono del sitio',
                              icon:
                                  Icons.phone_rounded,
                              keyboardType:
                                  TextInputType.phone,
                            ),

                            _campoTexto(
                              _correosController,
                              'Correo de contacto',
                              icon:
                                  Icons.email_outlined,
                              keyboardType:
                                  TextInputType.emailAddress,
                            ),

                            _campoTexto(
                              _sitioWebController,
                              'Sitio web',
                              icon:
                                  Icons.language_rounded,
                              keyboardType:
                                  TextInputType.url,
                            ),
                          ],
                        ),
                      ),

                      // =================================================
                      // INFORMACIÓN TURÍSTICA
                      // =================================================

                      _tarjetaSeccion(
                        child: Column(
                          children: [
                            _tituloSeccion(
                              Icons.travel_explore_rounded,
                              'Información turística',
                              'Información útil para los visitantes',
                            ),

                            _campoTexto(
                              _horarioController,
                              'Horario de atención',
                              icon:
                                  Icons.schedule_rounded,
                            ),

                            _campoTexto(
                              _precioDesdeController,
                              'Precio desde',
                              icon:
                                  Icons.payments_rounded,
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: true,
                              ),
                            ),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFF5F7F2,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                                border:
                                    Border.all(
                                  color:
                                      grisBorde,
                                ),
                              ),
                              child:
                                  SwitchListTile(
                                contentPadding:
                                    EdgeInsets.zero,
                                activeColor:
                                    verdePrincipal,
                                title:
                                    const Text(
                                  'Sitio activo',
                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight.w600,
                                    color:
                                        verdeOscuro,
                                  ),
                                ),
                                subtitle:
                                    Text(
                                  _activo
                                      ? 'Disponible para los visitantes'
                                      : 'Oculto para los visitantes',
                                  style:
                                      const TextStyle(
                                    fontSize: 11,
                                    color:
                                        grisTexto,
                                  ),
                                ),
                                value:
                                    _activo,
                                onChanged:
                                    (bool value) {
                                  setState(() {
                                    _activo =
                                        value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // =================================================
                      // IMAGEN
                      // =================================================

                      _tarjetaSeccion(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            _tituloSeccion(
                              Icons.photo_camera_outlined,
                              'Imagen principal',
                              'Una buena imagen ayuda a mostrar el sitio',
                            ),

                            _widgetImagen(),

                            const SizedBox(
                              height: 10,
                            ),

                            const Row(
                              children: [
                                Icon(
                                  Icons
                                      .photo_library_outlined,
                                  size: 16,
                                  color:
                                      grisTexto,
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Expanded(
                                  child: Text(
                                    'Toca la imagen para seleccionar una foto desde la galería.',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          11,
                                      color:
                                          grisTexto,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // =================================================
                      // GUARDAR
                      // =================================================

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child:
                            ElevatedButton.icon(
                          onPressed:
                              _guardando
                                  ? null
                                  : _guardar,
                          icon: _guardando
                              ? const SizedBox(
                                  width: 21,
                                  height: 21,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2.5,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .save_rounded,
                                ),
                          label: Text(
                            _guardando
                                ? 'Guardando...'
                                : esEdicion
                                    ? 'Guardar cambios'
                                    : 'Crear sitio turístico',
                            style:
                                const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                verdePrincipal,
                            foregroundColor:
                                Colors.white,
                            disabledBackgroundColor:
                                verdePrincipal
                                    .withOpacity(
                              0.55,
                            ),
                            elevation: 4,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                17,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // =================================================
                      // CANCELAR
                      // =================================================

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child:
                            OutlinedButton(
                          onPressed:
                              _guardando
                                  ? null
                                  : () {
                                      Navigator.pop(
                                        context,
                                      );
                                    },
                          style:
                              OutlinedButton
                                  .styleFrom(
                            foregroundColor:
                                verdeOscuro,
                            side:
                                const BorderSide(
                              color:
                                  grisBorde,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                15,
                              ),
                            ),
                          ),
                          child:
                              const Text(
                            'Cancelar',
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}