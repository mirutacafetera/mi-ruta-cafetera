import 'package:flutter/material.dart';

import '../../models/sitio/sitio_informacion_model.dart';
import '../../services/sitio/sitio_informacion_service.dart';
import '../../services/sitio/sitio_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class SitioPerfilScreen extends StatefulWidget {
  const SitioPerfilScreen({super.key});

  @override
  State<SitioPerfilScreen> createState() => _SitioPerfilScreenState();
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

      final sitio = await _informacionService.obtenerInformacion(
        _token,
      );

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

    _precioController.text = sitio.precioDesde == 0
        ? ''
        : sitio.precioDesde.toString();

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
        const SnackBar(
          content: Text(
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

  InputDecoration _decoracionCampo({
    required String label,
    required IconData icono,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
        borderSide: BorderSide(
          color: AppColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    int maxLines = 1,
    bool obligatorio = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _editando && !_guardando,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _decoracionCampo(
        label: label,
        icono: icono,
      ),
      validator: obligatorio
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Este campo es obligatorio';
              }

              return null;
            }
          : null,
    );
  }

  Widget _construirContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(
            AppDimensions.pageHorizontal,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: AppDimensions.iconLg,
                color: AppColors.error,
              ),
              const SizedBox(
                height: AppDimensions.spacingMd,
              ),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: AppDimensions.spacingMd,
              ),
              ElevatedButton.icon(
                onPressed: _cargarInformacion,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_sitio == null) {
      return const Center(
        child: Text(
          'No se encontró información del sitio.',
        ),
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(
          AppDimensions.pageHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Información del sitio',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall,
                  ),
                ),
                if (!_editando)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _editando = true;
                      });
                    },
                    icon: const Icon(
                      Icons.edit_rounded,
                    ),
                    label: const Text('Editar'),
                  ),
              ],
            ),

            const SizedBox(
              height: AppDimensions.spacingLg,
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(
                  AppDimensions.spacingLg,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Datos principales',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingLg,
                    ),

                    _campoTexto(
                      controller: _nombreController,
                      label: 'Nombre del sitio',
                      icono: Icons.storefront_rounded,
                      obligatorio: true,
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),

                    _campoTexto(
                      controller: _descripcionController,
                      label: 'Descripción',
                      icono: Icons.description_outlined,
                      maxLines: 4,
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),

                    _campoTexto(
                      controller: _direccionController,
                      label: 'Dirección',
                      icono: Icons.location_on_outlined,
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),

                    _campoTexto(
                      controller: _ciudadController,
                      label: 'Ciudad',
                      icono: Icons.location_city_outlined,
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),

                    _campoTexto(
                      controller: _departamentoController,
                      label: 'Departamento',
                      icono: Icons.map_outlined,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: AppDimensions.spacingLg,
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(
                  AppDimensions.spacingLg,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contacto',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingLg,
                    ),

                    _campoTexto(
                      controller: _telefonoController,
                      label: 'Teléfono',
                      icono: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),

                    _campoTexto(
                      controller: _correoController,
                      label: 'Correos',
                      icono: Icons.email_outlined,
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),

                    _campoTexto(
                      controller: _sitioWebController,
                      label: 'Sitio web',
                      icono: Icons.language_rounded,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),

                    _campoTexto(
                      controller: _horarioController,
                      label: 'Horario',
                      icono: Icons.schedule_outlined,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: AppDimensions.spacingLg,
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(
                  AppDimensions.spacingLg,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ubicación y precio',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingLg,
                    ),

                    _campoTexto(
                      controller: _latitudController,
                      label: 'Latitud',
                      icono: Icons.my_location_rounded,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),

                    _campoTexto(
                      controller: _longitudController,
                      label: 'Longitud',
                      icono: Icons.location_searching_rounded,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),

                    _campoTexto(
                      controller: _precioController,
                      label: 'Precio desde',
                      icono: Icons.attach_money_rounded,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_editando) ...[
              const SizedBox(
                height: AppDimensions.spacingLg,
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed:
                        _guardando ? null : _cancelarEdicion,
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(
                    width: AppDimensions.spacingMd,
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        _guardando ? null : _guardarCambios,
                    icon: _guardando
                        ? const SizedBox(
                            width: AppDimensions.iconSm,
                            height: AppDimensions.iconSm,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.save_rounded,
                          ),
                    label: Text(
                      _guardando
                          ? 'Guardando...'
                          : 'Guardar cambios',
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(
              height: AppDimensions.spacingXl,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _construirContenido(),
    );
  }
}