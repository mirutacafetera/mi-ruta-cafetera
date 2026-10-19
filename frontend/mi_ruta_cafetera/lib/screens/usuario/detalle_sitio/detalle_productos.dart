
import 'package:flutter/material.dart';

import '../../../models/sitio/sitio_producto_model.dart';
import '../../../services/sitio/sitio_productos_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class DetalleProductos extends StatefulWidget {
  const DetalleProductos({
    super.key,
    required this.sitioId,
  });

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

  void _abrirDetalle(SitioProductoModel producto) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _DetalleProductoScreen(producto: producto),
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
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
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
        child: InkWell(
          onTap: () => _abrirDetalle(producto),
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
                          color: AppColors.textPrimary,
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
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '\$ ${producto.precio.toStringAsFixed(0)} COP',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.primary,
                            size: 18,
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

class _DetalleProductoScreen extends StatefulWidget {
  const _DetalleProductoScreen({
    required this.producto,
  });

  final SitioProductoModel producto;

  @override
  State<_DetalleProductoScreen> createState() =>
      _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<_DetalleProductoScreen> {
  final PageController _pageController = PageController();

  int _indiceActual = 0;

  List<String> get _imagenes {
    final resultado = <String>[];
    final principal = widget.producto.imagenPrincipal.trim();

    if (principal.isNotEmpty) {
      resultado.add(principal);
    }

    for (final imagen in widget.producto.imagenes) {
      final url = imagen.trim();

      if (url.isNotEmpty && !resultado.contains(url)) {
        resultado.add(url);
      }
    }

    return resultado;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final imagenes = _imagenes;
    final categoria = producto.categoria.trim();

    return Scaffold(
      backgroundColor: AppColors.sitioBackground,
      appBar: AppBar(
        backgroundColor: AppColors.sitioPrimaryDark,
        foregroundColor: Colors.white,
        title: const Text('Detalle del producto'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagenes.isNotEmpty)
              _carrusel(imagenes)
            else
              AspectRatio(
                aspectRatio: 4 / 3,
                child: _imagenAlternativaDetalle(),
              ),
            Padding(
              padding: const EdgeInsets.all(
                AppDimensions.pageHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (categoria.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sitioSurfaceGreen,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.sitioPrimary.withValues(
                            alpha: 0.22,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_cafe_outlined,
                            size: 16,
                            color: AppColors.sitioPrimary,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            categoria,
                            style: const TextStyle(
                              color: AppColors.sitioPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                  ],
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      color: AppColors.sitioTextPrimary,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(
                      AppDimensions.spacingLg,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sitioSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.sitioBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.sell_outlined,
                              color: AppColors.sitioAccent,
                              size: 22,
                            ),
                            SizedBox(width: AppDimensions.spacingSm),
                            Text(
                              'Precio',
                              style: TextStyle(
                                color: AppColors.sitioTextSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(
                          '\$ ${producto.precio.toStringAsFixed(0)} COP',
                          style: const TextStyle(
                            color: AppColors.sitioPrimary,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),
                  const Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: AppColors.sitioPrimary,
                        size: 23,
                      ),
                      SizedBox(width: AppDimensions.spacingSm),
                      Expanded(
                        child: Text(
                          'Descripción del producto',
                          style: TextStyle(
                            color: AppColors.sitioPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    producto.descripcion.trim().isEmpty
                        ? 'No hay una descripción adicional disponible.'
                        : producto.descripcion.trim(),
                    style: const TextStyle(
                      color: AppColors.sitioTextSecondary,
                      fontSize: 15,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carrusel(List<String> imagenes) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: imagenes.length,
                onPageChanged: (index) {
                  setState(() => _indiceActual = index);
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    imagenes[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _imagenAlternativaDetalle(),
                  );
                },
              ),
              if (imagenes.length > 1)
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_indiceActual + 1} / ${imagenes.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (imagenes.length > 1)
          SizedBox(
            height: 88,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pageHorizontal,
                vertical: 10,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: imagenes.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppDimensions.spacingSm),
              itemBuilder: (context, index) {
                final seleccionada = _indiceActual == index;

                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Container(
                    width: 76,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: seleccionada
                            ? AppColors.sitioPrimary
                            : AppColors.sitioBorder,
                        width: seleccionada ? 3 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      imagenes[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imagenAlternativaDetalle(),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _imagenAlternativaDetalle() {
    return Container(
      color: AppColors.sitioSurfaceGreen,
      alignment: Alignment.center,
      child: const Icon(
        Icons.inventory_2_outlined,
        color: AppColors.sitioPrimary,
        size: 48,
      ),
    );
  }
}
