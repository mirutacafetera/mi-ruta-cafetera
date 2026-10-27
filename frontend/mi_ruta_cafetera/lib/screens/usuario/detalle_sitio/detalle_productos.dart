
import 'package:flutter/material.dart';

import '../../../models/sitio/sitio_producto_model.dart';
import '../../../services/sitio/sitio_productos_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../l10n/textos.dart';
import '../../../widgets/usuario/detalle_sitio/componentes_detalle.dart';
import '../../../widgets/usuario/detalle_sitio/panel_detalle_adaptable.dart';

class DetalleProductos extends StatefulWidget {
  const DetalleProductos({
    super.key,
    required this.sitioId,
    this.mostrarEncabezado = true,
  });

  final String sitioId;

  /// Cuando la pantalla que lo contiene ya dibuja el encabezado
  /// de la sección, se envía `false` para no repetirlo.
  final bool mostrarEncabezado;

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
        _error = Textos.t('No se pudo identificar el sitio turístico.');
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

  void _abrirDetalle(SitioProductoModel producto) {
    final imagenes = unirImagenesDetalle(
      producto.imagenPrincipal,
      producto.imagenes,
    );

    PanelDetalleAdaptable.mostrar<void>(
      context: context,
      titulo: producto.nombre,
      icono: Icons.storefront_outlined,
      maxWidth: 820,
      builder: (_) => _ContenidoDetalleProducto(
        producto: producto,
        imagenes: imagenes,
      ),
    );
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
          if (widget.mostrarEncabezado) ...[
            EncabezadoSeccionDetalle(
              icono: Icons.storefront_outlined,
              titulo: Textos.t('Productos de este sitio'),
              descripcion: Textos.t(
                'Descubre los productos que ofrece este establecimiento.',
              ),
              padding: EdgeInsets.zero,
              trailing: (!_cargando && _productos.isNotEmpty)
                  ? EtiquetaDetalle(texto: '${_productos.length}')
                  : null,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
          ],
          if (_cargando)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.spacingXxl),
                child: CircularProgressIndicator(
                  color: AppColors.sitioPrimary,
                ),
              ),
            )
          else if (_error != null)
            TarjetaEstadoDetalle(
              icono: Icons.cloud_off_outlined,
              titulo: Textos.t('No pudimos cargar los productos.'),
              descripcion: _error!,
              accion: OutlinedButton.icon(
                onPressed: _cargarProductos,
                icon: const Icon(Icons.refresh),
                label: const Tr('Intentar de nuevo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.sitioPrimary,
                  side: const BorderSide(color: AppColors.sitioPrimary),
                ),
              ),
            )
          else if (_productos.isEmpty)
            TarjetaEstadoDetalle(
              icono: Icons.inventory_2_outlined,
              titulo: Textos.t('Todavía no hay productos publicados.'),
              descripcion: Textos.t(
                'Cuando el establecimiento publique sus productos aprobados, aparecerán aquí.',
              ),
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
    final categoria = producto.categoria.trim();

    return SizedBox(
      width: 220,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: decoracionTarjetaDetalle(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _abrirDetalle(producto),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 135,
                  width: double.infinity,
                  child: imagen.isEmpty
                      ? const PlaceholderImagenDetalle(
                          icono: Icons.inventory_2_outlined,
                          compacto: true,
                        )
                      : Image.network(
                          imagen,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const PlaceholderImagenDetalle(
                            icono: Icons.inventory_2_outlined,
                            compacto: true,
                          ),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (categoria.isNotEmpty) ...[
                          Text(
                            categoria,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.sitioAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingXs),
                        ],
                        Text(
                          producto.nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.sitioTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        Expanded(
                          child: Text(
                            producto.descripcion.trim().isEmpty
                                ? Textos.t('Producto del establecimiento.')
                                : producto.descripcion.trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.sitioTextSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                formatearPrecioCop(producto.precio),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.sitioPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.sitioPrimary,
                              size: AppDimensions.iconSm,
                            ),
                          ],
                        ),
                      ],
                    ),
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

// =====================================================
// CONTENIDO DEL PANEL DE DETALLE DE UN PRODUCTO
// =====================================================

class _ContenidoDetalleProducto extends StatelessWidget {
  const _ContenidoDetalleProducto({
    required this.producto,
    required this.imagenes,
  });

  final SitioProductoModel producto;
  final List<String> imagenes;

  @override
  Widget build(BuildContext context) {
    final categoria = producto.categoria.trim();
    final descripcion = producto.descripcion.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imagenes.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            child: CarruselImagenesDetalle(
              imagenes: imagenes,
              aspectRatio: 4 / 3,
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            child: const AspectRatio(
              aspectRatio: 4 / 3,
              child: PlaceholderImagenDetalle(
                icono: Icons.inventory_2_outlined,
              ),
            ),
          ),
        const SizedBox(height: AppDimensions.spacingLg),
        if (categoria.isNotEmpty) ...[
          EtiquetaDetalle(
            texto: categoria,
            icono: Icons.local_cafe_outlined,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
        ],
        FilaDatoDetalle(
          icono: Icons.sell_outlined,
          titulo: Textos.t('Precio'),
          valor: formatearPrecioCop(producto.precio),
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        EncabezadoSeccionDetalle(
          icono: Icons.description_outlined,
          titulo: Textos.t('Descripción del producto'),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          descripcion.isEmpty
              ? Textos.t('No hay una descripción adicional disponible.')
              : descripcion,
          style: const TextStyle(
            color: AppColors.sitioTextSecondary,
            fontSize: 15,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}
