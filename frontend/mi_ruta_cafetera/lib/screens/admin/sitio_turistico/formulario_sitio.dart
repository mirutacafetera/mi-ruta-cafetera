import 'package:flutter/material.dart';

import '../../../controllers/admin/sitio/formulario_admin_sitio.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/sitio_turistico/sitio_formulario/boton_cancelar_sitio.dart';
import '../../../widgets/admin/sitio_turistico/sitio_formulario/boton_guardar_sitio.dart';
import '../../../widgets/admin/sitio_turistico/sitio_formulario/contacto_sitio.dart';
import '../../../widgets/admin/sitio_turistico/sitio_formulario/encabezado_formulario_sitio.dart';
import '../../../widgets/admin/sitio_turistico/sitio_formulario/sitio_datos_acceso.dart';
import '../../../widgets/admin/sitio_turistico/sitio_formulario/sitio_imagen.dart';
import '../../../widgets/admin/sitio_turistico/sitio_formulario/sitio_informacion.dart';
import '../../../widgets/admin/sitio_turistico/sitio_formulario/sitio_informacion_turistica.dart';
import '../../../widgets/admin/sitio_turistico/sitio_formulario/sitio_ubicacion.dart';

class FormularioSitio extends StatefulWidget {
  final Map<String, dynamic>? sitio;
  final List<Map<String, dynamic>> categorias;

  const FormularioSitio({
    super.key,
    this.sitio,
    this.categorias = const [],
  });

  bool get esEdicion => sitio != null;

  @override
  State<FormularioSitio> createState() => _FormularioSitioState();
}

class _FormularioSitioState extends State<FormularioSitio> {
  late final FormularioAdminSitio controlador;

  final _formKey = GlobalKey<FormState>();

  final _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();

    controlador = FormularioAdminSitio(
      sitio: widget.sitio,
      categorias: widget.categorias,
    );

    controlador.addListener(_actualizar);
  }

  void _actualizar() {
    if (mounted) {
      setState(() {});
    }
  }

  void _mostrarError(String mensaje) {
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(
            AppDimensions.spacingMd,
          ),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    try {
      await controlador.guardar();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      String mensaje = e.toString();

      if (mensaje.startsWith('Exception: ')) {
        mensaje = mensaje.substring(
          'Exception: '.length,
        );
      }

      _mostrarError(mensaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    final edicion = widget.esEdicion;

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * .94,
            decoration: BoxDecoration(
              color: AppColors.natureDark,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                  AppDimensions.radiusXxl,
                ),
              ),
            ),
            child: Column(
              children: [
                EncabezadoFormularioSitio(
                  edicion: edicion,
                  guardando: controlador.guardando,
                  onCerrar: () => Navigator.pop(context),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingLg,
                      vertical: AppDimensions.spacingLg,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // DATOS DE ACCESO
                          SitioDatosAcceso(
                            esEdicion: edicion,
                            controladorNombre:
                                controlador.nombreCuentaController,
                            controladorApellido:
                                controlador.apellidoCuentaController,
                            controladorCorreo:
                                controlador.correoController,
                            controladorContrasena:
                                controlador.passwordController,
                            controladorTelefono:
                                controlador.telefonoCuentaController,
                          ),

                          // INFORMACIÓN DEL SITIO
                          SitioInformacion(
                            nombreController:
                                controlador.nombreController,
                            descripcionController:
                                controlador.descripcionController,
                            etiquetasController:
                                controlador.etiquetasController,
                            categorias: widget.categorias,
                            categoriaSeleccionada:
                                controlador.categoriaSeleccionada,
                            onCategoriaChanged:
                                controlador.cambiarCategoria,
                            iconoCategoria:
                                controlador.obtenerIconoCategoria(),
                          ),

                          // UBICACIÓN
                          SitioUbicacion(
                            direccionController:
                                controlador.direccionController,
                            ciudadController:
                                controlador.ciudadController,
                            departamentoController:
                                controlador.departamentoController,
                            latitudController:
                                controlador.latitudController,
                            longitudController:
                                controlador.longitudController,
                          ),

                          // CONTACTO
                          ContactoSitio(
                            controladorTelefono:
                                controlador.telefonoController,
                            controladorCorreos:
                                controlador.correosController,
                            controladorSitioWeb:
                                controlador.sitioWebController,
                          ),

                          // INFORMACIÓN TURÍSTICA
                          SitioInformacionTuristica(
                            horarioController:
                                controlador.horarioController,
                            precioController:
                                controlador.precioDesdeController,
                            activo: controlador.activo,
                            onActivoChanged:
                                controlador.cambiarActivo,
                          ),

                          // IMAGEN
                          SitioImagen(
                            imagenBytes:
                                controlador.imagenBytes,
                            imagenesExistentes:
                                controlador.imagenesExistentes,
                            onSeleccionarImagen:
                                controlador.seleccionarImagen,
                          ),

                          const SizedBox(
                            height: AppDimensions.spacingXl,
                          ),

                          // GUARDAR
                          BotonGuardarSitio(
                            guardando: controlador.guardando,
                            edicion: edicion,
                            onPressed: _guardar,
                          ),

                          const SizedBox(
                            height: AppDimensions.spacingSm,
                          ),

                          // CANCELAR
                          BotonCancelarSitio(
                            deshabilitado:
                                controlador.guardando,
                            onPressed: () =>
                                Navigator.pop(context),
                          ),

                          const SizedBox(
                            height: AppDimensions.spacingLg,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controlador.removeListener(_actualizar);
    controlador.dispose();

    super.dispose();
  }
}