import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/sitio/sitio_informacion_model.dart';
import '../../services/sitio/sitio_informacion_service.dart';
import '../../services/sitio/sitio_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/sitio/campo_formulario_sitio.dart';
import '../../widgets/sitio/encabezado_perfil_sitio.dart';
import '../../widgets/sitio/seccion_formulario_sitio.dart';
import 'sitio_perfil/gestion_perfil_helper.dart';

class SitioPerfilScreen extends StatefulWidget {
  const SitioPerfilScreen({super.key});

  @override
  State<SitioPerfilScreen> createState() => _SitioPerfilScreenState();
}

class _SitioPerfilScreenState extends State<SitioPerfilScreen> {
  final SitioInformacionService _informacionService = SitioInformacionService();
  final SitioSesionService _sesionService = SitioSesionService();

  late final GestionPerfilHelper _helper = GestionPerfilHelper(
    informacionService: _informacionService,
    sesionService: _sesionService,
  );

  final _formKey = GlobalKey<FormState>();

  SitioInformacionModel? _sitio;
  bool _cargando = true;
  bool _guardando = false;
  bool _editando = false;
  String? _error;
  String _token = '';

  // Controladores y estados para la imagen principal
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _imagenSeleccionada;
  Uint8List? _vistaPreviaImagen;
  bool _subiendoImagen = false;
  bool _eliminandoImagen = false;

  @override
  void initState() {
    super.initState();
    _cargarInformacion();
  }

  @override
  void dispose() {
    _helper.dispose();
    super.dispose();
  }

  Future<void> _cargarInformacion() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      _token = await _helper.obtenerToken();
      final sitio = await _helper.cargarInformacion(_token);

      if (!mounted) return;

      _sitio = sitio;
      _helper.cargarCampos(sitio);

