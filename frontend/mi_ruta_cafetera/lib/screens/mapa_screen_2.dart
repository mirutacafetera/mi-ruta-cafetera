import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/mapa_controller.dart';
import '../controllers/mapa_ruta_controller.dart';
import '../models/ruta_predefinida_model.dart';
import '../models/sitio_turistico_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../widgets/mapa/mapa_buscador.dart';
import '../widgets/mapa/mapa_capas.dart';
import '../widgets/mapa/mapa_categorias.dart';
import '../widgets/mapa/mapa_controles.dart';
import '../widgets/mapa/mapa_detalle_sitio.dart';
import '../widgets/mapa/mapa_ruta_panel.dart';
import '../widgets/mapa/mapa_rutas_predefinidas.dart';
import '../widgets/mapa/mapa_selector_ruta.dart';

class MapaScreen2 extends StatefulWidget {
  const MapaScreen2({
    super.key,
  });

  @override
  State<MapaScreen2> createState() => _MapaScreen2State();
}

class _MapaScreen2State extends State<MapaScreen2> {
  // ============================================================
  // CONTROLADORES
  // ============================================================

  late final MapaController _mapaController;
  late final MapaRutaController _rutaController;

  final MapController _mapController = MapController();

  final TextEditingController _busquedaController =
      TextEditingController();

  // ============================================================
  // CICLO DE VIDA
  // ============================================================

  @override
  void initState() {
    super.initState();

    _mapaController = MapaController();
    _rutaController = MapaRutaController();

    _mapaController.addListener(
      _actualizarPantalla,
    );

    _rutaController.addListener(
      _actualizarPantalla,
    );

    _mapaController.cargarDatos();
  }

  @override
  void dispose() {
    _mapaController.removeListener(
      _actualizarPantalla,
    );

    _rutaController.removeListener(
      _actualizarPantalla,
    );

    _busquedaController.dispose();
    _mapController.dispose();
    _mapaController.dispose();
    _rutaController.dispose();

    super.dispose();
  }

