import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../config/mapa_corredor.dart';
import '../controllers/mapa_controller.dart';
import '../controllers/mapa_ruta_controller.dart';
import '../models/ruta_model.dart';
import '../models/sitio_turistico_model.dart';
import '../services/ruta_service.dart';
import '../services/ubicacion_service.dart';
import '../services/usuario/usuario_sesion_service.dart';
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
import 'usuario/detalle_sitio_usuario_screen.dart';
import '../l10n/textos.dart';

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

  final RutaService _rutaService = RutaService();

  bool _obteniendoUbicacion = false;
  bool _guardandoRuta = false;
  LatLng? _ubicacionUsuario;

  // ============================================================
// MODO SITIO PÚBLICO
// ============================================================

bool _sitioInicialCentrado = false;

bool get _modoSitioPublico =>
    widget.sitioInicial != null;

  // Solo se dibujan sitios con coordenadas válidas dentro del
  // corredor Garzón – Gigante. Una coordenada errónea (por
  // ejemplo con el signo invertido) mandaba el mapa a otro
  // continente.
  List<SitioTuristicoModel> get _sitiosVisiblesEnMapa {
    final List<SitioTuristicoModel> lista;

    if (_rutaController.rutaGuardada) {
      lista = _rutaController.rutaGuardadaSitios;
    } else if (_modoSitioPublico) {
      lista = <SitioTuristicoModel>[widget.sitioInicial!];
    } else {
      lista = _mapaController.sitiosFiltrados;
    }

    return lista
        .where((sitio) => sitio.enAreaTuristica)
        .toList();
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

  // Cuando el mapa se abre con una ruta ya cargada (por ejemplo
  // desde la sección Rutas), la cámara se ajusta al recorrido.
  if (_rutaController.rutaGuardada &&
      _rutaController.mostrarRutaGuardada) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _ajustarARuta();
        }
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

    if (sitio.enAreaTuristica) {
      _mapController.move(
        sitio.ubicacion,
        AppDimensions.mapaDetalleZoom,
      );
    }

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
          content: Tr(
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
          content: Tr(
            'Selecciona mínimo 2 sitios para calcular la ruta.',
          ),
        ),
      );

      return;
    }

    // Punto de partida: ubicación real del usuario (si es posible).
    _mostrarMensajeUbicacion(
      Textos.t('Obteniendo tu ubicación para iniciar la ruta...'),
    );

    final origen =
        await UbicacionService.obtenerOrigenRuta();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (origen.punto != null) {
      setState(() {
        _ubicacionUsuario = origen.punto;
      });
    }

    final correcta =
        await _rutaController.calcularRuta(
      origen: origen.punto,
      avisoOrigen: origen.aviso,
    );

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

        _ajustarARuta();
      },
    );
  }

  // ============================================================
  // CONFIRMAR RUTA CALCULADA
  // ============================================================

  Future<void> _confirmarRutaCalculada() async {
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

        _ajustarARuta();
      },
    );

    // La ruta ya se ve en el mapa. Ahora se ofrece guardarla en
    // la cuenta para recuperarla desde la sección Rutas.
    await _ofrecerGuardarRuta();
  }

  // ============================================================
  // GUARDAR LA RUTA CONFIRMADA
  // ============================================================
  //
  // Usa el mismo servicio y el mismo endpoint (POST /api/rutas)
  // que la pantalla "Crear ruta" de la sección Rutas, por lo que
  // la ruta guardada aquí aparece allí y viceversa.
  //
  // Solo se guarda si el usuario lo acepta. Abrir una plantilla
  // o calcular una ruta nunca guarda nada por sí solo.
  // ============================================================

  Future<void> _ofrecerGuardarRuta() async {
    if (!mounted || _guardandoRuta) {
      return;
    }

    // Ya guardada (por ejemplo, creada desde la sección Rutas).
    if (_rutaController.rutaPersistidaId != null) {
      return;
    }

    // Las rutas predefinidas ya están disponibles para todos en la
    // sección Rutas: no se guardan como ruta personal.
    if (_rutaController.esRutaPredefinida) {
      return;
    }

    final sitios = _rutaController.rutaGuardadaSitios;

    if (sitios.length < 2) {
      return;
    }

    final sesion =
        UsuarioSesionService.instance.sesionActual.value;

    if (sesion == null ||
        sesion.id.trim().isEmpty ||
        sesion.token.trim().isEmpty) {
      _mostrarMensajeUbicacion(
        Textos.t('Inicia sesión para guardar tus rutas.'),
      );

      return;
    }

    final nombre = await _pedirNombreRuta(
      _rutaController.nombreRuta,
    );

    if (!mounted || nombre == null) {
      return;
    }

    setState(() {
      _guardandoRuta = true;
    });

    try {
      final creada = await _rutaService.crearRuta(
        usuarioId: sesion.id,
        nombre: nombre,
        sitios: sitios.map((sitio) => sitio.id).toList(),
        descripcion:
            'Ruta personalizada creada desde el mapa.',
        tipo: 'personalizada',
        activa: true,
        token: sesion.token,
      );

      if (!mounted) {
        return;
      }

      _rutaController.marcarRutaPersistida(
        id: creada.id,
        nombre: nombre,
      );

      _mostrarMensajeUbicacion(
        Textos.t('Ruta guardada. Encuéntrala en la sección Rutas.'),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final detalle = error
          .toString()
          .replaceFirst('Exception: ', '');

      _mostrarMensajeUbicacion(
        Textos.t('La ruta se muestra en el mapa, pero no se guardó: {0}', [detalle]),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardandoRuta = false;
        });
      }
    }
  }

  Future<String?> _pedirNombreRuta(
    String nombreInicial,
  ) {
    final controller = TextEditingController(
      text: nombreInicial,
    );

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Tr('Guardar ruta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Tr(
                'Guárdala para recuperarla desde la sección Rutas. Se conserva 24 horas.',
              ),
              const SizedBox(
                height: AppDimensions.spacingMd,
              ),
              TextField(
                controller: controller,
                maxLength: 60,
                textCapitalization:
                    TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: Textos.t('Nombre de la ruta'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Tr('Solo ver'),
            ),
            ElevatedButton(
              onPressed: () {
                final nombre = controller.text.trim();

                if (nombre.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop(nombre);
              },
              child: const Tr('Guardar'),
            ),
          ],
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

        _ajustarARuta();
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
    RutaModel ruta,
  ) async {
    final seleccionada =
        await _rutaController.seleccionarRutaApi(
      ruta: ruta,
      sitios:
          _mapaController.todosLosSitios,
    );

    if (!mounted) {
      return;
    }

    if (!seleccionada) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _rutaController.mensaje ??
                Textos.t('No fue posible abrir la ruta.'),
          ),
        ),
      );
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
    _abrirDetalleSitio(sitio);
  }

  // Abre la pantalla completa del sitio (categoria y actividades).
  void _abrirDetalleSitio(
    SitioTuristicoModel sitio,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetalleSitioUsuarioScreen(
          sitio: sitio,
        ),
      ),
    );
  }

  // Tarjeta inferior anterior: se conserva por si se quiere volver a usar.
  // ignore: unused_element
  void _mostrarTarjetaSitio(
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

            if (sitio.enAreaTuristica) {
              _mapController.move(
                sitio.ubicacion,
                AppDimensions.mapaDetalleZoom,
              );
            }
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
          (sitio) => sitio.enAreaTuristica,
        )
        .toList();

    // Sin sitios válidos se muestra el corredor, nunca una
    // posición arbitraria.
    if (validos.isEmpty) {
      _verCorredor();

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
  // AJUSTAR A LA RUTA (GEOMETRÍA DE CARRETERA)
  // ============================================================
  //
  // Encuadra la geometría real de la ruta; si no hay geometría
  // se encuadran los sitios de la ruta.
  // ============================================================

  void _ajustarARuta() {
    final resultado = _rutaController.rutaResultado;

    final puntos = resultado?.puntos
            .where(MapaCorredor.contienePunto)
            .toList() ??
        const <LatLng>[];

    if (puntos.length < 2) {
      _ajustarMapa(
        sitios: _rutaController.rutaGuardadaSitios,
        padding: AppDimensions.mapaRutaPadding,
        maxZoom: AppDimensions.mapaRutaMaxZoom,
      );

      return;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(puntos),
        padding: const EdgeInsets.all(
          AppDimensions.mapaRutaPadding,
        ),
        maxZoom: AppDimensions.mapaRutaMaxZoom,
      ),
    );
  }

  // ============================================================
  // VER EL CORREDOR GARZÓN – GIGANTE
  // ============================================================

  void _verCorredor() {
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          MapaCorredor.vistaSuroeste,
          MapaCorredor.vistaNoreste,
        ),
        padding: const EdgeInsets.all(
          AppDimensions.spacingLg,
        ),
        maxZoom: AppDimensions.mapaMaxZoom,
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
      // Única implementación de geolocalización de la app:
      // comprueba servicio, permisos y obtiene el GPS real.
      final resultado = await UbicacionService.obtener(
        precision: LocationAccuracy.high,
      );

      if (!mounted) {
        return;
      }

      switch (resultado.estado) {
        case EstadoUbicacion.servicioDesactivado:
          await _mostrarDialogoUbicacion(
            titulo: Textos.t('Ubicación desactivada'),
            mensaje:
                Textos.t('Para centrar el mapa en tu ubicación actual, activa la ubicación del dispositivo.'),
            accionTexto: Textos.t('Abrir ubicación'),
            accion: Geolocator.openLocationSettings,
          );

          return;

        case EstadoUbicacion.permisoDenegado:
          _mostrarMensajeUbicacion(
            Textos.t('Se necesita permiso de ubicación para centrar el mapa.'),
          );

          return;

        case EstadoUbicacion.permisoBloqueado:
          await _mostrarDialogoUbicacion(
            titulo: Textos.t('Permiso de ubicación requerido'),
            mensaje:
                Textos.t('El permiso de ubicación está bloqueado. Puedes habilitarlo desde la configuración de la aplicación.'),
            accionTexto: Textos.t('Abrir configuración'),
            accion: Geolocator.openAppSettings,
          );

          return;

        case EstadoUbicacion.error:
          _mostrarMensajeUbicacion(
            Textos.t('No fue posible obtener tu ubicación actual. Se muestra el corredor Garzón–Gigante.'),
          );

          _verCorredor();

          return;

        case EstadoUbicacion.disponible:
          break;
      }

      final ubicacion = resultado.ubicacion;

      if (ubicacion == null) {
        _mostrarMensajeUbicacion(
          Textos.t('No fue posible obtener tu ubicación actual.'),
        );

        return;
      }

      final ubicacionActual = LatLng(
        ubicacion.latitud,
        ubicacion.longitud,
      );

      // El mapa está limitado al corredor. Si el usuario está
      // fuera de él se le dice con claridad y no se finge una
      // posición.
      if (!MapaCorredor.contienePunto(ubicacionActual)) {
        final km =
            MapaCorredor.distanciaAlCentroKm(ubicacionActual);

        _mostrarMensajeUbicacion(
          Textos.t('Estás fuera del corredor Garzón–Gigante (a unos {0} km). Se muestra el área turística.', [km.round()]),
        );

        _verCorredor();

        return;
      }

      setState(() {
        _ubicacionUsuario = ubicacionActual;
      });

      _mapController.move(
        ubicacionActual,
        AppDimensions.mapaDetalleZoom,
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
                  const Tr('Cancelar'),
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
  // BOTÓN DE MAPA: RESTABLECER LA VISTA DEL CORREDOR
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

    // Restablece la vista del corredor Garzón – Gigante.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        _verCorredor();
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
                        ? Textos.t('Ocultar ruta')
                        : Textos.t('Ver ruta'),
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
              : Textos.t('{0} km', [_rutaController.rutaResultado!.distanciaKm.toStringAsFixed(2)]),
      duracion:
          _rutaController.rutaResultado ==
                  null
              ? ''
              : Textos.t('{0} min', [_rutaController.rutaResultado!.duracionMinutos.toStringAsFixed(0)]),
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
  // ZONA INFERIOR: PANEL DE RUTA + BARRA "CREAR MI RUTA"
  // ============================================================
  //
  // El panel de la ruta (título, sitios y cierre) y la barra
  // "Crear mi ruta" se muestran a la vez al abrir una ruta
  // predefinida. Antes eran dos Positioned anclados a la misma
  // altura y se tapaban entre sí. Ahora van juntos en una sola
  // columna: el panel arriba, la barra debajo y un espacio entre
  // ambos. Si falta altura, el panel se encoge y se desplaza por
  // dentro; en pantallas muy bajas se desplaza toda la zona.
  // ============================================================

  static const double _alturaMinimaZonaInferior = 320;

  bool get _mostrarPanelRuta =>
      !_mostrarResumenRuta &&
      _rutaController.modoCrearRuta &&
      (_rutaController.calculando ||
          _rutaController.mensaje != null ||
          _rutaController.rutaResultado != null);

  bool get _mostrarBarraInferior =>
      !_modoSitioPublico && !_mostrarResumenRuta;

  Widget _zonaInferiorRuta(double topReservado) {
    final bottom = _rutaController.modoCrearRuta
        ? AppDimensions.mapaBarraRutaBottom
        : AppDimensions.spacingXl;

    if (!_mostrarPanelRuta) {
      return Positioned(
        left: AppDimensions.spacingMd,
        right: AppDimensions.spacingMd,
        bottom: bottom,
        child: SafeArea(
          top: false,
          child: _barraInferior(),
        ),
      );
    }

    final panel = _panelRuta();
    final barra = _mostrarBarraInferior ? _barraInferior() : null;

    return Positioned(
      left: AppDimensions.spacingMd,
      right: AppDimensions.spacingMd,
      top: topReservado,
      bottom: bottom,
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, restricciones) {
            final hijos = <Widget>[
              panel,
              if (barra != null) ...[
                const SizedBox(
                  height: AppDimensions.spacingMd,
                ),
                barra,
              ],
            ];

            // Poca altura (pantalla baja o horizontal): todo se
            // desplaza, con los botones siempre al final.
            if (restricciones.maxHeight <
                _alturaMinimaZonaInferior) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: hijos,
                  ),
                ),
              );
            }

            // Altura suficiente: la barra conserva su tamaño y el
            // panel usa el espacio restante (con desplazamiento
            // interno si su contenido no cabe).
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                Flexible(child: panel),
                if (barra != null) ...[
                  const SizedBox(
                    height: AppDimensions.spacingMd,
                  ),
                  barra,
                ],
              ],
            );
          },
        ),
      ),
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
                        child: Tr(
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
                          Textos.t('{0} sitios', [sitios.length]),
                        ),
                      ),
                      Expanded(
                        child:
                            _datoResumenRuta(
                          Icons.alt_route,
                          Textos.t('{0} km', [_rutaController.distanciaTotalKm.toStringAsFixed(1)]),
                        ),
                      ),
                      Expanded(
                        child:
                            _datoResumenRuta(
                          Icons.schedule,
                          Textos.t('{0} de viaje', [_formatoMinutos(_rutaController.duracionTotalMinutos.round())]),
                        ),
                      ),
                    ],
                  ),
                  ..._bloqueActividadesResumen(),

                  const SizedBox(
                    height:
                        AppDimensions.spacingMd,
                  ),

                  const Divider(),

                  const SizedBox(
                    height:
                        AppDimensions.spacingSm,
                  ),

                  _bloqueOrigenResumen(),

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
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      sitio.nombre,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                    if (_rutaController
                                            .minutosActividadDeSitio(
                                          sitio.id,
                                        ) !=
                                        null)
                                      Tr(
                                        '{0} en el sitio', args: [_formatoMinutos(_rutaController.minutosActividadDeSitio(sitio.id)!)],
                                        style:
                                            const TextStyle(
                                          color: AppColors
                                              .textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
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

                                  Tr(
                                    '↓ {0} km · {1} min', args: [tramos[index].distanciaKm.toStringAsFixed(1), tramos[index].duracionMinutos.toStringAsFixed(0)],
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
                              const Tr(
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
                              const Tr(
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

  // ============================================================
  // TIEMPOS: VIAJE vs ACTIVIDADES EN LOS SITIOS
  // ============================================================
  //
  // El tiempo de viaje sale del cálculo por carretera. El tiempo en
  // los sitios es el planificado en el itinerario de la ruta
  // predefinida (estimado). Se muestran por separado y también se
  // da la jornada total estimada (viaje + sitios).
  // ============================================================

  String _formatoMinutos(int minutos) {
    final horas = minutos ~/ 60;
    final resto = minutos % 60;

    if (horas == 0) {
      return Textos.t('{0} min', [resto]);
    }

    if (resto == 0) {
      return Textos.t('{0} h', [horas]);
    }

    return Textos.t('{0} h {1} min', [horas, resto]);
  }

  List<Widget> _bloqueActividadesResumen() {
    final actividades =
        _rutaController.duracionActividadesMinutos;

    if (actividades == null) {
      return const [];
    }

    final viaje =
        _rutaController.duracionTotalMinutos.round();

    return [
      const SizedBox(
        height: AppDimensions.spacingSm,
      ),
      _datoResumenRuta(
        Icons.timer_outlined,
        Textos.t('{0} en los sitios (estimado)', [_formatoMinutos(actividades)]),
      ),
      const SizedBox(
        height: AppDimensions.spacingXs,
      ),
      _datoResumenRuta(
        Icons.hourglass_bottom,
        Textos.t('Jornada total aprox. {0}', [_formatoMinutos(viaje + actividades)]),
      ),
    ];
  }

  // ============================================================
  // ORIGEN DE LA RUTA EN EL RESUMEN
  // ============================================================
  //
  // Muestra el tramo desde la ubicación real del usuario hasta
  // el primer sitio, o explica por qué la ruta empieza en el
  // primer sitio.
  // ============================================================

  Widget _bloqueOrigenResumen() {
    final tramo = _rutaController.tramoOrigen;
    final aviso = _rutaController.avisoOrigen;

    if (tramo == null && aviso == null) {
      return const SizedBox.shrink();
    }

    final texto = tramo != null
        ? Textos.t('Desde tu ubicación · {0} km · {1} min', [tramo.distanciaKm.toStringAsFixed(1), tramo.duracionMinutos.toStringAsFixed(0)])
        : aviso!;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spacingSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            tramo != null
                ? Icons.my_location
                : Icons.location_off_outlined,
            size: AppDimensions.iconMd,
            color: AppColors.primary,
          ),
          const SizedBox(
            width: AppDimensions.spacingSm,
          ),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
        limite:
            _rutaController
                .estado
                .limiteSitios,
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

                  const Tr(
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
                tooltip: Textos.t('Volver'),
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        title: Text(
          _modoSitioPublico
              ? Textos.t('Sitio turístico')
              : Textos.t('Mi Ruta Cafetera'),
        ),
        centerTitle: true,
        actions: [
          if (!_modoSitioPublico)
            IconButton(
              onPressed: _mapaController.cargarDatos,
              tooltip: Textos.t('Actualizar'),
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
              // PANEL DE RUTA + BARRA INFERIOR
              // ==================================================
              //
              // Van en una misma columna para que no se superpongan.

              if (_mostrarPanelRuta ||
                  _mostrarBarraInferior)
                _zonaInferiorRuta(controlesTop),

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
                              child: Tr(
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
                                  child: Tr(
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
                                  const Tr(
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


