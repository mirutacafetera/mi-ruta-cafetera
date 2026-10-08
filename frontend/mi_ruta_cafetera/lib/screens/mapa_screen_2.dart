import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

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
    this.rutaController,
    this.sitioInicial,
  });

  final MapaRutaController? rutaController;

  /// Sitio que se desea mostrar cuando el mapa
  /// es abierto desde la página pública.
  ///
  /// Si es null, el mapa funciona normalmente
  /// mostrando todos los sitios.
  final SitioTuristicoModel? sitioInicial;

  @override
  State<MapaScreen2> createState() =>
      _MapaScreen2State();
}

class _MapaScreen2State extends State<MapaScreen2> {
  // ============================================================
  // CONTROLADORES
  // ============================================================

  late final MapaController _mapaController;
  late final MapaRutaController _rutaController;
  late final bool _controladorRutaExterno;

  final MapController _mapController = MapController();

  final TextEditingController _busquedaController =
      TextEditingController();

  bool _obteniendoUbicacion = false;
  LatLng? _ubicacionUsuario;

  // ============================================================
// MODO SITIO PÚBLICO
// ============================================================

bool _sitioInicialCentrado = false;

bool get _modoSitioPublico =>
    widget.sitioInicial != null;

  List<SitioTuristicoModel> get _sitiosVisiblesEnMapa {
    if (_rutaController.rutaGuardada) {
      return _rutaController.rutaGuardadaSitios;
    }

    if (_modoSitioPublico) {
      return <SitioTuristicoModel>[widget.sitioInicial!];
    }

    return _mapaController.sitiosFiltrados;
  }


  // Indica que estamos mostrando el resumen de la ruta recién calculada.
  bool _mostrarResumenRuta = false;

  // ============================================================
  // CICLO DE VIDA
  // ============================================================

