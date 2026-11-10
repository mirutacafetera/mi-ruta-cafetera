
import 'package:flutter/material.dart';

import '../../models/contenido_model.dart';
import '../../models/sitio_turistico_model.dart';
import '../../models/sitio/sitio_actividad_model.dart';
import '../../services/contenido_service.dart';
import '../../services/sitio_service.dart';
import '../../services/sitio/sitio_actividades_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/navegacion/boton_regresar.dart';
import '../../widgets/usuario/seccion_contenido_sitio.dart';
import 'detalle_sitio/detalle_portada.dart';
import 'detalle_sitio/detalle_ubicacion.dart';
import 'detalle_sitio/detalle_actividades.dart';
import 'detalle_sitio/detalle_galeria.dart';
import 'detalle_sitio/detalle_sitio_audio.dart';
import 'detalle_sitio/detalle_sitio_acciones.dart';
import 'detalle_sitio/detalle_productos.dart';
import 'detalle_sitio/reproductor_historia/reproductor_historia_flotante.dart';
import 'detalle_sitio/seccion_resenas_sitio.dart';
import '../../l10n/textos.dart';
import '../../widgets/usuario/detalle_sitio/componentes_detalle.dart';

class DetalleSitioUsuarioScreen extends StatefulWidget {
  const DetalleSitioUsuarioScreen({
    super.key,
    required this.sitio,
    this.imagen,
    this.esFavorito = false,
    this.onFavorite,
    this.onRequiereCuenta,
  });

  final SitioTuristicoModel sitio;
  final String? imagen;
  final bool esFavorito;
  final Future<void> Function()? onFavorite;
  final VoidCallback? onRequiereCuenta;

  @override
  State<DetalleSitioUsuarioScreen> createState() =>
      _DetalleSitioUsuarioScreenState();
}

