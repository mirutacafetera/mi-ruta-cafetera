import 'package:flutter/material.dart';

import '../../../controllers/admin/producto/producto_controller.dart';
import '../../../services/admin/admin_servicio_autenticacion.dart';
import '../../../models/admin/admin_producto_model.dart';
import '../../../widgets/admin/producto/detalle_producto_admin.dart';
import '../../../widgets/admin/producto/tarjeta_producto.dart';
import '../../../widgets/admin/producto/resumen_productos.dart';
import '../../../widgets/admin/producto/formulario_motivo_rechazo.dart';
import '../../../widgets/admin/contenido/filtros_contenido.dart';
import '../../../widgets/admin/sitio_turistico/barra_busqueda.dart';
import '../../../widgets/admin/sitio_turistico/encabezado_lista.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class PantallaProducto extends StatefulWidget {
  const PantallaProducto({super.key});

  @override
  State<PantallaProducto> createState() => _PantallaProductoState();
}

class _PantallaProductoState extends State<PantallaProducto> {
  ProductoController? _controller;

  final TextEditingController _busquedaController =
      TextEditingController();

  bool _inicializando = true;
  String? _errorInicializacion;
  String _filtroActivo = 'todas';

  AdminProductoModel? _productoSeleccionado;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    try {
      await AdminServicioAutenticacion.cargarToken();

      final token = AdminServicioAutenticacion.tokenAdmin;

      if (token == null || token.trim().isEmpty) {
        throw Exception(
          'No se encontró el token del administrador. Inicia sesión nuevamente.',
        );
      }

      final controller = ProductoController(token: token);

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _inicializando = false;
      });

      await controller.cargarProductosPendientes();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorInicializacion =
            e.toString().replaceFirst('Exception: ', '');
        _inicializando = false;
      });
    }
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _actualizar() async {
    final controller = _controller;
    if (controller == null) return;

    await controller.actualizarProductos();
  }

  void _seleccionarEstado(String estado) {
    final controller = _controller;
    if (controller == null) return;

    setState(() {
      _filtroActivo = estado;
    });

    _busquedaController.clear();
    controller.limpiarBusqueda();

    if (estado == 'todas') {
      controller.actualizarProductos();
    } else {
      controller.seleccionarEstado(estado);
    }
  }

  Future<void> _aprobarProducto(
    String id,
    String nombre,
  ) async {
    final controller = _controller;
    if (controller == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.creamLight,
        title: const Text('Aceptar producto'),
        content: Text(
          '¿Deseas aprobar "$nombre"? '
          'El producto pasará a la lista de aceptados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Aceptar producto'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final resultado = await controller.aprobarProducto(id);

    if (!mounted) return;

    _mostrarMensaje(
      resultado
          ? 'Producto aprobado correctamente.'
          : controller.error ?? 'No se pudo aprobar el producto.',
      resultado ? AppColors.success : AppColors.error,
    );
  }

  Future<void> _rechazarProducto(
    String id,
    String nombre,
  ) async {
    final controller = _controller;
    if (controller == null) return;

    final motivo = await FormularioMotivoRechazo.mostrar(
      context,
      nombreProducto: nombre,
    );

    if (motivo == null || !mounted) return;

    final resultado = await controller.rechazarProducto(
      productoId: id,
      motivoRechazo: motivo,
    );

    if (!mounted) return;

    _mostrarMensaje(
      resultado
          ? 'Producto rechazado correctamente.'
          : controller.error ?? 'No se pudo rechazar el producto.',
      resultado ? AppColors.secondary : AppColors.error,
    );
  }

  Future<void> _eliminarProducto(
    String id,
    String nombre,
  ) async {
    final controller = _controller;

    if (controller == null || controller.estaProcesando(id)) {
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Eliminar producto',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '¿Deseas eliminar el producto "$nombre"? '
          'Esta acción no se puede deshacer.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 18,
            ),
            label: const Text('Eliminar'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final resultado = await controller.eliminarProducto(id);

    if (!mounted) return;

    _mostrarMensaje(
      resultado
          ? 'Producto eliminado correctamente.'
          : controller.error ?? 'No se pudo eliminar el producto.',
      resultado ? AppColors.success : AppColors.error,
    );

    if (resultado && _productoSeleccionado?.id == id) {
      setState(() {
        _productoSeleccionado = null;
      });
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
      ),
    );
  }

  String _tituloEstado(String estado) => switch (estado) {
        ProductoController.estadoAprobado => 'Productos aprobados',
        ProductoController.estadoRechazado => 'Productos rechazados',
        ProductoController.estadoPendiente => 'Productos pendientes',
        _ => 'Todos los productos',
      };

  String _descripcionEstado(String estado) => switch (estado) {
        ProductoController.estadoAprobado => 'productos aprobados',
        ProductoController.estadoRechazado => 'productos rechazados',
        ProductoController.estadoPendiente =>
          'productos pendientes de revisión',
        _ => 'Productos registrados',
      };

  String _mensajeVacio(String estado) => switch (estado) {
        ProductoController.estadoAprobado =>
          'Todavía no hay productos aprobados.',
        ProductoController.estadoRechazado =>
          'Todavía no hay productos rechazados.',
        ProductoController.estadoPendiente =>
          'No hay solicitudes pendientes.',
        _ => 'Todavía no hay productos registrados.',
      };

  IconData _iconoVacio(String estado) => switch (estado) {
        ProductoController.estadoAprobado =>
          Icons.check_circle_outline,
        ProductoController.estadoRechazado => Icons.cancel_outlined,
        _ => Icons.inventory_2_outlined,
      };

  @override
  Widget build(BuildContext context) {
    if (_inicializando) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_errorInicializacion != null) {
      return _construirErrorInicializacion();
    }

    final controller = _controller;

    if (controller == null) {
      return const Center(
        child: Text(
          'No se pudo inicializar la pantalla de productos.',
        ),
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final cargando =
            controller.cargando || controller.actualizando;

        final productoSeleccionado = _productoSeleccionado;

        if (productoSeleccionado != null) {
          return DetalleProductoAdmin(
            producto: productoSeleccionado,
            procesando: controller.estaProcesando(
              productoSeleccionado.id,
            ),
            onAprobar: () => _aprobarProducto(
              productoSeleccionado.id,
              productoSeleccionado.nombre,
            ),
            onRechazar: () => _rechazarProducto(
              productoSeleccionado.id,
              productoSeleccionado.nombre,
            ),
            onConfirmarRechazo: (motivo) {
              controller.rechazarProducto(
                productoId: productoSeleccionado.id,
                motivoRechazo: motivo,
              );
            },
            onActualizar: _actualizar,
            onEliminar: () => _eliminarProducto(
              productoSeleccionado.id,
              productoSeleccionado.nombre,
            ),
            onVolver: () {
              setState(() {
                _productoSeleccionado = null;
              });
            },
          );
        }

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              EncabezadoLista(
                titulo: '',
                descripcion: _descripcionEstado(_filtroActivo),
                textoNuevo: '',
                cantidad: controller.todosLosProductos.length,
                cargando: cargando,
                mostrarBotonNuevo: false,
                onActualizar: _actualizar,
                onNuevo: () {},
              ),
              ResumenProductos(
                pendientes: controller.totalPendientes,
                aprobados: controller.totalAceptados,
                rechazados: controller.totalRechazados,
                estadoSeleccionado: controller.estadoSeleccionado,
                onSeleccionar: (_) {},
              ),
              BarraBusqueda(
                valor: controller.busqueda,
                textoAyuda: 'Buscar producto o sitio turístico...',
                controller: _busquedaController,
                onChanged: controller.cambiarBusqueda,
                onLimpiar: () {
                  _busquedaController.clear();
                  controller.limpiarBusqueda();
                },
              ),
              FiltrosContenido(
                seleccionado: _filtroActivo,
                onSeleccionar: _seleccionarEstado,
                opciones: [
                  const OpcionFiltroAdmin(
                    titulo: 'Todos',
                    valor: 'todas',
                    icono: Icons.grid_view_rounded,
                    color: AppColors.secondary,
                  ),
                  OpcionFiltroAdmin(
                    titulo: 'Pendientes',
                    valor: ProductoController.estadoPendiente,
                    icono: Icons.pending_actions_rounded,
                    color: Colors.orange,
                  ),
                  OpcionFiltroAdmin(
                    titulo: 'Aprobados',
                    valor: ProductoController.estadoAprobado,
                    icono: Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                  ),
                  OpcionFiltroAdmin(
                    titulo: 'Rechazados',
                    valor: ProductoController.estadoRechazado,
                    icono: Icons.cancel_outlined,
                    color: AppColors.error,
                  ),
                ],
              ),
              if (cargando)
                const Padding(
                  padding: EdgeInsets.all(AppDimensions.spacingLg),
                  child: Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              else ...[
                if (controller.error != null)
                  _construirAvisoError(controller),
                _construirContenido(controller),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _construirContenido(ProductoController controller) {
    final productosBase = _filtroActivo == 'todas'
        ? controller.todosLosProductos
        : controller.productos;

    final consulta = controller.busqueda.trim().toLowerCase();

    final productos = consulta.isEmpty
        ? productosBase
        : productosBase.where((producto) {
            return [
              producto.nombre,
              producto.categoria,
              producto.sitioNombre,
              producto.ciudad,
              producto.departamento,
            ].any(
              (dato) => dato.toLowerCase().contains(consulta),
            );
          }).toList();

    if (productos.isEmpty) {
      final hayBusqueda = consulta.isNotEmpty;

      return _construirEstadoVacio(
        icono: hayBusqueda
            ? Icons.search_off
            : _iconoVacio(_filtroActivo),
        titulo: hayBusqueda
            ? 'No se encontraron productos'
            : _tituloEstado(_filtroActivo),
        descripcion: hayBusqueda
            ? 'Prueba con otro nombre, categoría o sitio turístico.'
            : _mensajeVacio(_filtroActivo),
        mostrarActualizar: !hayBusqueda,
      );
    }

    return Column(
      children: [
        for (final producto in productos)
          TarjetaProducto(
            key: ValueKey(producto.id),
            producto: producto,
            procesando: controller.estaProcesando(producto.id),
            onAprobar: () => _aprobarProducto(
              producto.id,
              producto.nombre,
            ),
            onRechazar: () => _rechazarProducto(
              producto.id,
              producto.nombre,
            ),
            onEliminar: () => _eliminarProducto(
              producto.id,
              producto.nombre,
            ),
            onConfirmarRechazo: (motivo) {
              controller.rechazarProducto(
                productoId: producto.id,
                motivoRechazo: motivo,
              );
            },
            onActualizar: _actualizar,
            onVerDetalle: () {
              setState(() {
                _productoSeleccionado = producto;
              });
            },
          ),
        const SizedBox(height: AppDimensions.spacingLg),
      ],
    );
  }

  Widget _construirEstadoVacio({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required bool mostrarActualizar,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            descripcion,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          if (mostrarActualizar) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            OutlinedButton.icon(
              onPressed: _actualizar,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirAvisoError(ProductoController controller) {
    return Material(
      color: AppColors.error.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pageHorizontalSmall,
          vertical: AppDimensions.spacingSm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Expanded(
              child: Text(
                controller.error!,
                style: const TextStyle(
                  color: AppColors.error,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Cerrar aviso',
              onPressed: controller.limpiarError,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirErrorInicializacion() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              _errorInicializacion ?? 'No se pudo cargar la pantalla.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _inicializando = true;
                  _errorInicializacion = null;
                });

                _inicializar();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar nuevamente'),
            ),
          ],
        ),
      ),
    );
  }
}