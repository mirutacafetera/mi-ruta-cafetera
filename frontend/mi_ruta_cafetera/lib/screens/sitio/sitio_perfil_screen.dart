import 'package:flutter/material.dart';

import '../../models/sitio/sitio_informacion_model.dart';
import '../../services/sitio/sitio_informacion_service.dart';
import '../../services/sitio/sitio_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/sitio/campo_formulario_sitio.dart';
import '../../widgets/sitio/encabezado_perfil_sitio.dart';
import '../../widgets/sitio/seccion_formulario_sitio.dart';

class SitioPerfilScreen extends StatefulWidget {
  const SitioPerfilScreen({
    super.key,
  });

  @override
  State<SitioPerfilScreen> createState() =>
      _SitioPerfilScreenState();
}

class _SitioPerfilScreenState extends State<SitioPerfilScreen> {
  final SitioInformacionService _informacionService =
      SitioInformacionService();

  final SitioSesionService _sesionService =
      SitioSesionService();

  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _departamentoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _sitioWebController = TextEditingController();
  final _horarioController = TextEditingController();
  final _precioController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();

  SitioInformacionModel? _sitio;

  bool _cargando = true;
  bool _guardando = false;
  bool _editando = false;

  String? _error;
  String _token = '';

  @override
  void initState() {
    super.initState();
    _cargarInformacion();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _departamentoController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _sitioWebController.dispose();
    _horarioController.dispose();
    _precioController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    super.dispose();
  }

