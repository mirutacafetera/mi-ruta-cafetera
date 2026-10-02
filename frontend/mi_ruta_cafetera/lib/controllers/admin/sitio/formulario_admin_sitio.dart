import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/admin/sitio/servicio_admin_sitio.dart';
import '../../../theme/app_colors.dart';

class FormularioAdminSitio extends ChangeNotifier {
  FormularioAdminSitio({
    this.sitio,
    this.categorias = const [],
  }) {
    _cargarDatos();
  }

  final Map<String, dynamic>? sitio;

  final List<Map<String, dynamic>> categorias;

  bool get esEdicion => sitio != null;

  final nombreCuentaController = TextEditingController();
  final apellidoCuentaController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final telefonoCuentaController = TextEditingController();

  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final direccionController = TextEditingController();
  final ciudadController = TextEditingController();
  final departamentoController = TextEditingController();
  final latitudController = TextEditingController();
  final longitudController = TextEditingController();
  final telefonoController = TextEditingController();
  final correosController = TextEditingController();
  final sitioWebController = TextEditingController();
  final horarioController = TextEditingController();
  final precioDesdeController = TextEditingController();
  final etiquetasController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Uint8List? imagenBytes;

  final List<String> imagenesExistentes = [];

  String? categoriaSeleccionada;

  bool activo = true;

  bool guardando = false;

  void _cargarDatos() {
    if (sitio == null) {
      ciudadController.text = 'Garzón';
      departamentoController.text = 'Huila';
      precioDesdeController.text = '0';
      return;
    }

    final data = sitio!;
    final cuenta = data['cuenta'];

    nombreCuentaController.text = cuenta is Map
        ? cuenta['nombre']?.toString() ?? ''
        : data['nombreCuenta']?.toString() ?? '';

    apellidoCuentaController.text = cuenta is Map
        ? cuenta['apellido']?.toString() ?? ''
        : data['apellidoCuenta']?.toString() ?? '';

    correoController.text = cuenta is Map
        ? cuenta['correo']?.toString() ?? ''
        : data['correo']?.toString() ?? '';

    telefonoCuentaController.text = cuenta is Map
        ? cuenta['telefono']?.toString() ?? ''
        : data['telefonoCuenta']?.toString() ?? '';

    nombreController.text =
        data['nombre']?.toString() ?? '';

    descripcionController.text =
        data['descripcion']?.toString() ?? '';

    direccionController.text =
        data['direccion']?.toString() ?? '';

    ciudadController.text =
        data['ciudad']?.toString() ?? 'Garzón';

    departamentoController.text =
        data['departamento']?.toString() ?? 'Huila';

    latitudController.text =
        data['latitud']?.toString() ?? '';

    longitudController.text =
        data['longitud']?.toString() ?? '';

    telefonoController.text =
        data['telefono']?.toString() ?? '';

    correosController.text =
        data['correos']?.toString() ?? '';

    sitioWebController.text =
        data['sitioWeb']?.toString() ?? '';

    horarioController.text =
        data['horario']?.toString() ?? '';

    precioDesdeController.text =
        data['precioDesde']?.toString() ?? '0';

    final etiquetas = data['etiquetas'];

    etiquetasController.text = etiquetas is List
        ? etiquetas.map((e) => e.toString()).join(', ')
        : etiquetas?.toString() ?? '';

    activo = data['activo'] != false;

    final categoria = data['categoria'];

    categoriaSeleccionada = categoria is Map
        ? categoria['_id']?.toString() ??
            categoria['id']?.toString()
        : categoria?.toString();

    final imagenes = data['imagenes'];

    if (imagenes is List) {
      imagenesExistentes.addAll(
        imagenes
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty),
      );
    }

    final imagen = data['imagen']?.toString();

