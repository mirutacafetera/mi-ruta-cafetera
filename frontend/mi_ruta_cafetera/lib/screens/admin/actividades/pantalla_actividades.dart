
import 'package:flutter/material.dart';

import '../../../controllers/admin/actividades/actividad_admin_controller.dart';
import '../../../models/admin/admin_actividad_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/actividades/tarjeta_actividad_admin.dart';
import '../../../widgets/admin/actividades/detalle_actividad_admin.dart';
import '../../../widgets/admin/contenido/filtros_contenido.dart';
import '../../../widgets/admin/contenido/galeria_imagenes.dart';
import '../../../widgets/admin/producto/resumen_productos.dart';
import '../../../widgets/admin/sitio_turistico/barra_busqueda.dart';

class PantallaActividades extends StatefulWidget {
  const PantallaActividades({super.key});

  @override
  State<PantallaActividades> createState() =>
      _PantallaActividadesState();
}

class _PantallaActividadesState extends State<PantallaActividades> {
  late final ActividadAdminController _controlador;

  String _estado = 'todas';
  String? _actividadEliminandoId;
  ActividadAdminModel? _actividadSeleccionada;
  bool _actualizandoDetalle = false;

  @override
  void initState() {
    super.initState();
    _controlador = ActividadAdminController();
    _controlador.cargarActividades();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    await _controlador.cargarActividades();
  }

  Future<void> _actualizarDetalle() async {
    if (_actualizandoDetalle || _controlador.procesando) return;

    setState(() => _actualizandoDetalle = true);

    try {
      await _controlador.cargarActividades();
    } catch (_) {
      if (mounted) {
        _mostrarMensaje(
          'No fue posible actualizar las actividades.',
          error: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _actualizandoDetalle = false);
      }
    }

    if (mounted && _controlador.error != null) {
      _mostrarMensaje(
        'No se pudieron actualizar las actividades.',
        error: true,
      );
    }
  }

  // Muestra un único mensaje personalizado.
  // Los éxitos aparecen en verde y los errores en el color de error.
  void _mostrarMensaje(
    String mensaje, {
    bool error = false,
  }) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: error
              ? AppColors.error
              : const Color(0xFF27864D),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _aprobar(ActividadAdminModel actividad) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aprobar actividad'),
        content: Text('¿Deseas aprobar "${actividad.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Aprobar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final resultado =
        await _controlador.aprobarActividad(actividad.id);

    if (!mounted) return;

    if (resultado == null) {
      setState(() => _actividadSeleccionada = null);
      _mostrarMensaje('Actividad aprobada correctamente.');
    } else {
      _mostrarMensaje(resultado, error: true);
    }
  }

