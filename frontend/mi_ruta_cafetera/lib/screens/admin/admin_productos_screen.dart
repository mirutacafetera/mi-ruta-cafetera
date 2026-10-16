import 'package:flutter/material.dart';

import '../../models/admin/admin_producto_model.dart';
import '../../services/admin/admin_productos_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class AdminProductosScreen extends StatefulWidget {
  const AdminProductosScreen({super.key});

  @override
  State<AdminProductosScreen> createState() => _AdminProductosScreenState();
}

class _AdminProductosScreenState extends State<AdminProductosScreen> {
  List<AdminProductoModel> _productos = [];

  bool _cargando = true;
  bool _operando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final productos = await AdminProductosService.obtenerPendientes();

      if (!mounted) return;

      setState(() {
        _productos = productos;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  Future<bool> _confirmarAprobacion(AdminProductoModel producto) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Aprobar producto'),
        content: Text(
          '¿Deseas aprobar "${producto.nombre}" para su publicación '
          'en el catálogo turístico?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Aprobar'),
          ),
        ],
      ),
    );

    return resultado ?? false;
  }

  Future<void> _aprobar(AdminProductoModel producto) async {
    if (_operando) return;

    final confirmado = await _confirmarAprobacion(producto);

    if (!confirmado || !mounted) return;

    setState(() => _operando = true);

    try {
      await AdminProductosService.aprobarProducto(producto.id);

      if (!mounted) return;

      _mostrarMensaje('Producto aprobado correctamente.');
      await _cargarProductos();
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _operando = false);
      }
    }
  }

  Future<void> _rechazar(AdminProductoModel producto) async {
    if (_operando) return;

    final controlador = TextEditingController();

    final motivo = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rechazar producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Producto: ${producto.nombre}'),
              const SizedBox(height: AppDimensions.spacingMd),
              TextField(
                controller: controlador,
                autofocus: true,
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Motivo del rechazo',
                  hintText: 'Explica qué debe corregir el propietario.',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () {
              final texto = controlador.text.trim();

              if (texto.length < 3) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'El motivo debe tener al menos 3 caracteres.',
                    ),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext, texto);
            },
            icon: const Icon(Icons.close_rounded),
            label: const Text('Rechazar'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          ),
        ],
      ),
    );

    controlador.dispose();

    if (motivo == null || motivo.trim().length < 3 || !mounted) {
      return;
    }

    setState(() => _operando = true);

    try {
      await AdminProductosService.rechazarProducto(
        productoId: producto.id,
        motivoRechazo: motivo,
      );

      if (!mounted) return;

      _mostrarMensaje(
        'Producto rechazado. Se notificará el motivo al propietario.',
      );
      await _cargarProductos();
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _operando = false);
      }
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: esError ? AppColors.error : AppColors.primary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _cargarProductos,
      child: _crearContenido(),
    );
  }

  Widget _crearContenido() {
    if (_cargando) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 180),
          Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        children: [
          const SizedBox(height: 70),
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'No fue posible cargar los productos',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: AppDimensions.spacingLg),
          Center(
            child: FilledButton.icon(
              onPressed: _cargarProductos,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar nuevamente'),
            ),
          ),
        ],
      );
    }

    if (_productos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        children: [
          const SizedBox(height: 100),
          Icon(Icons.inventory_2_outlined, size: 72, color: AppColors.primary),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'No hay productos pendientes',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          const Text(
            'Los productos enviados por los sitios turísticos '
            'aparecerán aquí para su revisión.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.pending_actions_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Productos pendientes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        '${_productos.length} producto'
                        '${_productos.length == 1 ? '' : 's'} por revisar.',
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: _operando ? null : _cargarProductos,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        ..._productos.map(_tarjetaProducto),
      ],
    );
  }

  Widget _tarjetaProducto(AdminProductoModel producto) {
    final ubicacion = [
      if (producto.ciudad.isNotEmpty) producto.ciudad,
      if (producto.departamento.isNotEmpty) producto.departamento,
    ].join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (producto.imagenPrincipal.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    producto.imagenPrincipal,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _imagenNoDisponible(),
                  ),
                ),
              )
            else
              _imagenNoDisponible(),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              producto.nombre,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              producto.sitioNombre,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (ubicacion.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                ubicacion,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: AppDimensions.spacingMd),
            Wrap(
              spacing: AppDimensions.spacingSm,
              runSpacing: AppDimensions.spacingSm,
              children: [
                Chip(
                  avatar: const Icon(Icons.category_outlined, size: 18),
                  label: Text(producto.categoria),
                ),
                Chip(
                  avatar: const Icon(Icons.payments_outlined, size: 18),
                  label: Text('\$${producto.precio.toStringAsFixed(0)} COP'),
                ),
              ],
            ),
            if (producto.descripcion.trim().isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                producto.descripcion,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ],
            if (producto.imagenes.length > 1) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                'Fotografías adicionales: ${producto.imagenes.length - 1}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              SizedBox(
                height: 84,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: producto.imagenes.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppDimensions.spacingSm),
                  itemBuilder: (context, index) {
                    final url = producto.imagenes[index];

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                      child: Image.network(
                        url,
                        width: 100,
                        height: 84,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 100,
                          color: AppColors.background,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.spacingLg),
            const Divider(),
            const SizedBox(height: AppDimensions.spacingSm),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppDimensions.spacingSm,
              runSpacing: AppDimensions.spacingSm,
              children: [
                OutlinedButton.icon(
                  onPressed: _operando ? null : () => _rechazar(producto),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Rechazar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _operando ? null : () => _aprobar(producto),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Aprobar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagenNoDisponible() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 44,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppDimensions.spacingSm),
          Text('Imagen no disponible'),
        ],
      ),
    );
  }
}
