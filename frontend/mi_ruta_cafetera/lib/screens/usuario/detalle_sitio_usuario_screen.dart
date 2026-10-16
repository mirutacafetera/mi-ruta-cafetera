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

class _DetalleSitioUsuarioScreenState extends State<DetalleSitioUsuarioScreen> {
  final ContenidoService _contenidoService = ContenidoService.instance;
  final SitioActividadesService _actividadesService = SitioActividadesService();

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
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
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
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
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
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorContenido != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pageHorizontal,
          vertical: AppDimensions.spacingLg,
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  color: AppColors.primary,
                  size: 36,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                const Text(
                  'No pudimos cargar el contenido.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(_errorContenido!, textAlign: TextAlign.center),
                const SizedBox(height: AppDimensions.spacingSm),
                OutlinedButton.icon(
                  onPressed: _cargarContenido,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Intentar de nuevo'),
                ),
              ],
            ),
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
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              children: [
                const Icon(
                  Icons.auto_stories_outlined,
                  color: AppColors.primary,
                  size: 36,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                const Text(
                  'Todavía no hay historias publicadas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  'Pronto podrás descubrir más sobre '
                  '${widget.sitio.nombre}.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingLg),
      child: SeccionContenidoSitio(
        contenidos: _contenidos,
        onReproducirAudioguia: _reproducirAudioguia,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagenContenido = _contenidos
        .where((contenido) => contenido.activo)
        .map((contenido) => contenido.imagenPrincipal.trim())
        .firstWhere((url) => url.isNotEmpty, orElse: () => '');

    final imagenPrincipal = imagenContenido.isNotEmpty
        ? imagenContenido
        : widget.imagen;

    final imagenes = <String>{
      if (widget.imagen?.trim().isNotEmpty == true) widget.imagen!.trim(),
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
        title: const Text('Detalle del sitio'),
        actions: [
          IconButton(
            onPressed: _procesandoFavorito ? null : _cambiarFavorito,
            tooltip: _esFavorito
                ? 'Quitar de favoritos'
                : 'Agregar a favoritos',
            icon: _procesandoFavorito
                ? const SizedBox(
                    width: AppDimensions.iconMd,
                    height: AppDimensions.iconMd,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _esFavorito ? Icons.favorite : Icons.favorite_border,
                    color: _esFavorito ? AppColors.error : AppColors.primary,
                  ),
          ),
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.sitio.etiquetas.isNotEmpty)
                      Wrap(
                        spacing: AppDimensions.spacingSm,
                        runSpacing: AppDimensions.spacingSm,
                        children: widget.sitio.etiquetas
                            .where((etiqueta) => etiqueta.trim().isNotEmpty)
                            .map(
                              (etiqueta) => Chip(label: Text(etiqueta.trim())),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    DetalleUbicacion(
                      sitio: widget.sitio,
                      onVerMapa: () =>
                          DetalleSitioAcciones.verMapa(context, widget.sitio),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () =>
                            DetalleSitioAcciones.agregarRuta(context),
                        icon: const Icon(Icons.route_outlined),
                        label: const Text('Agregar a mi ruta'),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            DetalleSitioAcciones.mostrarDetalleMapa(
                              context,
                              widget.sitio,
                            ),
                        icon: const Icon(Icons.place_outlined),
                        label: const Text('Ver detalles de ubicación'),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSection),
                  ],
                ),
              ),

              // Actividades del sitio turístico.
              DetalleActividades(
                actividades: _actividades,
                cargando: _cargandoActividades,
                onSeleccionar: (actividad) =>
                    DetalleSitioAcciones.mostrarActividad(context, actividad),
              ),

              // Productos publicados del establecimiento.
              DetalleProductos(
                key: ValueKey('productos_${widget.sitio.id}'),
                sitioId: widget.sitio.id,
              ),

              // Sección fija de historias, contenido y audioguías.
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.pageHorizontal,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_stories_outlined,
                            color: AppColors.primary,
                            size: 26,
                          ),
                          SizedBox(width: AppDimensions.spacingSm),
                          Expanded(
                            child: Text(
                              'Historias y contenido del sitio',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.pageHorizontal,
                      ),
                      child: Text(
                        'Descubre las historias, tradiciones y '
                        'experiencias de este lugar.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    _construirSeccionContenido(),
                  ],
                ),
              ),

              // Galería de fotografías.
              DetalleGaleria(
                imagenes: imagenes,
                cargando: _cargandoContenido || _cargandoActividades,
              ),

              // Reseñas y calificaciones.
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
