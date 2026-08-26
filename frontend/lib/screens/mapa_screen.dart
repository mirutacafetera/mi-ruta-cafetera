import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

// ============================================================
// MODELO DE CATEGORÍA
// ============================================================

class CategoriaItem {
  final String id;
  final String nombre;

  CategoriaItem({
    required this.id,
    required this.nombre,
  });

  factory CategoriaItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return CategoriaItem(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      nombre: json['nombre']?.toString() ??
          'General',
    );
  }
}

// ============================================================
// MODELO DE SITIO TURÍSTICO
// ============================================================

class SitioTuristicoItem {
  final String id;
  final String nombre;
  final String descripcion;
  final String direccion;
  final String ciudad;
  final String departamento;
  final double latitud;
  final double longitud;
  final String categoriaId;
  final String categoriaNombre;

  SitioTuristicoItem({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.direccion,
    required this.ciudad,
    required this.departamento,
    required this.latitud,
    required this.longitud,
    required this.categoriaId,
    required this.categoriaNombre,
  });

  LatLng get ubicacion {
    return LatLng(
      latitud,
      longitud,
    );
  }

  factory SitioTuristicoItem.fromJson(
    Map<String, dynamic> json,
  ) {
    String categoriaId = '';
    String categoriaNombre = '';

    final dynamic categoria =
        json['categoria'] ??
        json['categoriaId'] ??
        json['categoria_id'];

    if (categoria is Map) {
      categoriaId =
          categoria['_id']?.toString() ??
          categoria['id']?.toString() ??
          '';

      categoriaNombre =
          categoria['nombre']?.toString() ??
          '';
    } else if (categoria != null) {
      categoriaId =
          categoria.toString();
    }

    double parseDouble(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }

      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }

      if (value is Map) {
        final dynamic valor =
        value['\$numberDouble'] ??
        value['value'];

        if (valor != null) {
          return double.tryParse(
                valor.toString(),
              ) ??
              0.0;
        }
      }

      return 0.0;
    }

    return SitioTuristicoItem(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      nombre:
          json['nombre']?.toString() ??
              'Sin nombre',
      descripcion:
          json['descripcion']?.toString() ??
              'Sin descripción',
      direccion:
          json['direccion']?.toString() ??
              '',
      ciudad:
          json['ciudad']?.toString() ??
              'Garzón',
      departamento:
          json['departamento']?.toString() ??
              'Huila',
      latitud:
          parseDouble(
        json['latitud'],
      ),
      longitud:
          parseDouble(
        json['longitud'],
      ),
      categoriaId:
          categoriaId.trim(),
      categoriaNombre:
          categoriaNombre.trim(),
    );
  }
}

// ============================================================
// ESTILO DE CATEGORÍA
// ============================================================

class EstiloCategoria {
  final IconData icono;
  final Color color;

  EstiloCategoria({
    required this.icono,
    required this.color,
  });
}

// ============================================================
// MODELO DE RUTA PREDEFINIDA
// ============================================================

class RutaModel {
  final String id;
  final String nombre;
  final String descripcion;
  final IconData icono;
  final Color color;
  final List<String> categorias;

  // Municipios que se intentarán utilizar en orden.
  final List<String> municipios;

  final bool esCorredorRegional;

  RutaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.color,
    required this.categorias,
    this.municipios = const [],
    this.esCorredorRegional = false,
  });
}

// ============================================================
// ESTILOS DE MAPA
// ============================================================

class EstiloMapa {
  final String id;
  final String nombre;
  final String urlTemplate;
  final IconData icono;

  const EstiloMapa({
    required this.id,
    required this.nombre,
    required this.urlTemplate,
    required this.icono,
  });
}

// ============================================================
// PANTALLA DEL MAPA
// ============================================================

class MapaScreen extends StatefulWidget {
  const MapaScreen({
    super.key,
  });

  @override
  State<MapaScreen> createState() =>
      _MapaScreenState();
}

// ============================================================
// ESTADO DEL MAPA
// ============================================================

