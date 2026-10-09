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

  // ============================================================
  // DATOS GENERALES
  // ============================================================

  final Map<String, dynamic>? sitio;

  final List<Map<String, dynamic>> categorias;

  bool get esEdicion => sitio != null;

  // ============================================================
  // CUENTA DEL SITIO
  // ============================================================

  final nombreCuentaController =
      TextEditingController();

  final apellidoCuentaController =
      TextEditingController();

  final correoController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final telefonoCuentaController =
      TextEditingController();

  // ============================================================
  // INFORMACIÓN DEL SITIO
  // ============================================================

  final nombreController =
      TextEditingController();

  final descripcionController =
      TextEditingController();

  final direccionController =
      TextEditingController();

  final ciudadController =
      TextEditingController();

  final departamentoController =
      TextEditingController();

  final latitudController =
      TextEditingController();

  final longitudController =
      TextEditingController();

  final telefonoController =
      TextEditingController();

  final correosController =
      TextEditingController();

  final sitioWebController =
      TextEditingController();

  final horarioController =
      TextEditingController();

  final precioDesdeController =
      TextEditingController();

  final etiquetasController =
      TextEditingController();

  // ============================================================
  // IMAGEN PRINCIPAL
  // ============================================================

  final ImagePicker _picker =
      ImagePicker();

  Uint8List? imagenBytes;

  String nombreImagen = 'imagen.jpg';

  // Imagen principal existente cuando se está editando.
  final List<String> imagenesExistentes = [];

  // ============================================================
  // ESTADO
  // ============================================================

  String? categoriaSeleccionada;

  bool activo = true;

  bool guardando = false;

  // ============================================================
  // CARGAR DATOS
  // ============================================================

  void _cargarDatos() {
    // ----------------------------------------------------------
    // CREAR
    // ----------------------------------------------------------

    if (sitio == null) {
      ciudadController.text = 'Garzón';

      departamentoController.text = 'Huila';

      precioDesdeController.text = '0';

      return;
    }

    // ----------------------------------------------------------
    // EDITAR
    // ----------------------------------------------------------

    final data = sitio!;

    // ==========================================================
    // CUENTA
    // ==========================================================

    final cuenta = data['cuenta'];

    nombreCuentaController.text =
        cuenta is Map
            ? cuenta['nombre']?.toString() ?? ''
            : data['nombreCuenta']?.toString() ?? '';

    apellidoCuentaController.text =
        cuenta is Map
            ? cuenta['apellido']?.toString() ?? ''
            : data['apellidoCuenta']?.toString() ?? '';

    correoController.text =
        cuenta is Map
            ? cuenta['correo']?.toString() ?? ''
            : data['correo']?.toString() ?? '';

    telefonoCuentaController.text =
        cuenta is Map
            ? cuenta['telefono']?.toString() ?? ''
            : data['telefonoCuenta']?.toString() ?? '';

    // ==========================================================
    // DATOS DEL SITIO
    // ==========================================================

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

    // ==========================================================
    // ETIQUETAS
    // ==========================================================

    final etiquetas = data['etiquetas'];

    etiquetasController.text =
        etiquetas is List
            ? etiquetas
                .map((e) => e.toString())
                .join(', ')
            : etiquetas?.toString() ?? '';

    // ==========================================================
    // ESTADO
    // ==========================================================

    activo = data['activo'] != false;

    // ==========================================================
    // CATEGORÍA
    // ==========================================================

    final categoria = data['categoria'];

    categoriaSeleccionada =
        categoria is Map
            ? categoria['_id']?.toString() ??
                categoria['id']?.toString()
            : categoria?.toString();

    // ==========================================================
    // IMAGEN PRINCIPAL EXISTENTE
    // ==========================================================

    final imagen =
        data['imagen']?.toString();

    if (imagen != null &&
        imagen.isNotEmpty) {
      imagenesExistentes.add(imagen);
    }
  }

  // ============================================================
  // CATEGORÍA
  // ============================================================

  void cambiarCategoria(String? value) {
    categoriaSeleccionada = value;

    notifyListeners();
  }

  IconData obtenerIconoCategoria() {
    final categoria =
        categorias.firstWhere(
      (item) =>
          item['_id']?.toString() ==
          categoriaSeleccionada,
      orElse: () => {},
    );

    return AppColors.getIconForCategory(
      categoria['nombre']?.toString() ?? '',
    );
  }

  // ============================================================
  // ESTADO ACTIVO
  // ============================================================

  void cambiarActivo(bool value) {
    activo = value;

    notifyListeners();
  }

  // ============================================================
  // SELECCIONAR IMAGEN PRINCIPAL
  // ============================================================

  Future<void> seleccionarImagen() async {
    final imagen =
        await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (imagen == null) {
      return;
    }

    imagenBytes =
        await imagen.readAsBytes();

    nombreImagen = imagen.name;

    notifyListeners();
  }

  // ============================================================
  // ETIQUETAS
  // ============================================================

  List<String> obtenerEtiquetas() {
    return etiquetasController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // ============================================================
  // VALIDAR CUENTA
  // ============================================================

  void _validarCuenta() {
    // En edición no se crea una cuenta nueva.
    if (esEdicion) {
      return;
    }

    final nombre =
        nombreCuentaController.text.trim();

    final apellido =
        apellidoCuentaController.text.trim();

    final correo =
        correoController.text.trim();

    final password =
        passwordController.text.trim();

    if (nombre.isEmpty ||
        apellido.isEmpty ||
        correo.isEmpty ||
        password.isEmpty) {
      throw Exception(
        'Te faltan datos por rellenar en el '
        'formulario de la cuenta del sitio.',
      );
    }

    if (password.length < 6) {
      throw Exception(
        'La contraseña debe tener al menos '
        '6 caracteres.',
      );
    }
  }

  // ============================================================
  // VALIDAR SITIO
  // ============================================================

  void _validarSitio() {
    final nombre =
        nombreController.text.trim();

    final descripcion =
        descripcionController.text.trim();

    final ciudad =
        ciudadController.text.trim();

    final departamento =
        departamentoController.text.trim();

    if (nombre.isEmpty ||
        descripcion.isEmpty ||
        ciudad.isEmpty ||
        departamento.isEmpty) {
      throw Exception(
        'Te faltan datos por rellenar en el '
        'formulario del sitio.',
      );
    }

    // ----------------------------------------------------------
    // CATEGORÍA
    // ----------------------------------------------------------

    if (categoriaSeleccionada == null ||
        categoriaSeleccionada!
            .trim()
            .isEmpty) {
      throw Exception(
        'Selecciona una categoría.',
      );
    }

    // ----------------------------------------------------------
    // IMAGEN PRINCIPAL OBLIGATORIA
    // ----------------------------------------------------------

    if (!esEdicion &&
        imagenBytes == null) {
      throw Exception(
        'Selecciona una imagen principal '
        'para el sitio.',
      );
    }
  }

  // ============================================================
  // GUARDAR
  // ============================================================

  Future<void> guardar() async {
    if (guardando) {
      return;
    }

    // ----------------------------------------------------------
    // VALIDACIONES
    // ----------------------------------------------------------

    _validarSitio();

    _validarCuenta();

    // ----------------------------------------------------------
    // LATITUD
    // ----------------------------------------------------------

    final latitud =
        double.tryParse(
      latitudController.text
          .trim()
          .replaceAll(',', '.'),
    );

    // ----------------------------------------------------------
    // LONGITUD
    // ----------------------------------------------------------

    final longitud =
        double.tryParse(
      longitudController.text
          .trim()
          .replaceAll(',', '.'),
    );

    if (latitud == null ||
        longitud == null) {
      throw Exception(
        'La latitud y longitud deben ser '
        'números válidos.',
      );
    }

    // ----------------------------------------------------------
    // PRECIO
    // ----------------------------------------------------------

    final precio =
        double.tryParse(
          precioDesdeController.text
              .trim()
              .replaceAll(',', '.'),
        ) ??
        0;

    guardando = true;

    notifyListeners();

    try {
      final etiquetas =
          obtenerEtiquetas();

      // ========================================================
      // EDICIÓN
      // ========================================================

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

        await ServicioAdminSitio
            .actualizarSitio(
          id: id,

          nombre:
              nombreController.text.trim(),

          descripcion:
              descripcionController
                  .text
                  .trim(),

          categoria:
              categoriaSeleccionada!,

          direccion:
              direccionController.text
                  .trim(),

          ciudad:
              ciudadController.text.trim(),

          departamento:
              departamentoController
                  .text
                  .trim(),

          latitud: latitud,

          longitud: longitud,

          etiquetas: etiquetas,

          activo: activo,

          telefono:
              telefonoController.text
                  .trim(),

          correos:
              correosController.text
                  .trim(),

          sitioWeb:
              sitioWebController.text
                  .trim(),

          // En edición es opcional.
          // Si no selecciona una nueva,
          // se conserva la existente.
          imagenBytes: imagenBytes,

          nombreImagen: nombreImagen,

          horario:
              horarioController.text
                  .trim(),

          precioDesde: precio,
        );
      }

      // ========================================================
      // CREAR
      // ========================================================

      else {
        await ServicioAdminSitio
            .crearSitio(
          // ----------------------------------------------------
          // CUENTA
          // ----------------------------------------------------

          nombreCuenta:
              nombreCuentaController
                  .text
                  .trim(),

          apellidoCuenta:
              apellidoCuentaController
                  .text
                  .trim(),

          correo:
              correoController.text
                  .trim(),

          password:
              passwordController.text
                  .trim(),

          telefonoCuenta:
              telefonoCuentaController
                  .text
                  .trim(),

          // ----------------------------------------------------
          // SITIO
          // ----------------------------------------------------

          nombre:
              nombreController.text
                  .trim(),

          descripcion:
              descripcionController
                  .text
                  .trim(),

          categoria:
              categoriaSeleccionada!,

          direccion:
              direccionController.text
                  .trim(),

          ciudad:
              ciudadController.text
                  .trim(),

          departamento:
              departamentoController
                  .text
                  .trim(),

          latitud: latitud,

          longitud: longitud,

          etiquetas: etiquetas,

          activo: activo,

          telefono:
              telefonoController.text
                  .trim(),

          correos:
              correosController.text
                  .trim(),

          sitioWeb:
              sitioWebController.text
                  .trim(),

          // ----------------------------------------------------
          // IMAGEN PRINCIPAL OBLIGATORIA
          // ----------------------------------------------------

          imagenBytes: imagenBytes!,

          nombreImagen: nombreImagen,

          // ----------------------------------------------------
          // INFORMACIÓN TURÍSTICA
          // ----------------------------------------------------

          horario:
              horarioController.text
                  .trim(),

          precioDesde: precio,
        );
      }
    } finally {
      guardando = false;

      notifyListeners();
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    // ----------------------------------------------------------
    // CUENTA
    // ----------------------------------------------------------

    nombreCuentaController.dispose();

    apellidoCuentaController.dispose();

    correoController.dispose();

    passwordController.dispose();

    telefonoCuentaController.dispose();

    // ----------------------------------------------------------
    // SITIO
    // ----------------------------------------------------------

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