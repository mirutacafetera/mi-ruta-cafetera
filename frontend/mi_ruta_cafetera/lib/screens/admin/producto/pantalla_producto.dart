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
  final TextEditingController _busquedaController = TextEditingController();

  bool _inicializando = true;
  String? _errorInicializacion;
  String _filtroActivo = 'todas';

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
        _errorInicializacion = e.toString().replaceFirst('Exception: ', '');
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

    setState(() => _filtroActivo = estado);
    _busquedaController.clear();
    controller.limpiarBusqueda();

    if (estado != 'todas') {
      controller.seleccionarEstado(estado);
    } else {
      controller.actualizarProductos();
    }
  }

  Future<void> _aprobarProducto(
    String productoId,
    String nombreProducto,
  ) async {
    final controller = _controller;
    if (controller == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
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
        backgroundColor: resultado ? AppColors.success : AppColors.error,
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
        backgroundColor: resultado ? AppColors.secondary : AppColors.error,
      ),
    );
  }

  String _tituloEstado(String estado) {
    switch (estado) {
      case ProductoController.estadoAprobado:
        return 'Productos aprobados';
      case ProductoController.estadoRechazado:
        return 'Productos rechazados';
      case ProductoController.estadoPendiente:
        return 'Productos pendientes';
      default:
        return 'Todos los productos';
    }
  }

  String _descripcionEstado(String estado) {
    switch (estado) {
      case ProductoController.estadoAprobado:
        return 'productos aprobados';
      case ProductoController.estadoRechazado:
        return 'productos rechazados';
      case ProductoController.estadoPendiente:
        return 'productos pendientes de revisión';
      default:
        return 'Productos registrados';
    }
  }

  String _mensajeVacio(String estado) {
    switch (estado) {
      case ProductoController.estadoAprobado:
        return 'Todavía no hay productos aprobados.';
      case ProductoController.estadoRechazado:
        return 'Todavía no hay productos rechazados.';
      case ProductoController.estadoPendiente:
        return 'No hay solicitudes pendientes.';
      default:
        return 'Todavía no hay productos registrados.';
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorInicializacion != null) {
      return _construirErrorInicializacion();
    }

    final controller = _controller;

    if (controller == null) {
      return const Center(
        child: Text('No se pudo inicializar la pantalla de productos.'),
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              EncabezadoLista(
                titulo: '',
                descripcion: _descripcionEstado(_filtroActivo),
                textoNuevo: '',
                cantidad: controller.todosLosProductos.length,
                cargando: controller.cargando || controller.actualizando,
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
              _FiltrosProducto(
                seleccionado: _filtroActivo,
                onSeleccionar: _seleccionarEstado,
              ),
              if (controller.error != null)
                _construirAvisoError(controller),
              _construirContenido(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _construirContenido(ProductoController controller) {
    if (controller.cargando) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.spacingLg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final productosBase = _filtroActivo == 'todas'
        ? controller.todosLosProductos
        : controller.productos;

    final consulta = controller.busqueda.trim().toLowerCase();

    final productos = consulta.isEmpty
        ? productosBase
        : productosBase.where((producto) {
            return producto.nombre.toLowerCase().contains(consulta) ||
                producto.categoria.toLowerCase().contains(consulta) ||
                producto.sitioNombre.toLowerCase().contains(consulta) ||
                producto.ciudad.toLowerCase().contains(consulta) ||
                producto.departamento.toLowerCase().contains(consulta);
          }).toList();

    if (productos.isEmpty) {
      final hayBusqueda = consulta.isNotEmpty;

      return _construirEstadoVacio(
        icono: hayBusqueda ? Icons.search_off : _iconoVacio(_filtroActivo),
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
            style: const TextStyle(color: AppColors.textSecondary),
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
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: AppDimensions.spacingSm),
            Expanded(
              child: Text(
                controller.error!,
                style: const TextStyle(color: AppColors.error),
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

class _FiltrosProducto extends StatelessWidget {
  final String seleccionado;
  final ValueChanged<String> onSeleccionar;

  const _FiltrosProducto({
    required this.seleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final opciones = [
      ('Todos', 'todas', Icons.grid_view_rounded, AppColors.secondary),
      (
        'Pendientes',
        ProductoController.estadoPendiente,
        Icons.pending_actions_rounded,
        Colors.orange,
      ),
      (
        'Aprobados',
        ProductoController.estadoAprobado,
        Icons.check_circle_outline_rounded,
        AppColors.success,
      ),
      (
        'Rechazados',
        ProductoController.estadoRechazado,
        Icons.cancel_outlined,
        AppColors.error,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingSm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (int i = 0; i < opciones.length; i++) ...[
              if (i > 0)
                const SizedBox(width: AppDimensions.spacingSm),
              _FiltroProductoItem(
                titulo: opciones[i].$1,
                valor: opciones[i].$2,
                icono: opciones[i].$3,
                color: opciones[i].$4,
                seleccionado: seleccionado == opciones[i].$2,
                onTap: () => onSeleccionar(opciones[i].$2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FiltroProductoItem extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;

  const _FiltroProductoItem({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: seleccionado
            ? color.withValues(alpha: 0.12)
            : AppColors.creamLight,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.coffeeLight.withValues(alpha: 0.65),
          width: 1.1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          splashColor: color.withValues(alpha: 0.08),
          highlightColor: color.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icono, size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  titulo,
                  style: TextStyle(
                    color: seleccionado ? color : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}