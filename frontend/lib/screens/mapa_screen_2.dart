import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/mapa_controller.dart';
import '../controllers/mapa_ruta_controller.dart';
import '../controllers/mapa_ubicacion_controller.dart';

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
  late final MapaUbicacionController _ubicacionController;

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
    _ubicacionController = MapaUbicacionController();

    _mapaController.addListener(_actualizarPantalla);
    _rutaController.addListener(_actualizarPantalla);
    _ubicacionController.addListener(_actualizarPantalla);

    _mapaController.cargarDatos();
  }

  @override
  void dispose() {
    _mapaController.removeListener(_actualizarPantalla);
    _rutaController.removeListener(_actualizarPantalla);
    _ubicacionController.removeListener(_actualizarPantalla);

    _busquedaController.dispose();
    _mapController.dispose();

    _ubicacionController.dispose();
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
  // UBICACIÓN
  // ============================================================

  Future<void> _obtenerUbicacionUsuario() async {
    final ubicacion =
        await _ubicacionController.obtenerUbicacion();

    if (!mounted) {
      return;
    }

    if (ubicacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _ubicacionController.error ??
                'No fue posible obtener la ubicación actual.',
          ),
        ),
      );
      return;
    }

    _mapController.move(
      ubicacion,
      AppDimensions.mapaDetalleZoom,
    );
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
      _seleccionarSitio(sitio);
      return;
    }

    _mostrarDetalles(sitio);
  }

  // ============================================================
  // CATEGORÍAS
  // ============================================================

  void _seleccionarCategoria(
    String? id,
  ) {
    _rutaController.limpiarRutaGuardada();

    _mapaController.seleccionarCategoria(id);

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
    final agregado =
        _rutaController.alternarSitio(sitio);

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
    final correcta =
        await _rutaController.calcularRuta();

    if (!mounted || !correcta) {
      return;
    }

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _ajustarMapa(
            sitios:
                _rutaController.rutaGuardadaSitios,
            padding:
                AppDimensions.mapaRutaPadding,
            maxZoom:
                AppDimensions.mapaRutaMaxZoom,
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
            sitios:
                _rutaController.rutaGuardadaSitios,
            padding:
                AppDimensions.mapaRutaPadding,
            maxZoom:
                AppDimensions.mapaRutaMaxZoom,
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
          onSeleccionar:
              _seleccionarRutaPredefinida,
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

            _seleccionarSitio(sitio);
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
    return _rutaController.estado
        .estaSeleccionado(sitio);
  }

  int _numeroDeSitio(
    SitioTuristicoModel sitio,
  ) {
    final numeroSeleccion =
        _rutaController.estado.numeroDeSitio(sitio);

    if (numeroSeleccion > 0) {
      return numeroSeleccion;
    }

    return _rutaController.numeroDeSitio(sitio);
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
        maxZoom,
      );
      return;
    }

    double minLat = validos.first.latitud;
    double maxLat = validos.first.latitud;
    double minLng = validos.first.longitud;
    double maxLng = validos.first.longitud;

    for (final sitio in validos.skip(1)) {
      if (sitio.latitud < minLat) {
        minLat = sitio.latitud;
      }

      if (sitio.latitud > maxLat) {
        maxLat = sitio.latitud;
      }

      if (sitio.longitud < minLng) {
        minLng = sitio.longitud;
      }

      if (sitio.longitud > maxLng) {
        maxLng = sitio.longitud;
      }
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
        padding: EdgeInsets.all(padding),
        maxZoom: maxZoom,
      ),
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
      right: AppDimensions.spacingLg,
      bottom: 90,
      child: SafeArea(
        top: false,
        child: Material(
          elevation:
              AppDimensions.elevationHigh,
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusXl,
          ),
          child: InkWell(
            onTap: _rutaController
                .alternarVisibilidadRuta,
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusXl,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal:
                    AppDimensions.spacingLg,
                vertical:
                    AppDimensions.spacingMd,
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    _rutaController
                            .mostrarRutaGuardada
                        ? Icons.route
                        : Icons.route_outlined,
                    color:
                        AppColors.secondary,
                  ),
                  const SizedBox(
                    width:
                        AppDimensions.spacingSm,
                  ),
                  Text(
                    _rutaController
                            .mostrarRutaGuardada
                        ? 'Ocultar ruta'
                        : 'Ver ruta',
                    style: const TextStyle(
                      color:
                          AppColors.textPrimary,
                      fontWeight:
                          FontWeight.w600,
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
      sitios:
          _rutaController.sitiosSeleccionados,
      distancia:
          _rutaController.rutaResultado == null
              ? ''
              : '${_rutaController.rutaResultado!.distanciaKm.toStringAsFixed(2)} km',
      duracion:
          _rutaController.rutaResultado == null
              ? ''
              : '${_rutaController.rutaResultado!.duracionMinutos.toStringAsFixed(0)} min',
      mensaje:
          _rutaController.mensaje ?? '',
      calculando:
          _rutaController.calculando,
      colorRuta:
          AppColors.tertiary,
      onCerrar:
          _cancelarRuta,
      onGenerarRuta:
          _calcularRuta,
      mostrarBotonGenerar:
          _rutaController
                  .sitiosSeleccionados
                  .length >=
              2,
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
            _rutaController
                .sitiosSeleccionados,
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
            sitiosSeleccionados:
                const [],
            onIniciar: _iniciarRuta,
            onCancelar: _cancelarRuta,
            onCalcular: _calcularRuta,
          ),
        ),
        const SizedBox(
          width:
              AppDimensions.spacingSm,
        ),
        SizedBox(
          width: 115,
          height:
              AppDimensions.bottomBarHeight,
          child: Material(
            color: AppColors.white,
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radiusPill,
            ),
            elevation:
                AppDimensions
                    .elevationFloating,
            child: InkWell(
              onTap:
                  _mostrarRutasPredefinidas,
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radiusPill,
              ),
              child: const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.route,
                    color:
                        AppColors.secondary,
                    size:
                        AppDimensions.iconMd,
                  ),
                  SizedBox(
                    width:
                        AppDimensions.spacingSm,
                  ),
                  Text(
                    'Rutas',
                    style: TextStyle(
                      color:
                          AppColors.secondary,
                      fontWeight:
                          FontWeight.w700,
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
    Widget build(BuildContext context) {
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
      builder: (context, constraints) {
        final bool pantallaPequena =
            constraints.maxWidth < 600;

        final double controlesTop =
            pantallaPequena ? 150.0 : 175.0;

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
              ubicacionUsuario:
                  _ubicacionController.ubicacionActual,
              estaSeleccionado: _estaSeleccionado,
              numeroDeSitio: _numeroDeSitio,
              onTapSitio: _seleccionarSitio,
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
              top: 76,
              left: AppDimensions.spacingMd,
              right: AppDimensions.spacingMd,
              child: SafeArea(
                bottom: false,
                child: MapaCategorias(
                  categorias: _mapaController.categorias,
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
                  onCentrar: _obtenerUbicacionUsuario,
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
                bottom: 145,
                child: _panelRuta(),
              ),

            // ==================================================
            // BARRA INFERIOR
            // ==================================================

            Positioned(
              left: AppDimensions.spacingMd,
              right: AppDimensions.spacingMd,
              bottom: _rutaController.modoCrearRuta
                  ? 145
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
                bottom: 25,
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
                            width:
                                AppDimensions.iconLg,
                            height:
                                AppDimensions.iconLg,
                            child:
                                CircularProgressIndicator(),
                          ),
                          SizedBox(
                            width:
                                AppDimensions.spacingLg,
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
                bottom: 25,
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
                            height:
                                AppDimensions.spacingSm,
                          ),
                          Text(
                            _mapaController.error!,
                            maxLines: 4,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                          const SizedBox(
                            height:
                                AppDimensions.spacingMd,
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
