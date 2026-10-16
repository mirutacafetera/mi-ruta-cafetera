import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/sitio/sitio_producto_model.dart';
import '../../services/sitio/sitio_productos_service.dart';
import '../../services/sitio/sitio_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/sitio/formulario_producto_sitio.dart';
import '../../widgets/sitio/tarjeta_resumen_sitio.dart';
import '../../widgets/sitio/tarjeta_seccion_sitio.dart';

class SitioProductosScreen extends StatefulWidget {
  const SitioProductosScreen({super.key});

  @override
  State<SitioProductosScreen> createState() => _SitioProductosScreenState();
}

class _SitioProductosScreenState extends State<SitioProductosScreen> {
  final SitioProductosService _productosService = SitioProductosService();
  final SitioSesionService _sesionService = SitioSesionService();

  List<SitioProductoModel> _productos = [];
  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  String _token = '';
  String _sitioId = '';

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    if (mounted) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }

    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty || sesion.sitioId.isEmpty) {
        throw Exception('No se encontró una sesión activa del sitio.');
      }

      if (!sesion.activo) {
        throw Exception('La cuenta del sitio está inactiva.');
      }

      _token = sesion.token;
      _sitioId = sesion.sitioId;

      final productos = await _productosService.obtenerProductos(
        token: _token,
        sitioId: _sitioId,
      );

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

  int get _cantidadPublicados => _productos
      .where((p) => p.estadoPublicacion == 'aprobado' && p.activo)
      .length;

  int get _cantidadEnRevision => _productos
      .where((p) => p.estadoPublicacion == 'pendiente_revision')
      .length;

  Future<void> _mostrarFormulario({SitioProductoModel? producto}) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: !_guardando,
      builder: (_) => FormularioProductoSitio(
        producto: producto,
        onGuardar:
            ({
              required String nombre,
              required String descripcion,
              required double precio,
              required String categoria,
              required List<XFile> imagenes,
            }) async {
              await _guardarProducto(
                producto: producto,
                nombre: nombre,
                descripcion: descripcion,
                precio: precio,
                categoria: categoria,
                imagenes: imagenes,
              );
            },
      ),
    );

    if (mounted) {
      await _cargarProductos();
    }
  }

  Future<void> _guardarProducto({
    SitioProductoModel? producto,
    required String nombre,
    required String descripcion,
    required double precio,
    required String categoria,
    required List<XFile> imagenes,
  }) async {
    if (_token.isEmpty || _sitioId.isEmpty) {
      throw Exception('No hay una sesión activa del sitio.');
    }

    if (mounted) {
      setState(() => _guardando = true);
    }

    try {
      late SitioProductoModel guardado;

      if (producto == null) {
        guardado = await _productosService.crearProducto(
          token: _token,
          sitioId: _sitioId,
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          categoria: categoria,
        );
      } else {
        guardado = await _productosService.actualizarProducto(
          token: _token,
          sitioId: _sitioId,
          productoId: producto.id,
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          categoria: categoria,
        );
      }

      if (imagenes.isNotEmpty) {
        guardado = await _productosService.subirImagenes(
          token: _token,
          sitioId: _sitioId,
          productoId: guardado.id,
          archivos: imagenes,
        );
      }

      if (guardado.imagenPrincipal.isEmpty && guardado.imagenes.isNotEmpty) {
        guardado = await _productosService.establecerImagenPrincipal(
          token: _token,
          sitioId: _sitioId,
          productoId: guardado.id,
          url: guardado.imagenes.first,
        );
      }

      if (mounted) {
        _mostrarMensaje(
          producto == null
              ? 'Producto creado correctamente.'
              : 'Producto actualizado correctamente.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Future<void> _enviarARevision(SitioProductoModel producto) async {
    if (_token.isEmpty || _sitioId.isEmpty) return;

    try {
      await _productosService.enviarARevision(
        token: _token,
        sitioId: _sitioId,
        productoId: producto.id,
      );

      if (!mounted) return;

      _mostrarMensaje('El producto fue enviado a revisión.');
      await _cargarProductos();
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );
    }
  }

  Future<void> _eliminarProducto(SitioProductoModel producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Deseas eliminar definitivamente "${producto.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() => _guardando = true);

    try {
      await _productosService.eliminarProducto(
        token: _token,
        sitioId: _sitioId,
        productoId: producto.id,
      );

      if (!mounted) return;

      _mostrarMensaje('Producto eliminado correctamente.');
      await _cargarProductos();
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final esDesktop = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: esDesktop
                ? AppDimensions.pageHorizontal
                : AppDimensions.pageHorizontalSmall,
            vertical: AppDimensions.spacingLg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _encabezado(esDesktop),
                  const SizedBox(height: AppDimensions.spacingLg),
                  _resumen(esDesktop),
                  const SizedBox(height: AppDimensions.sectionGap),
                  TarjetaSeccionSitio(
                    titulo: 'Catálogo de productos',
                    subtitulo:
                        'Administra los productos que los visitantes pueden '
                        'conocer en tu sitio turístico.',
                    icono: Icons.inventory_2_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: esDesktop
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: _guardando || _cargando
                                ? null
                                : () => _mostrarFormulario(),
                            icon: const Icon(Icons.add),
                            label: const Text('Nuevo producto'),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingLg),
                        _contenidoProductos(esDesktop),
                      ],
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

  Widget _encabezado(bool esDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Productos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                'Organiza tu catálogo y envía tus productos para aprobación.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (esDesktop)
          IconButton(
            onPressed: _cargando ? null : _cargarProductos,
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
          ),
      ],
    );
  }

  Widget _resumen(bool esDesktop) {
    final tarjetas = [
      TarjetaResumenSitio(
        titulo: 'Total',
        valor: _productos.length.toString(),
        descripcion: 'Productos registrados',
        icono: Icons.inventory_2_rounded,
      ),
      TarjetaResumenSitio(
        titulo: 'Publicados',
        valor: _cantidadPublicados.toString(),
        descripcion: 'Visibles para visitantes',
        icono: Icons.check_circle_outline_rounded,
      ),
      TarjetaResumenSitio(
        titulo: 'En revisión',
        valor: _cantidadEnRevision.toString(),
        descripcion: 'Pendientes de aprobación',
        icono: Icons.hourglass_empty_rounded,
      ),
    ];

    if (esDesktop) {
      return Row(
        children: [
          Expanded(child: tarjetas[0]),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(child: tarjetas[1]),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(child: tarjetas[2]),
        ],
      );
    }

    return Column(
      children: [
        tarjetas[0],
        const SizedBox(height: AppDimensions.spacingMd),
        tarjetas[1],
        const SizedBox(height: AppDimensions.spacingMd),
        tarjetas[2],
      ],
    );
  }

  Widget _contenidoProductos(bool esDesktop) {
    if (_cargando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spacingXl),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Column(
        children: [
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          OutlinedButton.icon(
            onPressed: _cargarProductos,
            icon: const Icon(Icons.refresh),
            label: const Text('Intentar nuevamente'),
          ),
        ],
      );
    }

    if (_productos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.spacingXl),
        child: Center(child: Text('Aún no tienes productos registrados.')),
      );
    }

    return Column(
      children: _productos.map((producto) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
          child: _tarjetaProducto(producto, esDesktop),
        );
      }).toList(),
    );
  }

  Widget _tarjetaProducto(SitioProductoModel producto, bool esDesktop) {
    final estado = producto.estadoPublicacion;
    final publicado = estado == 'aprobado' && producto.activo;
    final pendiente = estado == 'pendiente_revision';
    final rechazado = estado == 'rechazado';

    final etiquetaEstado = publicado
        ? 'Publicado'
        : pendiente
        ? 'En revisión'
        : rechazado
        ? 'Rechazado'
        : 'Borrador';

    final colorEstado = publicado
        ? AppColors.primary
        : rechazado
        ? AppColors.error
        : AppColors.textSecondary;

    final acciones = Wrap(
      spacing: AppDimensions.spacingSm,
      runSpacing: AppDimensions.spacingSm,
      children: [
        OutlinedButton.icon(
          onPressed: _guardando
              ? null
              : () => _mostrarFormulario(producto: producto),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar'),
        ),
        if (!pendiente && !publicado)
          ElevatedButton.icon(
            onPressed: _guardando ? null : () => _enviarARevision(producto),
            icon: const Icon(Icons.send_outlined),
            label: const Text('Enviar a revisión'),
          ),
        OutlinedButton.icon(
          onPressed: _guardando ? null : () => _eliminarProducto(producto),
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Eliminar'),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: SizedBox(
                  width: esDesktop ? 150 : 100,
                  height: esDesktop ? 130 : 100,
                  child: producto.imagenPrincipal.isNotEmpty
                      ? Image.network(
                          producto.imagenPrincipal,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const _ImagenProductoVacia(),
                        )
                      : const _ImagenProductoVacia(),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      producto.categoria,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Text(
                      '\$${producto.precio.toStringAsFixed(0)} COP',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colorEstado.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusPill,
                        ),
                      ),
                      child: Text(
                        etiquetaEstado,
                        style: TextStyle(
                          color: colorEstado,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (producto.descripcion.trim().isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              producto.descripcion,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
          if (rechazado && producto.motivoRechazo.trim().isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              'Motivo del rechazo: ${producto.motivoRechazo}',
              style: const TextStyle(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppDimensions.spacingMd),
          acciones,
        ],
      ),
    );
  }
}

class _ImagenProductoVacia extends StatelessWidget {
  const _ImagenProductoVacia();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 36,
        color: AppColors.textSecondary,
      ),
    );
  }
}
