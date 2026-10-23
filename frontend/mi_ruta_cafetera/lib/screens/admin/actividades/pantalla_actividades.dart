import 'package:flutter/material.dart';

import '../../../controllers/admin/actividades/actividad_admin_controller.dart';
import '../../../models/admin/admin_actividad_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/admin/actividades/tarjeta_actividad_admin.dart';
import '../../../widgets/admin/actividades/detalle_actividad_admin.dart';
import '../../../widgets/admin/contenido/filtros_contenido.dart';
import '../../../widgets/admin/contenido/galeria_imagenes.dart';
import '../../../widgets/admin/producto/resumen_productos.dart';
import '../../../widgets/admin/sitio_turistico/barra_busqueda.dart';

class PantallaActividades extends StatefulWidget {
  const PantallaActividades({super.key});

  @override
  State<PantallaActividades> createState() => _PantallaActividadesState();
}

class _PantallaActividadesState extends State<PantallaActividades> {
  late final ActividadAdminController _controlador;
  String _estado = 'pendiente_revision';
  ActividadAdminModel? _actividadSeleccionada;

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

  void _mostrarMensaje(String mensaje, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: error ? AppColors.error : AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _aprobar(ActividadAdminModel actividad) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Aprobar actividad'),
        content: Text('¿Deseas aprobar "${actividad.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Aprobar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final resultado = await _controlador.aprobarActividad(actividad.id);
    if (!mounted) return;

    if (resultado == null) {
      setState(() => _actividadSeleccionada = null);
      _mostrarMensaje('Actividad aprobada correctamente.');
    } else {
      _mostrarMensaje(resultado, error: true);
    }
  }

  Future<void> _rechazar(ActividadAdminModel actividad) async {
    final controladorMotivo = TextEditingController();

    try {
      final motivo = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Rechazar actividad'),
          content: TextField(
            controller: controladorMotivo,
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () {
                final texto = controladorMotivo.text.trim();

                if (texto.length < 3) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Escribe un motivo de al menos 3 caracteres.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, texto);
              },
              child: const Text('Rechazar'),
            ),
          ],
        ),
      );

      if (motivo == null || !mounted) return;

      final resultado = await _controlador.rechazarActividad(
        actividad.id,
        motivo,
      );

      if (!mounted) return;

      if (resultado == null) {
        setState(() => _actividadSeleccionada = null);
        _mostrarMensaje('Actividad rechazada correctamente.');
      } else {
        _mostrarMensaje(resultado, error: true);
      }
    } finally {
      controladorMotivo.dispose();
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

  int _contarEstado(String estado) {
    return _controlador.actividades
        .where((actividad) => actividad.estadoPublicacion == estado)
        .length;
  }

  String _textoEstado() {
    switch (_estado) {
      case 'todas':
        return 'registradas';
      case 'aprobado':
        return 'aprobadas';
      case 'rechazado':
        return 'rechazadas';
      default:
        return 'pendientes';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controlador,
      builder: (context, _) {
        final actividades = _controlador.actividadesFiltradas
            .where(
              (actividad) =>
                  _estado == 'todas' ||
                  actividad.estadoPublicacion == _estado,
            )
            .toList();

        if (_actividadSeleccionada != null) {
          final actual = _obtenerActividad(_actividadSeleccionada!.id);

          if (actual != null) {
            return DetalleActividadAdmin(
              actividad: actual,
              onVolver: () {
                setState(() => _actividadSeleccionada = null);
              },
              onAprobar: () => _aprobar(actual),
              onRechazar: () => _rechazar(actual),
              onActualizar: _cargar,
              procesando: _controlador.procesando,
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Actualizar',
                            onPressed: _controlador.cargando ? null : _cargar,
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
                          cantidad: _contarEstado('pendiente_revision'),
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
                  SliverToBoxAdapter(
                    child: FiltrosContenido(
                      seleccionado: _estado,
                      onSeleccionar: (nuevoEstado) {
                        setState(() => _estado = nuevoEstado);
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    sliver: SliverToBoxAdapter(
                      child: BarraBusqueda(
                        valor: _controlador.busqueda,
                        textoAyuda: 'Buscar actividad o sitio turístico...',
                        onChanged: _controlador.buscar,
                        onLimpiar: () => _controlador.buscar(''),
                      ),
                    ),
                  ),
                  if (_controlador.cargando &&
                      _controlador.actividades.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_controlador.error != null &&
                      _controlador.actividades.isEmpty)
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
                        _controlador.busqueda.isNotEmpty
                            ? 'No se encontraron actividades'
                            : 'No hay actividades ${_textoEstado()}.',
                        _controlador.busqueda.isNotEmpty
                            ? 'Prueba con otro nombre o sitio turístico.'
                            : 'No hay registros para mostrar en este estado.',
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
                              padding: const EdgeInsets.only(bottom: 14),
                              child: TarjetaActividadAdmin(
                                actividad: actividad,
                                procesando: _controlador.procesando,
                                seleccionado: false,
                                onVerDetalles: () {
                                  setState(() {
                                    _actividadSeleccionada = actividad;
                                  });
                                },
                                onAprobar: () => _aprobar(actividad),
                                onRechazar: () => _rechazar(actividad),
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
              color: error ? colores.error : colores.primary,
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
            const SizedBox(height: 8),
            Text(
              descripcion,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colores.onSurfaceVariant),
            ),
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