      setState(() {
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate() ||
        _sitio == null ||
        _token.isEmpty) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final sitioActualizado = _helper.construirSitioActualizado(_sitio!);
      final resultado = await _helper.actualizarInformacion(
        token: _token,
        sitio: sitioActualizado,
      );

      if (!mounted) return;

      setState(() {
        _sitio = resultado;
        _helper.cargarCampos(resultado);
        _editando = false;
        _guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.sitioSuccess,
          behavior: SnackBarBehavior.floating,
          content: Text('Información actualizada correctamente.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.sitioError,
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _seleccionarImagen() async {
    if (!_editando || _guardando || _subiendoImagen) return;

    try {
      final imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imagen == null || !mounted) return;

      final bytes = await imagen.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imagenSeleccionada = imagen;
        _vistaPreviaImagen = bytes;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.sitioError,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'No fue posible seleccionar la imagen: '
            '${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  Future<void> _subirImagenPrincipal() async {
    if (_imagenSeleccionada == null || _token.isEmpty) return;

    setState(() {
      _subiendoImagen = true;
    });

    try {
      final resultado = await _informacionService.subirImagenPrincipal(
        token: _token,
        imagen: _imagenSeleccionada!,
      );

      if (!mounted) return;

      setState(() {
        _sitio = resultado;
        _imagenSeleccionada = null;
        _vistaPreviaImagen = null;
        _subiendoImagen = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.sitioSuccess,
          behavior: SnackBarBehavior.floating,
          content: Text('Imagen principal actualizada correctamente.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _subiendoImagen = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.sitioError,
          behavior: SnackBarBehavior.floating,
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _eliminarImagenPrincipal() async {
    if (_sitio == null ||
        _sitio!.imagen.isEmpty ||
        _token.isEmpty ||
        _subiendoImagen ||
        _guardando ||
        _eliminandoImagen) {
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quitar imagen principal'),
          content: const Text(
            '¿Estás seguro de que deseas quitar tu imagen personalizada? '
            'El sitio volverá a utilizar la imagen predeterminada '
            'de su categoría.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sitioError,
                foregroundColor: Colors.white,
              ),
              child: const Text('Quitar imagen'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      _eliminandoImagen = true;
    });

    try {
      final resultado =
          await _informacionService.eliminarImagenPrincipal(
        token: _token,
      );

      if (!mounted) return;

      setState(() {
        _sitio = resultado;
        _imagenSeleccionada = null;
        _vistaPreviaImagen = null;
        _eliminandoImagen = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.sitioSuccess,
          behavior: SnackBarBehavior.floating,
          content: Text('Imagen principal eliminada correctamente.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _eliminandoImagen = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.sitioError,
          behavior: SnackBarBehavior.floating,
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  void _cancelarEdicion() {
    if (_sitio == null) return;
    _helper.cargarCampos(_sitio!);
    setState(() {
      _editando = false;
      _imagenSeleccionada = null;
      _vistaPreviaImagen = null;
    });
  }

  Widget _construirContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.sitioPrimary),
      );
    }
    if (_error != null) return _estadoError();
    if (_sitio == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.sitioPagePadding),
          child: Text(
            'No se encontró información del sitio.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.sitioTextSecondary),
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final esPantallaAmplia = constraints.maxWidth >= 760;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(
              esPantallaAmplia
                  ? AppDimensions.sitioPagePadding
                  : AppDimensions.sitioPagePaddingCompact,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EncabezadoPerfilSitio(
                      editando: _editando,
                      onEditar: () => setState(() => _editando = true),
                    ),
                    const SizedBox(height: AppDimensions.sitioSectionGap),
                    _seccionImagenPrincipal(),
                    const SizedBox(height: AppDimensions.sitioSectionGap),
                    _seccionDatosPrincipales(),
                    const SizedBox(height: AppDimensions.sitioSectionGap),
                    _seccionContacto(),
                    const SizedBox(height: AppDimensions.sitioSectionGap),
                    _seccionUbicacion(),
                    if (_editando) ...[
                      const SizedBox(height: AppDimensions.sitioSectionGap),
                      _botonesEdicion(),
                    ],
                    const SizedBox(height: AppDimensions.sitioSectionGap),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _seccionImagenPrincipal() {
    final imagenActual = _sitio?.imagen ?? '';

    return SeccionFormularioSitio(
      titulo: 'Imagen principal del sitio',
      subtitulo: 'Esta imagen representará tu sitio turístico en la aplicación.',
      icono: Icons.image_rounded,
      campos: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                AppDimensions.sitioFormRadius,
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _vistaPreviaImagen != null
                    ? Image.memory(
                        _vistaPreviaImagen!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : imagenActual.isNotEmpty
                        ? Image.network(
                            imagenActual,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) {
                              return _placeholderImagenPrincipal();
                            },
                          )
                        : _placeholderImagenPrincipal(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            if (_vistaPreviaImagen != null)
              const Text(
                'Vista previa de la nueva imagen. Guarda para aplicar el cambio.',
                style: TextStyle(
                  color: AppColors.sitioTextSecondary,
                ),
              )
            else if (imagenActual.isEmpty)
              const Text(
                'Aún no tienes una imagen personalizada. '
                'En las vistas públicas se utilizará la imagen predeterminada '
                'de la categoría.',
                style: TextStyle(
                  color: AppColors.sitioTextSecondary,
                ),
              ),
            if (_editando) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              Wrap(
                spacing: AppDimensions.spacingSm,
                runSpacing: AppDimensions.spacingSm,
                children: [
                  OutlinedButton.icon(
                    onPressed: _subiendoImagen || _guardando || _eliminandoImagen
                        ? null
                        : _seleccionarImagen,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Seleccionar imagen'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.sitioPrimary,
                      side: const BorderSide(
                        color: AppColors.sitioPrimary,
                      ),
                    ),
                  ),
                  if (_imagenSeleccionada != null)
                    ElevatedButton.icon(
                      onPressed: _subiendoImagen || _guardando || _eliminandoImagen
                          ? null
                          : _subirImagenPrincipal,
                      icon: _subiendoImagen
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.sitioTextOnPrimary,
                              ),
                            )
                          : const Icon(Icons.cloud_upload_outlined),
                      label: Text(
                        _subiendoImagen ? 'Subiendo...' : 'Guardar imagen',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sitioPrimary,
                        foregroundColor: AppColors.sitioTextOnPrimary,
                      ),
                    ),
                  if (imagenActual.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: _subiendoImagen ||
                              _guardando ||
                              _eliminandoImagen
                          ? null
                          : _eliminarImagenPrincipal,
                      icon: _eliminandoImagen
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.delete_outline),
                      label: Text(
                        _eliminandoImagen ? 'Quitando...' : 'Quitar imagen',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.sitioError,
                        side: const BorderSide(
                          color: AppColors.sitioError,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _placeholderImagenPrincipal() {
    return Container(
      width: double.infinity,
      color: AppColors.sitioSurface,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 42,
            color: AppColors.sitioTextSecondary,
          ),
          SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Imagen principal',
            style: TextStyle(
              color: AppColors.sitioTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccionDatosPrincipales() {
    return SeccionFormularioSitio(
      titulo: 'Datos principales',
      subtitulo: 'Información que identifica y presenta tu sitio turístico.',
      icono: Icons.storefront_rounded,
      campos: [
        CampoFormularioSitio(
          controller: _helper.nombreController,
          label: 'Nombre del sitio',
          icono: Icons.storefront_rounded,
          obligatorio: true,
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _helper.descripcionController,
          label: 'Descripción',
          icono: Icons.description_outlined,
          maxLines: 4,
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _helper.direccionController,
          label: 'Dirección',
          icono: Icons.location_on_outlined,
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _helper.ciudadController,
          label: 'Ciudad',
          icono: Icons.location_city_outlined,
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _helper.departamentoController,
          label: 'Departamento',
          icono: Icons.map_outlined,
          habilitado: _editando && !_guardando,
        ),
      ],
    );
  }

  Widget _seccionContacto() {
    return SeccionFormularioSitio(
      titulo: 'Contacto',
      subtitulo:
          'Información para que los visitantes puedan comunicarse contigo.',
      icono: Icons.contact_phone_rounded,
      campos: [
        CampoFormularioSitio(
          controller: _helper.telefonoController,
          label: 'Teléfono',
          icono: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _helper.correoController,
          label: 'Correos',
          icono: Icons.email_outlined,
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _helper.sitioWebController,
          label: 'Sitio web',
          icono: Icons.language_rounded,
          keyboardType: TextInputType.url,
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _helper.horarioController,
          label: 'Horario',
          icono: Icons.schedule_outlined,
          maxLines: 2,
          habilitado: _editando && !_guardando,
        ),
      ],
    );
  }

  Widget _seccionUbicacion() {
    return SeccionFormularioSitio(
      titulo: 'Ubicación y precio',
      subtitulo:
          'Información relacionada con la ubicación y el valor de la experiencia.',
      icono: Icons.location_on_rounded,
      campos: [
        CampoFormularioSitio(
          controller: _helper.latitudController,
          label: 'Latitud',
          icono: Icons.my_location_rounded,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          habilitado: false,
        ),
        CampoFormularioSitio(
          controller: _helper.longitudController,
          label: 'Longitud',
          icono: Icons.location_searching_rounded,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          habilitado: false,
        ),
        CampoFormularioSitio(
          controller: _helper.precioController,
          label: 'Precio desde',
          icono: Icons.attach_money_rounded,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          habilitado: _editando && !_guardando,
        ),
      ],
    );
  }

  Widget _botonesEdicion() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final botones = [
          OutlinedButton.icon(
            onPressed: _guardando ? null : _cancelarEdicion,
            icon: const Icon(Icons.close_rounded),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.sitioPrimary,
              side: const BorderSide(color: AppColors.sitioPrimary),
              minimumSize: const Size(0, AppDimensions.sitioButtonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.sitioFormRadius,
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _guardando ? null : _guardarCambios,
            icon: _guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.sitioTextOnPrimary,
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(_guardando ? 'Guardando...' : 'Guardar cambios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sitioPrimary,
              foregroundColor: AppColors.sitioTextOnPrimary,
              minimumSize: const Size(0, AppDimensions.sitioButtonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.sitioFormRadius,
                ),
              ),
            ),
          ),
        ];

        if (constraints.maxWidth < 440) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              botones[1],
              const SizedBox(height: AppDimensions.spacingSm),
              botones[0],
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            botones[0],
            const SizedBox(width: AppDimensions.spacingMd),
            botones[1],
          ],
        );
      },
    );
  }

  Widget _estadoError() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.sitioPagePadding),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(AppDimensions.sitioPanelCardPadding),
          decoration: BoxDecoration(
            color: AppColors.sitioSurface,
            borderRadius: BorderRadius.circular(
              AppDimensions.sitioPanelCardRadius,
            ),
            border: Border.all(color: AppColors.sitioBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.sitioErrorSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 32,
                  color: AppColors.sitioError,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              const Text(
                'No pudimos cargar tu sitio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.sitioTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                _error ?? 'Ocurrió un error inesperado.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.sitioTextSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _cargarInformacion,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sitioPrimary,
                    foregroundColor: AppColors.sitioTextOnPrimary,
                    minimumSize: const Size(0, AppDimensions.sitioButtonHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.sitioFormRadius,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sitioBackground,
      body: _construirContenido(),
    );
  }
}