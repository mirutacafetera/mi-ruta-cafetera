import 'package:flutter/material.dart';

import '../../../controllers/admin/actividades/actividad_admin_controller.dart';
import '../../../models/admin/admin_actividad_model.dart';
import '../../../widgets/admin/actividades/tarjeta_actividad_admin.dart';
import '../../../widgets/admin/actividades/detalle_actividad_admin.dart';
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

  void _mensaje(String texto, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: error ? Colors.red : Colors.green.shade700,
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
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.check_circle_outline),
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
      _mensaje('Actividad aprobada correctamente.');
    } else {
      _mensaje(resultado, error: true);
    }
  }

  Future<void> _rechazar(ActividadAdminModel actividad) async {
    final motivoController = TextEditingController();

    try {
      final motivo = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Rechazar actividad'),
          content: TextField(
            controller: motivoController,
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                final texto = motivoController.text.trim();

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

                Navigator.of(dialogContext).pop(texto);
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
        _mensaje('Actividad rechazada correctamente.');
      } else {
        _mensaje(resultado, error: true);
      }
    } finally {
      motivoController.dispose();
    }
  }

  void _mostrarGaleria(List<String> imagenes, int inicial) {
    GaleriaImagenes.mostrar(context, imagenes, inicial);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controlador,
      builder: (context, _) {
        final actividades = _controlador.actividadesFiltradas
            .where((a) => a.estadoPublicacion == _estado)
            .toList();

        final seleccionada = _actividadSeleccionada;

        if (seleccionada != null) {
          final actividadActual = _controlador.actividades
              .where((a) => a.id == seleccionada.id)
              .firstOrNull;

          if (actividadActual != null) {
            return DetalleActividadAdmin(
              actividad: actividadActual,
              onVolver: () {
                setState(() => _actividadSeleccionada = null);
              },
              onAprobar: () => _aprobar(actividadActual),
              onRechazar: () => _rechazar(actividadActual),
              onActualizar: _cargar,
              procesando: _controlador.procesando,
              onMostrarGaleria: _mostrarGaleria,
            );
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
                      child: _encabezado(context),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ResumenProductos(
                      estadoSeleccionado: _estado,
                      onSeleccionar: (nuevoEstado) {
                        setState(() => _estado = nuevoEstado);
                      },
                      tarjetas: [
                        ResumenTarjetaConfig(
                          titulo: 'Pendientes',
                          cantidad: _contarEstado('pendiente_revision'),
                          icono: Icons.pending_actions,
                          color: Colors.orange,
                          estado: 'pendiente_revision',
                        ),
                        ResumenTarjetaConfig(
                          titulo: 'Aprobados',
                          cantidad: _contarEstado('aprobado'),
                          icono: Icons.check_circle_outline,
                          color: Colors.green,
                          estado: 'aprobado',
                        ),
                        ResumenTarjetaConfig(
                          titulo: 'Rechazados',
                          cantidad: _contarEstado('rechazado'),
                          icono: Icons.cancel_outlined,
                          color: Colors.red,
                          estado: 'rechazado',
                        ),
                      ],
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
                  if (_controlador.error != null &&
                      _controlador.actividades.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _estadoVacio(
                        context,
                        'No se pudieron cargar las actividades.',
                        _controlador.error!,
                        _cargar,
                        error: true,
                      ),
                    )
                  else if (_controlador.cargando &&
                      _controlador.actividades.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (actividades.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _estadoVacio(
                        context,
                        _controlador.busqueda.isNotEmpty
                            ? 'No se encontraron actividades'
                            : 'No hay actividades ${_textoEstado()}.',
                        _controlador.busqueda.isNotEmpty
                            ? 'Prueba con otro nombre o sitio turístico.'
                            : 'Las actividades aparecerán aquí cuando '
                                'haya registros de este estado.',
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

  int _contarEstado(String estado) {
    return _controlador.actividades
        .where((a) => a.estadoPublicacion == estado)
        .length;
  }

  String _textoEstado() {
    switch (_estado) {
      case 'aprobado':
        return 'aprobados';
      case 'rechazado':
        return 'rechazados';
      default:
        return 'pendientes';
    }
  }

  Widget _encabezado(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colores.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.event_available_rounded,
            color: colores.primary,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Moderación de actividades',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Revisa y gestiona las actividades enviadas.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colores.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Actualizar',
          onPressed: _controlador.cargando ? null : _cargar,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

  Widget _estadoVacio(
    BuildContext context,
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
              size: 58,
              color: error ? colores.error : colores.primary,
            ),
            const SizedBox(height: 14),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colores.onSurfaceVariant,
                  ),
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