  void _actualizarPantalla() {
    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // BÚSQUEDA
  // ============================================================

  void _limpiarBusqueda() {
    _busquedaController.clear();
    _mapaController.limpiarBusqueda();
  }

  void _seleccionarResultado(
    SitioTuristicoModel sitio,
  ) {
    _limpiarBusqueda();

    _mapController.move(
      sitio.ubicacion,
      AppDimensions.mapaDetalleZoom,
    );

    if (_rutaController.modoCrearRuta) {
      _seleccionarSitio(
        sitio,
      );

      return;
    }

    _mostrarDetalles(
      sitio,
    );
  }

  // ============================================================
  // CATEGORÍAS
  // ============================================================

  void _seleccionarCategoria(
    String? id,
  ) {
    _rutaController.limpiarRutaGuardada();

    _mapaController.seleccionarCategoria(
      id,
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _ajustarMapa();
        }
      },
    );
  }

  // ============================================================
  // RUTA
  // ============================================================

  void _iniciarRuta() {
    _rutaController.iniciar();
    _mapaController.mostrarTodos();
  }

  void _seleccionarSitio(
    SitioTuristicoModel sitio,
  ) {
    final agregado = _rutaController.alternarSitio(
      sitio,
    );

    if (!agregado &&
        !_rutaController.estado.estaSeleccionado(sitio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Puedes seleccionar máximo 4 sitios.',
          ),
        ),
      );
    }
  }

  void _cancelarRuta() {
    _rutaController.cancelar();

    if (_rutaController.rutaGuardada) {
      _mostrarSoloRuta();
    } else {
      _mapaController.mostrarTodos();
    }
  }

  Future<void> _calcularRuta() async {
    final correcta = await _rutaController.calcularRuta();

    if (!mounted || !correcta) {
      return;
    }

    // ==========================================================
    // IMPORTANTE:
    // después de calcular la ruta solo mostramos los sitios
    // que forman parte de ella.
    // ==========================================================

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _ajustarMapa(
            sitios: _rutaController.rutaGuardadaSitios,
            padding: AppDimensions.mapaRutaPadding,
            maxZoom: AppDimensions.mapaRutaMaxZoom,
          );
        }
      },
    );
  }

  void _mostrarSoloRuta() {
    if (!_rutaController.rutaGuardada) {
      return;
    }

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _ajustarMapa(
            sitios: _rutaController.rutaGuardadaSitios,
            padding: AppDimensions.mapaRutaPadding,
            maxZoom: AppDimensions.mapaRutaMaxZoom,
          );
        }
      },
    );
  }

  // ============================================================
  // RUTAS PREDEFINIDAS
  // ============================================================

  void _mostrarRutasPredefinidas() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return MapaRutasPredefinidas(
          onSeleccionar: _seleccionarRutaPredefinida,
        );
      },
    );
  }

  void _seleccionarRutaPredefinida(
    RutaPredefinidaModel ruta,
  ) {
    _rutaController.seleccionarRutaPredefinida(
      ruta: ruta,
      sitios: _mapaController.todosLosSitios,
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  // ============================================================
  // DETALLES
  // ============================================================

  void _mostrarDetalles(
    SitioTuristicoModel sitio,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return MapaDetalleSitio(
          sitio: sitio,
          onVerMapa: () {
            Navigator.pop(context);

            _mapController.move(
              sitio.ubicacion,
              AppDimensions.mapaDetalleZoom,
            );
          },
          onAgregarRuta: () {
            Navigator.pop(context);

            if (!_rutaController.modoCrearRuta) {
              _iniciarRuta();
            }

            _seleccionarSitio(
              sitio,
            );
          },
        );
      },
    );
  }

  // ============================================================
  // MARCADORES
  // ============================================================

  bool _estaSeleccionado(
    SitioTuristicoModel sitio,
  ) {
    return _rutaController.estado.estaSeleccionado(
      sitio,
    );
  }

  int _numeroDeSitio(
    SitioTuristicoModel sitio,
  ) {
    final numeroSeleccion =
        _rutaController.estado.numeroDeSitio(
      sitio,
    );

    if (numeroSeleccion > 0) {
      return numeroSeleccion;
    }

    return _rutaController.numeroDeSitio(
      sitio,
    );
  }

  // ============================================================
  // MAPA
  // ============================================================

  void _ajustarMapa({
    List<SitioTuristicoModel>? sitios,
    double padding = AppDimensions.mapaPadding,
    double maxZoom = AppDimensions.mapaMaxZoom,
  }) {
    final lista =
        sitios ?? _mapaController.sitiosFiltrados;

    final validos = lista
        .where(
          (sitio) => sitio.tieneCoordenadas,
        )
        .toList();

    if (validos.isEmpty) {
      return;
    }

    if (validos.length == 1) {
      _mapController.move(
        validos.first.ubicacion,
        AppDimensions.mapaMaxZoom,
      );

      return;
    }

    double minLat = validos.first.latitud;
    double maxLat = validos.first.latitud;
    double minLng = validos.first.longitud;
    double maxLng = validos.first.longitud;

    for (final sitio in validos.skip(1)) {
      minLat = sitio.latitud < minLat
          ? sitio.latitud
          : minLat;

      maxLat = sitio.latitud > maxLat
          ? sitio.latitud
          : maxLat;

      minLng = sitio.longitud < minLng
          ? sitio.longitud
          : minLng;

      maxLng = sitio.longitud > maxLng
          ? sitio.longitud
          : maxLng;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(
            minLat,
            minLng,
          ),
          LatLng(
            maxLat,
            maxLng,
          ),
        ),
        padding: EdgeInsets.all(
          padding,
        ),
        maxZoom: maxZoom,
      ),
    );
  }

  void _centrarMapa() {
    _mapController.move(
      const LatLng(
        2.195,
        -75.627,
      ),
      10.5,
    );
  }

  void _mostrarTodosLosSitios() {
    _rutaController.limpiarRutaGuardada();
    _mapaController.mostrarTodos();
    _ajustarMapa();
  }

  // ============================================================
  // BOTÓN DE RUTA GUARDADA
  // ============================================================

  Widget _botonRutaGuardada() {
    if (!_rutaController.rutaGuardada) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: AppDimensions.spacingSm +
          AppDimensions.spacingXs +
          AppDimensions.spacingXs,
      bottom: AppDimensions.mapaRutaGuardadaBottom,
      child: SafeArea(
        top: false,
        child: Material(
          elevation: AppDimensions.elevationHigh,
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusXl,
          ),
          child: InkWell(
            onTap: _rutaController.alternarVisibilidadRuta,
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusXl,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm +
                    AppDimensions.spacingXs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _rutaController.mostrarRutaGuardada
                        ? Icons.route
                        : Icons.route_outlined,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(
                    width: AppDimensions.spacingXs +
                        AppDimensions.spacingXs,
                  ),
                  Text(
                    _rutaController.mostrarRutaGuardada
                        ? 'Ocultar ruta'
                        : 'Ver ruta',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
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

  // ============================================================
  // PANEL DE RUTA
  // ============================================================

  Widget _panelRuta() {
    return MapaRutaPanel(
      titulo: _rutaController.nombreRuta,
      sitios: _rutaController.sitiosSeleccionados,
      distancia: _rutaController.rutaResultado == null
          ? ''
          : '${_rutaController.rutaResultado!.distanciaKm.toStringAsFixed(2)} km',
      duracion: _rutaController.rutaResultado == null
          ? ''
          : '${_rutaController.rutaResultado!.duracionMinutos.toStringAsFixed(0)} min',
      mensaje: _rutaController.mensaje ?? '',
      calculando: _rutaController.calculando,
      colorRuta: AppColors.tertiary,
      onCerrar: _cancelarRuta,
      onGenerarRuta: _calcularRuta,
      mostrarBotonGenerar:
          _rutaController.sitiosSeleccionados.length >= 2,
    );
  }

  // ============================================================
  // BARRA INFERIOR
  // ============================================================

  Widget _barraInferior() {
    if (_rutaController.modoCrearRuta) {
      return MapaSelectorRuta(
        activo: true,
        sitiosSeleccionados:
            _rutaController.sitiosSeleccionados,
        onIniciar: _iniciarRuta,
        onCancelar: _cancelarRuta,
        onCalcular: _calcularRuta,
      );
    }

    return Row(
      children: [
        Expanded(
          child: MapaSelectorRuta(
            activo: false,
            sitiosSeleccionados: const [],
            onIniciar: _iniciarRuta,
            onCancelar: _cancelarRuta,
            onCalcular: _calcularRuta,
          ),
        ),
        const SizedBox(
          width: AppDimensions.spacingSm,
        ),
        SizedBox(
          width: AppDimensions.mapaRutasButtonWidth,
          height: AppDimensions.bottomBarHeight,
          child: Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusPill,
            ),
            elevation: AppDimensions.elevationFloating,
            child: InkWell(
              onTap: _mostrarRutasPredefinidas,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusPill,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.route,
                    color: AppColors.secondary,
                    size: AppDimensions.iconMd,
                  ),
                  const SizedBox(
                    width: AppDimensions.spacingXs +
                        AppDimensions.spacingXs / 2,
                  ),
                  const Text(
                    'Rutas',
                    style: TextStyle(
                      color: AppColors.secondary,
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Ruta Cafetera',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _mapaController.cargarDatos,
            tooltip: 'Actualizar',
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final ancho = constraints.maxWidth;

          final pantallaPequena = ancho < 600;

          final controlesTop = pantallaPequena
              ? AppDimensions.mapaControlesTopPequeno
              : AppDimensions.mapaControlesTopGrande;

          return Stack(
            children: [
              // ==================================================
              // MAPA
              // ==================================================

              MapaCapas(
                mapController: _mapController,
                sitios: _rutaController.rutaGuardada
                    ? _rutaController.rutaGuardadaSitios
                    : _mapaController.sitiosFiltrados,
                ruta: _rutaController.rutaResultado,
                mostrarRuta:
                    _rutaController.mostrarRutaGuardada,
                estaSeleccionado: _estaSeleccionado,
                numeroDeSitio: _numeroDeSitio,
                onTapSitio: (sitio) {
                  if (_rutaController.modoCrearRuta) {
                    _seleccionarSitio(
                      sitio,
                    );
                  } else {
                    _mostrarDetalles(
                      sitio,
                    );
                  }
                },
              ),

              // ==================================================
              // BUSCADOR
              // ==================================================

              Positioned(
                top: AppDimensions.spacingMd,
                left: AppDimensions.spacingMd,
                right: AppDimensions.spacingMd,
                child: SafeArea(
                  bottom: false,
                  child: MapaBuscador(
                    controller: _busquedaController,
                    resultados:
                        _mapaController.resultadosBusqueda,
                    onChanged: _mapaController.buscar,
                    onSeleccionar: _seleccionarResultado,
                    onLimpiar: _limpiarBusqueda,
                  ),
                ),
              ),

              // ==================================================
              // CATEGORÍAS
              // ==================================================

              Positioned(
                top: AppDimensions.mapaCategoriasTop,
                left: AppDimensions.spacingMd,
                right: AppDimensions.spacingMd,
                child: SafeArea(
                  bottom: false,
                  child: MapaCategorias(
                    categorias:
                        _mapaController.categorias,
                    categoriaSeleccionada:
                        _mapaController.categoriaSeleccionada,
                    onCategoriaSeleccionada:
                        _seleccionarCategoria,
                  ),
                ),
              ),

              // ==================================================
              // CONTROLES
              // ==================================================

              Positioned(
                right: AppDimensions.spacingMd,
                top: controlesTop,
                child: SafeArea(
                  bottom: false,
                  child: MapaControles(
                    onCentrar: _centrarMapa,
                    onMostrarTodos:
                        _mostrarTodosLosSitios,
                  ),
                ),
              ),

              // ==================================================
              // RUTA GUARDADA
              // ==================================================

              if (!_rutaController.modoCrearRuta)
                _botonRutaGuardada(),

              // ==================================================
              // PANEL DE RUTA
              // ==================================================

              if (_rutaController.modoCrearRuta &&
                  (_rutaController.calculando ||
                      _rutaController.mensaje != null ||
                      _rutaController.rutaResultado != null))
                Positioned(
                  left: AppDimensions.spacingMd,
                  right: AppDimensions.spacingMd,
                  bottom:
                      AppDimensions.mapaPanelBottom,
                  child: _panelRuta(),
                ),

              // ==================================================
              // BARRA INFERIOR
              // ==================================================

              Positioned(
                left: AppDimensions.spacingMd,
                right: AppDimensions.spacingMd,
                bottom: _rutaController.modoCrearRuta
                    ? AppDimensions.mapaBarraRutaBottom
                    : AppDimensions.spacingXl,
                child: SafeArea(
                  top: false,
                  child: _barraInferior(),
                ),
              ),

              // ==================================================
              // CARGANDO
              // ==================================================

              if (_mapaController.cargando)
                Positioned(
                  left: AppDimensions.spacingXl,
                  right: AppDimensions.spacingXl,
                  bottom: AppDimensions.mapaCargaBottom,
                  child: SafeArea(
                    top: false,
                    child: Card(
                      elevation:
                          AppDimensions.elevationHigh,
                      child: const Padding(
                        padding: EdgeInsets.all(
                          AppDimensions.spacingLg,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: AppDimensions.iconLg,
                              height: AppDimensions.iconLg,
                              child:
                                  CircularProgressIndicator(),
                            ),
                            SizedBox(
                              width: AppDimensions.spacingMd,
                            ),
                            Expanded(
                              child: Text(
                                'Cargando sitios turísticos...',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // ==================================================
              // ERROR
              // ==================================================

              if (_mapaController.error != null)
                Positioned(
                  left: AppDimensions.spacingXl,
                  right: AppDimensions.spacingXl,
                  bottom: AppDimensions.mapaErrorBottom,
                  child: SafeArea(
                    top: false,
                    child: Card(
                      elevation:
                          AppDimensions.elevationHigh,
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppDimensions.spacingLg,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                ),
                                SizedBox(
                                  width:
                                      AppDimensions.spacingSm,
                                ),
                                Expanded(
                                  child: Text(
                                    'No se pudieron cargar los datos',
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: AppDimensions.spacingSm,
                            ),
                            Text(
                              _mapaController.error!,
                              maxLines: 4,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color:
                                    AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(
                              height: AppDimensions.spacingSm +
                                  AppDimensions.spacingXs,
                            ),
                            ElevatedButton.icon(
                              onPressed:
                                  _mapaController.cargarDatos,
                              icon: const Icon(
                                Icons.refresh,
                              ),
                              label: const Text(
                                'Reintentar',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}