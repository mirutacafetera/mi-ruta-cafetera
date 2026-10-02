import 'package:flutter/material.dart';

import '../../../controllers/admin/sitio/formulario_admin_sitio.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

import '../../../widgets/admin/sitio_turistico/sitio_formulario/contacto_sitio.dart';
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

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(
            AppDimensions.spacingMd,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final edicion = widget.esEdicion;

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * .94,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              AppDimensions.radiusXxl,
            ),
          ),
        ),
        child: Column(
          children: [
            _encabezado(edicion),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(
                  AppDimensions.spacingLg,
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
                      _botonGuardar(edicion),

                      const SizedBox(
                        height: AppDimensions.spacingSm,
                      ),

                      // CANCELAR
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
    );
  }

  Widget _botonGuardar(bool edicion) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeightLarge,
      child: ElevatedButton.icon(
        onPressed:
            controlador.guardando ? null : _guardar,
        icon: controlador.guardando
            ? const SizedBox(
                width: AppDimensions.iconMd,
                height: AppDimensions.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Icon(
                Icons.save_rounded,
                size: AppDimensions.iconMd,
              ),
        label: Text(
          controlador.guardando
              ? 'Guardando...'
              : edicion
                  ? 'Guardar cambios'
                  : 'Crear sitio turístico',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(
            double.infinity,
            AppDimensions.buttonHeightLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusXl,
            ),
          ),
        ),
      ),
    );
  }

  Widget _encabezado(bool edicion) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingXl,
        AppDimensions.spacingLg,
        AppDimensions.spacingSm,
        AppDimensions.spacingLg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            AppDimensions.radiusXxl,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: AppColors.white,
            size: AppDimensions.iconLg,
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
                  edicion
                      ? 'Editar sitio turístico'
                      : 'Nuevo sitio turístico',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: AppDimensions.spacingXs,
                ),

                Text(
                  edicion
                      ? 'Actualiza la información del sitio'
                      : 'Registra un nuevo lugar turístico',
                  style: TextStyle(
                    color: AppColors.white.withValues(
                      alpha: .75,
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
              size: AppDimensions.iconMd,
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