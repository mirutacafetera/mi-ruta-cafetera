import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../controllers/admin/contenido/admin_contenido_controller.dart';
import '../../../models/admin/admin_contenido_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/contenido/detalle_contenido.dart';
import '../../../widgets/admin/contenido/galeria_imagenes.dart';
import '../../../widgets/admin/contenido/tarjeta_contenido.dart';
import '../../../widgets/admin/producto/resumen_productos.dart';
import '../../../widgets/admin/sitio_turistico/barra_busqueda.dart';
import '../../../widgets/admin/sitio_turistico/encabezado_lista.dart';

class PantallaContenido extends StatefulWidget {
  const PantallaContenido({super.key});

  @override
  State<PantallaContenido> createState() => _PantallaContenidoState();
}

class _PantallaContenidoState extends State<PantallaContenido> {
  late final AdminContenidoController _controller;
  final _busqueda = TextEditingController();
  final _audio = AudioPlayer();

  String _estado = 'pendiente_revision';
  String? _seleccionado;

  @override
  void initState() {
    super.initState();
    _controller = AdminContenidoController();
    _cargar();
  }

  @override
  void dispose() {
    _audio.dispose();
    _busqueda.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    await _audio.stop();
    await _controller.cargarContenidos();

    if (mounted && _controller.error != null) {
      _mensaje(_controller.error!, true);
    }
  }

