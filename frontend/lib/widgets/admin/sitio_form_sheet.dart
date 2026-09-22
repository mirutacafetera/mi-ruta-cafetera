import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/admin/admin_sitio_service.dart';

import 'sitio_datos_acceso.dart';
import 'sitio_informacion.dart';
import 'sitio_ubicacion.dart';
import 'sitio_contacto.dart';
import 'sitio_informacion_turistica.dart';
import 'sitio_imagen.dart';

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
  static const verdePrincipal = Color(0xFF31572C);
  static const verdeOscuro = Color(0xFF1B4332);
  static const crema = Color(0xFFF8F5EF);

  final _formKey = GlobalKey<FormState>();

  final _nombreCuentaController = TextEditingController();
  final _apellidoCuentaController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoCuentaController = TextEditingController();

  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _departamentoController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correosController = TextEditingController();
  final _sitioWebController = TextEditingController();
  final _horarioController = TextEditingController();
  final _precioDesdeController = TextEditingController();
  final _etiquetasController = TextEditingController();

  final _picker = ImagePicker();
  Uint8List? _imagenBytes;
  final List<String> _imagenesExistentes = [];

  String? _categoriaSeleccionada;
  bool _activo = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();

    if (widget.sitio != null) {
      _cargarDatos(widget.sitio!);
    } else {
      _ciudadController.text = 'Garzón';
      _departamentoController.text = 'Huila';
      _precioDesdeController.text = '0';
    }
  }

  void _cargarDatos(Map<String, dynamic> sitio) {
    final cuenta = sitio['cuenta'];

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

    _passwordController.clear();

    _nombreController.text = sitio['nombre']?.toString() ?? '';
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

    final etiquetas = sitio['etiquetas'];

    _etiquetasController.text = etiquetas is List
        ? etiquetas.map((e) => e.toString()).join(', ')
        : etiquetas?.toString() ?? '';

    _activo = sitio['activo'] != false;

    final categoria = sitio['categoria'];

    if (categoria is Map) {
      _categoriaSeleccionada =
          categoria['_id']?.toString() ??
          categoria['id']?.toString();
    } else {
      _categoriaSeleccionada = categoria?.toString();
    }

    final imagenes = sitio['imagenes'];

    if (imagenes is List) {
      _imagenesExistentes.clear();

      for (final imagen in imagenes) {
        if (imagen.toString().isNotEmpty) {
          _imagenesExistentes.add(imagen.toString());
        }
      }
    }

    final imagen = sitio['imagen']?.toString();

    if (imagen != null &&
        imagen.isNotEmpty &&
        !_imagenesExistentes.contains(imagen)) {
      _imagenesExistentes.insert(0, imagen);
    }
  }

  Future<void> _seleccionarImagen() async {
    try {
      final imagen = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imagen == null) return;

      final bytes = await imagen.readAsBytes();

      if (!mounted) return;

      setState(() => _imagenBytes = bytes);
    } catch (_) {
      if (mounted) {
        _mostrarMensaje('No se pudo seleccionar la imagen.');
      }
    }
  }

  List<String> _obtenerEtiquetas() {
    return _etiquetasController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categoriaSeleccionada == null ||
        _categoriaSeleccionada!.isEmpty) {
      _mostrarMensaje('Selecciona una categoría.');
      return;
    }

    final latitud = double.tryParse(
      _latitudController.text.trim().replaceAll(',', '.'),
    );

    final longitud = double.tryParse(
      _longitudController.text.trim().replaceAll(',', '.'),
    );

    if (latitud == null || longitud == null) {
      _mostrarMensaje(
        'La latitud y longitud deben ser números válidos.',
      );
      return;
    }

    final precio = double.tryParse(
          _precioDesdeController.text
              .trim()
              .replaceAll(',', '.'),
        ) ??
        0;

    if (!widget.esEdicion &&
        (_nombreCuentaController.text.trim().isEmpty ||
            _apellidoCuentaController.text.trim().isEmpty ||
            _correoController.text.trim().isEmpty ||
            _passwordController.text.trim().isEmpty)) {
      _mostrarMensaje(
        'Completa los datos obligatorios de la cuenta.',
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final imagenes = List<String>.from(_imagenesExistentes);
      final imagenPrincipal =
          imagenes.isNotEmpty ? imagenes.first : '';

      final datos = {
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'categoria': _categoriaSeleccionada!,
        'etiquetas': _obtenerEtiquetas(),
        'direccion': _direccionController.text.trim(),
        'ciudad': _ciudadController.text.trim(),
        'departamento': _departamentoController.text.trim(),
        'latitud': latitud,
        'longitud': longitud,
        'activo': _activo,
        'telefono': _telefonoController.text.trim(),
        'correos': _correosController.text.trim(),
        'sitioWeb': _sitioWebController.text.trim(),
        'imagen': imagenPrincipal,
        'imagenes': imagenes,
        'horario': _horarioController.text.trim(),
        'precioDesde': precio,
      };

      if (widget.esEdicion) {
        final id = widget.sitio?['_id']?.toString() ??
            widget.sitio?['id']?.toString() ??
            '';

        if (id.isEmpty) {
          throw Exception(
            'No se encontró el ID del sitio turístico.',
          );
        }

        await AdminSitioService.actualizarSitio(
          id: id,
          nombre: datos['nombre'] as String,
          descripcion: datos['descripcion'] as String,
          categoria: datos['categoria'] as String,
          etiquetas: datos['etiquetas'] as List<String>,
          direccion: datos['direccion'] as String,
          ciudad: datos['ciudad'] as String,
          departamento: datos['departamento'] as String,
          latitud: latitud,
          longitud: longitud,
          activo: _activo,
          telefono: datos['telefono'] as String,
          correos: datos['correos'] as String,
          sitioWeb: datos['sitioWeb'] as String,
          imagen: imagenPrincipal,
          imagenes: imagenes,
          horario: datos['horario'] as String,
          precioDesde: precio,
        );
      } else {
        await AdminSitioService.crearSitio(
          nombreCuenta: _nombreCuentaController.text.trim(),
          apellidoCuenta: _apellidoCuentaController.text.trim(),
          correo: _correoController.text.trim(),
          password: _passwordController.text.trim(),
          telefonoCuenta: _telefonoCuentaController.text.trim(),
          nombre: datos['nombre'] as String,
          descripcion: datos['descripcion'] as String,
          categoria: datos['categoria'] as String,
          etiquetas: datos['etiquetas'] as List<String>,
          direccion: datos['direccion'] as String,
          ciudad: datos['ciudad'] as String,
          departamento: datos['departamento'] as String,
          latitud: latitud,
          longitud: longitud,
          activo: _activo,
          telefono: datos['telefono'] as String,
          correos: datos['correos'] as String,
          sitioWeb: datos['sitioWeb'] as String,
          imagen: imagenPrincipal,
          imagenes: imagenes,
          horario: datos['horario'] as String,
          precioDesde: precio,
        );
      }

      if (!mounted) return;

      _mostrarMensaje(
        widget.esEdicion
            ? 'Sitio actualizado correctamente.'
            : 'Sitio y cuenta creados correctamente.',
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        _mostrarMensaje(
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.esEdicion;

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * .94,
        decoration: const BoxDecoration(
          color: crema,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            _encabezado(esEdicion),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SitioDatosAcceso(
                        esEdicion: esEdicion,
                        nombreController: _nombreCuentaController,
                        apellidoController: _apellidoCuentaController,
                        correoController: _correoController,
                        passwordController: _passwordController,
                        telefonoController:
                            _telefonoCuentaController,
                      ),

                      SitioInformacion(
                        nombreController: _nombreController,
                        descripcionController:
                            _descripcionController,
                        etiquetasController:
                            _etiquetasController,
                        categorias: widget.categorias,
                        categoriaSeleccionada:
                            _categoriaSeleccionada,
                        onCategoriaChanged: (value) {
                          setState(() {
                            _categoriaSeleccionada = value;
                          });
                        },
                      ),

                      SitioUbicacion(
                        direccionController: _direccionController,
                        ciudadController: _ciudadController,
                        departamentoController:
                            _departamentoController,
                        latitudController: _latitudController,
                        longitudController: _longitudController,
                      ),

                      SitioContacto(
                        telefonoController: _telefonoController,
                        correosController: _correosController,
                        sitioWebController: _sitioWebController,
                      ),

                      SitioInformacionTuristica(
                        horarioController: _horarioController,
                        precioController: _precioDesdeController,
                        activo: _activo,
                        onActivoChanged: (value) {
                          setState(() => _activo = value);
                        },
                      ),

                      SitioImagen(
                        imagenBytes: _imagenBytes,
                        imagenesExistentes: _imagenesExistentes,
                        onSeleccionarImagen:
                            _seleccionarImagen,
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed:
                              _guardando ? null : _guardar,
                          icon: _guardando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: Text(
                            _guardando
                                ? 'Guardando...'
                                : esEdicion
                                    ? 'Guardar cambios'
                                    : 'Crear sitio turístico',
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor: verdePrincipal,
                            foregroundColor: Colors.white,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(17),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _guardando
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Cancelar'),
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

  Widget _encabezado(bool esEdicion) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      color: verdeOscuro,
      child: Row(
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  esEdicion
                      ? 'Editar sitio turístico'
                      : 'Nuevo sitio turístico',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  esEdicion
                      ? 'Actualiza la información del sitio'
                      : 'Registra un nuevo lugar turístico',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _guardando
                ? null
                : () => Navigator.pop(context),
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

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
}