  Future<void> _cargarInformacion() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception(
          'No hay una sesión de sitio disponible.',
        );
      }

      _token = sesion.token;

      final sitio =
          await _informacionService.obtenerInformacion(_token);

      if (!mounted) return;

      _sitio = sitio;
      _cargarCampos(sitio);

      setState(() {
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = error.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  void _cargarCampos(SitioInformacionModel sitio) {
    _nombreController.text = sitio.nombre;
    _descripcionController.text = sitio.descripcion;
    _direccionController.text = sitio.direccion;
    _ciudadController.text = sitio.ciudad;
    _departamentoController.text = sitio.departamento;
    _telefonoController.text = sitio.telefono;
    _correoController.text = sitio.correos.join(', ');
    _sitioWebController.text = sitio.sitioWeb;
    _horarioController.text = sitio.horario;
    _precioController.text =
        sitio.precioDesde == 0 ? '' : sitio.precioDesde.toString();
    _latitudController.text = sitio.latitud.toString();
    _longitudController.text = sitio.longitud.toString();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_sitio == null || _token.isEmpty) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final correos = _correoController.text
          .split(',')
          .map((correo) => correo.trim())
          .where((correo) => correo.isNotEmpty)
          .toList();

      final sitioActualizado = SitioInformacionModel(
        id: _sitio!.id,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        direccion: _direccionController.text.trim(),
        ciudad: _ciudadController.text.trim(),
        departamento: _departamentoController.text.trim(),
        latitud: double.tryParse(
              _latitudController.text.trim(),
            ) ??
            _sitio!.latitud,
        longitud: double.tryParse(
              _longitudController.text.trim(),
            ) ??
            _sitio!.longitud,
        categoria: _sitio!.categoria,
        etiquetas: _sitio!.etiquetas,
        activo: _sitio!.activo,
        telefono: _telefonoController.text.trim(),
        correos: correos,
        sitioWeb: _sitioWebController.text.trim(),
        imagen: _sitio!.imagen,
        imagenes: _sitio!.imagenes,
        horario: _horarioController.text.trim(),
        precioDesde: double.tryParse(
              _precioController.text.trim(),
            ) ??
            0,
      );

      final resultado =
          await _informacionService.actualizarInformacion(
        token: _token,
        sitio: sitioActualizado,
      );

      if (!mounted) return;

      setState(() {
        _sitio = resultado;
        _cargarCampos(resultado);
        _editando = false;
        _guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.sitioSuccess,
          behavior: SnackBarBehavior.floating,
          content: const Text(
            'Información actualizada correctamente.',
          ),
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
          content: Text(
            error.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  void _cancelarEdicion() {
    if (_sitio == null) return;

    _cargarCampos(_sitio!);

    setState(() {
      _editando = false;
    });
  }

  Widget _construirContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.sitioPrimary,
        ),
      );
    }

    if (_error != null) {
      return _estadoError();
    }

    if (_sitio == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(
            AppDimensions.sitioPagePadding,
          ),
          child: Text(
            'No se encontró información del sitio.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.sitioTextSecondary,
            ),
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
                constraints: const BoxConstraints(
                  maxWidth: 1100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EncabezadoPerfilSitio(
                      editando: _editando,
                      onEditar: () {
                        setState(() {
                          _editando = true;
                        });
                      },
                    ),
                    const SizedBox(
                      height: AppDimensions.sitioSectionGap,
                    ),
                    _seccionDatosPrincipales(),
                    const SizedBox(
                      height: AppDimensions.sitioSectionGap,
                    ),
                    _seccionContacto(),
                    const SizedBox(
                      height: AppDimensions.sitioSectionGap,
                    ),
                    _seccionUbicacion(),
                    if (_editando) ...[
                      const SizedBox(
                        height: AppDimensions.sitioSectionGap,
                      ),
                      _botonesEdicion(),
                    ],
                    const SizedBox(
                      height: AppDimensions.sitioSectionGap,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _seccionDatosPrincipales() {
    return SeccionFormularioSitio(
      titulo: 'Datos principales',
      subtitulo:
          'Información que identifica y presenta tu sitio turístico.',
      icono: Icons.storefront_rounded,
      campos: [
        CampoFormularioSitio(
          controller: _nombreController,
          label: 'Nombre del sitio',
          icono: Icons.storefront_rounded,
          obligatorio: true,
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _descripcionController,
          label: 'Descripción',
          icono: Icons.description_outlined,
          maxLines: 4,
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _direccionController,
          label: 'Dirección',
          icono: Icons.location_on_outlined,
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _ciudadController,
          label: 'Ciudad',
          icono: Icons.location_city_outlined,
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _departamentoController,
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
          controller: _telefonoController,
          label: 'Teléfono',
          icono: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _correoController,
          label: 'Correos',
          icono: Icons.email_outlined,
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _sitioWebController,
          label: 'Sitio web',
          icono: Icons.language_rounded,
          keyboardType: TextInputType.url,
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _horarioController,
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
          controller: _latitudController,
          label: 'Latitud',
          icono: Icons.my_location_rounded,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _longitudController,
          label: 'Longitud',
          icono: Icons.location_searching_rounded,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          habilitado: _editando && !_guardando,
        ),
        CampoFormularioSitio(
          controller: _precioController,
          label: 'Precio desde',
          icono: Icons.attach_money_rounded,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
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
              side: const BorderSide(
                color: AppColors.sitioPrimary,
              ),
              minimumSize: const Size(
                0,
                AppDimensions.sitioButtonHeight,
              ),
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
            label: Text(
              _guardando ? 'Guardando...' : 'Guardar cambios',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sitioPrimary,
              foregroundColor: AppColors.sitioTextOnPrimary,
              minimumSize: const Size(
                0,
                AppDimensions.sitioButtonHeight,
              ),
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
        padding: const EdgeInsets.all(
          AppDimensions.sitioPagePadding,
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 480,
          ),
          padding: const EdgeInsets.all(
            AppDimensions.sitioPanelCardPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.sitioSurface,
            borderRadius: BorderRadius.circular(
              AppDimensions.sitioPanelCardRadius,
            ),
            border: Border.all(
              color: AppColors.sitioBorder,
            ),
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
              const SizedBox(
                height: AppDimensions.spacingMd,
              ),
              const Text(
                'No pudimos cargar tu sitio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.sitioTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingSm,
              ),
              Text(
                _error ?? 'Ocurrió un error inesperado.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.sitioTextSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingLg,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _cargarInformacion,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sitioPrimary,
                    foregroundColor: AppColors.sitioTextOnPrimary,
                    minimumSize: const Size(
                      0,
                      AppDimensions.sitioButtonHeight,
                    ),
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