  void _mensaje(String texto, [bool error = false]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? Colors.red : AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        AdminContenidoModel? contenido;

        for (final c in _controller.contenidos) {
          if (c.id == _seleccionado) {
            contenido = c;
            break;
          }
        }

        if (contenido != null) return _detalle(contenido);

        return Column(
          children: [
            EncabezadoLista(
              titulo: 'Moderación de contenido',
              descripcion: 'Revisa los contenidos enviados',
              textoNuevo: '',
              cantidad: _controller.totalContenidos,
              cargando: _controller.cargando,
              mostrarBotonNuevo: false,
              onActualizar: _cargar,
              onNuevo: () {},
            ),
            ResumenProductos(
              estadoSeleccionado: _estado,
              onSeleccionar: (v) => setState(() => _estado = v),
              tarjetas: [
                ResumenTarjetaConfig(
                  titulo: 'Pendientes',
                  cantidad: _controller.totalPendientes,
                  icono: Icons.pending_actions,
                  color: Colors.orange,
                  estado: 'pendiente_revision',
                ),
                ResumenTarjetaConfig(
                  titulo: 'Aprobados',
                  cantidad: _controller.totalAceptados,
                  icono: Icons.check_circle_outline,
                  color: Colors.green,
                  estado: 'aprobado',
                ),
                ResumenTarjetaConfig(
                  titulo: 'Rechazados',
                  cantidad: _controller.totalRechazados,
                  icono: Icons.cancel_outlined,
                  color: Colors.red,
                  estado: 'rechazado',
                ),
              ],
            ),
            BarraBusqueda(
              valor: _controller.busqueda,
              textoAyuda: 'Buscar contenido o sitio turístico...',
              controller: _busqueda,
              onChanged: _controller.cambiarBusqueda,
              onLimpiar: () {
                _busqueda.clear();
                _controller.limpiarBusqueda();
              },
            ),
            Expanded(child: _lista()),
          ],
        );
      },
    );
  }

  Widget _lista() {
    if (_controller.cargando && _controller.contenidos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.error != null && _controller.contenidos.isEmpty) {
      return _vacio(_controller.error!, _cargar);
    }

    final lista = _controller.contenidosFiltrados
        .where((c) => c.estadoPublicacion == _estado)
        .toList();

    if (lista.isEmpty) {
      return _vacio(
        'No hay contenidos ${_estadoTexto()}.',
        _controller.busqueda.isNotEmpty
            ? () {
                _busqueda.clear();
                _controller.limpiarBusqueda();
              }
            : _cargar,
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          bottom: AppDimensions.spacingLg,
        ),
        itemCount: lista.length,
        itemBuilder: (_, i) {
          final c = lista[i];

          return TarjetaContenido(
            key: ValueKey(c.id),
            contenido: c,
            procesando:
                _controller.contenidosEnProcesamiento.contains(c.id),
            onVer: () => _ver(c),
            onSeleccionar: () => _ver(c),
            onEditar: () => _editar(c),
            onCambiarEstado: () => _cambiarEstado(c),
            onEliminar: () => _eliminar(c),
            onAprobar: () => _aprobar(c),
            onRechazar: () => _rechazar(c),
          );
        },
      ),
    );
  }

  Widget _detalle(AdminContenidoModel c) {
    return DetalleContenido(
      contenido: c,
      audio: _audio,
      onVolver: () => setState(() => _seleccionado = null),
      onActualizar: _cargar,
      onEditar: () => _editar(c),
      onCambiarEstado: () => _cambiarEstado(c),
      onEliminar: () => _eliminar(c),
      onAprobar: () => _aprobar(c),
      onRechazar: () => _rechazar(c),
      onMostrarGaleria: (imagenes, inicial) =>
          GaleriaImagenes.mostrar(context, imagenes, inicial),
      onMensaje: _mensaje,
    );
  }

  Future<void> _ver(AdminContenidoModel c) async {
    await _audio.stop();
    if (mounted) setState(() => _seleccionado = c.id);
  }

  String _estadoTexto() => switch (_estado) {
        'pendiente_revision' => 'pendientes',
        'aprobado' => 'aprobados',
        _ => 'rechazados',
      };

  Widget _vacio(String texto, VoidCallback accion) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.perm_media_outlined, size: 48),
            const SizedBox(height: 12),
            Text(texto, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: accion,
              child: const Text('Actualizar o limpiar búsqueda'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmar(String titulo, String mensaje) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _aprobar(AdminContenidoModel c) async {
    if (await _confirmar(
          'Aprobar contenido',
          '¿Deseas aprobar "${c.titulo}"?',
        ) !=
        true) {
      return;
    }

    final ok = await _controller.aprobarContenido(c.id);
    if (!mounted) return;

    if (ok) {
      setState(() {
        _seleccionado = null;
        _estado = 'aprobado';
      });
    }

    _mensaje(
      ok ? 'Contenido aprobado.' : _controller.error ?? 'No se pudo aprobar.',
      !ok,
    );
  }

  Future<void> _rechazar(AdminContenidoModel c) async {
    final motivo = TextEditingController();

    try {
      final texto = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Rechazar contenido'),
          content: TextField(
            controller: motivo,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Motivo del rechazo',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (motivo.text.trim().isNotEmpty) {
                  Navigator.pop(ctx, motivo.text.trim());
                }
              },
              child: const Text('Rechazar'),
            ),
          ],
        ),
      );

      if (texto == null) return;

      final ok = await _controller.rechazarContenido(
        id: c.id,
        motivoRechazo: texto,
      );

      if (!mounted) return;

      if (ok) {
        setState(() {
          _seleccionado = null;
          _estado = 'rechazado';
        });
      }

      _mensaje(
        ok ? 'Contenido rechazado.' : _controller.error ?? 'No se pudo rechazar.',
        !ok,
      );
    } finally {
      motivo.dispose();
    }
  }

  Future<void> _editar(AdminContenidoModel c) async {
    final titulo = TextEditingController(text: c.titulo);
    final descripcion = TextEditingController(text: c.descripcion);
    final formKey = GlobalKey<FormState>();

    try {
      final datos = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Editar contenido'),
          content: SizedBox(
            width: 340,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titulo,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'El título es obligatorio'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descripcion,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx, {
                    'titulo': titulo.text.trim(),
                    'descripcion': descripcion.text.trim(),
                  });
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      );

      if (datos == null) return;

      final ok = await _controller.actualizarContenido(
        id: c.id,
        datos: datos,
      );

      if (mounted) {
        _mensaje(
          ok ? 'Contenido actualizado.' : _controller.error ?? 'No se pudo actualizar.',
          !ok,
        );
      }
    } finally {
      titulo.dispose();
      descripcion.dispose();
    }
  }

  Future<void> _cambiarEstado(AdminContenidoModel c) async {
    final activar = !c.activo;

    if (await _confirmar(
          activar ? 'Activar contenido' : 'Desactivar contenido',
          '¿Deseas ${activar ? 'activar' : 'desactivar'} "${c.titulo}"?',
        ) !=
        true) {
      return;
    }

    final ok = activar
        ? await _controller.activarContenido(c.id)
        : await _controller.desactivarContenido(c.id);

    if (mounted) {
      _mensaje(
        ok ? 'Estado actualizado.' : _controller.error ?? 'No se pudo actualizar.',
        !ok,
      );
    }
  }

  Future<void> _eliminar(AdminContenidoModel c) async {
    if (await _confirmar(
          'Eliminar contenido',
          '¿Eliminar "${c.titulo}"? Esta acción no se puede deshacer.',
        ) !=
        true) {
      return;
    }

    await _audio.stop();
    final ok = await _controller.eliminarContenido(c.id);
    if (!mounted) return;

    if (ok && _seleccionado == c.id) {
      setState(() => _seleccionado = null);
    }

    _mensaje(
      ok ? 'Contenido eliminado.' : _controller.error ?? 'No se pudo eliminar.',
      !ok,
    );
  }
}