class _MapaScreenState
    extends State<MapaScreen> {
  final MapController _mapController =
      MapController();

  final TextEditingController
      _searchController =
      TextEditingController();

  // ==========================================================
  // DATOS
  // ==========================================================

  List<SitioTuristicoItem>
      _todosLosSitios = [];

  List<SitioTuristicoItem>
      _sitiosFiltrados = [];

  List<CategoriaItem>
      _categorias = [];

  List<SitioTuristicoItem>
      _sitiosSeleccionados = [];

  List<SitioTuristicoItem>
      _sugerenciasBusqueda = [];

  // ==========================================================
  // FILTROS
  // ==========================================================

  CategoriaItem?
      _categoriaSeleccionada;

  String _busquedaTexto = '';

  // ==========================================================
  // RUTA
  // ==========================================================

  RutaModel? _rutaActiva;

  List<LatLng> _puntosRuta = [];

  double _distanciaRuta = 0;

  double _duracionRuta = 0;

  bool _calculandoRuta = false;

  String _mensajeRuta = '';

  // ==========================================================
  // ESTADOS DE INTERFAZ
  // ==========================================================

  bool _cargando = true;

  bool _mostrarPanelRuta = false;

  bool _mostrarCategorias = true;

  bool _mostrarEstilosMapa = false;

  // ==========================================================
  // MODO CREAR RUTA
  // ==========================================================

  bool _modoCrearRuta = false;

  // ==========================================================
  // ESTADO DEL BUSCADOR
  // ==========================================================

  bool _mostrarSugerenciasBusqueda = false;

  // ==========================================================
  // ESTILO ACTUAL DEL MAPA
  // ==========================================================

  EstiloMapa _estiloMapaActual =
      const EstiloMapa(
    id: 'osm',
    nombre: 'OpenStreetMap',
    urlTemplate:
        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    icono: Icons.map,
  );

  // ==========================================================
  // ESTILOS DISPONIBLES
  // ==========================================================

  final List<EstiloMapa> _estilosMapa =
      const [
    EstiloMapa(
      id: 'osm',
      nombre: 'OpenStreetMap',
      urlTemplate:
          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      icono: Icons.map,
    ),
    EstiloMapa(
      id: 'light',
      nombre: 'Mapa claro',
      urlTemplate:
          'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
      icono: Icons.light_mode,
    ),
    EstiloMapa(
      id: 'dark',
      nombre: 'Mapa oscuro',
      urlTemplate:
          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
      icono: Icons.dark_mode,
    ),
  ];

  // ==========================================================
  // RUTAS PREDEFINIDAS
  // ==========================================================

  final List<RutaModel>
      _rutasPredefinidas = [
    // --------------------------------------------------------
    // RUTA PRINCIPAL DEL CORREDOR
    // --------------------------------------------------------

    RutaModel(
      id:
          'corredor_gigante_zuluaga_garzon',
      nombre:
          'Gigante → Zuluaga → Garzón',
      descripcion:
          'Recorrido regional por carretera pasando por Gigante, Zuluaga y Garzón cuando existan sitios registrados.',
      icono:
          Icons.alt_route,
      color:
          Color(0xFF6F4E37),
      categorias: [],
      municipios: [
        'Gigante',
        'Zuluaga',
        'Garzón',
      ],
      esCorredorRegional:
          true,
    ),

    // --------------------------------------------------------
    // RUTA DIRECTA
    // --------------------------------------------------------

    RutaModel(
      id:
          'corredor_gigante_garzon',
      nombre:
          'Gigante → Garzón',
      descripcion:
          'Recorrido directo entre Gigante y Garzón por carretera.',
      icono:
          Icons.route,
      color:
          Color(0xFF1565C0),
      categorias: [],
      municipios: [
        'Gigante',
        'Garzón',
      ],
      esCorredorRegional:
          true,
    ),

    // --------------------------------------------------------
    // RUTA TEMÁTICA
    // --------------------------------------------------------

    RutaModel(
      id: 'r1',
      nombre:
          'Ruta Integral del Café Especial',
      descripcion:
          'Café, naturaleza, gastronomía, miradores y productos locales.',
      icono:
          Icons.coffee,
      color:
          Color(0xFF6F4E37),
      categorias: [
        'Café',
        'Aventuras',
        'Experiencias Familiares',
        'Artesanías y Productos Locales',
      ],
    ),

    RutaModel(
      id: 'r2',
      nombre:
          'Aventura y Naturaleza Cafetera',
      descripcion:
          'Naturaleza, senderos, miradores y aventura.',
      icono:
          Icons.terrain,
      color:
          Color(0xFF2E7D32),
      categorias: [
        'Aventuras',
      ],
    ),

    RutaModel(
      id: 'r3',
      nombre:
          'Experiencia Familiar y Tradición',
      descripcion:
          'Cultura, experiencias familiares y productos locales.',
      icono:
          Icons.family_restroom,
      color:
          Color(0xFFF57F17),
      categorias: [
        'Cultura e Historia',
        'Experiencias Familiares',
        'Artesanías y Productos Locales',
      ],
    ),
  ];

  // ==========================================================
  // INICIALIZACIÓN
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _actualizarSugerencias,
    );

    _cargarDatos();
  }

  // ==========================================================
  // CARGAR DATOS DESDE MONGO
  // ==========================================================

  Future<void> _cargarDatos() async {
    if (mounted) {
      setState(() {
        _cargando = true;
      });
    }

    try {
      // ------------------------------------------------------
      // CATEGORÍAS
      // ------------------------------------------------------

      final responseCategorias =
          await http
              .get(
            Uri.parse(
              ApiConfig
                  .categoriasSitiosUrl,
            ),
          )
              .timeout(
            const Duration(
              seconds: 15,
            ),
          );

      if (responseCategorias
              .statusCode ==
          200) {
        final decoded =
            jsonDecode(
          responseCategorias.body,
        );

        List<dynamic> lista = [];

        if (decoded is List) {
          lista = decoded;
        } else if (decoded
            is Map<String, dynamic>) {
          final posibles =
              decoded['categorias'] ??
              decoded['data'] ??
              decoded['results'];

          if (posibles is List) {
            lista = posibles;
          }
        }

        _categorias = lista
            .whereType<Map>()
            .map(
              (item) =>
                  CategoriaItem
                      .fromJson(
                Map<String, dynamic>
                    .from(item),
              ),
            )
            .where(
              (categoria) =>
                  categoria.id
                      .isNotEmpty ||
                  categoria.nombre
                      .isNotEmpty,
            )
            .toList();
      }

      // ------------------------------------------------------
      // SITIOS TURÍSTICOS
      // ------------------------------------------------------

      final responseSitios =
          await http
              .get(
            Uri.parse(
              ApiConfig.sitiosUrl,
            ),
          )
              .timeout(
            const Duration(
              seconds: 20,
            ),
          );

      if (responseSitios
              .statusCode !=
          200) {
        throw Exception(
          'Error HTTP ${responseSitios.statusCode}',
        );
      }

      final decodedSitios =
          jsonDecode(
        responseSitios.body,
      );

      List<dynamic> listaSitios = [];

      if (decodedSitios is List) {
        listaSitios =
            decodedSitios;
      } else if (decodedSitios
          is Map<String, dynamic>) {
        final posibles =
            decodedSitios['sitios'] ??
            decodedSitios[
                'sitiosTuristicos'] ??
            decodedSitios['data'] ??
            decodedSitios['results'];

        if (posibles is List) {
          listaSitios =
              posibles;
        }
      }

      _todosLosSitios =
          listaSitios
              .whereType<Map>()
              .map(
                (item) =>
                    SitioTuristicoItem
                        .fromJson(
                  Map<String, dynamic>
                      .from(item),
                ),
              )
              .where(
                (sitio) =>
                    sitio.latitud !=
                        0 &&
                    sitio.longitud !=
                        0,
              )
              .toList();

      debugPrint(
        '======================================',
      );

      debugPrint(
        'SITIOS RECIBIDOS DESDE MONGO: '
        '${_todosLosSitios.length}',
      );

      debugPrint(
        'CATEGORÍAS RECIBIDAS: '
        '${_categorias.length}',
      );

      debugPrint(
        '======================================',
      );

      for (final categoria
          in _categorias) {
        debugPrint(
          'CATEGORIA: '
          '${categoria.nombre}',
        );
      }

      _aplicarFiltros(
        usarSetState: false,
      );
    } catch (error) {
      debugPrint(
        'ERROR CARGANDO MAPA: $error',
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'No fue posible cargar los sitios: $error',
            ),
            duration:
                const Duration(
              seconds: 5,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  // ==========================================================
  // FILTRAR SITIOS
  // ==========================================================

  void _aplicarFiltros({
    bool usarSetState = true,
  }) {
    final query =
        _normalizarTexto(
      _busquedaTexto,
    );

    final resultado =
        _todosLosSitios.where(
      (sitio) {
        bool coincideCategoria =
            true;

        if (_categoriaSeleccionada !=
            null) {
          final categoria =
              _categoriaSeleccionada!;

          coincideCategoria =
              sitio.categoriaId ==
                      categoria.id ||
                  _normalizarTexto(
                        sitio
                            .categoriaNombre,
                      ) ==
                      _normalizarTexto(
                        categoria.nombre,
                      );
        }

        final textoSitio =
            _normalizarTexto(
          '${sitio.nombre} '
          '${sitio.ciudad} '
          '${sitio.descripcion} '
          '${sitio.direccion} '
          '${sitio.categoriaNombre}',
        );

        final coincideBusqueda =
            query.isEmpty ||
                textoSitio
                    .contains(query);

        return coincideCategoria &&
            coincideBusqueda;
      },
    ).toList();

    if (usarSetState &&
        mounted) {
      setState(() {
        _sitiosFiltrados =
            resultado;
      });
    } else {
      _sitiosFiltrados =
          resultado;
    }
  }

  // ==========================================================
  // AUTOCOMPLETADO DEL BUSCADOR
  // ==========================================================

  void _actualizarSugerencias() {
    final texto =
        _normalizarTexto(
      _searchController.text,
    );

    if (texto.isEmpty) {
      if (mounted) {
        setState(() {
          _mostrarSugerenciasBusqueda =
              false;
          _sugerenciasBusqueda = [];
        });
      }

      return;
    }

    final coincidencias =
        _todosLosSitios.where(
      (sitio) {
        final contenido =
            _normalizarTexto(
          '${sitio.nombre} '
          '${sitio.ciudad} '
          '${sitio.categoriaNombre} '
          '${sitio.direccion}',
        );

        return contenido.contains(
          texto,
        );
      },
    ).take(8).toList();

    if (mounted) {
      setState(() {
        _sugerenciasBusqueda =
            coincidencias;

        _mostrarSugerenciasBusqueda =
            coincidencias.isNotEmpty;
      });
    }
  }

  // ==========================================================
  // SELECCIONAR SUGERENCIA
  // ==========================================================

  void _seleccionarSugerencia(
    SitioTuristicoItem sitio,
  ) {
    _searchController.text =
        sitio.nombre;

    _busquedaTexto =
        sitio.nombre;

    _mostrarSugerenciasBusqueda =
        false;

    _aplicarFiltros();

    _mapController.move(
      sitio.ubicacion,
      15,
    );

    _mostrarDetalles(
      sitio,
    );
  }

  // ==========================================================
  // ESTILO DE CATEGORÍA
  // ==========================================================

  EstiloCategoria
      _obtenerEstiloCategoria(
    String id,
    String nombre,
  ) {
    final texto =
        _normalizarTexto(
      '$id $nombre',
    );

    if (texto.contains('cafe') ||
        texto.contains('cafetera')) {
      return EstiloCategoria(
        icono:
            Icons.coffee,
        color:
            const Color(0xFF6F4E37),
      );
    }

    if (texto.contains(
          'aventura',
        ) ||
        texto.contains(
          'naturaleza',
        ) ||
        texto.contains(
          'mirador',
        )) {
      return EstiloCategoria(
        icono:
            Icons.terrain,
        color:
            const Color(0xFF2E7D32),
      );
    }

    if (texto.contains(
          'cultura',
        ) ||
        texto.contains(
          'historia',
        )) {
      return EstiloCategoria(
        icono:
            Icons.account_balance,
        color:
            const Color(0xFF7B1FA2),
      );
    }

    if (texto.contains(
          'artesania',
        ) ||
        texto.contains(
          'producto',
        )) {
      return EstiloCategoria(
        icono:
            Icons.storefront,
        color:
            const Color(0xFFE65100),
      );
    }

    if (texto.contains(
      'famil',
    )) {
      return EstiloCategoria(
        icono:
            Icons.family_restroom,
        color:
            const Color(0xFFF57F17),
      );
    }

    if (texto.contains(
          'alojamiento',
        ) ||
        texto.contains(
          'hotel',
        ) ||
        texto.contains(
          'hospedaje',
        )) {
      return EstiloCategoria(
        icono:
            Icons.hotel,
        color:
            const Color(0xFF1565C0),
      );
    }

    if (texto.contains(
      'gastronom',
    )) {
      return EstiloCategoria(
        icono:
            Icons.restaurant,
        color:
            const Color(0xFFC62828),
      );
    }

    if (texto.contains(
      'relig',
    )) {
      return EstiloCategoria(
        icono:
            Icons.church,
        color:
            const Color(0xFF4527A0),
      );
    }

    return EstiloCategoria(
      icono:
          Icons.location_on,
      color:
          const Color(0xFF00838F),
    );
  }

  // ==========================================================
  // SELECCIONAR / DESELECCIONAR SITIO
  // ==========================================================

  void _alternarSeleccionSitio(
    SitioTuristicoItem sitio,
  ) {
    if (!_modoCrearRuta) {
      _mostrarDetalles(
        sitio,
      );
      return;
    }

    setState(() {
      final existe =
          _sitiosSeleccionados.any(
        (item) =>
            item.id == sitio.id,
      );

      if (existe) {
        _sitiosSeleccionados
            .removeWhere(
          (item) =>
              item.id == sitio.id,
        );
      } else {
        _sitiosSeleccionados
            .add(sitio);
      }

      _mostrarPanelRuta =
          _sitiosSeleccionados
              .isNotEmpty;
    });
  }

  // ==========================================================
  // COMPROBAR SI UN SITIO ESTÁ SELECCIONADO
  // ==========================================================

  bool _estaSeleccionado(
    SitioTuristicoItem sitio,
  ) {
    return _sitiosSeleccionados
        .any(
      (item) =>
          item.id == sitio.id,
    );
  }

  // ==========================================================
  // ACTIVAR MODO CREAR RUTA
  // ==========================================================

  void _activarModoCrearRuta() {
    setState(() {
      _modoCrearRuta = true;

      _rutaActiva = null;

      _puntosRuta = [];

      _distanciaRuta = 0;

      _duracionRuta = 0;

      _mensajeRuta =
          'Selecciona mínimo 2 sitios';

      _sitiosSeleccionados =
          [];

      _mostrarPanelRuta = true;
    });

    _mostrarMensaje(
      'Selecciona 2 o más sitios del mapa.',
    );
  }

  // ==========================================================
  // CANCELAR CREACIÓN DE RUTA
  // ==========================================================

  void _cancelarCrearRuta() {
    setState(() {
      _modoCrearRuta = false;

      _rutaActiva = null;

      _sitiosSeleccionados =
          [];

      _puntosRuta = [];

      _distanciaRuta = 0;

      _duracionRuta = 0;

      _mensajeRuta = '';

      _mostrarPanelRuta =
          false;

      _mostrarSugerenciasBusqueda =
          false;
    });
  }

  // ==========================================================
  // CREAR RUTA PERSONALIZADA
  // ==========================================================

  Future<void>
      _generarRutaPersonalizada() async {
    if (_sitiosSeleccionados.length <
        2) {
      _mostrarMensaje(
        'Selecciona mínimo 2 sitios para generar una ruta.',
      );
      return;
    }

    final sitiosOrdenados =
        _ordenarSitiosParaRuta(
      _sitiosSeleccionados,
    );

    setState(() {
      _sitiosSeleccionados =
          sitiosOrdenados;

      _rutaActiva = null;

      _mostrarPanelRuta =
          true;

      _calculandoRuta =
          true;

      _mensajeRuta =
          'Calculando recorrido por carretera...';
    });

    await _calcularRuta(
      sitiosOrdenados,
    );
  }

  // ==========================================================
  // ORDENAR SITIOS PARA RUTA
  // ==========================================================
  //
  // Para rutas personalizadas utilizamos una aproximación
  // de vecino más cercano.
  //
  // Esto evita muchos recorridos innecesarios cuando el
  // usuario selecciona sitios que están geográficamente
  // próximos entre sí.
  //
  // La geometría final SIEMPRE la decide el backend/motor
  // de carreteras.
  //
  // ==========================================================

  List<SitioTuristicoItem>
      _ordenarSitiosParaRuta(
    List<SitioTuristicoItem>
        sitios,
  ) {
    if (sitios.length <= 2) {
      return List.from(
        sitios,
      );
    }

    final disponibles =
        List<SitioTuristicoItem>
            .from(sitios);

    final resultado =
        <SitioTuristicoItem>[];

    // --------------------------------------------------------
    // Si existe Gigante, lo usamos como inicio preferente.
    // --------------------------------------------------------

    final indiceGigante =
        disponibles.indexWhere(
      (sitio) =>
          _normalizarTexto(
            sitio.ciudad,
          ) ==
          'gigante',
    );

    SitioTuristicoItem actual;

    if (indiceGigante >= 0) {
      actual =
          disponibles.removeAt(
        indiceGigante,
      );
    } else {
      actual =
          disponibles.removeAt(0);
    }

    resultado.add(
      actual,
    );

    // --------------------------------------------------------
    // VECINO MÁS CERCANO
    // --------------------------------------------------------

    while (disponibles.isNotEmpty) {
      SitioTuristicoItem
          siguiente =
          disponibles.first;

      double menorDistancia =
          double.infinity;

      for (final candidato
          in disponibles) {
        final distancia =
            _distanciaGeografica(
          actual,
          candidato,
        );

        if (distancia <
            menorDistancia) {
          menorDistancia =
              distancia;

          siguiente =
              candidato;
        }
      }

      disponibles.remove(
        siguiente,
      );

      resultado.add(
        siguiente,
      );

      actual =
          siguiente;
    }

    return resultado;
  }

  // ==========================================================
  // DISTANCIA GEOGRÁFICA
  // ==========================================================

  double _distanciaGeografica(
    SitioTuristicoItem a,
    SitioTuristicoItem b,
  ) {
    const radioTierra = 6371000.0;

    final lat1 =
        a.latitud *
            math.pi /
            180;

    final lat2 =
        b.latitud *
            math.pi /
            180;

    final deltaLat =
        (b.latitud -
                a.latitud) *
            math.pi /
            180;

    final deltaLng =
        (b.longitud -
                a.longitud) *
            math.pi /
            180;

    final h =
        math.sin(
              deltaLat / 2,
            ) *
            math.sin(
              deltaLat / 2,
            ) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(
              deltaLng / 2,
            ) *
            math.sin(
              deltaLng / 2,
            );

    final c =
        2 *
            math.atan2(
              math.sqrt(h),
              math.sqrt(
                1 - h,
              ),
            );

    return radioTierra * c;
  }

  // ==========================================================
  // BUSCAR SITIOS POR MUNICIPIO
  // ==========================================================

  List<SitioTuristicoItem>
      _buscarSitiosPorMunicipio(
    String municipio,
  ) {
    final buscado =
        _normalizarTexto(
      municipio,
    );

    return _todosLosSitios
        .where(
          (sitio) {
            final ciudad =
                _normalizarTexto(
              sitio.ciudad,
            );

            final direccion =
                _normalizarTexto(
              sitio.direccion,
            );

            return ciudad ==
                    buscado ||
                ciudad.contains(
                  buscado,
                ) ||
                buscado.contains(
                  ciudad,
                ) ||
                direccion.contains(
                  buscado,
                );
          },
        )
        .toList();
  }

  // ==========================================================
  // NORMALIZAR TEXTO
  // ==========================================================

  String _normalizarTexto(
    String texto,
  ) {
    return texto
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u');
  }

  // ==========================================================
  // SELECCIONAR SITIO DEL MUNICIPIO
  // ==========================================================

  SitioTuristicoItem?
      _seleccionarSitioMunicipio(
    String municipio,
    List<SitioTuristicoItem>
        yaSeleccionados,
  ) {
    final candidatos =
        _buscarSitiosPorMunicipio(
      municipio,
    );

    for (final sitio
        in candidatos) {
      final repetido =
          yaSeleccionados.any(
        (item) =>
            item.id == sitio.id,
      );

      if (!repetido) {
        return sitio;
      }
    }

    return null;
  }

  // ==========================================================
  // ACTIVAR RUTA PREDEFINIDA
  // ==========================================================

  Future<void> _activarRutaPredefinida(
    RutaModel ruta,
  ) async {
    if (_todosLosSitios.length < 2) {
      _mostrarMensaje(
        'No hay suficientes sitios disponibles.',
      );
      return;
    }

    if (ruta.esCorredorRegional) {
      await _activarRutaCorredorRegional(
        ruta,
      );
      return;
    }

    List<SitioTuristicoItem>
        seleccionados = [];

    // --------------------------------------------------------
    // BUSCAR SITIOS POR CATEGORÍA
    // --------------------------------------------------------

    for (final categoria
        in ruta.categorias) {
      final categoriaBuscada =
          _normalizarTexto(
        categoria,
      );

      final coincidencias =
          _todosLosSitios.where(
        (sitio) {
          final nombreCategoria =
              _normalizarTexto(
            sitio.categoriaNombre,
          );

          return nombreCategoria
                  .contains(
                categoriaBuscada,
              ) ||
              categoriaBuscada
                  .contains(
                nombreCategoria,
              );
        },
      );

      for (final sitio
          in coincidencias) {
        final repetido =
            seleccionados.any(
          (item) =>
              item.id == sitio.id,
        );

        if (!repetido) {
          seleccionados.add(
            sitio,
          );
        }

        if (seleccionados.length >=
            5) {
          break;
        }
      }

      if (seleccionados.length >=
          5) {
        break;
      }
    }

    // --------------------------------------------------------
    // COMPLETAR CON SITIOS DISPONIBLES
    // --------------------------------------------------------

    if (seleccionados.length <
        2) {
      seleccionados =
          _todosLosSitios
              .take(2)
              .toList();
    } else if (seleccionados.length <
        4) {
      for (final sitio
          in _todosLosSitios) {
        if (!seleccionados.any(
          (item) =>
              item.id == sitio.id,
        )) {
          seleccionados.add(
            sitio,
          );
        }

        if (seleccionados.length >=
            4) {
          break;
        }
      }
    }

    if (seleccionados.length <
        2) {
      _mostrarMensaje(
        'No hay suficientes sitios para esta ruta.',
      );
      return;
    }

    final ordenados =
        _ordenarSitiosParaRuta(
      seleccionados,
    );

    setState(() {
      _modoCrearRuta = false;

      _rutaActiva = ruta;

      _sitiosSeleccionados =
          ordenados;

      _mostrarPanelRuta = true;

      _calculandoRuta = true;

      _mensajeRuta =
          'Calculando ruta predefinida por carretera...';
    });

    await _calcularRuta(
      ordenados,
    );
  }

  // ==========================================================
  // ACTIVAR CORREDOR GIGANTE - ZULUAGA - GARZÓN
  // ==========================================================

  Future<void>
      _activarRutaCorredorRegional(
    RutaModel ruta,
  ) async {
    final List<SitioTuristicoItem>
        seleccionados = [];

    // --------------------------------------------------------
    // BUSCAR MUNICIPIOS EN EL ORDEN DE LA RUTA
    // --------------------------------------------------------

    for (final municipio
        in ruta.municipios) {
      final sitio =
          _seleccionarSitioMunicipio(
        municipio,
        seleccionados,
      );

      if (sitio != null) {
        seleccionados.add(
          sitio,
        );
      }
    }

    // --------------------------------------------------------
    // SI ZULUAGA NO TIENE SITIOS
    // NO INVENTAMOS COORDENADAS.
    // --------------------------------------------------------

    if (seleccionados.length <
        2) {
      _mostrarMensaje(
        'No se encontraron suficientes sitios para ${ruta.nombre}. '
        'Verifica los sitios registrados en MongoDB.',
      );
      return;
    }

    setState(() {
      _modoCrearRuta = false;

      _rutaActiva = ruta;

      _sitiosSeleccionados =
          seleccionados;

      _mostrarPanelRuta = true;

      _calculandoRuta = true;

      if (seleccionados.length ==
          3) {
        _mensajeRuta =
            'Calculando Gigante → Zuluaga → Garzón por carretera...';
      } else {
        _mensajeRuta =
            'Calculando recorrido disponible por carretera...';
      }
    });

    await _calcularRuta(
      seleccionados,
    );
  }

  // ==========================================================
  // CALCULAR RUTA REAL POR CARRETERA
  // ==========================================================

  Future<void> _calcularRuta(
    List<SitioTuristicoItem> sitios,
  ) async {
    if (sitios.length < 2) {
      _mostrarMensaje(
        'Se necesitan mínimo 2 sitios.',
      );
      return;
    }

    setState(() {
      _calculandoRuta = true;

      _puntosRuta = [];

      _distanciaRuta = 0;

      _duracionRuta = 0;

      _mensajeRuta =
          'Calculando ruta por carretera...';
    });

    try {
      // ------------------------------------------------------
      // PREPARAR PUNTOS
      // ------------------------------------------------------

      final puntos =
          sitios.map(
        (sitio) {
          return {
            'latitud':
                sitio.latitud,
            'longitud':
                sitio.longitud,
          };
        },
      ).toList();

      debugPrint(
        '======================================',
      );

      debugPrint(
        'CALCULANDO RUTA POR CARRETERA',
      );

      for (int i = 0;
          i < sitios.length;
          i++) {
        debugPrint(
          '${i + 1}. '
          '${sitios[i].nombre} '
          '(${sitios[i].ciudad}) '
          '${sitios[i].latitud}, '
          '${sitios[i].longitud}',
        );
      }

      debugPrint(
        '======================================',
      );

      // ------------------------------------------------------
      // LLAMADA AL BACKEND
      // ------------------------------------------------------

      final response =
          await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/rutas/calcular',
        ),
        headers: {
          'Content-Type':
              'application/json',
        },
        body: jsonEncode({
          'puntos': puntos,
        }),
      ).timeout(
        const Duration(
          seconds: 60,
        ),
      );

      debugPrint(
        'RESPUESTA RUTA: '
        '${response.statusCode}',
      );

      debugPrint(
        'BODY RUTA: '
        '${response.body}',
      );

      if (response.statusCode !=
          200) {
        throw Exception(
          'El servidor respondió '
          '${response.statusCode}: '
          '${response.body}',
        );
      }

      final decoded =
          jsonDecode(
        response.body,
      );

      if (decoded is! Map) {
        throw Exception(
          'La respuesta del servidor no es válida.',
        );
      }

      final data =
          Map<String, dynamic>.from(
        decoded,
      );

      if (data['ok'] == false) {
        throw Exception(
          data['mensaje'] ??
              data['message'] ??
              'No fue posible calcular la ruta.',
        );
      }

      // ------------------------------------------------------
      // BUSCAR OBJETO DE RUTA
      // ------------------------------------------------------

      dynamic ruta =
          data['ruta'] ??
          data['data'] ??
          data['result'];

      if (ruta is Map) {
        ruta =
            Map<String, dynamic>.from(
          ruta,
        );
      }

      if (ruta is! Map) {
        throw Exception(
          'El servidor no devolvió información de ruta.',
        );
      }

      // ------------------------------------------------------
      // GEOMETRÍA
      // ------------------------------------------------------

      dynamic geometry =
          ruta['geometria'] ??
          ruta['geometry'];

      if (geometry is Map) {
        geometry =
            Map<String, dynamic>.from(
          geometry,
        );
      }

      if (geometry is! Map) {
        throw Exception(
          'La respuesta no contiene geometría de carretera.',
        );
      }

      final coordinates =
          geometry['coordinates'];

      if (coordinates is! List) {
        throw Exception(
          'La geometría de la ruta no es válida.',
        );
      }

      // ------------------------------------------------------
      // CONVERTIR GEOJSON A LATLNG
      // ------------------------------------------------------

      final List<LatLng>
          puntosCalculados = [];

      for (final coordenada
          in coordinates) {
        if (coordenada is List &&
            coordenada.length >= 2) {
          final longitud =
              _parseDouble(
            coordenada[0],
          );

          final latitud =
              _parseDouble(
            coordenada[1],
          );

          if (latitud != 0 &&
              longitud != 0) {
            puntosCalculados.add(
              LatLng(
                latitud,
                longitud,
              ),
            );
          }
        }
      }

      if (puntosCalculados.length <
          2) {
        throw Exception(
          'La ruta no contiene suficientes puntos de carretera.',
        );
      }

      // ------------------------------------------------------
      // DISTANCIA
      // ------------------------------------------------------

      final distancia =
          _parseDouble(
        ruta['distancia'] ??
            ruta['distance'] ??
            data['distancia'],
      );

      // ------------------------------------------------------
      // DURACIÓN
      // ------------------------------------------------------

      final duracion =
          _parseDouble(
        ruta['duracion'] ??
            ruta['duration'] ??
            data['duracion'],
      );

      // ------------------------------------------------------
      // GUARDAR RESULTADO
      // ------------------------------------------------------

      if (!mounted) {
        return;
      }

      setState(() {
        _puntosRuta =
            puntosCalculados;

        _distanciaRuta =
            distancia;

        _duracionRuta =
            duracion;

        _calculandoRuta = false;

        _mensajeRuta =
            'Ruta calculada correctamente por carretera.';
      });

      _ajustarMapaARuta();
    } catch (error) {
      debugPrint(
        '======================================',
      );

      debugPrint(
        'ERROR CALCULANDO RUTA',
      );

      debugPrint(
        '$error',
      );

      debugPrint(
        '======================================',
      );

      if (mounted) {
        setState(() {
          _calculandoRuta =
              false;

          _mensajeRuta =
              'No fue posible calcular la ruta por carretera.';
        });
      }

      _mostrarMensaje(
        'Error al calcular la ruta: $error',
      );
    }
  }

  // ==========================================================
  // PARSEAR NÚMERO
  // ==========================================================

  double _parseDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(
            value,
          ) ??
          0;
    }

    if (value is Map) {

      final dynamic interno =
    value['\$numberDouble'] ??
    value['value'];

      if (interno != null) {
        return double.tryParse(
              interno.toString(),
            ) ??
            0;
      }
    }

    return 0;
  }

  // ==========================================================
  // AJUSTAR MAPA A LA RUTA
  // ==========================================================

  void _ajustarMapaARuta() {
    if (_puntosRuta.length < 2) {
      return;
    }

    double minLat =
        _puntosRuta.first.latitude;

    double maxLat =
        _puntosRuta.first.latitude;

    double minLng =
        _puntosRuta.first.longitude;

    double maxLng =
        _puntosRuta.first.longitude;

    for (final punto
        in _puntosRuta) {
      minLat = math.min(
        minLat,
        punto.latitude,
      );

      maxLat = math.max(
        maxLat,
        punto.latitude,
      );

      minLng = math.min(
        minLng,
        punto.longitude,
      );

      maxLng = math.max(
        maxLng,
        punto.longitude,
      );
    }

    final diferenciaLat =
        maxLat - minLat;

    final diferenciaLng =
        maxLng - minLng;

    final margenLat =
        diferenciaLat == 0
            ? 0.02
            : diferenciaLat * 0.10;

    final margenLng =
        diferenciaLng == 0
            ? 0.02
            : diferenciaLng * 0.10;

    final bounds =
        LatLngBounds(
      LatLng(
        minLat - margenLat,
        minLng - margenLng,
      ),
      LatLng(
        maxLat + margenLat,
        maxLng + margenLng,
      ),
    );

    Future.delayed(
      const Duration(
        milliseconds: 300,
      ),
      () {
        if (!mounted) {
          return;
        }

        try {
          _mapController
              .fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding:
                  const EdgeInsets.all(
                80,
              ),
            ),
          );
        } catch (error) {
          debugPrint(
            'No se pudo ajustar mapa: $error',
          );
        }
      },
    );
  }

  // ==========================================================
  // LIMPIAR RUTA
  // ==========================================================

  void _limpiarRuta() {
    setState(() {
      _modoCrearRuta = false;

      _rutaActiva = null;

      _sitiosSeleccionados =
          [];

      _puntosRuta = [];

      _distanciaRuta = 0;

      _duracionRuta = 0;

      _mensajeRuta = '';

      _mostrarPanelRuta =
          false;
    });
  }

  // ==========================================================
  // DISTANCIA FORMATEADA
  // ==========================================================

  String _distanciaFormateada() {
    if (_distanciaRuta <= 0) {
      return 'Calculando';
    }

    if (_distanciaRuta < 1000) {
      return '${_distanciaRuta.toStringAsFixed(0)} m';
    }

    return '${(_distanciaRuta / 1000).toStringAsFixed(1)} km';
  }

  // ==========================================================
  // DURACIÓN FORMATEADA
  // ==========================================================

  String _duracionFormateada() {
    if (_duracionRuta <= 0) {
      return 'Calculando';
    }

    final minutos =
        (_duracionRuta / 60)
            .round();

    if (minutos < 60) {
      return '$minutos min';
    }

    final horas =
        minutos ~/ 60;

    final minutosRestantes =
        minutos % 60;

    if (minutosRestantes == 0) {
      return '$horas h';
    }

    return '$horas h '
        '$minutosRestantes min';
  }

  // ==========================================================
  // MENSAJE
  // ==========================================================

  void _mostrarMensaje(
    String mensaje,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
        ),
        duration:
            const Duration(
          seconds: 4,
        ),
      ),
    );
  }

  // ==========================================================
  // MARCADORES
  // ==========================================================

  List<Marker>
      _obtenerMarcadores() {
    final List<Marker>
        marcadores = [];

    // --------------------------------------------------------
    // SI HAY SITIOS SELECCIONADOS
    // --------------------------------------------------------

    if (_sitiosSeleccionados
        .isNotEmpty) {
      for (int i = 0;
          i <
              _sitiosSeleccionados
                  .length;
          i++) {
        final sitio =
            _sitiosSeleccionados[i];

        final estilo =
            _obtenerEstiloCategoria(
          sitio.categoriaId,
          sitio.categoriaNombre,
        );

        marcadores.add(
          Marker(
            point:
                sitio.ubicacion,
            width: 50,
            height: 50,
            child:
                GestureDetector(
              onTap: () =>
                  _mostrarDetalles(
                sitio,
              ),
              child:
                  Container(
                decoration:
                    BoxDecoration(
                  color:
                      _rutaActiva
                              ?.color ??
                          estilo.color,
                  shape:
                      BoxShape.circle,
                  border:
                      Border.all(
                    color:
                        Colors.white,
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color:
                          Colors.black38,
                      blurRadius:
                          6,
                      offset:
                          Offset(
                        0,
                        3,
                      ),
                    ),
                  ],
                ),
                child:
                    Center(
                  child:
                      Text(
                    '${i + 1}',
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight
                              .bold,
                      fontSize:
                          17,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return marcadores;
    }

    // --------------------------------------------------------
    // MARCADORES NORMALES
    // --------------------------------------------------------

    for (final sitio
        in _sitiosFiltrados) {
      final estilo =
          _obtenerEstiloCategoria(
        sitio.categoriaId,
        sitio.categoriaNombre,
      );

      final seleccionado =
          _estaSeleccionado(
        sitio,
      );

      marcadores.add(
        Marker(
          point:
              sitio.ubicacion,
          width: 48,
          height: 48,
          child:
              GestureDetector(
            onTap: () {
              if (_modoCrearRuta) {
                _alternarSeleccionSitio(
                  sitio,
                );
              } else {
                _mostrarDetalles(
                  sitio,
                );
              }
            },
            child:
                Container(
              decoration:
                  BoxDecoration(
                color:
                    seleccionado
                        ? const Color(
                            0xFF1565C0,
                          )
                        : estilo.color,
                shape:
                    BoxShape.circle,
                border:
                    Border.all(
                  color:
                      Colors.white,
                  width: 3,
                ),
                boxShadow:
                    const [
                  BoxShadow(
                    color:
                        Colors.black38,
                    blurRadius:
                        5,
                    offset:
                        Offset(
                      0,
                      3,
                    ),
                  ),
                ],
              ),
              child:
                  Icon(
                seleccionado
                    ? Icons.check
                    : estilo.icono,
                color:
                    Colors.white,
                size: 23,
              ),
            ),
          ),
        ),
      );
    }

    return marcadores;
  }

  // ==========================================================
  // POLYLINE DE CARRETERA
  // ==========================================================

  List<Polyline>
      _obtenerPolilineas() {
    if (_puntosRuta.length < 2) {
      return [];
    }

    final colorRuta =
        _rutaActiva?.color ??
            const Color(
              0xFF1565C0,
            );

    return [
      // ------------------------------------------------------
      // BORDE
      // ------------------------------------------------------

      Polyline(
        points:
            _puntosRuta,
        strokeWidth: 10,
        color:
            Colors.white,
      ),

      // ------------------------------------------------------
      // RUTA PRINCIPAL
      // ------------------------------------------------------

      Polyline(
        points:
            _puntosRuta,
        strokeWidth: 6,
        color:
            colorRuta,
      ),
    ];
  }

  // ==========================================================
  // DETALLES DEL SITIO
  // ==========================================================

  void _mostrarDetalles(
    SitioTuristicoItem sitio,
  ) {
    final estilo =
        _obtenerEstiloCategoria(
      sitio.categoriaId,
      sitio.categoriaNombre,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(
            24,
          ),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child:
              Padding(
            padding:
                const EdgeInsets.all(
              20,
            ),
            child:
                Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius:
                          26,
                      backgroundColor:
                          estilo.color,
                      child:
                          Icon(
                        estilo.icono,
                        color:
                            Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            sitio.nombre,
                            style:
                                const TextStyle(
                              fontSize:
                                  18,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          Text(
                            '${sitio.ciudad}, '
                            '${sitio.departamento}',
                            style:
                                TextStyle(
                              color:
                                  Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),

                if (sitio
                    .categoriaNombre
                    .isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        estilo.icono,
                        size: 18,
                        color:
                            estilo.color,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        sitio
                            .categoriaNombre,
                        style:
                            TextStyle(
                          color:
                              estilo.color,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(
                  height: 12,
                ),

                if (sitio
                    .direccion
                    .isNotEmpty)
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Expanded(
                        child:
                            Text(
                          sitio
                              .direccion,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  sitio.descripcion,
                  style:
                      const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );

                      if (!_modoCrearRuta) {
                        _activarModoCrearRuta();
                      }

                      _alternarSeleccionSitio(
                        sitio,
                      );
                    },
                    icon:
                        Icon(
                      _estaSeleccionado(
                        sitio,
                      )
                          ? Icons.remove
                          : Icons
                              .add_location_alt,
                    ),
                    label:
                        Text(
                      _estaSeleccionado(
                        sitio,
                      )
                          ? 'Quitar de la ruta'
                          : 'Agregar a la ruta',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // PANEL DE RUTA
  // ==========================================================

  Widget _construirPanelRuta() {
    if (!_mostrarPanelRuta) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 12,
      right: 12,
      bottom: 16,
      child: Card(
        elevation: 10,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),
        child:
            Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child:
              Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        _rutaActiva
                                ?.color ??
                            const Color(
                              0xFF1565C0,
                            ),
                    child:
                        Text(
                      '${_sitiosSeleccionados.length}',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          _rutaActiva
                                  ?.nombre ??
                              'Nueva ruta',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize:
                                16,
                          ),
                        ),
                        Text(
                          _modoCrearRuta
                              ? 'Selecciona 2 o más sitios'
                              : '${_sitiosSeleccionados.length} sitios',
                          style:
                              TextStyle(
                            color:
                                Colors.grey[600],
                            fontSize:
                                12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ------------------------------------------------
                  // CERRAR / CANCELAR
                  // ------------------------------------------------

                  IconButton(
                    tooltip:
                        _modoCrearRuta
                            ? 'Cancelar'
                            : 'Cerrar',
                    onPressed:
                        _modoCrearRuta
                            ? _cancelarCrearRuta
                            : _limpiarRuta,
                    icon:
                        const Icon(
                      Icons.close,
                    ),
                  ),
                ],
              ),

              // ------------------------------------------------
              // SITIOS SELECCIONADOS
              // ------------------------------------------------

              if (_sitiosSeleccionados
                  .isNotEmpty)
                Container(
                  constraints:
                      const BoxConstraints(
                    maxHeight:
                        110,
                  ),
                  margin:
                      const EdgeInsets.only(
                    top: 8,
                  ),
                  child:
                      ListView.builder(
                    shrinkWrap:
                        true,
                    itemCount:
                        _sitiosSeleccionados
                            .length,
                    itemBuilder:
                        (context,
                            index) {
                      final sitio =
                          _sitiosSeleccionados[
                              index];

                      return Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom:
                              4,
                        ),
                        child:
                            Row(
                          children: [
                            CircleAvatar(
                              radius:
                                  12,
                              backgroundColor:
                                  _rutaActiva
                                          ?.color ??
                                      const Color(
                                        0xFF1565C0,
                                      ),
                              child:
                                  Text(
                                '${index + 1}',
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      11,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child:
                                  Text(
                                sitio
                                    .nombre,
                                maxLines:
                                    1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      12,
                                ),
                              ),
                            ),
                            if (_modoCrearRuta)
                              IconButton(
                                visualDensity:
                                    VisualDensity
                                        .compact,
                                onPressed:
                                    () {
                                  setState(
                                    () {
                                      _sitiosSeleccionados
                                          .removeWhere(
                                        (item) =>
                                            item.id ==
                                            sitio.id,
                                      );
                                    },
                                  );
                                },
                                icon:
                                    const Icon(
                                  Icons.close,
                                  size:
                                      16,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(
                height: 8,
              ),

              if (_sitiosSeleccionados
                      .length >=
                  2)
                Text(
                  _textoRecorrido(),
                  maxLines:
                      2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      TextStyle(
                    color:
                        Colors.grey[700],
                    fontSize:
                        12,
                  ),
                ),

              // ------------------------------------------------
              // CALCULANDO
              // ------------------------------------------------

              if (_calculandoRuta)
                const Padding(
                  padding:
                      EdgeInsets.only(
                    top: 8,
                  ),
                  child:
                      Column(
                    children: [
                      LinearProgressIndicator(),
                      SizedBox(
                        height:
                            8,
                      ),
                      Text(
                        'Calculando recorrido real por carretera...',
                        style:
                            TextStyle(
                          fontSize:
                              12,
                        ),
                      ),
                    ],
                  ),
                )

              // ------------------------------------------------
              // DATOS
              // ------------------------------------------------

              else if (_puntosRuta
                      .length >=
                  2)
                Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    top: 8,
                  ),
                  child:
                      Row(
                    children: [
                      Expanded(
                        child:
                            _datoRuta(
                          Icons.route,
                          _distanciaFormateada(),
                          'Distancia',
                        ),
                      ),
                      Expanded(
                        child:
                            _datoRuta(
                          Icons.access_time,
                          _duracionFormateada(),
                          'Tiempo',
                        ),
                      ),
                    ],
                  ),
                ),

              if (_mensajeRuta
                  .isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    top: 8,
                  ),
                  child:
                      Text(
                    _mensajeRuta,
                    style:
                        TextStyle(
                      color:
                          Colors.grey[700],
                      fontSize:
                          12,
                    ),
                  ),
                ),

              // ------------------------------------------------
              // BOTONES DE ACCIÓN
              // ------------------------------------------------

              if (_modoCrearRuta)
                Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    top: 10,
                  ),
                  child:
                      Row(
                    children: [
                      Expanded(
                        child:
                            OutlinedButton.icon(
                          onPressed:
                              _cancelarCrearRuta,
                          icon:
                              const Icon(
                            Icons.close,
                          ),
                          label:
                              const Text(
                            'Cancelar',
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child:
                            ElevatedButton.icon(
                          onPressed:
                              _sitiosSeleccionados
                                          .length >=
                                      2
                                  ? _generarRutaPersonalizada
                                  : null,
                          icon:
                              const Icon(
                            Icons.route,
                          ),
                          label:
                              const Text(
                            'Calcular ruta',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // TEXTO DEL RECORRIDO
  // ==========================================================

  String _textoRecorrido() {
    if (_sitiosSeleccionados
        .isEmpty) {
      return '';
    }

    return _sitiosSeleccionados
        .map(
          (sitio) =>
              sitio.ciudad
                  .isNotEmpty
                  ? sitio.ciudad
                  : sitio.nombre,
        )
        .join(' → ');
  }

  // ==========================================================
  // DATO DE RUTA
  // ==========================================================

  Widget _datoRuta(
    IconData icono,
    String valor,
    String titulo,
  ) {
    return Row(
      children: [
        Icon(
          icono,
          size: 20,
          color:
              const Color(
            0xFF1565C0,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              valor,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            Text(
              titulo,
              style:
                  const TextStyle(
                fontSize: 10,
                color:
                    Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // PANEL SUPERIOR
  // ==========================================================

  Widget _construirPanelSuperior() {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child:
          Column(
        children: [
          // --------------------------------------------------
          // BUSCADOR
          // --------------------------------------------------

          Card(
            elevation: 7,
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                25,
              ),
            ),
            child:
                TextField(
              controller:
                  _searchController,
              onChanged:
                  (valor) {
                _busquedaTexto =
                    valor;

                _aplicarFiltros();
              },
              decoration:
                  InputDecoration(
                hintText:
                    _modoCrearRuta
                        ? 'Buscar y agregar un sitio...'
                        : 'Buscar sitio o municipio...',
                prefixIcon:
                    const Icon(
                  Icons.search,
                  color:
                      Color(0xFF6F4E37),
                ),
                suffixIcon:
                    _busquedaTexto
                            .isNotEmpty
                        ? IconButton(
                            onPressed:
                                () {
                              _searchController
                                  .clear();

                              _busquedaTexto =
                                  '';

                              _sugerenciasBusqueda =
                                  [];

                              _mostrarSugerenciasBusqueda =
                                  false;

                              _aplicarFiltros();
                            },
                            icon:
                                const Icon(
                              Icons.clear,
                            ),
                          )
                        : null,
                border:
                    InputBorder.none,
                contentPadding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 14,
                ),
              ),
            ),
          ),

          // --------------------------------------------------
          // AUTOCOMPLETADO
          // --------------------------------------------------

          if (_mostrarSugerenciasBusqueda)
            _construirSugerenciasBusqueda(),

          const SizedBox(
            height: 8,
          ),

          // --------------------------------------------------
          // MODO CREAR RUTA
          // --------------------------------------------------

          if (_modoCrearRuta)
            _construirBannerCrearRuta(),

          const SizedBox(
            height: 8,
          ),

          // --------------------------------------------------
          // BOTONES PRINCIPALES
          // --------------------------------------------------

          Row(
            children: [
              Expanded(
                child:
                    _botonSuperior(
                  icono:
                      Icons.alt_route,
                  texto:
                      'Rutas',
                  color:
                      const Color(
                    0xFF6F4E37,
                  ),
                  onPressed:
                      _mostrarPanelRutas,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child:
                    _botonSuperior(
                  icono:
                      Icons.add_location_alt,
                  texto:
                      'Crear ruta',
                  color:
                      const Color(
                    0xFF1565C0,
                  ),
                  onPressed:
                      _activarModoCrearRuta,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Material(
                color:
                    Colors.white,
                elevation:
                    5,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                child:
                    InkWell(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  onTap:
                      () {
                    setState(
                      () {
                        _mostrarEstilosMapa =
                            !_mostrarEstilosMapa;
                      },
                    );
                  },
                  child:
                      Padding(
                    padding:
                        const EdgeInsets
                            .all(
                      11,
                    ),
                    child:
                        Icon(
                      Icons.layers,
                      color:
                          _estiloMapaActual
                              .id ==
                              'dark'
                          ? Colors.black87
                          : const Color(
                              0xFF455A64,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          if (_mostrarEstilosMapa)
            _construirSelectorEstilos(),

          if (_mostrarCategorias)
            _construirCategorias(),
        ],
      ),
    );
  }

  // ==========================================================
  // BANNER CREAR RUTA
  // ==========================================================

  Widget _construirBannerCrearRuta() {
    return Card(
      color:
          const Color(
        0xFFE3F2FD,
      ),
      elevation:
          4,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child:
          Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        child:
            Row(
          children: [
            const CircleAvatar(
              backgroundColor:
                  Color(
                0xFF1565C0,
              ),
              child:
                  Icon(
                Icons.route,
                color:
                    Colors.white,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Crear nueva ruta',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(
                        0xFF0D47A1,
                      ),
                    ),
                  ),
                  Text(
                    'Selecciona 2 o más sitios. La ruta seguirá las carreteras.',
                    style:
                        TextStyle(
                      fontSize:
                          11,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed:
                  _cancelarCrearRuta,
              child:
                  const Text(
                'Cancelar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SUGERENCIAS DEL BUSCADOR
  // ==========================================================

  Widget _construirSugerenciasBusqueda() {
    return Card(
      elevation:
          8,
      margin:
          const EdgeInsets.only(
        top: 2,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child:
          ListView.builder(
        shrinkWrap:
            true,
        padding:
            const EdgeInsets
                .symmetric(
          vertical: 4,
        ),
        itemCount:
            _sugerenciasBusqueda
                .length,
        itemBuilder:
            (context, index) {
          final sitio =
              _sugerenciasBusqueda[
                  index];

          final estilo =
              _obtenerEstiloCategoria(
            sitio.categoriaId,
            sitio.categoriaNombre,
          );

          return ListTile(
            dense:
                true,
            leading:
                CircleAvatar(
              radius:
                  18,
              backgroundColor:
                  estilo.color,
              child:
                  Icon(
                estilo.icono,
                color:
                    Colors.white,
                size:
                    18,
              ),
            ),
            title:
                Text(
              sitio.nombre,
              maxLines:
                  1,
              overflow:
                  TextOverflow
                      .ellipsis,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize:
                    13,
              ),
            ),
            subtitle:
                Text(
              '${sitio.ciudad}'
              '${sitio.categoriaNombre.isNotEmpty ? ' • ${sitio.categoriaNombre}' : ''}',
              maxLines:
                  1,
              overflow:
                  TextOverflow
                      .ellipsis,
            ),
            onTap:
                () {
              if (_modoCrearRuta) {
                _searchController
                    .text =
                    sitio.nombre;

                _busquedaTexto =
                    sitio.nombre;

                _mostrarSugerenciasBusqueda =
                    false;

                _alternarSeleccionSitio(
                  sitio,
                );
              } else {
                _seleccionarSugerencia(
                  sitio,
                );
              }
            },
          );
        },
      ),
    );
  }

  // ==========================================================
  // BOTÓN SUPERIOR
  // ==========================================================

  Widget _botonSuperior({
    required IconData icono,
    required String texto,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color:
          Colors.white,
      elevation:
          5,
      borderRadius:
          BorderRadius.circular(
        18,
      ),
      child:
          InkWell(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        onTap:
            onPressed,
        child:
            Padding(
          padding:
              const EdgeInsets
                  .symmetric(
            vertical:
                11,
            horizontal:
                8,
          ),
          child:
              Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              Icon(
                icono,
                color:
                    color,
                size:
                    20,
              ),
              const SizedBox(
                width: 6,
              ),
              Flexible(
                child:
                    Text(
                  texto,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      TextStyle(
                    color:
                        color,
                    fontWeight:
                        FontWeight
                            .bold,
                    fontSize:
                        12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SELECTOR DE ESTILOS DEL MAPA
  // ==========================================================

  Widget _construirSelectorEstilos() {
    return Card(
      elevation:
          7,
      margin:
          const EdgeInsets
              .symmetric(
        horizontal:
            2,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          8,
        ),
        child:
            SizedBox(
          height:
              52,
          child:
              ListView.separated(
            scrollDirection:
                Axis.horizontal,
            itemCount:
                _estilosMapa
                    .length,
            separatorBuilder:
                (_, __) =>
                    const SizedBox(
              width:
                  8,
            ),
            itemBuilder:
                (context,
                    index) {
              final estilo =
                  _estilosMapa[
                      index];

              final activo =
                  estilo.id ==
                      _estiloMapaActual
                          .id;

              return ChoiceChip(
                avatar:
                    Icon(
                  estilo.icono,
                  size:
                      17,
                  color:
                      activo
                          ? Colors.white
                          : Colors.black54,
                ),
                label:
                    Text(
                  estilo.nombre,
                ),
                selected:
                    activo,
                selectedColor:
                    const Color(
                  0xFF6F4E37,
                ),
                labelStyle:
                    TextStyle(
                  color:
                      activo
                          ? Colors.white
                          : Colors.black87,
                  fontWeight:
                      FontWeight.w600,
                ),
                onSelected:
                    (_) {
                  setState(
                    () {
                      _estiloMapaActual =
                          estilo;

                      _mostrarEstilosMapa =
                          false;
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // CATEGORÍAS
  // ==========================================================

  Widget _construirCategorias() {
    if (_categorias.isEmpty) {
      return const SizedBox(
        height:
            48,
      );
    }

    return Container(
      height:
          48,
      padding:
          const EdgeInsets
              .symmetric(
        horizontal:
            4,
      ),
      child:
          ListView(
        scrollDirection:
            Axis.horizontal,
        children: [
          ChoiceChip(
            label:
                const Text(
              'Todos',
            ),
            selected:
                _categoriaSeleccionada ==
                    null,
            selectedColor:
                const Color(
              0xFF6F4E37,
            ),
            labelStyle:
                TextStyle(
              color:
                  _categoriaSeleccionada ==
                          null
                      ? Colors.white
                      : Colors.black87,
              fontWeight:
                  FontWeight.bold,
            ),
            onSelected:
                (_) {
              setState(
                () {
                  _categoriaSeleccionada =
                      null;
                },
              );

              _aplicarFiltros();
            },
          ),

          const SizedBox(
            width:
                6,
          ),

          ..._categorias.map(
            (categoria) {
              final seleccionada =
                  _categoriaSeleccionada
                          ?.id ==
                      categoria.id;

              final estilo =
                  _obtenerEstiloCategoria(
                categoria.id,
                categoria.nombre,
              );

              return Padding(
                padding:
                    const EdgeInsets
                        .only(
                  right:
                      6,
                ),
                child:
                    ChoiceChip(
                  avatar:
                      Icon(
                    estilo.icono,
                    size:
                        17,
                    color:
                        seleccionada
                            ? Colors.white
                            : estilo.color,
                  ),
                  label:
                      Text(
                    categoria.nombre,
                  ),
                  selected:
                      seleccionada,
                  selectedColor:
                      estilo.color,
                  labelStyle:
                      TextStyle(
                    color:
                        seleccionada
                            ? Colors.white
                            : Colors.black87,
                  ),
                  onSelected:
                      (_) {
                    setState(
                      () {
                        _categoriaSeleccionada =
                            categoria;
                      },
                    );

                    _aplicarFiltros();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MOSTRAR RUTAS PREDEFINIDAS
  // ==========================================================

  void _mostrarPanelRutas() {
    showModalBottomSheet(
      context:
          context,
      isScrollControlled:
          true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top:
              Radius.circular(
            24,
          ),
        ),
      ),
      builder:
          (context) {
        return SafeArea(
          child:
              DraggableScrollableSheet(
            expand:
                false,
            initialChildSize:
                0.70,
            minChildSize:
                0.45,
            maxChildSize:
                0.90,
            builder:
                (
              context,
              scrollController,
            ) {
              return Padding(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  18,
                  18,
                  18,
                  10,
                ),
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.route,
                          color:
                              Color(
                            0xFF6F4E37,
                          ),
                        ),
                        const SizedBox(
                          width:
                              8,
                        ),
                        const Expanded(
                          child:
                              Text(
                            'Rutas disponibles',
                            style:
                                TextStyle(
                              fontSize:
                                  21,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              () {
                            Navigator.pop(
                              context,
                            );
                          },
                          icon:
                              const Icon(
                            Icons.close,
                          ),
                        ),
                      ],
                    ),

                    const Text(
                      'Selecciona una ruta predefinida o crea tu propio recorrido con 2 o más sitios.',
                      style:
                          TextStyle(
                        color:
                            Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height:
                          14,
                    ),

                    Expanded(
                      child:
                          ListView(
                        controller:
                            scrollController,
                        children: [
                          ..._rutasPredefinidas
                              .map(
                            (ruta) {
                              return _tarjetaRuta(
                                ruta,
                                context,
                              );
                            },
                          ),

                          const SizedBox(
                            height:
                                8,
                          ),

                          Card(
                            elevation:
                                2,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                18,
                              ),
                            ),
                            child:
                                ListTile(
                              contentPadding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    16,
                                vertical:
                                    8,
                              ),
                              leading:
                                  const CircleAvatar(
                                backgroundColor:
                                    Color(
                                  0xFF1565C0,
                                ),
                                child:
                                    Icon(
                                  Icons.add_road,
                                  color:
                                      Colors.white,
                                ),
                              ),
                              title:
                                  const Text(
                                'Crear nueva ruta',
                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                              subtitle:
                                  const Text(
                                'Selecciona 2 o más sitios de cualquier categoría.',
                              ),
                              trailing:
                                  const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size:
                                    16,
                              ),
                              onTap:
                                  () {
                                Navigator.pop(
                                  context,
                                );

                                _activarModoCrearRuta();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ==========================================================
  // TARJETA DE RUTA
  // ==========================================================

  Widget _tarjetaRuta(
    RutaModel ruta,
    BuildContext context,
  ) {
    final esCorredor =
        ruta.esCorredorRegional;

    return Card(
      margin:
          const EdgeInsets.only(
        bottom:
            10,
      ),
      elevation:
          esCorredor
              ? 4
              : 2,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        side:
            esCorredor
                ? BorderSide(
                    color:
                        ruta.color
                            .withOpacity(
                      0.35,
                    ),
                  )
                : BorderSide.none,
      ),
      child:
          InkWell(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        onTap:
            () {
          Navigator.pop(
            context,
          );

          _activarRutaPredefinida(
            ruta,
          );
        },
        child:
            Padding(
          padding:
              const EdgeInsets.all(
            14,
          ),
          child:
              Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              CircleAvatar(
                radius:
                    25,
                backgroundColor:
                    ruta.color,
                child:
                    Icon(
                  ruta.icono,
                  color:
                      Colors.white,
                ),
              ),

              const SizedBox(
                width:
                    12,
              ),

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      ruta.nombre,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize:
                            16,
                      ),
                    ),

                    const SizedBox(
                      height:
                          4,
                    ),

                    Text(
                      ruta.descripcion,
                      style:
                          TextStyle(
                        color:
                            Colors.grey[700],
                        fontSize:
                            13,
                      ),
                    ),

                    if (esCorredor &&
                        ruta.municipios
                            .isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          top:
                              8,
                        ),
                        child:
                            Wrap(
                          spacing:
                              5,
                          children:
                              ruta
                                  .municipios
                                  .map(
                            (municipio) {
                              return Chip(
                                label:
                                    Text(
                                  municipio,
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        10,
                                  ),
                                ),
                                visualDensity:
                                    VisualDensity
                                        .compact,
                                padding:
                                    EdgeInsets
                                        .zero,
                              );
                            },
                          ).toList(),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(
                width:
                    6,
              ),

              const Icon(
                Icons
                    .arrow_forward_ios,
                size:
                    16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar:
          AppBar(
        title:
            const Text(
          'Mi Ruta Mágica del Café',
          style:
              TextStyle(
            color:
                Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        backgroundColor:
            const Color(
          0xFF6F4E37,
        ),
        actions: [
          // --------------------------------------------------
          // CONTADOR
          // --------------------------------------------------

          if (_sitiosSeleccionados
              .isNotEmpty)
            Center(
              child:
                  Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      4,
                ),
                child:
                    Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal:
                        10,
                    vertical:
                        5,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white24,
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                  child:
                      Text(
                    '${_sitiosSeleccionados.length}',
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // --------------------------------------------------
          // RECARGAR
          // --------------------------------------------------

          IconButton(
            tooltip:
                'Recargar sitios',
            icon:
                const Icon(
              Icons.refresh,
              color:
                  Colors.white,
            ),
            onPressed:
                _cargarDatos,
          ),
        ],
      ),

      // ======================================================
      // BODY
      // ======================================================

      body:
          Stack(
        children: [
          // ==================================================
          // MAPA
          // ==================================================

          FlutterMap(
            mapController:
                _mapController,
            options:
                const MapOptions(
              initialCenter:
                  LatLng(
                2.2,
                -75.60,
              ),
              initialZoom:
                  10.5,
              minZoom:
                  5,
              maxZoom:
                  18,
            ),
            children: [
              // ----------------------------------------------
              // CAPA CARTOGRÁFICA
              // ----------------------------------------------

              TileLayer(
                urlTemplate:
                    _estiloMapaActual
                        .urlTemplate,
                subdomains:
                    const [
                  'a',
                  'b',
                  'c',
                ],
                userAgentPackageName:
                    'com.mirutacafetera.app',
                maxZoom:
                    19,
              ),

              // ----------------------------------------------
              // RUTA REAL POR CARRETERA
              // ----------------------------------------------

              PolylineLayer(
                polylines:
                    _obtenerPolilineas(),
              ),

              // ----------------------------------------------
              // MARCADORES
              // ----------------------------------------------

              MarkerLayer(
                markers:
                    _obtenerMarcadores(),
              ),
            ],
          ),

          // ==================================================
          // PANEL SUPERIOR
          // ==================================================

          _construirPanelSuperior(),

          // ==================================================
          // PANEL INFERIOR DE RUTA
          // ==================================================

          _construirPanelRuta(),

          // ==================================================
          // INDICADOR DE CARGA
          // ==================================================

          if (_cargando)
            const Center(
              child:
                  Card(
                elevation:
                    8,
                child:
                    Padding(
                  padding:
                      EdgeInsets.all(
                    20,
                  ),
                  child:
                      Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height:
                            12,
                      ),
                      Text(
                        'Cargando sitios turísticos...',
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ==================================================
          // BOTÓN GENERAR RUTA
          // ==================================================

          if (!_modoCrearRuta &&
              !_cargando &&
              _sitiosSeleccionados
                      .length >=
                  2 &&
              !_calculandoRuta)
            Positioned(
              left:
                  20,
              right:
                  20,
              bottom:
                  _mostrarPanelRuta
                      ? 145
                      : 20,
              child:
                  ElevatedButton.icon(
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF1565C0,
                  ),
                  foregroundColor:
                      Colors.white,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical:
                        15,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),
                  ),
                ),
                onPressed:
                    _generarRutaPersonalizada,
                icon:
                    const Icon(
                  Icons.route,
                ),
                label:
                    Text(
                  'GENERAR RUTA '
                  '(${_sitiosSeleccionados.length} sitios)',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // LIBERAR RECURSOS
  // ==========================================================

  @override
  void dispose() {
    _searchController
        .removeListener(
      _actualizarSugerencias,
    );

    _searchController
        .dispose();

    super.dispose();
  }
}