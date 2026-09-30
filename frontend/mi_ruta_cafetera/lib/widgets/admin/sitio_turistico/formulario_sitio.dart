import 'package:flutter/material.dart';

import '../../../controllers/admin/sitio/controlador_formulario_sitio.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

import 'sitio_formulario/contacto_sitio.dart';
import 'sitio_formulario/sitio_datos_acceso.dart';
import 'sitio_formulario/sitio_imagen.dart';
import 'sitio_formulario/sitio_informacion.dart';
import 'sitio_formulario/sitio_informacion_turistica.dart';
import 'sitio_formulario/sitio_ubicacion.dart';

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
  late final ControladorFormularioSitio controlador;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    controlador = ControladorFormularioSitio(
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

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await controlador.guardar();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.esEdicion
                ? 'Sitio actualizado correctamente.'
                : 'Sitio y cuenta creados correctamente.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.esEdicion;

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * .94,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              AppDimensions.radiusXxl,
            ),
          ),
        ),
        child: Column(
          children: [
            _encabezado(esEdicion),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(
                  AppDimensions.spacingLg,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SitioDatosAcceso(
                        esEdicion: esEdicion,
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

                      SitioInformacion(
                        nombreController:
                            controlador.nombreController,
                        descripcionController:
                            controlador.descripcionController,
                        etiquetasController:
                            controlador.etiquetasController,
                        categorias:
                            widget.categorias,
                        categoriaSeleccionada:
                            controlador.categoriaSeleccionada,
                        onCategoriaChanged:
                            controlador.cambiarCategoria,
                      ),

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

                      ContactoSitio(
                        controladorTelefono:
                            controlador.telefonoController,
                        controladorCorreos:
                            controlador.correosController,
                        controladorSitioWeb:
                            controlador.sitioWebController,
                      ),

                      SitioInformacionTuristica(
                        horarioController:
                            controlador.horarioController,
                        precioController:
                            controlador.precioDesdeController,
                        activo: controlador.activo,
                        onActivoChanged:
                            controlador.cambiarActivo,
                      ),

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

                      SizedBox(
                        width: double.infinity,
                        height:
                            AppDimensions.buttonHeightLarge,
                        child: ElevatedButton.icon(
                          onPressed: controlador.guardando
                              ? null
                              : _guardar,
                          icon: controlador.guardando
                              ? const SizedBox(
                                  width:
                                      AppDimensions.iconMd,
                                  height:
                                      AppDimensions.iconMd,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.save_rounded,
                                ),
                          label: Text(
                            controlador.guardando
                                ? 'Guardando...'
                                : esEdicion
                                    ? 'Guardar cambios'
                                    : 'Crear sitio turístico',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primary,
                            foregroundColor:
                                AppColors.white,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: AppDimensions.spacingSm,
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: OutlinedButton(
                          onPressed: controlador.guardando
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
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingXl,
        AppDimensions.spacingLg +
            AppDimensions.spacingXs / 2,
        AppDimensions.spacingSm +
            AppDimensions.spacingXs / 2,
        AppDimensions.spacingLg +
            AppDimensions.spacingXs / 2,
      ),
      color: AppColors.primary,
      child: Row(
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: AppColors.white,
            size: 30,
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
                  esEdicion
                      ? 'Editar sitio turístico'
                      : 'Nuevo sitio turístico',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  esEdicion
                      ? 'Actualiza la información del sitio'
                      : 'Registra un nuevo lugar turístico',
                  style: TextStyle(
                    color: AppColors.white.withValues(
                      alpha: 0.75,
                    ),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controlador.guardando
                ? null
                : () => Navigator.pop(context),
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.white,
            ),
          ),
        ],
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