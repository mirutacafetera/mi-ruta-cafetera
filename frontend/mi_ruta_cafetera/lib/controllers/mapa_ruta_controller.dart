import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../models/ruta_model.dart';
import '../models/ruta_predefinida_model.dart';
import '../models/sitio_turistico_model.dart';
import '../services/routing_service.dart';
import '../widgets/mapa/mapa_estado_ruta.dart';
import '../l10n/textos.dart';
import 'mapa_ruta/itinerario_ruta_helper.dart';
import 'mapa_ruta/seleccion_ruta_helper.dart';

class MapaRutaController extends ChangeNotifier {
  MapaRutaController({
    RoutingService? routingService,
    MapaEstadoRuta? estadoRuta,
  })  : _routingService = routingService ?? RoutingService(),
        estado = estadoRuta ?? MapaEstadoRuta() {
    estado.addListener(_onEstadoChanged);
  }

  final RoutingService _routingService;
  final MapaEstadoRuta estado;

  // ============================================================
  // RUTA CALCULADA
  // ============================================================

  RutaResultado? _rutaResultado;

  List<SitioTuristicoModel> _rutaGuardadaSitios = [];

  bool _rutaGuardada = false;

  bool _mostrarRutaGuardada = false;

  bool _calculando = false;

  String? _mensaje;

  String _nombreRuta = 'Mi ruta personalizada';

  // ------------------------------------------------------------
  // PUNTO DE PARTIDA (UBICACIÓN REAL DEL USUARIO)
  // ------------------------------------------------------------
  //
  // Si la ruta se calculó desde la ubicación del usuario, el
  // primer tramo calculado va del origen al primer sitio. Ese
  // tramo se guarda aparte para que [tramosRuta] conserve el
  // significado de siempre: un tramo entre cada par de sitios
  // consecutivos.
  // ------------------------------------------------------------

  LatLng? _origen;

  TramoRuta? _tramoOrigen;

  String? _avisoOrigen;

  // ------------------------------------------------------------
  // ITINERARIO DE UNA RUTA PREDEFINIDA (API)
  // ------------------------------------------------------------
  //
  // Tiempo planificado de la ACTIVIDAD en cada sitio, por id de
  // sitio. Es independiente del tiempo de viaje por carretera, que
  // viene del cálculo de la ruta. Vacío en rutas personales.
  // ------------------------------------------------------------
  Map<String, int> _minutosActividadPorSitio = {};

  // true cuando la ruta mostrada es una ruta predefinida de la API
  // (administrada, no guardable como ruta personal).
  bool _esRutaPredefinida = false;

  // Identificador de la ruta ya guardada en la API (si existe).
  // Evita guardar dos veces la misma ruta.
  String? _rutaPersistidaId;

  // ============================================================
  // GETTERS
  // ============================================================

  RutaResultado? get rutaResultado => _rutaResultado;

  List<SitioTuristicoModel> get rutaGuardadaSitios =>
      List.unmodifiable(_rutaGuardadaSitios);

  bool get rutaGuardada => _rutaGuardada;

  bool get mostrarRutaGuardada => _mostrarRutaGuardada;

  bool get calculando => _calculando;

  String? get mensaje => _mensaje;

  String get nombreRuta => _nombreRuta;

  /// Punto de partida (ubicación real del usuario), si se usó.
  LatLng? get origen => _origen;

  /// Tramo entre el origen y el primer sitio.
  TramoRuta? get tramoOrigen => _tramoOrigen;

  /// Explica por qué la ruta no empieza en la ubicación del
  /// usuario (GPS desactivado, permiso denegado, fuera del área).
  String? get avisoOrigen => _avisoOrigen;

  /// true si la ruta es una predefinida de la API. Estas rutas ya
  /// existen para todos los usuarios, por lo que no se ofrecen para
  /// guardar como ruta personal.
  bool get esRutaPredefinida => _esRutaPredefinida;

  /// Minutos planificados en el sitio [sitioId] (ruta predefinida),
  /// o null si la ruta no define ese dato.
  int? minutosActividadDeSitio(String sitioId) =>
      _minutosActividadPorSitio[sitioId];

  /// Suma de los minutos planificados en los sitios de la ruta
  /// mostrada, o null si no hay itinerario con duraciones.
  ///
  /// NO incluye el tiempo de viaje: [duracionTotalMinutos] es solo
  /// el desplazamiento por carretera.
  int? get duracionActividadesMinutos {
    if (_minutosActividadPorSitio.isEmpty) {
      return null;
    }

    var total = 0;
    var hayDatos = false;

    for (final sitio in _rutaGuardadaSitios) {
      final minutos = _minutosActividadPorSitio[sitio.id];

      if (minutos != null) {
        total += minutos;
        hayDatos = true;
      }
    }

    return hayDatos ? total : null;
  }

