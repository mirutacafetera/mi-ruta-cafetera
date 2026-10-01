import 'package:flutter/material.dart';

import '../../models/sitio/sitio_informacion_model.dart';
import '../../services/sitio/sitio_informacion_service.dart';
import '../../services/sitio/sitio_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class SitioContenidoScreen extends StatefulWidget {
  const SitioContenidoScreen({super.key});

  @override
  State<SitioContenidoScreen> createState() =>
      _SitioContenidoScreenState();
}

class _SitioContenidoScreenState
    extends State<SitioContenidoScreen> {
  final SitioInformacionService _informacionService =
      SitioInformacionService();

  final SitioSesionService _sesionService =
      SitioSesionService();

  SitioInformacionModel? _sitio;

  bool _cargando = true;
  bool _guardando = false;

  String? _error;
  String _token = '';

  @override
  void initState() {
    super.initState();
    _cargarContenido();
  }

  Future<void> _cargarContenido() async {
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
          await _informacionService.obtenerInformacion(
        _token,
      );

      if (!mounted) return;

      setState(() {
        _sitio = sitio;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _guardarCambios({
    required String descripcion,
    required String horario,
    required double precioDesde,
    required String telefono,
    required String correos,
  }) async {
    if (_sitio == null || _token.isEmpty) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final sitioActualizado = SitioInformacionModel(
        id: _sitio!.id,
        nombre: _sitio!.nombre,
        descripcion: descripcion,
        direccion: _sitio!.direccion,
        ciudad: _sitio!.ciudad,
        departamento: _sitio!.departamento,
        latitud: _sitio!.latitud,
        longitud: _sitio!.longitud,
        categoria: _sitio!.categoria,
        etiquetas: _sitio!.etiquetas,
        activo: _sitio!.activo,
        telefono: telefono,
        correos: correos.isEmpty
            ? []
            : correos
                .split(',')
                .map((correo) => correo.trim())
                .where(
                  (correo) => correo.isNotEmpty,
                )
                .toList(),
        sitioWeb: _sitio!.sitioWeb,
        imagen: _sitio!.imagen,
        imagenes: _sitio!.imagenes,
        horario: horario,
        precioDesde: precioDesde,
      );

      final resultado =
          await _informacionService.actualizarInformacion(
        token: _token,
        sitio: sitioActualizado,
      );

      if (!mounted) return;

      setState(() {
        _sitio = resultado;
        _guardando = false;
      });

      Navigator.of(context).pop();

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
            error
                .toString()
                .replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  void _editarDescripcion() {
    if (_sitio == null) return;

    final controller = TextEditingController(
      text: _sitio!.descripcion,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: AppDimensions.pageHorizontal,
                right: AppDimensions.pageHorizontal,
                top: AppDimensions.spacingLg,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                        AppDimensions.spacingLg,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Editar descripción',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight.w700,
                                  color:
                                      AppColors.textPrimary,
                                ),
                          ),
                        ),
                        IconButton(
                          onPressed: _guardando
                              ? null
                              : () =>
                                  Navigator.pop(context),
                          icon: const Icon(
                            Icons.close_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingLg,
                    ),

                    TextField(
                      controller: controller,
                      maxLines: 7,
                      enabled: !_guardando,
                      decoration: InputDecoration(
                        labelText: 'Descripción del sitio',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingLg,
                    ),

                    SizedBox(
                      width: double.infinity,
                      height:
                          AppDimensions.buttonHeightLarge,
                      child: ElevatedButton.icon(
                        onPressed: _guardando
                            ? null
                            : () async {
                                final descripcion =
                                    controller.text.trim();

                                if (descripcion.isEmpty) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'La descripción no puede estar vacía.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setModalState(() {});

                                await _guardarCambios(
                                  descripcion:
                                      descripcion,
                                  horario:
                                      _sitio!.horario,
                                  precioDesde:
                                      _sitio!.precioDesde,
                                  telefono:
                                      _sitio!.telefono,
                                  correos:
                                      _sitio!.correos
                                          .join(', '),
                                );
                              },
                        icon: _guardando
                            ? const SizedBox(
                                width:
                                    AppDimensions.iconMd,
                                height:
                                    AppDimensions.iconMd,
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
                              : 'Guardar descripción',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _editarInformacion() {
    if (_sitio == null) return;

    final horarioController = TextEditingController(
      text: _sitio!.horario,
    );

    final precioController = TextEditingController(
      text: _sitio!.precioDesde == 0
          ? ''
          : _sitio!.precioDesde.toString(),
    );

    final telefonoController = TextEditingController(
      text: _sitio!.telefono,
    );

    final correoController = TextEditingController(
      text: _sitio!.correos.join(', '),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: AppDimensions.pageHorizontal,
            right: AppDimensions.pageHorizontal,
            top: AppDimensions.spacingLg,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                    AppDimensions.spacingLg,
          ),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Editar información turística',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  AppColors.textPrimary,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: _guardando
                          ? null
                          : () =>
                              Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: AppDimensions.spacingLg,
                ),

                _campo(
                  controller: horarioController,
                  label: 'Horarios',
                  icono: Icons.schedule_rounded,
                  maxLines: 3,
                ),

                const SizedBox(
                  height: AppDimensions.spacingMd,
                ),

                _campo(
                  controller: precioController,
                  label: 'Precio de ingreso',
                  icono:
                      Icons.attach_money_rounded,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),

                const SizedBox(
                  height: AppDimensions.spacingMd,
                ),

                _campo(
                  controller: telefonoController,
                  label: 'Teléfono',
                  icono: Icons.phone_rounded,
                  keyboardType:
                      TextInputType.phone,
                ),

                const SizedBox(
                  height: AppDimensions.spacingMd,
                ),

                _campo(
                  controller: correoController,
                  label: 'Correo electrónico',
                  icono: Icons.email_rounded,
                  keyboardType:
                      TextInputType.emailAddress,
                ),

                const SizedBox(
                  height: AppDimensions.spacingLg,
                ),

                SizedBox(
                  width: double.infinity,
                  height:
                      AppDimensions.buttonHeightLarge,
                  child: ElevatedButton.icon(
                    onPressed: _guardando
                        ? null
                        : () async {
                            final precio =
                                double.tryParse(
                                  precioController
                                      .text
                                      .trim(),
                                ) ??
                                    0;

                            await _guardarCambios(
                              descripcion:
                                  _sitio!.descripcion,
                              horario:
                                  horarioController
                                      .text
                                      .trim(),
                              precioDesde: precio,
                              telefono:
                                  telefonoController
                                      .text
                                      .trim(),
                              correos:
                                  correoController
                                      .text
                                      .trim(),
                            );
                          },
                    icon: _guardando
                        ? const SizedBox(
                            width:
                                AppDimensions.iconMd,
                            height:
                                AppDimensions.iconMd,
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
                          : 'Guardar información',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: !_guardando,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icono,
          color: AppColors.primary,
        ),
        filled: true,
        fillColor: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMd,
          ),
        ),
      ),
    );
  }

  Widget _tarjetaResumen({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(
          AppDimensions.spacingMd,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surface,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
              ),
              child: Icon(
                icono,
                color: AppColors.primary,
              ),
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
                    titulo,
                    style: const TextStyle(
                      color:
                          AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valor,
                    style: const TextStyle(
                      color:
                          AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaInformacion({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingSm,
      ),
      child: Row(
        children: [
          Icon(
            icono,
            color: AppColors.primary,
          ),

          const SizedBox(
            width: AppDimensions.spacingMd,
          ),

          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Flexible(
            child: Text(
              valor.isEmpty ? 'No registrado' : valor,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenido() {
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
            mainAxisAlignment:
                MainAxisAlignment.center,
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
                onPressed: _cargarContenido,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
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

    final descripcionRegistrada =
        _sitio!.descripcion.trim().isNotEmpty;

    final informacionRegistrada =
        _sitio!.horario.trim().isNotEmpty ||
        _sitio!.precioDesde > 0 ||
        _sitio!.telefono.trim().isNotEmpty ||
        _sitio!.correos.isNotEmpty;

    final contacto = [
      if (_sitio!.telefono.trim().isNotEmpty)
        _sitio!.telefono.trim(),
      if (_sitio!.correos.isNotEmpty)
        _sitio!.correos.join(', '),
    ].join(' · ');

    return RefreshIndicator(
      onRefresh: _cargarContenido,
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(
          AppDimensions.pageHorizontal,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _tarjetaResumen(
                  icono: Icons.description_rounded,
                  titulo: 'Descripción',
                  valor: descripcionRegistrada
                      ? 'Registrada'
                      : 'Pendiente',
                ),

                const SizedBox(
                  width: AppDimensions.spacingMd,
                ),

                _tarjetaResumen(
                  icono: Icons.info_rounded,
                  titulo: 'Información',
                  valor: informacionRegistrada
                      ? 'Registrada'
                      : 'Pendiente',
                ),
              ],
            ),

            const SizedBox(
              height: AppDimensions.spacingLg,
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                AppDimensions.spacingLg,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface,
                borderRadius:
                    BorderRadius.circular(
                  AppDimensions.radiusLg,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color:
                              AppColors.primary.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: const Icon(
                          Icons.description_rounded,
                          color:
                              AppColors.primary,
                        ),
                      ),

                      const SizedBox(
                        width:
                            AppDimensions.spacingMd,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Descripción del sitio',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Información principal que aparecerá para los visitantes.',
                              style: TextStyle(
                                color:
                                    AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height:
                        AppDimensions.spacingLg,
                  ),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(
                      AppDimensions.spacingMd,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            color:
                                AppColors.textSecondary,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          descripcionRegistrada
                              ? _sitio!.descripcion
                              : 'Aquí aparecerá la descripción turística de tu sitio.',
                          style: const TextStyle(
                            color:
                                AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height:
                        AppDimensions.spacingMd,
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          _editarDescripcion,
                      icon: const Icon(
                        Icons.edit_rounded,
                      ),
                      label: const Text(
                        'Editar descripción',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: AppDimensions.spacingLg,
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                AppDimensions.spacingLg,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface,
                borderRadius:
                    BorderRadius.circular(
                  AppDimensions.radiusLg,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color:
                              AppColors.primary.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: const Icon(
                          Icons.travel_explore_rounded,
                          color:
                              AppColors.primary,
                        ),
                      ),

                      const SizedBox(
                        width:
                            AppDimensions.spacingMd,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información turística',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Datos adicionales que ayudan al visitante a conocer tu experiencia.',
                              style: TextStyle(
                                color:
                                    AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height:
                        AppDimensions.spacingLg,
                  ),

                  _filaInformacion(
                    icono: Icons.schedule_rounded,
                    titulo: 'Horarios',
                    valor: _sitio!.horario,
                  ),

                  const Divider(),

                  _filaInformacion(
                    icono:
                        Icons.local_atm_rounded,
                    titulo:
                        'Información de ingreso',
                    valor: _sitio!.precioDesde > 0
                        ? '\$${_sitio!.precioDesde.toStringAsFixed(0)}'
                        : '',
                  ),

                  const Divider(),

                  _filaInformacion(
                    icono: Icons.phone_rounded,
                    titulo: 'Contacto',
                    valor: contacto,
                  ),

                  const SizedBox(
                    height:
                        AppDimensions.spacingMd,
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          _editarInformacion,
                      icon: const Icon(
                        Icons.edit_rounded,
                      ),
                      label: const Text(
                        'Editar información',
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
      backgroundColor:
          Theme.of(context).colorScheme.surfaceContainerLowest,
      body: _contenido(),
    );
  }
}