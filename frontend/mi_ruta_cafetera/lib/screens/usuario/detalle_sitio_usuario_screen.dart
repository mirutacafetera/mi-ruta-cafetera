
import 'package:flutter/material.dart';

import '../../models/contenido_model.dart';
import '../../models/sitio_turistico_model.dart';
import '../../models/sitio/sitio_actividad_model.dart';
import '../../services/contenido_service.dart';
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

  List<ContenidoModel> _contenidos = [];
  List<SitioActividadModel> _actividades = [];

  bool _cargandoContenido = true;
  bool _cargandoActividades = true;
  bool _procesandoFavorito = false;

  String? _errorContenido;

  @override
  void initState() {
    super.initState();

    _esFavorito = widget.esFavorito;
    _audioController = DetalleSitioAudio();

    _cargarContenido();
    _cargarActividades();
  }

  Future<void> _cargarContenido() async {
    setState(() {
      _cargandoContenido = true;
      _errorContenido = null;
    });

    try {
      final sitioId = widget.sitio.id.trim();

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
      final sitioId = widget.sitio.id.trim();

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
          child: CircularProgressIndicator(),
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
          descripcion:
              Textos.t('Estamos preparando más contenido para que descubras las tradiciones y experiencias de {0}.', [widget.sitio.nombre]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingLg,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.divider,
              ),
            ),
            child: Icon(
              icono,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            descripcion,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (accion != null) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            accion,
          ],
        ],
      ),
    );
  }

  Widget _construirEtiquetas() {
    final etiquetas = widget.sitio.etiquetas
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
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.divider,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.eco_outlined,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  etiqueta,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _construirAcciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: () =>
                DetalleSitioAcciones.agregarRuta(context),
            icon: const Icon(Icons.route_rounded),
            label: const Tr('Agregar a mi ruta'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 1,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingLg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              DetalleSitioAcciones.mostrarDetalleMapa(
                context,
                widget.sitio,
              );
            },
            icon: const Icon(Icons.location_on_outlined),
            label: const Tr('Ver detalles de ubicación'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.55),
                width: 1.3,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingLg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirEncabezadoSeccion({
    required IconData icono,
    required String titulo,
    required String descripcion,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.divider,
              ),
            ),
            child: Icon(
              icono,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
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

    final imagenPrincipal = imagenContenido.isNotEmpty
        ? imagenContenido
        : widget.imagen;

    final imagenes = <String>{
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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: const BotonRegresar(),
        title: const Tr('Detalle del sitio'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _procesandoFavorito ? null : _cambiarFavorito,
            tooltip: _esFavorito
                ? Textos.t('Quitar de favoritos')
                : Textos.t('Agregar a favoritos'),
            icon: _procesandoFavorito
                ? const SizedBox(
                    width: AppDimensions.iconMd,
                    height: AppDimensions.iconMd,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    _esFavorito
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _esFavorito
                        ? AppColors.error
                        : AppColors.primary,
                  ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetallePortada(
                sitio: widget.sitio,
                imagenPrincipal: imagenPrincipal,
              ),

              // Etiquetas del sitio.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontal,
                ),
                child: _construirEtiquetas(),
              ),

              // Ubicación y acciones principales.
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
                      sitio: widget.sitio,
                      onVerMapa: () {
                        DetalleSitioAcciones.verMapa(
                          context,
                          widget.sitio,
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    _construirAcciones(),
                  ],
                ),
              ),

              // Actividades turísticas.
              if (_cargandoActividades || _actividades.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimensions.spacingSm,
                    bottom: AppDimensions.spacingMd,
                  ),
                  child: _construirEncabezadoSeccion(
                    icono: Icons.explore_outlined,
                    titulo: Textos.t('Experiencias para disfrutar'),
                    descripcion:
                        Textos.t('Conoce las actividades que puedes vivir durante tu visita.'),
                  ),
                ),
                DetalleActividades(
                  actividades: _actividades,
                  cargando: _cargandoActividades,
                  onSeleccionar: (actividad) {
                    DetalleSitioAcciones.mostrarActividad(
                      context,
                      actividad,
                    );
                  },
                ),
              ],

              // Productos del establecimiento.
              DetalleProductos(
                key: ValueKey('productos_${widget.sitio.id}'),
                sitioId: widget.sitio.id,
              ),

              // Historias, contenido y audioguías.
              Padding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.spacingLg,
                ),
                child: _construirEncabezadoSeccion(
                  icono: Icons.auto_stories_outlined,
                  titulo: Textos.t('Historias y contenido'),
                  descripcion:
                      Textos.t('Descubre las historias, tradiciones y experiencias que hacen especial a este lugar.'),
                ),
              ),
              _construirSeccionContenido(),

              // Galería de fotografías.
              if (_cargandoContenido ||
                  _cargandoActividades ||
                  imagenes.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimensions.spacingLg,
                    bottom: AppDimensions.spacingMd,
                  ),
                  child: _construirEncabezadoSeccion(
                    icono: Icons.photo_library_outlined,
                    titulo: Textos.t('Galería del sitio'),
                    descripcion:
                        Textos.t('Explora en imágenes los espacios y rincones de este destino.'),
                  ),
                ),
                DetalleGaleria(
                  imagenes: imagenes,
                  cargando: _cargandoContenido || _cargandoActividades,
                ),
              ],

              // Reseñas y calificaciones.
              Padding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.spacingLg,
                  bottom: AppDimensions.spacingSm,
                ),
                child: _construirEncabezadoSeccion(
                  icono: Icons.star_outline_rounded,
                  titulo: Textos.t('Opiniones de viajeros'),
                  descripcion:
                      Textos.t('Consulta las experiencias y valoraciones de otros visitantes.'),
                ),
              ),
              SeccionResenasSitio(
                key: ValueKey('resenas_${widget.sitio.id}'),
                sitioId: widget.sitio.id,
                onRequiereCuenta: widget.onRequiereCuenta,
              ),

              const SizedBox(height: AppDimensions.spacingSection),
            ],
          ),
        ),
      ),

      // Reproductor persistente de audioguías.
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
