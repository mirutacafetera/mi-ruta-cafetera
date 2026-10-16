import 'package:flutter/material.dart';

import '../../../models/sitio/sitio_producto_model.dart';
import '../../../services/sitio/sitio_productos_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class DetalleProductos extends StatefulWidget {
  const DetalleProductos({super.key, required this.sitioId});

  final String sitioId;

  @override
  State<DetalleProductos> createState() => _DetalleProductosState();
}

class _DetalleProductosState extends State<DetalleProductos> {
  final SitioProductosService _productosService = SitioProductosService();

  List<SitioProductoModel> _productos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void didUpdateWidget(covariant DetalleProductos oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sitioId != widget.sitioId) {
      _cargarProductos();
    }
  }

  Future<void> _cargarProductos() async {
    final sitioId = widget.sitioId.trim();

    if (sitioId.isEmpty) {
      setState(() {
        _productos = [];
        _error = 'No se pudo identificar el sitio turístico.';
        _cargando = false;
      });
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final productos = await _productosService.obtenerProductosPublicos(
        sitioId: sitioId,
      );

      if (!mounted) return;

      setState(() {
        _productos = productos;
        _cargando = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error al cargar productos del sitio: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
        vertical: AppDimensions.spacingLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.storefront_outlined,
                color: AppColors.primary,
                size: 26,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              const Expanded(
                child: Text(
                  'Productos de este sitio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (!_cargando && _productos.isNotEmpty)
                Text(
                  '${_productos.length}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          const Text(
            'Descubre los productos que ofrece este establecimiento.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          if (_cargando)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.spacingXxl),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            _mensajeEstado(
              icono: Icons.cloud_off_outlined,
              mensaje: 'No pudimos cargar los productos.',
              detalle: _error!,
              mostrarReintento: true,
            )
          else if (_productos.isEmpty)
            _mensajeEstado(
              icono: Icons.inventory_2_outlined,
              mensaje: 'Todavía no hay productos publicados.',
              detalle:
                  'Cuando el establecimiento publique sus productos '
                  'aprobados, aparecerán aquí.',
            )
          else
            SizedBox(
              height: 300,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _productos.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppDimensions.spacingMd),
                itemBuilder: (context, index) {
                  return _tarjetaProducto(_productos[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _tarjetaProducto(SitioProductoModel producto) {
    final imagen = producto.imagenPrincipal.trim();

    return SizedBox(
      width: 220,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 135,
              width: double.infinity,
              child: imagen.isEmpty
                  ? _imagenAlternativa()
                  : Image.network(
                      imagen,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imagenAlternativa(),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.categoria,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      producto.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Expanded(
                      child: Text(
                        producto.descripcion.trim().isEmpty
                            ? 'Producto del establecimiento.'
                            : producto.descripcion.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Text(
                      '\$ ${producto.precio.toStringAsFixed(0)} COP',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagenAlternativa() {
    return Container(
      color: AppColors.divider,
      alignment: Alignment.center,
      child: const Icon(
        Icons.inventory_2_outlined,
        size: 42,
        color: AppColors.primary,
      ),
    );
  }

  Widget _mensajeEstado({
    required IconData icono,
    required String mensaje,
    required String detalle,
    bool mostrarReintento = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icono, size: 36, color: AppColors.primary),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(detalle, textAlign: TextAlign.center),
          if (mostrarReintento) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            OutlinedButton.icon(
              onPressed: _cargarProductos,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar de nuevo'),
            ),
          ],
        ],
      ),
    );
  }
}