class _DetalleSitioUsuarioScreenState
    extends State<DetalleSitioUsuarioScreen> {
  final ContenidoService _contenidoService = ContenidoService.instance;

  final SitioActividadesService _actividadesService =
      SitioActividadesService();

  late final DetalleSitioAudio _audioController;
  late bool _esFavorito;
  late SitioTuristicoModel _sitio;

  List<ContenidoModel> _contenidos = [];
  List<SitioActividadModel> _actividades = [];

  bool _cargandoContenido = true;
  bool _cargandoActividades = true;
  bool _procesandoFavorito = false;

  String? _errorContenido;

  @override
  void initState() {
    super.initState();

    _sitio = widget.sitio;
    _esFavorito = widget.esFavorito;
    _audioController = DetalleSitioAudio();

    _refrescarSitio();
    _cargarContenido();
    _cargarActividades();
  }

  Future<void> _refrescarSitio() async {
    try {
      final actualizado = await SitioService().obtenerSitioPorId(
        widget.sitio.id,
      );

      if (!mounted) return;

      setState(() {
        _sitio = actualizado;
      });
    } catch (_) {
      // Si falla, se mantienen los datos con los que se abrió la pantalla.
    }
  }

  Future<void> _cargarContenido() async {
    setState(() {
      _cargandoContenido = true;
      _errorContenido = null;
    });

    try {
      final sitioId = _sitio.id.trim();

      if (sitioId.isEmpty) {
        throw Exception('No se pudo identificar el sitio turístico.');
      }

      final resultado = await _contenidoService.obtenerContenidosPorSitio(
        sitioId,
      );

      if (!mounted) return;

      setState(() {
        _contenidos = resultado;
      });
    } catch (e, stackTrace) {
      debugPrint('Error al cargar contenido del sitio: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _errorContenido = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargandoContenido = false;
        });
      }
    }
  }

  Future<void> _cargarActividades() async {
    try {
      final sitioId = _sitio.id.trim();

      if (sitioId.isEmpty) return;

      final resultado = await _actividadesService.obtenerActividadesPublicas(
        sitioId: sitioId,
      );

      if (!mounted) return;

      setState(() {
        _actividades = resultado;
      });
    } catch (e, stackTrace) {
      debugPrint('Error al cargar actividades del sitio: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          _cargandoActividades = false;
        });
      }
    }
  }

  Future<void> _cambiarFavorito() async {
    final accion = widget.onFavorite;

    if (accion == null) {
      widget.onRequiereCuenta?.call();
      return;
    }

    if (_procesandoFavorito) return;

    final anterior = _esFavorito;

    setState(() {
      _esFavorito = !anterior;
      _procesandoFavorito = true;
    });

    try {
      await accion();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _esFavorito = anterior;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _procesandoFavorito = false;
        });
      }
    }
  }

  Future<void> _reproducirAudioguia(ContenidoModel contenido) async {
    try {
      await _audioController.reproducirContenido(contenido);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _cerrarReproductor() {
    return _audioController.cerrar();
  }

  Widget _construirSeccionContenido() {
    if (_cargandoContenido) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.spacingXxl),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.sitioPrimary,
          ),
        ),
      );
    }

    if (_errorContenido != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pageHorizontal,
          vertical: AppDimensions.spacingLg,
        ),
        child: _tarjetaEstado(
          icono: Icons.cloud_off_outlined,
          titulo: Textos.t('No pudimos cargar el contenido'),
          descripcion: _errorContenido!,
          accion: OutlinedButton.icon(
            onPressed: _cargarContenido,
            icon: const Icon(Icons.refresh_rounded),
            label: const Tr('Intentar de nuevo'),
          ),
        ),
      );
    }

    if (_contenidos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pageHorizontal,
          vertical: AppDimensions.spacingLg,
        ),
        child: _tarjetaEstado(
          icono: Icons.auto_stories_outlined,
          titulo: Textos.t('Próximamente habrá nuevas historias'),
          descripcion: Textos.t(
            'Estamos preparando más contenido para que descubras las tradiciones y experiencias de {0}.',
            [_sitio.nombre],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.spacingLg,
      ),
      child: SeccionContenidoSitio(
        contenidos: _contenidos,
        onReproducirAudioguia: _reproducirAudioguia,
      ),
    );
  }

  Widget _tarjetaEstado({
    required IconData icono,
    required String titulo,
    required String descripcion,
    Widget? accion,
  }) {
    return TarjetaEstadoDetalle(
      icono: icono,
      titulo: titulo,
      descripcion: descripcion,
      accion: accion,
    );
  }

  Widget _construirEtiquetas() {
    final etiquetas = _sitio.etiquetas
        .map((etiqueta) => etiqueta.trim())
        .where((etiqueta) => etiqueta.isNotEmpty)
        .toList();

    if (etiquetas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.spacingLg,
        bottom: AppDimensions.spacingSm,
      ),
      child: Wrap(
        spacing: AppDimensions.spacingSm,
        runSpacing: AppDimensions.spacingSm,
        children: etiquetas.map((etiqueta) {
          return EtiquetaDetalle(
            texto: etiqueta,
            icono: Icons.local_offer_outlined,
          );
        }).toList(),
      ),
    );
  }

  // =====================================================
  // ACCIONES DEL SITIO
  // =====================================================

  Widget _construirAcciones() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 66,
            child: OutlinedButton(
              onPressed: () => DetalleSitioAcciones.agregarRuta(
                context,
                _sitio,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.sitioPrimary,
                backgroundColor: AppColors.sitioSurface,
                side: BorderSide(
                  color: AppColors.sitioPrimary.withValues(alpha: 0.65),
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 7,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.route_rounded, size: 19),
                  SizedBox(height: 4),
                  Tr(
                    'Agregar a mi ruta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 66,
            child: OutlinedButton(
              onPressed: () {
                DetalleSitioAcciones.mostrarDetalleMapa(
                  context,
                  _sitio,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.sitioPrimary,
                backgroundColor: AppColors.sitioSurface,
                side: BorderSide(
                  color: AppColors.sitioPrimary.withValues(alpha: 0.65),
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 7,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined, size: 19),
                  SizedBox(height: 4),
                  Tr(
                    'Ver detalles de ubicación',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // ENCABEZADO DE SECCIONES
  // =====================================================

  Widget _construirEncabezadoSeccion({
    required IconData icono,
    required String titulo,
    required String descripcion,
  }) {
    return EncabezadoSeccionDetalle(
      icono: icono,
      titulo: titulo,
      descripcion: descripcion,
    );
  }

  // =====================================================
  // SEPARADOR DE EXPERIENCIAS
  // =====================================================

  Widget _construirSeparadorExperiencias() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
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
              Icons.hiking_rounded,
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
  // ENCABEZADO VISUAL DE EXPERIENCIAS
  // =====================================================

  Widget _construirEncabezadoExperiencias() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 54,
            height: 76,
            child: Center(
              child: Icon(
                Icons.hiking_rounded,
                color: AppColors.sitioAccent,
                size: 42,
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
                  Textos.t('Experiencias para disfrutar'),
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
                    'Conoce las actividades que puedes vivir durante tu visita.',
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

  // =====================================================
  // SEPARADOR DE HISTORIAS Y CONTENIDO
  // =====================================================

  Widget _construirSeparadorHistorias() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
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
              Icons.auto_stories_outlined,
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
  // ENCABEZADO VISUAL DE HISTORIAS
  // =====================================================

  Widget _construirEncabezadoHistorias() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 54,
            height: 76,
            child: Center(
              child: Icon(
                Icons.auto_stories_outlined,
                color: AppColors.sitioAccent,
                size: 42,
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
                  Textos.t('Historias y contenido'),
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
                    'Descubre las historias, tradiciones y experiencias que hacen especial a este lugar.',
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

  // =====================================================
  // SEPARADOR DE GALERÍA
  // =====================================================

  Widget _construirSeparadorGaleria() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
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
              Icons.photo_library_outlined,
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
  // SEPARADOR DE OPINIONES DE VIAJEROS
  // =====================================================

  Widget _construirSeparadorResenas() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
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
              Icons.star_outline_rounded,
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
  // ENCABEZADO VISUAL DE OPINIONES DE VIAJEROS
  // =====================================================

  Widget _construirEncabezadoResenas() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 54,
            height: 76,
            child: Center(
              child: Icon(
                Icons.star_outline_rounded,
                color: AppColors.sitioAccent,
                size: 42,
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
                  Textos.t('Opiniones de viajeros'),
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
                    'Consulta las experiencias y valoraciones de otros visitantes.',
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
    final imagenContenido = _contenidos
        .where((contenido) => contenido.activo)
        .map((contenido) => contenido.imagenPrincipal.trim())
        .firstWhere(
          (url) => url.isNotEmpty,
          orElse: () => '',
        );

    final imagenSitio = _sitio.imagen.trim();

    final imagenPrincipal = imagenSitio.isNotEmpty
        ? imagenSitio
        : (widget.imagen?.trim().isNotEmpty == true
            ? widget.imagen!.trim()
            : imagenContenido);

    final imagenes = <String>{
      if (_sitio.imagen.trim().isNotEmpty) _sitio.imagen.trim(),
      if (widget.imagen?.trim().isNotEmpty == true)
        widget.imagen!.trim(),
      ..._contenidos
          .map((contenido) => contenido.imagenPrincipal.trim())
          .where((url) => url.isNotEmpty),
      ..._contenidos
          .expand((contenido) => contenido.imagenes)
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty),
      ..._actividades
          .map((actividad) => actividad.imagenPrincipal.trim())
          .where((url) => url.isNotEmpty),
      ..._actividades
          .expand((actividad) => actividad.imagenes)
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty),
    }.toList();

    return Scaffold(
      backgroundColor: AppColors.sitioBackground,
      appBar: AppBar(
        leading: const BotonRegresar(),
        title: Row(
          children: [
            const Expanded(
              child: Tr('Detalle del sitio'),
            ),
            IconButton(
              onPressed: _procesandoFavorito ? null : _cambiarFavorito,
              tooltip: _esFavorito
                  ? Textos.t('Quitar de favoritos')
                  : Textos.t('Agregar a favoritos'),
              icon: _procesandoFavorito
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _esFavorito
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _esFavorito
                          ? AppColors.sitioError
                          : AppColors.sitioPrimary,
                    ),
            ),
          ],
        ),
        centerTitle: false,
        actions: const [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetallePortada(
                sitio: _sitio,
                imagenPrincipal: imagenPrincipal,
              ),

              // ETIQUETAS DEL SITIO
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontal,
                ),
                child: _construirEtiquetas(),
              ),

              // UBICACIÓN Y ACCIONES PRINCIPALES
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.pageHorizontal,
                  AppDimensions.spacingSm,
                  AppDimensions.pageHorizontal,
                  AppDimensions.spacingXl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DetalleUbicacion(
                      sitio: _sitio,
                      onVerMapa: () {
                        DetalleSitioAcciones.verMapa(
                          context,
                          _sitio,
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    _construirAcciones(),
                  ],
                ),
              ),

              // ACTIVIDADES TURÍSTICAS
              if (_cargandoActividades || _actividades.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingLg),
                _construirSeparadorExperiencias(),
                const SizedBox(height: AppDimensions.spacingLg),
                _construirEncabezadoExperiencias(),
                const SizedBox(height: AppDimensions.spacingSm),
                DetalleActividades(
                  actividades: _actividades,
                  cargando: _cargandoActividades,
                  mostrarEncabezado: false,
                  onSeleccionar: (actividad) {
                    DetalleSitioAcciones.mostrarActividad(
                      context,
                      actividad,
                    );
                  },
                ),
              ],

              // PRODUCTOS DEL ESTABLECIMIENTO
              DetalleProductos(
                key: ValueKey('productos_${_sitio.id}'),
                sitioId: _sitio.id,
              ),

              // HISTORIAS, CONTENIDO Y AUDIOGUÍAS
              Padding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.spacingSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _construirSeparadorHistorias(),
                    const SizedBox(height: AppDimensions.spacingLg),
                    _construirEncabezadoHistorias(),
                  ],
                ),
              ),
              _construirSeccionContenido(),

              // GALERÍA DE FOTOGRAFÍAS
              if (_cargandoContenido ||
                  _cargandoActividades ||
                  imagenes.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingLg),
                _construirSeparadorGaleria(),
                const SizedBox(height: AppDimensions.spacingLg),
                _construirEncabezadoSeccion(
                  icono: Icons.photo_library_outlined,
                  titulo: Textos.t('Galería del sitio'),
                  descripcion: Textos.t(
                    'Explora en imágenes los espacios y rincones de este destino.',
                  ),
                ),
                DetalleGaleria(
                  imagenes: imagenes,
                  cargando: _cargandoContenido || _cargandoActividades,
                  mostrarEncabezado: false,
                ),
              ],

              // RESEÑAS Y CALIFICACIONES
              Padding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.spacingLg,
                  bottom: AppDimensions.spacingMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _construirSeparadorResenas(),
                    const SizedBox(height: AppDimensions.spacingLg),
                    _construirEncabezadoResenas(),
                  ],
                ),
              ),
              SeccionResenasSitio(
                key: ValueKey('resenas_${_sitio.id}'),
                sitioId: _sitio.id,
                onRequiereCuenta: widget.onRequiereCuenta,
                mostrarEncabezado: false,
              ),

              const SizedBox(height: AppDimensions.spacingSection),
            ],
          ),
        ),
      ),

      // REPRODUCTOR PERSISTENTE DE AUDIOGUÍAS
      bottomNavigationBar: AnimatedBuilder(
        animation: _audioController,
        builder: (context, _) {
          final audio = _audioController.audioActual;

          if (audio == null) {
            return const SizedBox.shrink();
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: ReproductorHistoriaFlotante(
                player: _audioController.player,
                titulo: audio.titulo,
                cargando: _audioController.cargando,
                error: _audioController.error,
                onCerrar: _cerrarReproductor,
                onAlternarReproduccion: () {
                  _audioController.alternarReproduccion();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _audioController.dispose();
    super.dispose();
  }
}
