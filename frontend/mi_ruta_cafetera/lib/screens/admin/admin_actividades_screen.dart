import 'package:flutter/material.dart';

import '../../models/admin/admin_actividad_model.dart';
import '../../services/admin/admin_actividades_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class AdminActividadesScreen extends StatefulWidget {
  const AdminActividadesScreen({super.key});

  @override
  State<AdminActividadesScreen> createState() =>
      _AdminActividadesScreenState();
}

class _AdminActividadesScreenState
    extends State<AdminActividadesScreen> {
  List<AdminActividadModel> _actividades = [];

  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarActividades();
  }

  // ============================================================
  // CARGAR ACTIVIDADES PENDIENTES
  // ============================================================

  Future<void> _cargarActividades() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final actividades =
          await AdminActividadesService.obtenerPendientes();

      if (!mounted) return;

      setState(() {
        _actividades = actividades;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
        _cargando = false;
      });
    }
  }

  // ============================================================
  // APROBAR
  // ============================================================

  Future<void> _aprobarActividad(
    AdminActividadModel actividad,
  ) async {
    final confirmado = await _mostrarConfirmacion(
      titulo: 'Aprobar actividad',
      mensaje:
          '¿Deseas aprobar "${actividad.nombre}" para su publicación?',
      textoConfirmar: 'Aprobar',
    );

    if (!confirmado) return;

    _mostrarCargando();

    try {
      await AdminActividadesService.aprobarActividad(
        actividad.id,
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      _mostrarMensaje(
        'La actividad fue aprobada correctamente.',
      );

      await _cargarActividades();
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop();

      _mostrarError(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  // ============================================================
  // RECHAZAR
  // ============================================================

  Future<void> _rechazarActividad(
    AdminActividadModel actividad,
  ) async {
    final motivo = await _mostrarDialogoRechazo();

    if (motivo == null || motivo.trim().isEmpty) {
      return;
    }

    _mostrarCargando();

    try {
      await AdminActividadesService.rechazarActividad(
        actividadId: actividad.id,
        motivoRechazo: motivo.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      _mostrarMensaje(
        'La actividad fue rechazada correctamente.',
      );

      await _cargarActividades();
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop();

      _mostrarError(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  // ============================================================
  // DIÁLOGO DE CONFIRMACIÓN
  // ============================================================

  Future<bool> _mostrarConfirmacion({
    required String titulo,
    required String mensaje,
    required String textoConfirmar,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(textoConfirmar),
            ),
          ],
        );
      },
    );

    return resultado ?? false;
  }

  // ============================================================
  // DIÁLOGO DE RECHAZO
  // ============================================================

  Future<String?> _mostrarDialogoRechazo() async {
    final controlador = TextEditingController();

    final resultado = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rechazar actividad'),
          content: TextField(
            controller: controlador,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Motivo del rechazo',
              hintText:
                  'Explica al sitio qué debe corregir...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final motivo =
                    controlador.text.trim();

                if (motivo.length < 3) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(
                          'El motivo debe tener al menos 3 caracteres.',
                        ),
                      ),
                    );

                  return;
                }

                Navigator.of(context).pop(motivo);
              },
              child: const Text('Rechazar'),
            ),
          ],
        );
      },
    );

    controlador.dispose();

    return resultado;
  }

  // ============================================================
  // CARGANDO OPERACIÓN
  // ============================================================

  void _mostrarCargando() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  // ============================================================
  // MENSAJES
  // ============================================================

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
        ),
      );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _cargarActividades,
      child: _crearContenido(),
    );
  }

  // ============================================================
  // CONTENIDO
  // ============================================================

  Widget _crearContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _crearError();
    }

    if (_actividades.isEmpty) {
      return _crearEstadoVacio();
    }

    return _crearLista();
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _crearError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.error_outline,
          size: 64,
          color: AppColors.error,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Text(
          'No fue posible cargar las actividades',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          _error!,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        Center(
          child: FilledButton.icon(
            onPressed: _cargarActividades,
            icon: const Icon(Icons.refresh),
            label: const Text('Intentar nuevamente'),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ESTADO VACÍO
  // ============================================================

  Widget _crearEstadoVacio() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.check_circle_outline,
          size: 72,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Text(
          'No hay actividades pendientes',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          'Las actividades enviadas por los sitios turísticos '
          'aparecerán aquí para su revisión.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ============================================================
  // LISTA
  // ============================================================

  Widget _crearLista() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      children: [
        _crearEncabezado(),
        const SizedBox(height: AppDimensions.spacingLg),
        ..._actividades.map(
          (actividad) =>
              _crearTarjetaActividad(actividad),
        ),
      ],
    );
  }

  // ============================================================
  // ENCABEZADO
  // ============================================================

  Widget _crearEncabezado() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingLg,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor:
                  AppColors.primary.withValues(alpha: 0.12),
              child: Icon(
                Icons.pending_actions,
                color: AppColors.primary,
                size: 28,
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
                    'Actividades pendientes',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingXs,
                  ),
                  Text(
                    '${_actividades.length} actividad${_actividades.length == 1 ? '' : 'es'} esperando revisión.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA
  // ============================================================

  Widget _crearTarjetaActividad(
    AdminActividadModel actividad,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingLg,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.local_activity,
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
                        actividad.nombre,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingXs,
                      ),
                      Text(
                        actividad.sitioNombre.isNotEmpty
                            ? actividad.sitioNombre
                            : 'Sitio turístico',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                _crearEstado(),
              ],
            ),

            const SizedBox(
              height: AppDimensions.spacingMd,
            ),

            if (actividad.descripcion.isNotEmpty)
              Text(
                actividad.descripcion,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),

            const SizedBox(
              height: AppDimensions.spacingMd,
            ),

            _crearDatosActividad(actividad),

            if (actividad.ciudad.isNotEmpty ||
                actividad.departamento.isNotEmpty) ...[
              const SizedBox(
                height: AppDimensions.spacingSm,
              ),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(
                    width: AppDimensions.spacingXs,
                  ),
                  Expanded(
                    child: Text(
                      [
                        if (actividad.ciudad.isNotEmpty)
                          actividad.ciudad,
                        if (actividad.departamento
                            .isNotEmpty)
                          actividad.departamento,
                      ].join(', '),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(
              height: AppDimensions.spacingLg,
            ),

            const Divider(),

            const SizedBox(
              height: AppDimensions.spacingSm,
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      _rechazarActividad(actividad),
                  icon: const Icon(
                    Icons.close,
                  ),
                  label: const Text('Rechazar'),
                ),
                const SizedBox(
                  width: AppDimensions.spacingSm,
                ),
                FilledButton.icon(
                  onPressed: () =>
                      _aprobarActividad(actividad),
                  icon: const Icon(
                    Icons.check,
                  ),
                  label: const Text('Aprobar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ESTADO
  // ============================================================

  Widget _crearEstado() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusSm,
        ),
      ),
      child: Text(
        'Pendiente',
        style: TextStyle(
          color: AppColors.warning,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // DATOS
  // ============================================================

  Widget _crearDatosActividad(
    AdminActividadModel actividad,
  ) {
    return Wrap(
      spacing: AppDimensions.spacingLg,
      runSpacing: AppDimensions.spacingSm,
      children: [
        _dato(
          Icons.payments_outlined,
          'Precio',
          '\$${actividad.precio.toStringAsFixed(0)}',
        ),
        _dato(
          Icons.schedule,
          'Horario',
          actividad.horario.isNotEmpty
              ? actividad.horario
              : 'No especificado',
        ),
        _dato(
          Icons.timer_outlined,
          'Duración',
          actividad.duracion.isNotEmpty
              ? actividad.duracion
              : 'No especificada',
        ),
      ],
    );
  }

  Widget _dato(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icono,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(
          width: AppDimensions.spacingXs,
        ),
        Text(
          '$titulo: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        Flexible(
          child: Text(valor),
        ),
      ],
    );
  }
}