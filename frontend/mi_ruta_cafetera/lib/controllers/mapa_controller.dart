import 'package:flutter/foundation.dart';

import '../models/categoria_model.dart';
import '../models/sitio_turistico_model.dart';
import '../services/categoria_service.dart';
import '../services/sitio_service.dart';

class MapaController extends ChangeNotifier {
  final SitioService _sitioService;
  final CategoriaService _categoriaService;

  MapaController({
    SitioService? sitioService,
    CategoriaService? categoriaService,
  })  : _sitioService = sitioService ?? SitioService(),
        _categoriaService = categoriaService ?? CategoriaService();

  // ============================================================
  // DATOS
  // ============================================================

  List<SitioTuristicoModel> _todosLosSitios = [];

  List<SitioTuristicoModel> _sitiosFiltrados = [];

  List<CategoriaModel> _categorias = [];

  List<SitioTuristicoModel> _resultadosBusqueda = [];

  String? _categoriaSeleccionada;

  bool _cargando = true;

  String? _error;

  // ============================================================
  // GETTERS
  // ============================================================

  List<SitioTuristicoModel> get todosLosSitios =>
      List.unmodifiable(_todosLosSitios);

  List<SitioTuristicoModel> get sitiosFiltrados =>
      List.unmodifiable(_sitiosFiltrados);

  List<CategoriaModel> get categorias =>
      List.unmodifiable(_categorias);

  List<SitioTuristicoModel> get resultadosBusqueda =>
      List.unmodifiable(_resultadosBusqueda);

  String? get categoriaSeleccionada =>
      _categoriaSeleccionada;

  bool get cargando => _cargando;

  String? get error => _error;

  // ============================================================
  // CARGAR DATOS
  // ============================================================

  Future<void> cargarDatos() async {
    _cargando = true;
    _error = null;

    notifyListeners();

    try {
      final resultados = await Future.wait([
        _sitioService.obtenerSitios(),
        _categoriaService.obtenerCategorias(),
      ]);

      final sitios =
          resultados[0] as List<SitioTuristicoModel>;

      final categorias =
          resultados[1] as List<CategoriaModel>;

      // ========================================================
      // DEBUG TEMPORAL
      // ========================================================

      debugPrint('========================================');
      debugPrint(
        'MAPA - SITIOS RECIBIDOS: ${sitios.length}',
      );
      debugPrint(
        'MAPA - CATEGORIAS RECIBIDAS: ${categorias.length}',
      );
      debugPrint('========================================');

      for (final sitio in sitios) {
        debugPrint(
          '${sitio.nombre} | '
          '${sitio.latitud}, ${sitio.longitud} | '
          '${sitio.categoriaNombre} | '
          'activo=${sitio.activo}',
        );
      }

      debugPrint('========================================');
      debugPrint('MAPA - FIN DE DATOS RECIBIDOS');
      debugPrint('========================================');

      // ========================================================
      // GUARDAR DATOS
      // ========================================================

      _todosLosSitios =
          List<SitioTuristicoModel>.from(sitios);

      _sitiosFiltrados =
          List<SitioTuristicoModel>.from(sitios);

      _categorias =
          List<CategoriaModel>.from(categorias);

      _resultadosBusqueda = [];

      _categoriaSeleccionada = null;

      _cargando = false;

      notifyListeners();
    } catch (e) {
      _cargando = false;

      _error = e.toString();

      debugPrint(
        '========================================',
      );

      debugPrint(
        'MAPA - ERROR AL CARGAR DATOS:',
      );

      debugPrint(
        e.toString(),
      );

      debugPrint(
        '========================================',
      );

      notifyListeners();
    }
  }

  // ============================================================
  // SELECCIONAR CATEGORÍA
  // ============================================================

  void seleccionarCategoria(
    String? categoriaId,
  ) {
    _categoriaSeleccionada = categoriaId;

    aplicarFiltroCategoria();

    notifyListeners();
  }

  // ============================================================
  // FILTRAR CATEGORÍA
  // ============================================================

  void aplicarFiltroCategoria() {
    if (_categoriaSeleccionada == null) {
      _sitiosFiltrados =
          List<SitioTuristicoModel>.from(
        _todosLosSitios,
      );

      return;
    }

    final categoria =
        _buscarCategoriaPorId(
      _categoriaSeleccionada!,
    );

    if (categoria == null) {
      _sitiosFiltrados = [];

      return;
    }

    final idSeleccionado =
        _normalizarId(categoria.id);

    final nombreSeleccionado =
        _normalizarTexto(categoria.nombre);

    _sitiosFiltrados =
        _todosLosSitios.where(
      (sitio) {
        final idSitio =
            _normalizarId(
          sitio.categoriaId,
        );

        final nombreSitio =
            _normalizarTexto(
          sitio.categoriaNombre,
        );

        final coincideId =
            idSitio.isNotEmpty &&
            idSitio == idSeleccionado;

        final coincideNombre =
            nombreSitio.isNotEmpty &&
            nombreSitio == nombreSeleccionado;

        return coincideId || coincideNombre;
      },
    ).toList();
  }

  CategoriaModel? _buscarCategoriaPorId(
    String id,
  ) {
    final idNormalizado =
        _normalizarId(id);

    for (final categoria in _categorias) {
      if (_normalizarId(categoria.id) ==
          idNormalizado) {
        return categoria;
      }
    }

    return null;
  }

  // ============================================================
  // MOSTRAR TODOS
  // ============================================================

  void mostrarTodos() {
    _categoriaSeleccionada = null;

    _sitiosFiltrados =
        List<SitioTuristicoModel>.from(
      _todosLosSitios,
    );

    notifyListeners();
  }

  // ============================================================
  // BUSCAR
  // ============================================================

  void buscar(String texto) {
    final consulta =
        texto.trim().toLowerCase();

    if (consulta.isEmpty) {
      _resultadosBusqueda = [];

      notifyListeners();

      return;
    }

    _resultadosBusqueda =
        _todosLosSitios.where(
      (sitio) {
        final nombre =
            sitio.nombre
                .trim()
                .toLowerCase();

        final descripcion =
            sitio.descripcion
                .trim()
                .toLowerCase();

        final categoria =
            sitio.categoriaNombre
                .trim()
                .toLowerCase();

        final ciudad =
            sitio.ciudad
                .trim()
                .toLowerCase();

        return nombre.contains(consulta) ||
            descripcion.contains(consulta) ||
            categoria.contains(consulta) ||
            ciudad.contains(consulta);
      },
    ).take(8).toList();

    notifyListeners();
  }

  void limpiarBusqueda() {
    _resultadosBusqueda = [];

    notifyListeners();
  }

  // ============================================================
  // UTILIDADES
  // ============================================================

  String normalizarTexto(String valor) {
    return _normalizarTexto(valor);
  }

  String _normalizarId(String valor) {
    return valor
        .trim()
        .toLowerCase();
  }

  String _normalizarTexto(String valor) {
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
}