  /// Identificador de la ruta guardada en la API, o null si la
  /// ruta mostrada todavía no se ha guardado.
  String? get rutaPersistidaId => _rutaPersistidaId;

  bool get modoCrearRuta => estado.modoCrearRuta;

  List<SitioTuristicoModel> get sitiosSeleccionados =>
      estado.sitiosSeleccionados;

  /// Tramos calculados entre cada sitio consecutivo de la ruta.
  ///
  /// 0 = primer sitio -> segundo sitio
  /// 1 = segundo sitio -> tercer sitio
  /// 2 = tercer sitio -> cuarto sitio
  List<TramoRuta> get tramosRuta =>
      _rutaResultado?.tramos ?? const [];

  /// Distancia total de la ruta en kilómetros.
  double get distanciaTotalKm =>
      _rutaResultado?.distanciaKm ?? 0;

  /// Duración total de la ruta en minutos.
  double get duracionTotalMinutos =>
      _rutaResultado?.duracionMinutos ?? 0;

  // ============================================================
  // SINCRONIZACIÓN CON EL ESTADO
  // ============================================================

  void _onEstadoChanged() {
    notifyListeners();
  }

  // ============================================================
  // INICIAR
  // ============================================================

  void iniciar() {
    limpiarRutaGuardada(notificar: false);

    estado.iniciar();
  }

  // ============================================================
  // CANCELAR
  // ============================================================

  void cancelar() {
    _calculando = false;
    _mensaje = null;

    estado.cancelar();
  }

  // ============================================================
  // SELECCIONAR SITIO
  // ============================================================

  bool alternarSitio(
    SitioTuristicoModel sitio,
  ) {
    if (!estado.modoCrearRuta) {
      return false;
    }

    if (!estado.estaSeleccionado(sitio) &&
        estado.limiteAlcanzado) {
      return false;
    }

    return estado.alternarSitio(sitio);
  }

  // ============================================================
  // CALCULAR RUTA
  // ============================================================

