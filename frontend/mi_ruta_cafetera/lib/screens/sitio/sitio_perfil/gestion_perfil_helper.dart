
 // ignore_for_file: prefer_initializing_formals

import 'package:flutter/widgets.dart';

import '../../../models/sitio/sitio_informacion_model.dart';
import '../../../services/sitio/sitio_informacion_service.dart';
import '../../../services/sitio/sitio_sesion_service.dart';

class GestionPerfilHelper {
  GestionPerfilHelper({
    required SitioInformacionService informacionService,
    required SitioSesionService sesionService,
  })  : _informacionService = informacionService,
        _sesionService = sesionService;

  final SitioInformacionService _informacionService;
  final SitioSesionService _sesionService;

  // Controladores de texto para los campos del perfil.
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final direccionController = TextEditingController();
  final ciudadController = TextEditingController();
  final departamentoController = TextEditingController();
  final telefonoController = TextEditingController();
  final correoController = TextEditingController();
  final sitioWebController = TextEditingController();
  final horarioController = TextEditingController();
  final precioController = TextEditingController();
  final latitudController = TextEditingController();
  final longitudController = TextEditingController();

  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    direccionController.dispose();
    ciudadController.dispose();
    departamentoController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    sitioWebController.dispose();
    horarioController.dispose();
    precioController.dispose();
    latitudController.dispose();
    longitudController.dispose();
  }

  void cargarCampos(SitioInformacionModel sitio) {
    nombreController.text = sitio.nombre;
    descripcionController.text = sitio.descripcion;
    direccionController.text = sitio.direccion;
    ciudadController.text = sitio.ciudad;
    departamentoController.text = sitio.departamento;
    telefonoController.text = sitio.telefono;
    correoController.text = sitio.correos.join(', ');
    sitioWebController.text = sitio.sitioWeb;
    horarioController.text = sitio.horario;
    precioController.text =
        sitio.precioDesde == 0 ? '' : sitio.precioDesde.toString();
    latitudController.text = sitio.latitud.toString();
    longitudController.text = sitio.longitud.toString();
  }

  Future<String> obtenerToken() async {
    final sesion = await _sesionService.obtenerSesion();

    if (sesion == null || sesion.token.isEmpty) {
      throw Exception('No hay una sesión de sitio disponible.');
    }

    return sesion.token;
  }

  Future<SitioInformacionModel> cargarInformacion(String token) {
    return _informacionService.obtenerInformacion(token);
  }

  SitioInformacionModel construirSitioActualizado(
    SitioInformacionModel sitioActual,
  ) {
    final correos = correoController.text
        .split(',')
        .map((correo) => correo.trim())
        .where((correo) => correo.isNotEmpty)
        .toList();

    return SitioInformacionModel(
      id: sitioActual.id,
      nombre: nombreController.text.trim(),
      descripcion: descripcionController.text.trim(),
      direccion: direccionController.text.trim(),
      ciudad: ciudadController.text.trim(),
      departamento: departamentoController.text.trim(),
      latitud:
          double.tryParse(latitudController.text.trim()) ??
              sitioActual.latitud,
      longitud:
          double.tryParse(longitudController.text.trim()) ??
              sitioActual.longitud,
      categoria: sitioActual.categoria,
      etiquetas: sitioActual.etiquetas,
      activo: sitioActual.activo,
      telefono: telefonoController.text.trim(),
      correos: correos,
      sitioWeb: sitioWebController.text.trim(),
      imagen: sitioActual.imagen,
      imagenes: sitioActual.imagenes,
      horario: horarioController.text.trim(),
      precioDesde: double.tryParse(precioController.text.trim()) ?? 0,
    );
  }

  Future<SitioInformacionModel> actualizarInformacion({
    required String token,
    required SitioInformacionModel sitio,
  }) {
    return _informacionService.actualizarInformacion(
      token: token,
      sitio: sitio,
    );
  }
}
