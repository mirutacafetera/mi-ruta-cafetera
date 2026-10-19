
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
  State<SitioProductosScreen> createState() =>
      _SitioProductosScreenState();
}

class _SitioProductosScreenState extends State<SitioProductosScreen> {
  final SitioProductosService _productosService =
      SitioProductosService();

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

      if (sesion == null ||
          sesion.token.isEmpty ||
          sesion.sitioId.isEmpty) {
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
        _error = null;
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

  Future<void> _mostrarFormulario({
    SitioProductoModel? producto,
  }) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: !_guardando,
      builder: (_) => FormularioProductoSitio(
        producto: producto,
        onGuardar: ({
          required String nombre,
          required String descripcion,
          required double precio,
          required String categoria,
          required List<XFile> imagenes,
          required List<String> imagenesConservar,
          required String imagenPrincipalActual,
        }) async {
          await _guardarProducto(
            producto: producto,
            nombre: nombre,
            descripcion: descripcion,
            precio: precio,
            categoria: categoria,
            imagenes: imagenes,
            imagenesConservar: imagenesConservar,
            imagenPrincipalActual: imagenPrincipalActual,
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
    required List<String> imagenesConservar,
    required String imagenPrincipalActual,
  }) async {
    if (_token.isEmpty || _sitioId.isEmpty) {
      throw Exception('No hay una sesión activa del sitio.');
    }

    if (mounted) {
      setState(() => _guardando = true);
    }

    try {
      final imagenesOriginales = <String>{
        if (producto != null && producto.imagenPrincipal.isNotEmpty)
          producto.imagenPrincipal,
        ...?producto?.imagenes,
      };

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

      Set<String> obtenerUrls(SitioProductoModel productoActual) {
        return {
          if (productoActual.imagenPrincipal.isNotEmpty)
            productoActual.imagenPrincipal,
          ...productoActual.imagenes.where((url) => url.isNotEmpty),
        };
      }

      var urlsDisponibles = obtenerUrls(guardado);

      final imagenesNuevas = urlsDisponibles
          .where((url) => !imagenesOriginales.contains(url))
          .toList();

      var principalDeseada = imagenPrincipalActual.trim();

      if (principalDeseada.isEmpty ||
          !urlsDisponibles.contains(principalDeseada)) {
        principalDeseada = '';

        for (final url in imagenesConservar) {
          if (urlsDisponibles.contains(url)) {
            principalDeseada = url;
            break;
          }
        }
      }

      if (principalDeseada.isEmpty && imagenesNuevas.isNotEmpty) {
        principalDeseada = imagenesNuevas.first;
      }

      if (principalDeseada.isEmpty && urlsDisponibles.isNotEmpty) {
        principalDeseada = urlsDisponibles.first;
      }

      if (principalDeseada.isEmpty) {
        throw Exception('El producto debe tener al menos una imagen.');
      }

      if (guardado.imagenPrincipal != principalDeseada) {
        if (!guardado.imagenes.contains(principalDeseada)) {
          throw Exception(
            'No se pudo establecer la imagen principal seleccionada.',
          );
        }

        guardado = await _productosService.establecerImagenPrincipal(
          token: _token,
          sitioId: _sitioId,
          productoId: guardado.id,
          url: principalDeseada,
        );

        urlsDisponibles = obtenerUrls(guardado);
      }

      if (producto != null) {
        final urlsPorEliminar = imagenesOriginales
            .where((url) => !imagenesConservar.contains(url))
            .toList();

        for (final url in urlsPorEliminar) {
          if (url == guardado.imagenPrincipal) {
            throw Exception(
              'No se puede eliminar una imagen que continúa siendo '
              'la principal. Selecciona otra imagen principal.',
            );
          }

          if (!urlsDisponibles.contains(url)) {
            continue;
          }

          guardado = await _productosService.eliminarImagen(
            token: _token,
            sitioId: _sitioId,
            productoId: guardado.id,
            url: url,
          );

          urlsDisponibles = obtenerUrls(guardado);
        }
      }

      if (mounted) {
        _mostrarMensaje(
          producto == null
              ? 'Producto creado correctamente.'
              : 'Producto actualizado correctamente.',
        );
      }
    } catch (error) {
      if (mounted) {
        _mostrarMensaje(
          error.toString().replaceFirst('Exception: ', ''),
          esError: true,
        );
      }

      rethrow;
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Future<void> _enviarARevision(
    SitioProductoModel producto,
  ) async {
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

  Future<void> _eliminarProducto(
    SitioProductoModel producto,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.sitioSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Eliminar producto',
          style: TextStyle(
            color: AppColors.sitioTextPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          '¿Deseas eliminar definitivamente "${producto.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
          style: const TextStyle(
            color: AppColors.sitioTextSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.sitioTextSecondary),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sitioError,
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

  void _mostrarMensaje(
    String mensaje, {
    bool esError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(mensaje),
          backgroundColor: esError
              ? AppColors.sitioError
              : AppColors.sitioPrimary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esDesktop = constraints.maxWidth >= 900;

        return Container(
          color: AppColors.sitioBackground,
          child: RefreshIndicator(
            color: AppColors.sitioPrimary,
            onRefresh: _cargarProductos,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(
                esDesktop
                    ? AppDimensions.sitioPagePadding
                    : AppDimensions.sitioPagePaddingCompact,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _encabezado(esDesktop),
                      const SizedBox(height: 20),
                      _resumen(esDesktop),
                      const SizedBox(height: 24),
                      TarjetaSeccionSitio(
                        titulo: 'Catálogo de productos',
                        subtitulo:
                            'Administra los productos que los visitantes '
                            'pueden conocer en tu sitio turístico.',
                        icono: Icons.inventory_2_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: esDesktop ? null : double.infinity,
                              child: Align(
                                alignment: esDesktop
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: ElevatedButton.icon(
                                  onPressed: _guardando || _cargando
                                      ? null
                                      : () => _mostrarFormulario(),
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Nuevo producto'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.sitioPrimary,
                                    foregroundColor:
                                        AppColors.sitioTextOnPrimary,
                                    minimumSize: const Size(0, 46),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _contenidoProductos(esDesktop),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
                      color: AppColors.sitioTextPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Organiza tu catálogo y envía tus productos para aprobación.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.sitioTextSecondary,
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
        if (esDesktop)
          IconButton(
            onPressed: _cargando ? null : _cargarProductos,
            tooltip: 'Actualizar catálogo',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.sitioSurface,
              foregroundColor: AppColors.sitioPrimary,
            ),
            icon: const Icon(Icons.refresh_rounded),
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
          const SizedBox(width: 14),
          Expanded(child: tarjetas[1]),
          const SizedBox(width: 14),
          Expanded(child: tarjetas[2]),
        ],
      );
    }

    if (MediaQuery.sizeOf(context).width >= 600) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: tarjetas.map((tarjeta) {
          return SizedBox(
            width: (MediaQuery.sizeOf(context).width - 80) / 2,
            child: tarjeta,
          );
        }).toList(),
      );
    }

    return Column(
      children: [
        tarjetas[0],
        const SizedBox(height: 12),
        tarjetas[1],
        const SizedBox(height: 12),
        tarjetas[2],
      ],
    );
  }

  Widget _contenidoProductos(bool esDesktop) {
    if (_cargando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            color: AppColors.sitioPrimary,
          ),
        ),
      );
    }

    if (_error != null) {
      return _estadoCatalogo(
        icono: Icons.cloud_off_rounded,
        titulo: 'No fue posible cargar los productos',
        descripcion: _error!,
        accion: OutlinedButton.icon(
          onPressed: _cargarProductos,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Intentar nuevamente'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.sitioPrimary,
            side: const BorderSide(color: AppColors.sitioBorder),
          ),
        ),
      );
    }

    if (_productos.isEmpty) {
      return _estadoCatalogo(
        icono: Icons.inventory_2_outlined,
        titulo: 'Tu catálogo está esperando sus primeros productos',
        descripcion:
            'Agrega los productos de tu sitio para que los visitantes '
            'puedan conocerlos.',
        accion: ElevatedButton.icon(
          onPressed: _guardando ? null : () => _mostrarFormulario(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Crear primer producto'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.sitioPrimary,
            foregroundColor: AppColors.sitioTextOnPrimary,
          ),
        ),
      );
    }

    return Column(
      children: _productos.map((producto) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _tarjetaProducto(producto, esDesktop),
        );
      }).toList(),
    );
  }

  Widget _estadoCatalogo({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Widget accion,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.sitioBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: const BoxDecoration(
              color: AppColors.sitioSurfaceGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icono,
              color: AppColors.sitioPrimary,
              size: 31,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.sitioTextPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            descripcion,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.sitioTextSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          accion,
        ],
      ),
    );
  }

  Widget _tarjetaProducto(
    SitioProductoModel producto,
    bool esDesktop,
  ) {
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
        ? AppColors.sitioSuccess
        : pendiente
            ? AppColors.sitioWarning
            : rechazado
                ? AppColors.sitioError
                : AppColors.sitioTextSecondary;

    final fondoEstado = publicado
        ? AppColors.sitioSuccessSoft
        : pendiente
            ? AppColors.sitioWarningSoft
            : rechazado
                ? AppColors.sitioErrorSoft
                : AppColors.sitioSurfaceSoft;

    final acciones = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: _guardando
              ? null
              : () => _mostrarFormulario(producto: producto),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Editar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.sitioPrimary,
            side: const BorderSide(color: AppColors.sitioBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (!pendiente && !publicado)
          ElevatedButton.icon(
            onPressed: _guardando
                ? null
                : () => _enviarARevision(producto),
            icon: const Icon(Icons.send_outlined, size: 18),
            label: const Text('Enviar a revisión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sitioPrimary,
              foregroundColor: AppColors.sitioTextOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        OutlinedButton.icon(
          onPressed: _guardando
              ? null
              : () => _eliminarProducto(producto),
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          label: const Text('Eliminar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.sitioError,
            side: const BorderSide(color: AppColors.sitioError),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sitioSurface,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        border: Border.all(color: AppColors.sitioBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: esDesktop ? 142 : 100,
                  height: esDesktop ? 142 : 112,
                  child: producto.imagenPrincipal.isNotEmpty
                      ? Image.network(
                          producto.imagenPrincipal,
                          fit: BoxFit.cover,
                          errorBuilder: (_, error, stackTrace) =>
                              const _ImagenProductoVacia(),
                        )
                      : const _ImagenProductoVacia(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.sitioTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      producto.categoria,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.sitioTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '\$${producto.precio.toStringAsFixed(0)} COP',
                      style: const TextStyle(
                        color: AppColors.sitioPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: fondoEstado,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: colorEstado,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              etiquetaEstado,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorEstado,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (producto.descripcion.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              producto.descripcion,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.sitioTextSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
          if (rechazado && producto.motivoRechazo.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.sitioErrorSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.sitioError,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Motivo del rechazo: ${producto.motivoRechazo}',
                      style: const TextStyle(
                        color: AppColors.sitioError,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(color: AppColors.sitioDivider, height: 1),
          const SizedBox(height: 12),
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
      color: AppColors.sitioSurfaceGreen,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 34,
        color: AppColors.sitioPrimary,
      ),
    );
  }
}