    if (imagen != null &&
        imagen.isNotEmpty &&
        !imagenesExistentes.contains(imagen)) {
      imagenesExistentes.insert(0, imagen);
    }
  }

  void cambiarCategoria(String? value) {
    categoriaSeleccionada = value;
    notifyListeners();
  }

  IconData obtenerIconoCategoria() {
    final categoria = categorias.firstWhere(
      (item) => item['_id']?.toString() == categoriaSeleccionada,
      orElse: () => {},
    );

    final nombre = categoria['nombre']?.toString() ?? '';

    return AppColors.getIconForCategory(nombre);
  }

  void cambiarActivo(bool value) {
    activo = value;
    notifyListeners();
  }

  Future<void> seleccionarImagen() async {
    final imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (imagen == null) return;

    imagenBytes = await imagen.readAsBytes();

    notifyListeners();
  }

  List<String> obtenerEtiquetas() {
    return etiquetasController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> guardar() async {
    if (guardando) return;

    if (categoriaSeleccionada == null ||
        categoriaSeleccionada!.isEmpty) {
      throw Exception('Selecciona una categoría.');
    }

    if (!esEdicion &&
        (nombreCuentaController.text.trim().isEmpty ||
            apellidoCuentaController.text.trim().isEmpty ||
            correoController.text.trim().isEmpty ||
            passwordController.text.trim().isEmpty)) {
      throw Exception(
        'Completa los datos obligatorios de la cuenta.',
      );
    }

    final latitud = double.tryParse(
      latitudController.text.trim().replaceAll(',', '.'),
    );

    final longitud = double.tryParse(
      longitudController.text.trim().replaceAll(',', '.'),
    );

    if (latitud == null || longitud == null) {
      throw Exception(
        'La latitud y longitud deben ser números válidos.',
      );
    }

    final precio = double.tryParse(
          precioDesdeController.text.trim().replaceAll(',', '.'),
        ) ??
        0;

    guardando = true;
    notifyListeners();

    try {
      final imagenes = List<String>.from(imagenesExistentes);

      final imagen =
          imagenes.isNotEmpty ? imagenes.first : '';

      final etiquetas = obtenerEtiquetas();

      if (esEdicion) {
        final id =
            sitio?['_id']?.toString() ??
            sitio?['id']?.toString() ??
            '';

        if (id.isEmpty) {
          throw Exception(
            'No se encontró el ID del sitio.',
          );
        }

        await ServicioAdminSitio.actualizarSitio(
          id: id,
          nombre: nombreController.text.trim(),
          descripcion: descripcionController.text.trim(),
          categoria: categoriaSeleccionada!,
          direccion: direccionController.text.trim(),
          ciudad: ciudadController.text.trim(),
          departamento: departamentoController.text.trim(),
          latitud: latitud,
          longitud: longitud,
          etiquetas: etiquetas,
          activo: activo,
          telefono: telefonoController.text.trim(),
          correos: correosController.text.trim(),
          sitioWeb: sitioWebController.text.trim(),
          imagen: imagen,
          imagenes: imagenes,
          horario: horarioController.text.trim(),
          precioDesde: precio,
        );
      } else {
        await ServicioAdminSitio.crearSitio(
          nombreCuenta:
              nombreCuentaController.text.trim(),
          apellidoCuenta:
              apellidoCuentaController.text.trim(),
          correo: correoController.text.trim(),
          password: passwordController.text.trim(),
          telefonoCuenta:
              telefonoCuentaController.text.trim(),
          nombre: nombreController.text.trim(),
          descripcion:
              descripcionController.text.trim(),
          categoria: categoriaSeleccionada!,
          direccion:
              direccionController.text.trim(),
          ciudad: ciudadController.text.trim(),
          departamento:
              departamentoController.text.trim(),
          latitud: latitud,
          longitud: longitud,
          etiquetas: etiquetas,
          activo: activo,
          telefono:
              telefonoController.text.trim(),
          correos:
              correosController.text.trim(),
          sitioWeb:
              sitioWebController.text.trim(),
          imagen: imagen,
          imagenes: imagenes,
          horario:
              horarioController.text.trim(),
          precioDesde: precio,
        );
      }
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nombreCuentaController.dispose();
    apellidoCuentaController.dispose();
    correoController.dispose();
    passwordController.dispose();
    telefonoCuentaController.dispose();

    nombreController.dispose();
    descripcionController.dispose();
    direccionController.dispose();
    ciudadController.dispose();
    departamentoController.dispose();
    latitudController.dispose();
    longitudController.dispose();

    telefonoController.dispose();
    correosController.dispose();
    sitioWebController.dispose();
    horarioController.dispose();
    precioDesdeController.dispose();
    etiquetasController.dispose();

    super.dispose();
  }
}