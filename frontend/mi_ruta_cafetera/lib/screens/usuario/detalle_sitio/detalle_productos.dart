
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
  final bool mostrarEncabezado;

  @override
  State<DetalleProductos> createState() => _DetalleProductosState();
}

class _DetalleProductosState extends State<DetalleProductos> {
  final SitioProductosService _productosService = SitioProductosService();

  List<SitioProductoModel> _productos = [];
  bool _cargando = true;
  String? _error;

  static const double _anchoTarjeta = 175;
  static const double _altoLista = 215;

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

  // =====================================================
  // SEPARADOR DE LA SECCIÓN DE PRODUCTOS
  // MISMO DISEÑO Y COLORES DE ACTIVIDADES
  // =====================================================

  Widget _construirSeparadorProductos() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.adminBorder.withValues(alpha: 0.45),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.sitioSurfaceSoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.adminBorder.withValues(alpha: 0.60),
                width: 0.5,
              ),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: AppColors.sitioAccent,
              size: 19,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.adminBorder.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ENCABEZADO DE PRODUCTOS
  // =====================================================

  Widget _construirEncabezadoProductos() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 54,
            height: 76,
            child: Center(
              child: Icon(
                Icons.storefront_outlined,
                color: AppColors.sitioAccent,
                size: 34,
              ),
            ),
          ),
          Container(
            width: 2,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.sitioPrimary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Textos.t('Productos de este sitio'),
                  style: const TextStyle(
                    color: AppColors.sitioPrimaryDark,
                    fontSize: 18,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  Textos.t(
                    'Descubre los productos que ofrece este establecimiento.',
                  ),
                  style: const TextStyle(
                    color: AppColors.sitioTextSecondary,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.pageHorizontal,
        right: AppDimensions.pageHorizontal,
        top: AppDimensions.spacingLg,
        bottom: AppDimensions.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.mostrarEncabezado) ...[
            const SizedBox(height: AppDimensions.spacingSm),

            _construirSeparadorProductos(),

            const SizedBox(height: AppDimensions.spacingLg),

            _construirEncabezadoProductos(),

            const SizedBox(height: AppDimensions.spacingLg),
          ],

          if (_cargando)
            const Padding(
              padding: EdgeInsets.all(AppDimensions.spacingXxl),
              child: Center(
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
                  side: const BorderSide(
                    color: AppColors.sitioPrimary,
                  ),
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
              height: _altoLista,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: _productos.length,
                separatorBuilder: (_, _) => const SizedBox(
                  width: AppDimensions.spacingMd,
                ),
                itemBuilder: (context, index) {
                  return _tarjetaProducto(_productos[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  // =====================================================
  // TARJETA DE PRODUCTO
  // =====================================================

  Widget _tarjetaProducto(SitioProductoModel producto) {
    final imagen = producto.imagenPrincipal.trim();
    final categoria = producto.categoria.trim();
    final nombre = producto.nombre.trim();
    final descripcion = producto.descripcion.trim();

    final precio = producto.precio > 0
        ? 'Precio: ${formatearPrecioCop(producto.precio)}'
        : 'Precio: por consultar';

    return SizedBox(
      width: _anchoTarjeta,
      child: Container(
        decoration: decoracionTarjetaDetalle().copyWith(
          border: Border.all(
            color: AppColors.adminBorder.withValues(alpha: 0.60),
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.all(1),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius - 1,
          ),
          child: Material(
            color: AppColors.sitioSurface,
            child: InkWell(
              onTap: () => _abrirDetalle(producto),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IMAGEN
                  SizedBox(
                    height: 96,
                    width: double.infinity,
                    child: imagen.isNotEmpty
                        ? Image.network(
                            imagen,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const _FondoProducto(),
                          )
                        : const _FondoProducto(),
                  ),

                  // INFORMACIÓN DEL PRODUCTO
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        9,
                        8,
                        9,
                        8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CATEGORÍA
                          if (categoria.isNotEmpty) ...[
                            Text(
                              categoria,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.sitioAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                          ],

                          // NOMBRE
                          Text(
                            nombre.isNotEmpty
                                ? nombre
                                : Textos.t('Producto turístico'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.sitioTextPrimary,
                              fontSize: 12,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // DESCRIPCIÓN
                          Expanded(
                            child: Text(
                              descripcion.isNotEmpty
                                  ? descripcion
                                  : Textos.t(
                                      'Producto del establecimiento.',
                                    ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.sitioTextSecondary,
                                fontSize: 10,
                                height: 1.35,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),

                          // PRECIO CON ÍCONO DE TIQUETE Y BOTÓN
                          Row(
                            children: [
                              const Icon(
                                Icons.confirmation_number_outlined,
                                color: AppColors.sitioPrimary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  precio,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.sitioPrimaryDark,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Material(
                                color: AppColors.sitioPrimary,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  onTap: () => _abrirDetalle(producto),
                                  customBorder: const CircleBorder(),
                                  child: const SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: AppColors.sitioTextOnPrimary,
                                      size: 15,
                                    ),
                                  ),
                                ),
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
      ),
    );
  }
}

// =====================================================
// IMAGEN ALTERNATIVA DEL PRODUCTO
// =====================================================

class _FondoProducto extends StatelessWidget {
  const _FondoProducto();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sitioSurfaceGreen,
      alignment: Alignment.center,
      child: const Icon(
        Icons.storefront_outlined,
        size: 40,
        color: AppColors.sitioPrimary,
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
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusLg,
            ),
            child: CarruselImagenesDetalle(
              imagenes: imagenes,
              aspectRatio: 4 / 3,
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusLg,
            ),
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
              ? Textos.t(
                  'No hay una descripción adicional disponible.',
                )
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