  /// Calcula la ruta por carretera con los sitios seleccionados.
  ///
  /// Si se recibe [origen] (ubicación real del usuario) la ruta
  /// empieza ahí: origen -> sitio 1 -> ... -> sitio N. Si no, se
  /// explica el motivo en [avisoOrigen] y la ruta empieza en el
  /// primer sitio.
  Future<bool> calcularRuta({
    LatLng? origen,
    String? avisoOrigen,
  }) async {
    final seleccionados =
        List<SitioTuristicoModel>.from(
      estado.sitiosSeleccionados,
    );

    if (seleccionados.length < 2) {
      _mensaje =
          Textos.t('Selecciona mínimo 2 sitios para calcular la ruta.');

      notifyListeners();

      return false;
    }

    if (seleccionados.any(
      (sitio) => !sitio.enAreaTuristica,
    )) {
      _mensaje =
          Textos.t('Hay sitios sin coordenadas válidas dentro del corredor Garzón–Gigante.');

      notifyListeners();

      return false;
    }

    _calculando = true;
    _mensaje =
        Textos.t('Calculando el mejor recorrido por carretera.');

    notifyListeners();

    try {
      final puntos = <LatLng>[
        ?origen,
        ...seleccionados.map(
          (sitio) => sitio.ubicacion,
        ),
      ];

      final resultado =
          await _routingService.calcularRuta(
        puntos,
      );

      _aplicarResultado(
        resultado,
        origen: origen,
      );

      _avisoOrigen =
          origen == null ? avisoOrigen : null;

      _rutaGuardadaSitios =
          List<SitioTuristicoModel>.from(
        seleccionados,
      );

      _rutaGuardada = true;
      _rutaPersistidaId = null;

      // IMPORTANTE:
      // La ruta ya fue calculada, pero todavía NO
      // se muestra en el mapa.
      _mostrarRutaGuardada = false;

      _calculando = false;
      _mensaje = Textos.t('Ruta calculada correctamente.');

      // NO cancelamos aquí el modo de creación.
      // El usuario debe poder ver el resumen y decidir
      // si confirma o cancela.
      notifyListeners();

      return true;
    } catch (e) {
      _calculando = false;
      _mensaje =
          Textos.t('No fue posible calcular la ruta: {0}', [e]);

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // APLICAR RESULTADO DEL SERVICIO DE RUTAS
  // ============================================================
  //
  // Cuando la ruta incluye origen, el primer tramo es
  // origen -> primer sitio. Se separa en [tramoOrigen] y el resto
  // se re-indexa para que tramosRuta[i] sea sitio i -> sitio i+1.
  // ============================================================

  void _aplicarResultado(
    RutaResultado resultado, {
    LatLng? origen,
  }) {
    _origen = origen;

    if (origen == null || resultado.tramos.isEmpty) {
      _tramoOrigen = null;
      _rutaResultado = resultado;

      return;
    }

    _tramoOrigen = resultado.tramos.first;

    final restantes = <TramoRuta>[];

    for (var i = 1; i < resultado.tramos.length; i++) {
      final tramo = resultado.tramos[i];

      restantes.add(
        TramoRuta(
          indice: i - 1,
          distanciaMetros: tramo.distanciaMetros,
          duracionSegundos: tramo.duracionSegundos,
        ),
      );
    }

    _rutaResultado = RutaResultado(
      puntos: resultado.puntos,
      distanciaMetros: resultado.distanciaMetros,
      duracionSegundos: resultado.duracionSegundos,
      tramos: restantes,
    );
  }

  // ============================================================
  // CONFIRMAR RUTA CALCULADA
  // ============================================================

  void confirmarRuta() {
    if (!_rutaGuardada ||
        _rutaResultado == null) {
      return;
    }

    _mostrarRutaGuardada = true;
    _mensaje = Textos.t('Ruta confirmada.');

    // Ahora sí salimos del modo de creación.
    estado.cancelar();

    notifyListeners();
  }

  // ============================================================
  // CARGAR RUTA GUARDADA
  // ============================================================

  /// Carga y muestra una ruta ya existente (guardada o plantilla).
  ///
  /// [rutaId] es el identificador persistente cuando la ruta es una
  /// ruta personal guardada; para una plantilla se deja en null y
  /// no se guarda nada.
  ///
  /// Los [sitios] deben venir en el orden de visita de la ruta.
  Future<bool> cargarRutaGuardada({
    required String nombre,
    required List<SitioTuristicoModel> sitios,
    String? rutaId,
    LatLng? origen,
    String? avisoOrigen,
    int maxSitios = MapaEstadoRuta.maxSitios,
    List<ParadaRutaModel> paradas = const [],
  }) async {
    if (sitios.length < 2) {
      _mensaje =
          Textos.t('La ruta guardada no tiene suficientes sitios.');

      notifyListeners();

      return false;
    }

    final sitiosValidos = sitios
        .where(
          (sitio) => sitio.enAreaTuristica,
        )
        .take(maxSitios)
        .toList();

    if (sitiosValidos.length < 2) {
      _mensaje =
          Textos.t('Los sitios de esta ruta no tienen coordenadas válidas.');

      notifyListeners();

      return false;
    }

    limpiarRutaGuardada(
      notificar: false,
    );

    _nombreRuta = nombre.trim().isEmpty
        ? 'Mi ruta personalizada'
        : nombre.trim();

    _rutaGuardadaSitios =
        List<SitioTuristicoModel>.from(
      sitiosValidos,
    );

    _rutaPersistidaId = rutaId;
    _minutosActividadPorSitio = _minutosDeParadas(paradas);

    _calculando = true;
    _mensaje =
        Textos.t('Cargando y calculando tu ruta...');

    notifyListeners();

    try {
      final puntos = <LatLng>[
        ?origen,
        ...sitiosValidos.map(
          (sitio) => sitio.ubicacion,
        ),
      ];

      final resultado =
          await _routingService.calcularRuta(
        puntos,
      );

      _aplicarResultado(
        resultado,
        origen: origen,
      );
      _avisoOrigen =
          origen == null ? avisoOrigen : null;
      _rutaGuardada = true;
      _mostrarRutaGuardada = true;
      _calculando = false;
      _mensaje = Textos.t('Ruta cargada correctamente.');

      estado.cancelar();

      notifyListeners();

      return true;
    } catch (e) {
      _rutaResultado = null;
      _rutaGuardadaSitios = [];
      _rutaGuardada = false;
      _mostrarRutaGuardada = false;
      _rutaPersistidaId = null;
      _minutosActividadPorSitio = {};
      _calculando = false;
      _mensaje =
          Textos.t('No fue posible cargar la ruta: {0}', [e]);

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // PERSISTENCIA
  // ============================================================
  //
  // El guardado en la API lo hace la pantalla con RutaService.
  // El controlador solo recuerda el resultado para no guardar
  // dos veces la misma ruta.
  // ============================================================

  void marcarRutaPersistida({
    required String id,
    String? nombre,
  }) {
    _rutaPersistidaId = id;

    if (nombre != null && nombre.trim().isNotEmpty) {
      _nombreRuta = nombre.trim();
    }

    notifyListeners();
  }

  // ============================================================
  // MOSTRAR / OCULTAR RUTA
  // ============================================================

  void alternarVisibilidadRuta() {
    if (!_rutaGuardada) {
      return;
    }

    _mostrarRutaGuardada =
        !_mostrarRutaGuardada;

    notifyListeners();
  }

  void mostrarRuta() {
    if (!_rutaGuardada ||
        _mostrarRutaGuardada) {
      return;
    }

    _mostrarRutaGuardada = true;

    notifyListeners();
  }

  void ocultarRuta() {
    if (!_mostrarRutaGuardada) {
      return;
    }

    _mostrarRutaGuardada = false;

    notifyListeners();
  }

  // ============================================================
  // LIMPIAR RUTA
  // ============================================================

  void limpiarRutaGuardada({
    bool notificar = true,
  }) {
    _rutaResultado = null;
    _rutaGuardadaSitios = [];
    _rutaGuardada = false;
    _mostrarRutaGuardada = false;
    _mensaje = null;
    _nombreRuta = 'Mi ruta personalizada';
    _origen = null;
    _tramoOrigen = null;
    _avisoOrigen = null;
    _rutaPersistidaId = null;
    _minutosActividadPorSitio = {};
    _esRutaPredefinida = false;

    if (notificar) {
      notifyListeners();
    }
  }

  // ============================================================
  // RUTA PREDEFINIDA (PLANTILLA)
  // ============================================================
  //
  // Una plantilla describe QUÉ sitios buscar (municipios y/o
  // categorías). Abrirla NO guarda nada: solo una ruta que el
  // usuario confirma y decide guardar se convierte en ruta
  // personal.
  // ============================================================

  /// Todos los sitios válidos que coinciden con la plantilla.
  List<SitioTuristicoModel>
      buscarSitiosParaRutaPredefinida({
    required RutaPredefinidaModel ruta,
    required List<SitioTuristicoModel> sitios,
  }) {
    return SeleccionRutaHelper.buscarSitios(
      ruta: ruta,
      sitios: sitios,
    );
  }

  /// Elige, en orden de visita, hasta [MapaEstadoRuta.maxSitios]
  /// sitios para la plantilla.
  ///
  /// * Plantillas por municipio (corredores): reparte los sitios
  ///   entre los municipios y respeta el orden de la plantilla
  ///   (por ejemplo Gigante -> Zuluaga -> Garzón).
  /// * Plantillas por categoría: reparte entre las categorías y
  ///   ordena los sitios por cercanía para evitar recorridos en
  ///   zigzag.
  List<SitioTuristicoModel>
      seleccionarSitiosParaRutaPredefinida({
    required RutaPredefinidaModel ruta,
    required List<SitioTuristicoModel> sitios,
  }) {
    return SeleccionRutaHelper.seleccionarSitios(
      ruta: ruta,
      sitios: sitios,
    );
  }

  /// Selecciona los sitios de la plantilla en el modo de creación
  /// del mapa. NO guarda nada.
  Future<void> seleccionarRutaPredefinida({
    required RutaPredefinidaModel ruta,
    required List<SitioTuristicoModel> sitios,
  }) async {
    final seleccionados =
        seleccionarSitiosParaRutaPredefinida(
      ruta: ruta,
      sitios: sitios,
    );

    if (seleccionados.length < 2) {
      _mensaje =
          Textos.t('No hay suficientes sitios disponibles para esta ruta.');

      notifyListeners();

      return;
    }

    limpiarRutaGuardada(
      notificar: false,
    );

    estado.iniciar();

    for (final sitio in seleccionados) {
      estado.alternarSitio(sitio);
    }

    _nombreRuta = ruta.nombre;
    _mensaje =
        Textos.t('Ruta predefinida seleccionada.');

    notifyListeners();
  }

  /// Calcula y muestra una plantilla directamente (por ejemplo,
  /// al abrirla desde la sección Rutas). NO guarda nada.
  Future<bool> cargarRutaPredefinida({
    required RutaPredefinidaModel ruta,
    required List<SitioTuristicoModel> sitios,
  }) async {
    final seleccionados =
        seleccionarSitiosParaRutaPredefinida(
      ruta: ruta,
      sitios: sitios,
    );

    if (seleccionados.length < 2) {
      _mensaje =
          Textos.t('No hay suficientes sitios disponibles para esta ruta.');

      notifyListeners();

      return false;
    }

    return cargarRutaGuardada(
      nombre: ruta.nombre,
      sitios: seleccionados,
    );
  }

  // ============================================================
  // RUTA PREDEFINIDA DE LA API
  // ============================================================
  //
  // Las rutas predefinidas se administran en MongoDB (colección
  // de rutas, tipo "predefinida") y llegan con un itinerario
  // (paradas) en orden de visita. Abrirlas NO guarda nada.
  // ============================================================

  /// Minutos de actividad por id de sitio, tomados de las paradas.
  Map<String, int> _minutosDeParadas(
    List<ParadaRutaModel> paradas,
  ) {
    return ItinerarioRutaHelper.minutosDeParadas(paradas);
  }

  /// Sitios de una ruta de la API en orden de visita (primero por
  /// las paradas; si no hay, por `ruta.sitios`).
  ///
  /// Devuelve una lista vacía si algún sitio de la ruta no está
  /// disponible o no tiene coordenadas válidas dentro del corredor:
  /// una ruta temática incompleta no debe mostrarse como si lo
  /// estuviera.
  List<SitioTuristicoModel> sitiosDeRutaApi({
    required RutaModel ruta,
    required List<SitioTuristicoModel> sitios,
  }) {
    return ItinerarioRutaHelper.sitiosDeRutaApi(
      ruta: ruta,
      sitios: sitios,
    );
  }

  /// Selecciona los sitios de una ruta predefinida de la API en el
  /// modo de creación del mapa, para que el usuario la calcule
  /// (con su ubicación como origen) y la confirme. NO guarda nada.
  Future<bool> seleccionarRutaApi({
    required RutaModel ruta,
    required List<SitioTuristicoModel> sitios,
  }) async {
    final seleccionados = sitiosDeRutaApi(
      ruta: ruta,
      sitios: sitios,
    );

    if (seleccionados.isEmpty) {
      _mensaje =
          Textos.t('Algunos sitios de esta ruta no están disponibles.');
      notifyListeners();
      return false;
    }

    limpiarRutaGuardada(
      notificar: false,
    );

    estado.iniciar(
      limite: MapaEstadoRuta.maxSitiosPredefinida,
    );

    for (final sitio in seleccionados) {
      estado.alternarSitio(sitio);
    }

    _nombreRuta = ruta.nombre;
    _minutosActividadPorSitio = _minutosDeParadas(ruta.paradas);
    _esRutaPredefinida = true;
    _mensaje = Textos.t('Ruta predefinida seleccionada.');

    notifyListeners();

    return true;
  }

  /// Calcula y muestra directamente una ruta predefinida de la API
  /// (por ejemplo, al abrirla desde la sección Rutas). NO guarda
  /// nada. Si se recibe [origen] la ruta empieza en la ubicación
  /// del usuario; si no, se explica el motivo en [avisoOrigen].
  Future<bool> cargarRutaApi({
    required RutaModel ruta,
    required List<SitioTuristicoModel> sitios,
    LatLng? origen,
    String? avisoOrigen,
  }) async {
    final seleccionados = sitiosDeRutaApi(
      ruta: ruta,
      sitios: sitios,
    );

    if (seleccionados.isEmpty) {
      _mensaje =
          Textos.t('Algunos sitios de esta ruta no están disponibles.');
      notifyListeners();
      return false;
    }

    final cargada = await cargarRutaGuardada(
      nombre: ruta.nombre,
      sitios: seleccionados,
      origen: origen,
      avisoOrigen: avisoOrigen,
      maxSitios: MapaEstadoRuta.maxSitiosPredefinida,
      paradas: ruta.paradas,
    );

    if (cargada) {
      _esRutaPredefinida = true;
      notifyListeners();
    }

    return cargada;
  }

  // ============================================================
  // NUMERACIÓN
  // ============================================================

  int numeroDeSitio(
    SitioTuristicoModel sitio,
  ) {
    final indice =
        _rutaGuardadaSitios.indexWhere(
      (item) => item.id == sitio.id,
    );

    return indice == -1
        ? 0
        : indice + 1;
  }

  bool esSitioDeRutaGuardada(
    SitioTuristicoModel sitio,
  ) {
    return _rutaGuardadaSitios.any(
      (item) => item.id == sitio.id,
    );
  }

  // ============================================================
  // CICLO DE VIDA
  // ============================================================

  @override
  void dispose() {
    estado.removeListener(
      _onEstadoChanged,
    );

    estado.dispose();

    super.dispose();
  }
}