  Future<void> _rechazar(
    ActividadAdminModel actividad, [
    String? motivoRecibido,
  ]) async {
    String? motivo = motivoRecibido;

    if (motivo == null) {
      final campo = TextEditingController();

      try {
        motivo = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Rechazar actividad'),
            content: TextField(
              controller: campo,
              autofocus: true,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Motivo del rechazo',
                hintText: 'Explica qué debe corregirse...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                onPressed: () {
                  final texto = campo.text.trim();

                  if (texto.length < 3) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Escribe un motivo de al menos 3 caracteres.',
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(ctx, texto);
                },
                child: const Text('Rechazar'),
              ),
            ],
          ),
        );
      } finally {
        campo.dispose();
      }
    }

    if (motivo == null || !mounted) return;

    if (motivo.trim().length < 3) {
      _mostrarMensaje(
        'Escribe un motivo de al menos 3 caracteres.',
        error: true,
      );
      return;
    }

    final resultado = await _controlador.rechazarActividad(
      actividad.id,
      motivo.trim(),
    );

    if (!mounted) return;

    if (resultado == null) {
      setState(() => _actividadSeleccionada = null);
      _mostrarMensaje('Actividad rechazada correctamente.');
    } else {
      _mostrarMensaje(resultado, error: true);
    }
  }

  // Oculta la actividad del panel administrativo.
  // La eliminación lógica del backend debe conservar el registro
  // y permitir que siga visible en el panel del sitio propietario.
  Future<void> _eliminar(ActividadAdminModel actividad) async {
    if (_controlador.procesando) return;

    setState(() => _actividadEliminandoId = actividad.id);

    try {
      final resultado =
          await _controlador.eliminarActividad(actividad.id);

      if (!mounted) return;

      final mensaje = resultado?.toLowerCase().trim() ?? '';

      // Reconocer los mensajes de éxito que puede devolver el backend.
      final esExito = resultado == null ||
          mensaje.contains('ocultada del panel administrativo') ||
          mensaje.contains('ya estaba oculta') ||
          mensaje.contains('eliminada correctamente');

      if (esExito) {
        setState(() {
          _actividadSeleccionada = null;
        });

        // Mostrar solamente el mensaje diseñado en Flutter.
        _mostrarMensaje(
          'Actividad eliminada correctamente.',
          error: false,
        );
      } else {
        _mostrarMensaje(resultado, error: true);
      }
    } catch (_) {
      if (!mounted) return;

      _mostrarMensaje(
        'No fue posible ocultar la actividad del panel administrativo.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => _actividadEliminandoId = null);
      }
    }
  }

  ActividadAdminModel? _obtenerActividad(String id) {
    for (final actividad in _controlador.actividades) {
      if (actividad.id == id) return actividad;
    }

    return null;
  }

  void _mostrarGaleria(List<String> imagenes, int inicial) {
    GaleriaImagenes.mostrar(context, imagenes, inicial);
  }

  int _contarEstado(String estado) => _controlador.actividades
      .where((a) => a.estadoPublicacion == estado)
      .length;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controlador,
      builder: (context, _) {
        final actividades = _controlador.actividadesFiltradas
            .where(
              (a) =>
                  _estado == 'todas' ||
                  a.estadoPublicacion == _estado,
            )
            .toList();

        if (_actividadSeleccionada != null) {
          final actual =
              _obtenerActividad(_actividadSeleccionada!.id);

          if (actual != null) {
            return DetalleActividadAdmin(
              actividad: actual,
              onVolver: () => setState(() {
                _actividadSeleccionada = null;
                _actualizandoDetalle = false;
              }),
              onAprobar: () => _aprobar(actual),
              onRechazar: (motivo) => _rechazar(actual, motivo),
              onActualizar: _actualizarDetalle,
              onEliminar: () => _eliminar(actual),
              procesando:
                  _controlador.procesando || _actualizandoDetalle,
              onMostrarGaleria: _mostrarGaleria,
            );
          } else {
            _actividadSeleccionada = null;
          }
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _cargar,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_controlador.actividades.length} '
                              'Actividades registradas',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Actualizar',
                            onPressed: _controlador.cargando
                                ? null
                                : _cargar,
                            icon: const Icon(Icons.refresh_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ResumenProductos(
                      tarjetas: [
                        ResumenTarjetaConfig(
                          titulo: 'Pendientes',
                          cantidad:
                              _contarEstado('pendiente_revision'),
                          icono: Icons.pending_actions_rounded,
                          color: AppColors.secondary,
                          estado: 'pendiente_revision',
                        ),
                        ResumenTarjetaConfig(
                          titulo: 'Aprobados',
                          cantidad: _contarEstado('aprobado'),
                          icono: Icons.check_circle_rounded,
                          color: AppColors.success,
                          estado: 'aprobado',
                        ),
                        ResumenTarjetaConfig(
                          titulo: 'Rechazados',
                          cantidad: _contarEstado('rechazado'),
                          icono: Icons.cancel_rounded,
                          color: AppColors.error,
                          estado: 'rechazado',
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: BarraBusqueda(
                        valor: _controlador.busqueda,
                        textoAyuda:
                            'Buscar actividad o sitio turístico...',
                        onChanged: _controlador.buscar,
                        onLimpiar: () => _controlador.buscar(''),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: FiltrosContenido(
                      seleccionado: _estado,
                      onSeleccionar: (estado) {
                        setState(() => _estado = estado);
                      },
                    ),
                  ),
                  if (_controlador.cargando)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(
                          AppDimensions.spacingLg,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 4,
                          ),
                        ),
                      ),
                    )
                  else if (_controlador.error != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _estadoVacio(
                        'No se pudieron cargar las actividades.',
                        _controlador.error!,
                        _cargar,
                        error: true,
                      ),
                    )
                  else if (actividades.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _estadoVacio(
                        'No hay actividades registradas',
                        '',
                        _cargar,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final actividad = actividades[index];

                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 14),
                              child: TarjetaActividadAdmin(
                                actividad: actividad,
                                procesando:
                                    _actividadEliminandoId ==
                                        actividad.id,
                                seleccionado: false,
                                onVerDetalles: () {
                                  setState(() {
                                    _actividadSeleccionada = actividad;
                                  });
                                },
                                onAprobar: () => _aprobar(actividad),
                                onRechazar: () => _rechazar(actividad),
                                onEliminar: () => _eliminar(actividad),
                              ),
                            );
                          },
                          childCount: actividades.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _estadoVacio(
    String titulo,
    String descripcion,
    VoidCallback accion, {
    bool error = false,
  }) {
    final colores = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              error
                  ? Icons.cloud_off_rounded
                  : Icons.event_available_rounded,
              size: 54,
              color: error ? colores.error : AppColors.primary,
            ),
            const SizedBox(height: 14),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (descripcion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                descripcion,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: colores.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: accion,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
