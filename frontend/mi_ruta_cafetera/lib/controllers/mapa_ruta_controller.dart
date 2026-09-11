import 'package:flutter/foundation.dart';

import '../models/ruta_predefinida_model.dart';
import '../models/sitio_turistico_model.dart';
import '../services/routing_service.dart';
import '../widgets/mapa/mapa_estado_ruta.dart';

class MapaRutaController extends ChangeNotifier {
  final RoutingService _routingService;

  final MapaEstadoRuta estado;

  MapaRutaController({
    RoutingService? routingService,
    MapaEstadoRuta? estadoRuta,
  })  : _routingService =
            routingService ?? RoutingService(),
        estado =
            estadoRuta ?? MapaEstadoRuta();

  // ============================================================
  // RUTA CALCULADA
  // ============================================================

  RutaResultado? _rutaResultado;

  List<SitioTuristicoModel> _rutaGuardadaSitios = [];

  bool _rutaGuardada = false;

  bool _mostrarRutaGuardada = false;

  bool _calculando = false;

  String? _mensaje;

  String _nombreRuta =
      'Mi ruta personalizada';

  // ============================================================
  // GETTERS
  // ============================================================

  RutaResultado? get rutaResultado =>
      _rutaResultado;

  List<SitioTuristicoModel>
      get rutaGuardadaSitios =>
          List.unmodifiable(
        _rutaGuardadaSitios,
      );

  bool get rutaGuardada =>
      _rutaGuardada;

  bool get mostrarRutaGuardada =>
      _mostrarRutaGuardada;

  bool get calculando =>
      _calculando;

  String? get mensaje =>
      _mensaje;

  String get nombreRuta =>
      _nombreRuta;

  bool get modoCrearRuta =>
      estado.modoCrearRuta;

  List<SitioTuristicoModel>
      get sitiosSeleccionados =>
          estado.sitiosSeleccionados;

  // ============================================================
  // INICIAR
  // ============================================================

  void iniciar() {
    limpiarRutaGuardada();

    estado.iniciar();

    _mensaje = null;

    notifyListeners();
  }

  // ============================================================
  // CANCELAR
  // ============================================================

  void cancelar() {
    estado.cancelar();

    _calculando = false;

    _mensaje = null;

    notifyListeners();
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

    estado.alternarSitio(sitio);

    notifyListeners();

    return true;
  }

  // ============================================================
  // CALCULAR RUTA
  // ============================================================

  Future<bool> calcularRuta() async {
    final seleccionados =
        List<SitioTuristicoModel>.from(
      estado.sitiosSeleccionados,
    );

    if (seleccionados.length < 2) {
      _mensaje =
          'Selecciona mínimo 2 sitios para calcular la ruta.';

      notifyListeners();

      return false;
    }

    _calculando = true;

    _mensaje =
        'Calculando el mejor recorrido por carretera...';

    notifyListeners();

    try {
      // ----------------------------------------------------------
      // El orden enviado corresponde al orden seleccionado.
      //
      // El RoutingService se encarga de consultar el backend
      // y obtener la geometría real de las carreteras.
      // ----------------------------------------------------------

      final puntos = seleccionados
    .map((sitio) => sitio.ubicacion)
    .toList();

      final resultado =
        await _routingService.calcularRuta(
        puntos,
      );

      _rutaResultado = resultado;

      _rutaGuardadaSitios =
          List<SitioTuristicoModel>.from(
        seleccionados,
      );

      _rutaGuardada = true;

      _mostrarRutaGuardada = true;

      _calculando = false;

      _mensaje =
          'Ruta calculada correctamente.';

      estado.cancelar();

      notifyListeners();

      return true;
    } catch (e) {
      _calculando = false;

      _mensaje =
          'No fue posible calcular la ruta: $e';

      notifyListeners();

      return false;
    }
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
    if (!_rutaGuardada) {
      return;
    }

    _mostrarRutaGuardada = true;

    notifyListeners();
  }

  void ocultarRuta() {
    _mostrarRutaGuardada = false;

    notifyListeners();
  }

  // ============================================================
  // LIMPIAR RUTA
  // ============================================================

  void limpiarRutaGuardada() {
    _rutaResultado = null;

    _rutaGuardadaSitios = [];

    _rutaGuardada = false;

    _mostrarRutaGuardada = false;

    _mensaje = null;

    _nombreRuta =
        'Mi ruta personalizada';

    notifyListeners();
  }

  // ============================================================
  // RUTA PREDEFINIDA
  // ============================================================

  List<SitioTuristicoModel>
      buscarSitiosParaRutaPredefinida({
    required RutaPredefinidaModel ruta,
    required List<SitioTuristicoModel> sitios,
  }) {
    final municipios =
        ruta.municipios
            .map(_normalizarTexto)
            .where(
              (item) => item.isNotEmpty,
            )
            .toSet();

    final categorias =
        ruta.categorias
            .map(_normalizarTexto)
            .where(
              (item) => item.isNotEmpty,
            )
            .toSet();

    final resultados =
        sitios.where(
      (sitio) {
        final municipio =
            _normalizarTexto(
          sitio.ciudad,
        );

        final categoria =
            _normalizarTexto(
          sitio.categoriaNombre,
        );

        final coincideMunicipio =
            municipios.contains(
          municipio,
        );

        final coincideCategoria =
            categorias.any(
          (categoriaRuta) {
            return categoria ==
                    categoriaRuta ||
                categoria.contains(
                  categoriaRuta,
                ) ||
                categoriaRuta.contains(
                  categoria,
                );
          },
        );

        if (municipios.isEmpty &&
            categorias.isEmpty) {
          return false;
        }

        if (municipios.isNotEmpty &&
            categorias.isNotEmpty) {
          return coincideMunicipio ||
              coincideCategoria;
        }

        return coincideMunicipio ||
            coincideCategoria;
      },
    ).toList();

    return resultados;
  }

  Future<void> seleccionarRutaPredefinida({
    required RutaPredefinidaModel ruta,
    required List<SitioTuristicoModel> sitios,
  }) async {
    final candidatos =
        buscarSitiosParaRutaPredefinida(
      ruta: ruta,
      sitios: sitios,
    );

    if (candidatos.length < 2) {
      _mensaje =
          'No hay suficientes sitios disponibles para esta ruta.';

      notifyListeners();

      return;
    }

    final seleccionados =
        candidatos.take(4).toList();

    limpiarRutaGuardada();

    estado.iniciar();

    for (final sitio in seleccionados) {
      estado.alternarSitio(sitio);
    }

    _nombreRuta = ruta.nombre;

    _mensaje =
        'Ruta predefinida seleccionada.';

    notifyListeners();
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

    if (indice == -1) {
      return 0;
    }

    return indice + 1;
  }

  bool esSitioDeRutaGuardada(
    SitioTuristicoModel sitio,
  ) {
    return _rutaGuardadaSitios.any(
      (item) => item.id == sitio.id,
    );
  }

  // ============================================================
  // UTILIDADES
  // ============================================================

  String _normalizarTexto(
    String valor,
  ) {
    return valor
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u');
  }

  @override
  void dispose() {
    estado.dispose();
    super.dispose();
  }
}