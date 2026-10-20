
import 'package:flutter/material.dart';

import '../../../controllers/admin/producto/producto_controller.dart';
import '../../../services/admin/admin_servicio_autenticacion.dart';
import '../../../widgets/admin/producto/tarjeta_producto.dart';
import '../../../widgets/admin/producto/resumen_productos.dart';
import '../../../widgets/admin/producto/formulario_motivo_rechazo.dart';
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
          'No se encontró el token del administrador. '
          'Inicia sesión nuevamente.',
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
        _errorInicializacion = e
            .toString()
            .replaceFirst('Exception: ', '');
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

  Future<void> _seleccionarEstado(String estado) async {
    final controller = _controller;

    if (controller == null) return;

    _busquedaController.clear();
    await controller.seleccionarEstado(estado);
  }

  Future<void> _aprobarProducto(
    String productoId,
    String nombreProducto,
  ) async {
    final controller = _controller;

    if (controller == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aceptar producto'),
          content: Text(
            '¿Deseas aprobar "$nombreProducto"? '
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
        );
      },
    );

    if (confirmar != true || !mounted) return;

    final resultado = await controller.aprobarProducto(productoId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resultado
              ? 'Producto aprobado correctamente.'
              : controller.error ?? 'No se pudo aprobar el producto.',
        ),
        backgroundColor: resultado ? Colors.green.shade700 : Colors.red,
      ),
    );
  }

  Future<void> _rechazarProducto(
    String productoId,
    String nombreProducto,
  ) async {
    final controller = _controller;

    if (controller == null) return;

    final motivo = await FormularioMotivoRechazo.mostrar(
      context,
      nombreProducto: nombreProducto,
    );

    if (motivo == null || !mounted) return;

    final resultado = await controller.rechazarProducto(
      productoId: productoId,
      motivoRechazo: motivo,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resultado
              ? 'Producto rechazado correctamente.'
              : controller.error ?? 'No se pudo rechazar el producto.',
        ),
        backgroundColor: resultado ? Colors.orange.shade800 : Colors.red,
      ),
    );
  }

  String _tituloEstado(String estado) {
    switch (estado) {
      case ProductoController.estadoAprobado:
        return 'Productos aceptados';
      case ProductoController.estadoRechazado:
        return 'Productos rechazados';
      default:
        return 'Solicitudes pendientes';
    }
  }

  String _descripcionEstado(String estado) {
    switch (estado) {
      case ProductoController.estadoAprobado:
        return 'productos aceptados';
      case ProductoController.estadoRechazado:
        return 'productos rechazados';
      default:
        return 'solicitudes pendientes';
    }
  }

  String _mensajeVacio(String estado) {
    switch (estado) {
      case ProductoController.estadoAprobado:
        return 'Todavía no hay productos aceptados.';
      case ProductoController.estadoRechazado:
        return 'Todavía no hay productos rechazados.';
      default:
        return 'No hay solicitudes pendientes. '
            'Cuando un sitio turístico envíe un producto para revisión, '
            'aparecerá aquí.';
    }
  }

  IconData _iconoVacio(String estado) {
    switch (estado) {
      case ProductoController.estadoAprobado:
        return Icons.check_circle_outline;
      case ProductoController.estadoRechazado:
        return Icons.cancel_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_inicializando) {
      return const Center(
        child: CircularProgressIndicator(),
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
        final estado = controller.estadoSeleccionado;

        return Column(
          children: [
            EncabezadoLista(
              titulo: 'Productos',
              descripcion: _descripcionEstado(estado),
              textoNuevo: '',
              cantidad: controller.productos.length,
              cargando: controller.cargando || controller.actualizando,
              mostrarBotonNuevo: false,
              onActualizar: _actualizar,
              onNuevo: () {},
            ),
            
            ResumenProductos(
              pendientes: controller.totalPendientes,
              aprobados: controller.totalAceptados,
              rechazados: controller.totalRechazados,
              estadoSeleccionado: estado,
              onSeleccionar: _seleccionarEstado,
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
            if (controller.error != null)
              _construirAvisoError(controller),
            Expanded(
              child: _construirContenido(controller),
            ),
          ],
        );
      },
    );
  }

  Widget _construirContenido(ProductoController controller) {
    if (controller.cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final productos = controller.productosFiltrados;

    if (productos.isEmpty) {
      final hayBusqueda = controller.busqueda.trim().isNotEmpty;

      return _construirEstadoVacio(
        icono: hayBusqueda
            ? Icons.search_off
            : _iconoVacio(controller.estadoSeleccionado),
        titulo: hayBusqueda
            ? 'No se encontraron productos'
            : _tituloEstado(controller.estadoSeleccionado),
        descripcion: hayBusqueda
            ? 'Prueba con otro nombre, categoría o sitio turístico.'
            : _mensajeVacio(controller.estadoSeleccionado),
        mostrarActualizar: !hayBusqueda,
      );
    }

    return RefreshIndicator(
      onRefresh: _actualizar,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          bottom: AppDimensions.spacingLg,
        ),
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto = productos[index];

          return TarjetaProducto(
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
          );
        },
      ),
    );
  }

  Widget _construirEstadoVacio({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required bool mostrarActualizar,
  }) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(
          AppDimensions.spacingLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(
              height: AppDimensions.spacingSm,
            ),
            Text(
              descripcion,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            if (mostrarActualizar) ...[
              const SizedBox(
                height: AppDimensions.spacingMd,
              ),
              OutlinedButton.icon(
                onPressed: _actualizar,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _construirAvisoError(ProductoController controller) {
    return Material(
      color: Colors.red.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pageHorizontalSmall,
          vertical: AppDimensions.spacingSm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
            const SizedBox(
              width: AppDimensions.spacingSm,
            ),
            Expanded(
              child: Text(
                controller.error!,
                style: const TextStyle(
                  color: Colors.red,
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
        padding: const EdgeInsets.all(
          AppDimensions.spacingLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            Text(
              _errorInicializacion ?? 'No se pudo cargar la pantalla.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
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