 @override
void initState() {
  super.initState();

  _mapaController = MapaController();

  _controladorRutaExterno =
      widget.rutaController != null;

  _rutaController =
      widget.rutaController ??
          MapaRutaController();

  _mapaController.addListener(
    _actualizarPantalla,
  );

  _rutaController.addListener(
    _actualizarPantalla,
  );

  _mapaController.cargarDatos();

  // Cuando el mapa se abre desde un sitio público,
  // esperamos a que exista el primer frame para
  // centrar la cámara sobre ese sitio.
  if (widget.sitioInicial != null) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _centrarSitioInicial();
      },
    );
  }
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

    if (!_controladorRutaExterno) {
      _rutaController.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // ACTUALIZAR PANTALLA
  // ============================================================

  void _actualizarPantalla() {
    if (!mounted) {
      return;
    }

    setState(() {});
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
    // Una nueva categoría debe mostrar nuevamente los sitios
    // correspondientes y no conservar una ruta personalizada
    // anterior.
    _rutaController.limpiarRutaGuardada();

    setState(() {
      _mostrarResumenRuta = false;
    });

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
  // RUTA PERSONALIZADA
  // ============================================================

  void _iniciarRuta() {
    _rutaController.iniciar();

    _mapaController.mostrarTodos();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _ajustarMapa();
        }
      },
    );
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

  // ============================================================
  // CANCELAR RUTA
  // ============================================================

  void _cancelarRuta() {
    // Si estamos viendo el resumen de una ruta recién calculada,
    // cancelar significa descartar completamente esa ruta.
    if (_mostrarResumenRuta) {
      setState(() {
        _mostrarResumenRuta = false;
      });

      _rutaController.cancelar();
      _rutaController.limpiarRutaGuardada();

      _mapaController.mostrarTodos();

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          if (mounted) {
            _ajustarMapa();
          }
        },
      );

      return;
    }

    _rutaController.cancelar();

    // Si existe una ruta guardada/confirmada, conservamos la ruta
    // y simplemente salimos del modo de creación.
    if (_rutaController.rutaGuardada) {
      _mostrarSoloRuta();
    } else {
      _mapaController.mostrarTodos();
    }
  }

  // ============================================================
  // CALCULAR RUTA
  // ============================================================

  Future<void> _calcularRuta() async {
    if (_rutaController.sitiosSeleccionados.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona mínimo 2 sitios para calcular la ruta.',
          ),
        ),
      );

      return;
    }

    final correcta =
        await _rutaController.calcularRuta();

    if (!mounted || !correcta) {
      return;
    }

    // Importante:
    // La ruta YA fue calculada, pero todavía NO se muestra
    // la polilínea. Primero mostramos el resumen.
    setState(() {
      _mostrarResumenRuta = true;
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        _ajustarMapa(
          sitios:
              _rutaController.rutaGuardadaSitios,
          padding:
              AppDimensions.mapaRutaPadding,
          maxZoom:
              AppDimensions.mapaRutaMaxZoom,
        );
      },
    );
  }

  // ============================================================
  // CONFIRMAR RUTA CALCULADA
  // ============================================================

  void _confirmarRutaCalculada() {
    _rutaController.confirmarRuta();

    if (!mounted) {
      return;
    }

    // Al confirmar:
    // 1. Se cierra el resumen.
    // 2. El controller cambia mostrarRutaGuardada a true.
    // 3. MapaCapas dibuja la polilínea.
    setState(() {
      _mostrarResumenRuta = false;
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        _ajustarMapa(
          sitios:
              _rutaController.rutaGuardadaSitios,
          padding:
              AppDimensions.mapaRutaPadding,
          maxZoom:
              AppDimensions.mapaRutaMaxZoom,
        );
      },
    );
  }

  // ============================================================
  // MOSTRAR SOLO LA RUTA
  // ============================================================

  void _mostrarSoloRuta() {
    if (!_rutaController.rutaGuardada) {
      return;
    }

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        _ajustarMapa(
          sitios:
              _rutaController.rutaGuardadaSitios,
          padding:
              AppDimensions.mapaRutaPadding,
          maxZoom:
              AppDimensions.mapaRutaMaxZoom,
        );
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

  Future<void> _seleccionarRutaPredefinida(
    RutaPredefinidaModel ruta,
  ) async {
    await _rutaController.seleccionarRutaPredefinida(
      ruta: ruta,
      sitios:
          _mapaController.todosLosSitios,
    );

    if (!mounted) {
      return;
    }

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _ajustarMapa(
            sitios:
                _rutaController.sitiosSeleccionados,
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
  // DETALLES DEL SITIO
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
        _rutaController.estado.numeroDeSitio(
      sitio,
    );

    if (numeroSeleccion > 0) {
      return numeroSeleccion;
    }

    return _rutaController.numeroDeSitio(sitio);
  }

  // ============================================================
  // AJUSTE AUTOMÁTICO DEL MAPA
  // ============================================================

  void _ajustarMapa({
    List<SitioTuristicoModel>? sitios,
    double padding =
        AppDimensions.mapaPadding,
    double maxZoom =
        AppDimensions.mapaMaxZoom,
  }) {
    final lista =
        sitios ?? _sitiosVisiblesEnMapa;

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

    double minLat =
        validos.first.latitud;
    double maxLat =
        validos.first.latitud;
    double minLng =
        validos.first.longitud;
    double maxLng =
        validos.first.longitud;

    for (final sitio
        in validos.skip(1)) {
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
        padding:
            EdgeInsets.all(padding),
        maxZoom: maxZoom,
      ),
    );
  }

  // ============================================================
  // CENTRAR MAPA CON GPS REAL
  // ============================================================

  Future<void> _centrarMapa() async {
    if (_obteniendoUbicacion) {
      return;
    }

    setState(() {
      _obteniendoUbicacion = true;
    });

    try {
      final servicioActivo =
          await Geolocator
              .isLocationServiceEnabled();

      if (!servicioActivo) {
        if (!mounted) {
          return;
        }

        await _mostrarDialogoUbicacion(
          titulo: 'Ubicación desactivada',
          mensaje:
              'Para centrar el mapa en tu ubicación actual, '
              'activa la ubicación del dispositivo.',
          accionTexto:
              'Abrir ubicación',
          accion:
              Geolocator.openLocationSettings,
        );

        return;
      }

      var permiso =
          await Geolocator.checkPermission();

      if (permiso ==
          LocationPermission.denied) {
        permiso =
            await Geolocator.requestPermission();
      }

      if (permiso ==
          LocationPermission.denied) {
        if (!mounted) {
          return;
        }

        _mostrarMensajeUbicacion(
          'Se necesita permiso de ubicación para centrar el mapa.',
        );

        return;
      }

      if (permiso ==
          LocationPermission.deniedForever) {
        if (!mounted) {
          return;
        }

        await _mostrarDialogoUbicacion(
          titulo:
              'Permiso de ubicación requerido',
          mensaje:
              'El permiso de ubicación está bloqueado. '
              'Puedes habilitarlo desde la configuración de la aplicación.',
          accionTexto:
              'Abrir configuración',
          accion:
              Geolocator.openAppSettings,
        );

        return;
      }

      final posicion =
          await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy:
              LocationAccuracy.high,
        ),
      );

      if (!mounted) {
        return;
      }

      final ubicacionActual =
          LatLng(
        posicion.latitude,
        posicion.longitude,
      );

      setState(() {
        _ubicacionUsuario =
            ubicacionActual;
      });

      _mapController.move(
        ubicacionActual,
        AppDimensions.mapaDetalleZoom,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _mostrarMensajeUbicacion(
        'No fue posible obtener tu ubicación actual.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _obteniendoUbicacion = false;
        });
      }
    }
  }

  void _mostrarMensajeUbicacion(
    String mensaje,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
        ),
      );
  }

  Future<void> _mostrarDialogoUbicacion({
    required String titulo,
    required String mensaje,
    required String accionTexto,
    required Future<bool> Function()
        accion,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await accion();
              },
              child: Text(accionTexto),
            ),
          ],
        );
      },
    );
  }

   // ============================================================
  // MOSTRAR TODOS LOS SITIOS
  // ============================================================

  void _mostrarTodosLosSitios() {
    if (_modoSitioPublico) {
      final sitio = widget.sitioInicial;

      if (sitio != null && sitio.tieneCoordenadas) {
        _mapController.move(
          sitio.ubicacion,
          AppDimensions.mapaDetalleZoom,
        );
      }

      return;
    }

    _rutaController.limpiarRutaGuardada();
    _limpiarBusqueda();

    setState(() {
      _mostrarResumenRuta = false;
    });

    _mapaController.mostrarTodos();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        _ajustarMapa(
          sitios: _mapaController.todosLosSitios,
        );
      },
    );
  }

  void _centrarSitioInicial() {
    if (!mounted ||
        _sitioInicialCentrado ||
        widget.sitioInicial == null) {
      return;
    }

    final sitio = widget.sitioInicial!;

    if (!sitio.tieneCoordenadas) {
      return;
    }

    _sitioInicialCentrado = true;

    _mapController.move(
      sitio.ubicacion,
      AppDimensions.mapaDetalleZoom,
    );
  }

  // ============================================================
  // BOTÓN DE RUTA GUARDADA
  // ============================================================

  Widget _botonRutaGuardada() {
    if (!_rutaController.rutaGuardada) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right:
          AppDimensions.spacingSm +
              AppDimensions.spacingXs +
              AppDimensions.spacingXs,
      bottom:
          AppDimensions.mapaRutaGuardadaBottom,
      child: SafeArea(
        top: false,
        child: Material(
          elevation:
              AppDimensions.elevationHigh,
          color: AppColors.white,
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radiusXl,
          ),
          child: InkWell(
            onTap: _rutaController
                .alternarVisibilidadRuta,
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radiusXl,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal:
                    AppDimensions.spacingMd,
                vertical:
                    AppDimensions.spacingSm +
                        AppDimensions.spacingXs,
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
                        AppDimensions.spacingXs +
                            AppDimensions.spacingXs,
                  ),
                  Text(
                    _rutaController
                            .mostrarRutaGuardada
                        ? 'Ocultar ruta'
                        : 'Ver ruta',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                      color:
                          AppColors.textPrimary,
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
      titulo:
          _rutaController.nombreRuta,
      sitios:
          _rutaController.sitiosSeleccionados,
      distancia:
          _rutaController.rutaResultado ==
                  null
              ? ''
              : '${_rutaController.rutaResultado!.distanciaKm.toStringAsFixed(2)} km',
      duracion:
          _rutaController.rutaResultado ==
                  null
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
  // RESUMEN DE RUTA CALCULADA
  // ============================================================

  Widget _resumenRutaCalculada() {
    final sitios =
        _rutaController.rutaGuardadaSitios;

    final tramos =
        _rutaController.tramosRuta;

    return Positioned(
      left:
          AppDimensions.spacingMd,
      right:
          AppDimensions.spacingMd,
      bottom:
          AppDimensions.mapaPanelBottom,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxHeight: 430,
          ),
          child: Card(
            elevation:
                AppDimensions.elevationHigh,
            color: AppColors.white,
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radiusXl,
              ),
            ),
            child:
                SingleChildScrollView(
              padding:
                  const EdgeInsets.all(
                AppDimensions.spacingLg,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.route,
                        color:
                            AppColors.primary,
                        size:
                            AppDimensions.iconLg,
                      ),
                      const SizedBox(
                        width:
                            AppDimensions.spacingSm,
                      ),
                      const Expanded(
                        child: Text(
                          'RUTA CALCULADA',
                          style:
                              TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height:
                        AppDimensions.spacingMd,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                            _datoResumenRuta(
                          Icons.location_on,
                          '${sitios.length} sitios',
                        ),
                      ),
                      Expanded(
                        child:
                            _datoResumenRuta(
                          Icons.alt_route,
                          '${_rutaController.distanciaTotalKm.toStringAsFixed(1)} km',
                        ),
                      ),
                      Expanded(
                        child:
                            _datoResumenRuta(
                          Icons.schedule,
                          '${_rutaController.duracionTotalMinutos.toStringAsFixed(0)} min',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height:
                        AppDimensions.spacingMd,
                  ),

                  const Divider(),

                  const SizedBox(
                    height:
                        AppDimensions.spacingSm,
                  ),

                  ...List.generate(
                    sitios.length,
                    (index) {
                      final sitio =
                          sitios[index];

                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment:
                                    Alignment.center,
                                decoration:
                                    const BoxDecoration(
                                  color:
                                      AppColors.primary,
                                  shape:
                                      BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style:
                                      const TextStyle(
                                    color:
                                        AppColors.white,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width:
                                    AppDimensions.spacingSm,
                              ),

                              Expanded(
                                child: Text(
                                  sitio.nombre,
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (index <
                                  sitios.length -
                                      1 &&
                              index <
                                  tramos.length)
                            Padding(
                              padding:
                                  const EdgeInsets.only(
                                left: 13,
                                top: 4,
                                bottom: 4,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 2,
                                    height: 24,
                                    color:
                                        AppColors.primary,
                                  ),

                                  const SizedBox(
                                    width:
                                        AppDimensions.spacingSm,
                                  ),

                                  Text(
                                    '↓ ${tramos[index].distanciaKm.toStringAsFixed(1)} km · '
                                    '${tramos[index].duracionMinutos.toStringAsFixed(0)} min',
                                    style:
                                        const TextStyle(
                                      color:
                                          AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(
                    height:
                        AppDimensions.spacingMd,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                            OutlinedButton(
                          onPressed:
                              _cancelarRuta,
                          child:
                              const Text(
                            'Cancelar',
                          ),
                        ),
                      ),

                      const SizedBox(
                        width:
                            AppDimensions.spacingSm,
                      ),

                      Expanded(
                        child:
                            ElevatedButton.icon(
                          onPressed:
                              _confirmarRutaCalculada,
                          icon:
                              const Icon(
                            Icons.check,
                          ),
                          label:
                              const Text(
                            'Confirmar ruta',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _datoResumenRuta(
    IconData icono,
    String texto,
  ) {
    return Row(
      children: [
        Icon(
          icono,
          color:
              AppColors.primary,
          size:
              AppDimensions.iconMd,
        ),
        const SizedBox(
          width:
              AppDimensions.spacingXs,
        ),
        Flexible(
          child: Text(
            texto,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ],
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
        onIniciar:
            _iniciarRuta,
        onCancelar:
            _cancelarRuta,
        onCalcular:
            _calcularRuta,
      );
    }

    return Row(
      children: [
        Expanded(
          child: MapaSelectorRuta(
            activo: false,
            sitiosSeleccionados:
                const [],
            onIniciar:
                _iniciarRuta,
            onCancelar:
                _cancelarRuta,
            onCalcular:
                _calcularRuta,
          ),
        ),

        const SizedBox(
          width:
              AppDimensions.spacingSm,
        ),

        SizedBox(
          width:
              AppDimensions.mapaRutasButtonWidth,
          height:
              AppDimensions.bottomBarHeight,
          child: Material(
            color: AppColors.white,
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radiusPill,
            ),
            elevation:
                AppDimensions.elevationFloating,
            child: InkWell(
              onTap:
                  _mostrarRutasPredefinidas,
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radiusPill,
              ),
              child: Row(
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

                  const SizedBox(
                    width:
                        AppDimensions.spacingXs +
                            AppDimensions.spacingXs /
                                2,
                  ),

                  const Text(
                    'Rutas',
                    style:
                        TextStyle(
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
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        leading: _modoSitioPublico
            ? IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                tooltip: 'Volver',
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        title: Text(
          _modoSitioPublico
              ? 'Sitio turístico'
              : 'Mi Ruta Mágica del Café',
        ),
        centerTitle: true,
        actions: [
          if (!_modoSitioPublico)
            IconButton(
              onPressed: _mapaController.cargarDatos,
              tooltip: 'Actualizar',
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),

      body: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final ancho =
              constraints.maxWidth;

          final pantallaPequena =
              ancho < 600;

          final controlesTop =
              pantallaPequena
                  ? AppDimensions
                      .mapaControlesTopPequeno
                  : AppDimensions
                      .mapaControlesTopGrande;

          return Stack(
            children: [
              // ==================================================
              // MAPA
              // ==================================================

              MapaCapas(
                mapController:
                    _mapController,

                // Mientras se crea la ruta se muestran los sitios
                // disponibles. Cuando existe una ruta guardada,
                // mostramos únicamente sus sitios.
                sitios: _sitiosVisiblesEnMapa,

                ruta:
                    _rutaController
                        .rutaResultado,

                // IMPORTANTE:
                // El controller solo pone esto en true después
                // de "Confirmar ruta".
                mostrarRuta:
                    _rutaController
                        .mostrarRutaGuardada,

                ubicacionUsuario:
                    _ubicacionUsuario,

                estaSeleccionado:
                    _estaSeleccionado,

                numeroDeSitio:
                    _numeroDeSitio,

                onTapSitio:
                    (sitio) {
                  if (_rutaController
                      .modoCrearRuta) {
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
              // BUSCADOR + CATEGORÍAS
              // ==================================================
              //
              // Ambos elementos están dentro de la misma columna.
              //
              // Cuando MapaBuscador despliega sus resultados,
              // la columna aumenta su altura y las categorías
              // se desplazan hacia abajo automáticamente.
              //
              // De esta manera las categorías nunca quedan
              // encima de los resultados de búsqueda.
              //

              if (!_modoSitioPublico)
              Positioned(
                top:
                    AppDimensions.spacingMd,

                left:
                    AppDimensions.spacingMd,

                right:
                    AppDimensions.spacingMd,

                child: SafeArea(
                  bottom: false,

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,

                    children: [
                      // ------------------------------------------
                      // BUSCADOR
                      // ------------------------------------------

                      MapaBuscador(
                        controller:
                            _busquedaController,

                        resultados:
                            _mapaController
                                .resultadosBusqueda,

                        onChanged:
                            _mapaController
                                .buscar,

                        onSeleccionar:
                            _seleccionarResultado,

                        onLimpiar:
                            _limpiarBusqueda,
                      ),

                      const SizedBox(
                        height:
                            AppDimensions.spacingSm,
                      ),

                      // ------------------------------------------
                      // CATEGORÍAS
                      // ------------------------------------------

                      MapaCategorias(
                        categorias:
                            _mapaController
                                .categorias,

                        categoriaSeleccionada:
                            _mapaController
                                .categoriaSeleccionada,

                        onCategoriaSeleccionada:
                            _seleccionarCategoria,
                      ),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // CONTROLES
              // ==================================================

              if (!_modoSitioPublico)
              Positioned(
                right:
                    AppDimensions.spacingMd,
                top:
                    controlesTop,
                child: SafeArea(
                  bottom: false,
                  child:
                      MapaControles(
                    onCentrar:
                        _centrarMapa,
                    onMostrarTodos:
                        _mostrarTodosLosSitios,
                  ),
                ),
              ),

              // ==================================================
              // RUTA GUARDADA
              // ==================================================

              if (!_modoSitioPublico &&
                  !_rutaController.modoCrearRuta)
                _botonRutaGuardada(),

              // ==================================================
              // RESUMEN DE RUTA CALCULADA
              // ==================================================

              if (_mostrarResumenRuta)
                _resumenRutaCalculada(),

              // ==================================================
              // PANEL DE RUTA
              // ==================================================

              if (!_mostrarResumenRuta &&
                  _rutaController
                      .modoCrearRuta &&
                  (_rutaController
                          .calculando ||
                      _rutaController
                              .mensaje !=
                          null ||
                      _rutaController
                              .rutaResultado !=
                          null))
                Positioned(
                  left:
                      AppDimensions.spacingMd,
                  right:
                      AppDimensions.spacingMd,
                  bottom:
                      AppDimensions
                          .mapaPanelBottom,
                  child:
                      _panelRuta(),
                ),

              // ==================================================
              // BARRA INFERIOR
              // ==================================================

              if (!_modoSitioPublico &&
                  !_mostrarResumenRuta)
                Positioned(
                  left:
                      AppDimensions.spacingMd,
                  right:
                      AppDimensions.spacingMd,
                  bottom:
                      _rutaController
                              .modoCrearRuta
                          ? AppDimensions
                              .mapaBarraRutaBottom
                          : AppDimensions
                              .spacingXl,
                  child: SafeArea(
                    top: false,
                    child:
                        _barraInferior(),
                  ),
                ),

              // ==================================================
              // CARGANDO
              // ==================================================

              if (_mapaController
                  .cargando)
                Positioned(
                  left:
                      AppDimensions.spacingXl,
                  right:
                      AppDimensions.spacingXl,
                  bottom:
                      AppDimensions
                          .mapaCargaBottom,
                  child: SafeArea(
                    top: false,
                    child: Card(
                      elevation:
                          AppDimensions
                              .elevationHigh,
                      child: const Padding(
                        padding:
                            EdgeInsets.all(
                          AppDimensions
                              .spacingLg,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width:
                                  AppDimensions
                                      .iconLg,
                              height:
                                  AppDimensions
                                      .iconLg,
                              child:
                                  CircularProgressIndicator(),
                            ),

                            SizedBox(
                              width:
                                  AppDimensions
                                      .spacingMd,
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

              if (_mapaController
                      .error !=
                  null)
                Positioned(
                  left:
                      AppDimensions.spacingXl,
                  right:
                      AppDimensions.spacingXl,
                  bottom:
                      AppDimensions
                          .mapaErrorBottom,
                  child: SafeArea(
                    top: false,
                    child: Card(
                      elevation:
                          AppDimensions
                              .elevationHigh,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          AppDimensions
                              .spacingLg,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons
                                      .error_outline,
                                  color:
                                      AppColors
                                          .error,
                                ),

                                SizedBox(
                                  width:
                                      AppDimensions
                                          .spacingSm,
                                ),

                                Expanded(
                                  child: Text(
                                    'No se pudieron cargar los datos',
                                    style:
                                        TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height:
                                  AppDimensions
                                      .spacingSm,
                            ),

                            Text(
                              _mapaController
                                  .error!,
                              maxLines: 4,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    AppColors
                                        .textSecondary,
                              ),
                            ),

                            const SizedBox(
                              height:
                                  AppDimensions
                                          .spacingSm +
                                      AppDimensions
                                          .spacingXs,
                            ),

                            ElevatedButton
                                .icon(
                              onPressed:
                                  _mapaController
                                      .cargarDatos,
                              icon:
                                  const Icon(
                                Icons.refresh,
                              ),
                              label:
                                  const Text(
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