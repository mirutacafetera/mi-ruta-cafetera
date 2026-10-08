import 'package:flutter/material.dart';

import '../../models/categoria_model.dart';
import '../../models/sitio_turistico_model.dart';
import '../../services/categoria_service.dart';
import '../../services/sitio_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../utils/text_utils.dart';
import '../../widgets/publico/banner_cuenta.dart';
import '../../widgets/publico/categoria_card.dart';
import '../../widgets/publico/home_hero.dart';
import '../../widgets/publico/requiere_cuenta_sheet.dart';
import '../../widgets/publico/sitio_card.dart';
import '../mapa_screen_2.dart';
import '../usuario/login_usuario_screen.dart';

class HomePublicoScreen extends StatefulWidget {
  /// Callback utilizado por PublicShellScreen.
  ///
  /// Recibe el sitio exacto que el usuario seleccionó
  /// para abrirlo en el mapa.
  final void Function(SitioTuristicoModel sitio)? onIrMapa;

  const HomePublicoScreen({
    super.key,
    this.onIrMapa,
  });

  @override
  State<HomePublicoScreen> createState() =>
      _HomePublicoScreenState();
}

class _HomePublicoScreenState
    extends State<HomePublicoScreen> {
  // ============================================================
  // SERVICIOS
  // ============================================================

  final CategoriaService _categoriaService =
      CategoriaService();

  final SitioService _sitioService =
      SitioService();

  // ============================================================
  // DATOS
  // ============================================================

  List<CategoriaModel> _categorias = [];

  List<SitioTuristicoModel> _sitios = [];

  // ============================================================
  // ESTADO
  // ============================================================

  bool _cargandoCategorias = true;

  bool _cargandoSitios = true;

  String? _errorCategorias;

  String? _errorSitios;

  // ============================================================
  // FILTRO POR CATEGORÍA
  // ============================================================

  String? _categoriaSeleccionada;

  // ============================================================
  // CICLO DE VIDA
  // ============================================================

  @override
  void initState() {
    super.initState();

    _cargarContenido();
  }

  // ============================================================
  // CARGAR CONTENIDO
  // ============================================================

  Future<void> _cargarContenido() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _cargandoCategorias = true;
      _cargandoSitios = true;

      _errorCategorias = null;
      _errorSitios = null;
    });

    await Future.wait([
      _cargarCategorias(),
      _cargarSitios(),
    ]);
  }

  // ============================================================
  // CATEGORÍAS
  // ============================================================

  Future<void> _cargarCategorias() async {
    try {
      final categorias =
          await _categoriaService.obtenerCategorias();

      if (!mounted) {
        return;
      }

      setState(() {
        _categorias = categorias;
        _cargandoCategorias = false;
        _errorCategorias = null;
      });

      debugPrint(
        'HOME - CATEGORÍAS CARGADAS: '
        '${categorias.length}',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _categorias = [];
        _cargandoCategorias = false;
        _errorCategorias =
            'No fue posible cargar las categorías.';
      });

      debugPrint(
        'HOME - ERROR CATEGORÍAS: $error',
      );
    }
  }

  // ============================================================
  // SITIOS
  // ============================================================

  Future<void> _cargarSitios() async {
    try {
      final sitios =
          await _sitioService.obtenerSitios();

      if (!mounted) {
        return;
      }

      setState(() {
        _sitios = sitios;
        _cargandoSitios = false;
        _errorSitios = null;
      });

      debugPrint(
        'HOME - SITIOS CARGADOS: '
        '${sitios.length}',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _sitios = [];
        _cargandoSitios = false;
        _errorSitios =
            'No fue posible cargar los sitios turísticos.';
      });

      debugPrint(
        'HOME - ERROR SITIOS: $error',
      );
    }
  }

  // ============================================================
  // RECARGAR
  // ============================================================

  Future<void> _recargar() async {
    await _cargarContenido();
  }

  // ============================================================
  // NORMALIZAR TEXTO
  // ============================================================

  String _normalizarTexto(String texto) {
    return TextUtils.normalizar(texto)
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .toLowerCase()
        .trim();
  }

  // ============================================================
  // SITIOS FILTRADOS POR CATEGORÍA
  // ============================================================

  List<SitioTuristicoModel>
      get _sitiosFiltrados {
    if (_categoriaSeleccionada == null) {
      return _sitios;
    }

    final categoriaSeleccionada =
        _normalizarTexto(
      _categoriaSeleccionada!,
    );

    return _sitios.where((sitio) {
      final categoriaSitio =
          _normalizarTexto(
        sitio.categoriaNombre,
      );

      return categoriaSitio ==
          categoriaSeleccionada;
    }).toList();
  }

  // ============================================================
  // SITIOS DESTACADOS
  //
  // Se conservan todos los sitios devueltos
  // por la API y los correspondientes a la
  // categoría seleccionada.
  // ============================================================

  List<SitioTuristicoModel>
      get _sitiosDestacados {
    return _sitiosFiltrados;
  }

  // ============================================================
  // SELECCIONAR CATEGORÍA
  // ============================================================

  void _seleccionarCategoria(
    String? categoria,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      if (categoria == null) {
        _categoriaSeleccionada = null;
        return;
      }

      final nuevaCategoria =
          _normalizarTexto(categoria);

      final categoriaActual =
          _categoriaSeleccionada == null
              ? ''
              : _normalizarTexto(
                  _categoriaSeleccionada!,
                );

      if (nuevaCategoria == categoriaActual) {
        _categoriaSeleccionada = null;
      } else {
        _categoriaSeleccionada = categoria;
      }
    });

    debugPrint(
      'HOME - CATEGORÍA SELECCIONADA: '
      '$_categoriaSeleccionada',
    );
  }

  // ============================================================
  // LIMPIAR CATEGORÍA
  // ============================================================

  void _limpiarCategoria() {
    if (!mounted) {
      return;
    }

    setState(() {
      _categoriaSeleccionada = null;
    });
  }

  // ============================================================
  // LOGIN
  // ============================================================

  void _irLoginUsuario() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LoginUsuarioScreen(),
      ),
    );
  }

  // ============================================================
  // ACCIONES QUE REQUIEREN CUENTA
  // ============================================================

  void _requiereCuenta() {
    RequiereCuentaSheet.mostrar(
      context: context,
      onIniciarSesion:
          _irLoginUsuario,
    );
  }

  // ============================================================
  // ABRIR MAPA GENERAL
  // ============================================================

  void _abrirMapa() {
    Navigator.pushNamed(
      context,
      '/mapa',
    );
  }

  // ============================================================
  // ABRIR SITIO SELECCIONADO EN EL MAPA
  // ============================================================

  void _abrirSitio(
    SitioTuristicoModel sitio,
  ) {
    // Si el Home está dentro de PublicShellScreen,
    // enviamos el sitio seleccionado al Shell.
    if (widget.onIrMapa != null) {
      widget.onIrMapa!(sitio);
      return;
    }

    // Si HomePublicoScreen se utiliza directamente,
    // abrimos el mapa y enviamos el sitio seleccionado.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapaScreen2(
          sitioInicial: sitio,
        ),
      ),
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
      backgroundColor:
          AppColors.surfaceGreen,
      body: RefreshIndicator(
        onRefresh: _recargar,
        color: AppColors.secondary,
        child: CustomScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ==================================================
            // CARRUSEL SUPERIOR
            // ==================================================

            HomeHero(
              onLogin:
                  _irLoginUsuario,
            ),

            // ==================================================
            // CONTENIDO
            // ==================================================

            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  AppDimensions.spacingLg + 4,
                  AppDimensions.spacingLg + 6,
                  AppDimensions.spacingLg + 4,
                  AppDimensions.spacingSection + 3,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // BANNER
                    // ==========================================

                    BannerCuenta(
                      onLogin:
                          _irLoginUsuario,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.spacingSection - 2,
                    ),

                    // ==========================================
                    // CATEGORÍAS
                    // ==========================================

                    _construirCategorias(),

                    const SizedBox(
                      height:
                          AppDimensions.spacingSection - 2,
                    ),

                    // ==========================================
                    // SITIOS
                    // ==========================================

                    _construirSitios(),

                    const SizedBox(
                      height:
                          AppDimensions.spacingSection,
                    ),

                    // ==========================================
                    // RUTAS
                    // ==========================================

                    _construirRutas(),

                    const SizedBox(
                      height:
                          AppDimensions.spacingSection + 3,
                    ),

                    // ==========================================
                    // MENSAJE FINAL
                    // ==========================================

                    _construirMensajeFinal(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORÍAS
  // ============================================================

  Widget _construirCategorias() {
    if (_cargandoCategorias) {
      return _construirCargaCategorias();
    }

    if (_categorias.isEmpty) {
      return _construirEstadoCategorias();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Explora por experiencia',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: AppColors.textOnDark,
          ),
        ),

        const SizedBox(
          height:
              AppDimensions.spacingMd + 3,
        ),

        SizedBox(
          height:
              AppDimensions.categoryCardHeight,
          child: ListView.separated(
            scrollDirection:
                Axis.horizontal,
            itemCount:
                _categorias.length,
            separatorBuilder:
                (context, index) {
              return const SizedBox(
                width:
                    AppDimensions.spacingMd,
              );
            },
            itemBuilder:
                (context, index) {
              final categoria =
                  _categorias[index];

              return CategoriaCard(
                categoria: categoria,
                categoriaSeleccionada:
                    _categoriaSeleccionada,
                onTap: () {
                  _seleccionarCategoria(
                    categoria.nombre,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SITIOS
  // ============================================================

  Widget _construirSitios() {
    final sitios =
        _sitiosDestacados;

    final hayFiltro =
        _categoriaSeleccionada != null;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Descubre lugares',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      AppColors.textOnDark,
                ),
              ),
            ),

            TextButton.icon(
              onPressed:
                  _abrirMapa,
              icon:
                  const Icon(
                Icons.map_outlined,
                size:
                    AppDimensions.iconSm,
              ),
              label:
                  const Text(
                'Ver mapa',
              ),
            ),
          ],
        ),

        const SizedBox(
          height:
              AppDimensions.spacingSm,
        ),

        if (_cargandoSitios)
          _construirCargaSitios()
        else if (_errorSitios != null &&
            _sitios.isEmpty)
          _construirEstadoError()
        else if (sitios.isEmpty)
          _construirEstadoVacio(
            hayFiltro: hayFiltro,
          )
        else
          SizedBox(
            height: 330,
            child:
                ListView.separated(
              scrollDirection:
                  Axis.horizontal,
              itemCount:
                  sitios.length,
              separatorBuilder:
                  (context, index) {
                return const SizedBox(
                  width:
                      AppDimensions.spacingMd + 3,
                );
              },
              itemBuilder:
                  (context, index) {
                final sitio =
                    sitios[index];

                return SitioCard(
                  sitio: sitio,
                  imagen:
                      _imagenSitio(sitio),
                  onFavorite:
                      _requiereCuenta,

                  // ==================================================
                  // IMPORTANTE:
                  // Aquí enviamos el sitio seleccionado.
                  // Ya no abrimos simplemente el mapa general.
                  // ==================================================

                  onTap: () {
                    _abrirSitio(sitio);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  // ============================================================
  // IMÁGENES DE SITIOS
  // ============================================================

  String _imagenSitio(
    SitioTuristicoModel sitio,
  ) {
    final categoria =
        _normalizarTexto(
      sitio.categoriaNombre,
    );

    if (categoria.contains('cafe')) {
      return 'assets/images/sitios/cafe.jpeg';
    }

    if (categoria.contains('artesania')) {
      return 'assets/images/sitios/artesanias.jpg';
    }

    if (categoria.contains('gastronom')) {
      return 'assets/images/sitios/gastronomia.jpeg';
    }

    if (categoria.contains('alojamiento') ||
        categoria.contains('hotel') ||
        categoria.contains('hospedaje')) {
      return 'assets/images/sitios/alojamiento.jpg';
    }

    if (categoria.contains('famil')) {
      return 'assets/images/sitios/familiares.jpeg';
    }

    if (categoria.contains('naturaleza') ||
        categoria.contains('ecoturismo') ||
        categoria.contains('senderismo')) {
      return 'assets/images/sitios/naturaleza.jpeg';
    }

    if (categoria.contains('cultura') ||
        categoria.contains('historia') ||
        categoria.contains('patrimonio')) {
      return 'assets/images/sitios/cultura.jpg';
    }

    if (categoria.contains('aventura')) {
      return 'assets/images/sitios/aventuras.jpeg';
    }

    if (categoria.contains('mirador') ||
        categoria.contains('paisaje')) {
      return 'assets/images/sitios/miradores.jpeg';
    }

    // Imagen existente como respaldo.
    return 'assets/images/sitios/naturaleza.jpeg';
  }

  // ============================================================
  // RUTAS
  // ============================================================

  Widget _construirRutas() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Rutas para inspirarte',
          style: TextStyle(
            fontSize: 21,
            fontWeight:
                FontWeight.w800,
            color:
                AppColors.textOnDark,
          ),
        ),

        const SizedBox(
          height:
              AppDimensions.spacingSm,
        ),

        _construirRutasVacias(),
      ],
    );
  }

  // ============================================================
  // RUTAS VACÍAS
  // ============================================================

  Widget _construirRutasVacias() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        border:
            Border.all(
          color:
              AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppColors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(
              color:
                  AppColors.getSoftColorForCategory(
                'naturaleza',
              ),
              shape:
                  BoxShape.circle,
            ),
            child:
                const Icon(
              Icons.route_rounded,
              color:
                  AppColors.primary,
              size: 29,
            ),
          ),

          const SizedBox(
            width:
                AppDimensions.spacingMd,
          ),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Muy pronto',
                  style:
                      TextStyle(
                    color:
                        AppColors.primary,
                    fontWeight:
                        FontWeight.w800,
                    fontSize: 15,
                  ),
                ),

                SizedBox(
                  height:
                      AppDimensions.spacingXs,
                ),

                Text(
                  'Estamos preparando rutas '
                  'especiales para que descubras '
                  'el Huila paso a paso.',
                  style:
                      TextStyle(
                    color:
                        AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MENSAJE FINAL
  // ============================================================

  Widget _construirMensajeFinal() {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.eco_rounded,
            color:
                AppColors.coffeeLight,
            size:
                AppDimensions.iconLg + 6,
          ),

          const SizedBox(
            height:
                AppDimensions.spacingSm + 2,
          ),

          const Text(
            'En cada taza hay una historia, '
            'un paisaje y un corazón que late.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  AppColors.secondary,
              fontSize: 15,
              fontStyle:
                  FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARGA DE CATEGORÍAS
  // ============================================================

  Widget _construirCargaCategorias() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Explora por experiencia',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color:
                AppColors.textOnDark,
          ),
        ),

        const SizedBox(
          height:
              AppDimensions.spacingMd,
        ),

        SizedBox(
          height:
              AppDimensions.categoryCardHeight,
          child:
              ListView.separated(
            scrollDirection:
                Axis.horizontal,
            itemCount: 5,
            separatorBuilder:
                (context, index) {
              return const SizedBox(
                width:
                    AppDimensions.spacingMd,
              );
            },
            itemBuilder:
                (context, index) {
              return const
                  _CategoriaSkeleton();
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CARGA DE SITIOS
  // ============================================================

  Widget _construirCargaSitios() {
    return SizedBox(
      height: 330,
      child:
          ListView.separated(
        scrollDirection:
            Axis.horizontal,
        itemCount: 3,
        separatorBuilder:
            (context, index) {
          return const SizedBox(
            width:
                AppDimensions.spacingMd + 3,
          );
        },
        itemBuilder:
            (context, index) {
          return const
              _SitioCardSkeleton();
        },
      ),
    );
  }

  // ============================================================
  // ERROR CATEGORÍAS
  // ============================================================

  Widget _construirEstadoCategorias() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal:
            AppDimensions.spacingLg,
        vertical:
            AppDimensions.spacingMd,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        border:
            Border.all(
          color:
              AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.category_outlined,
            color:
                AppColors.textSecondary,
          ),

          const SizedBox(
            width:
                AppDimensions.spacingSm,
          ),

          Expanded(
            child: Text(
              _errorCategorias ??
                  'No se pudieron cargar las categorías.',
              style:
                  const TextStyle(
                color:
                    AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),

          TextButton(
            onPressed:
                _recargar,
            child:
                const Text(
              'Reintentar',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR SITIOS
  // ============================================================

  Widget _construirEstadoError() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        border:
            Border.all(
          color:
              AppColors.border,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color:
                AppColors.textSecondary,
            size: 38,
          ),

          const SizedBox(
            height:
                AppDimensions.spacingMd,
          ),

          const Text(
            'No pudimos cargar los sitios.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontWeight:
                  FontWeight.bold,
              color:
                  AppColors.textPrimary,
            ),
          ),

          const SizedBox(
            height:
                AppDimensions.spacingSm,
          ),

          Text(
            _errorSitios ??
                'Ocurrió un problema al obtener '
                'los sitios turísticos.',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  AppColors.textSecondary,
              fontSize: 13,
            ),
          ),

          const SizedBox(
            height:
                AppDimensions.spacingSm,
          ),

          TextButton(
            onPressed:
                _recargar,
            child:
                const Text(
              'Intentar nuevamente',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIN RESULTADOS
  // ============================================================

  Widget _construirEstadoVacio({
    required bool hayFiltro,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        border:
            Border.all(
          color:
              AppColors.border,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.travel_explore_rounded,
            color:
                AppColors.coffeeLight,
            size: 42,
          ),

          const SizedBox(
            height:
                AppDimensions.spacingMd,
          ),

          Text(
            hayFiltro
                ? 'No encontramos lugares '
                  'para esta categoría.'
                : 'Todavía no hay lugares disponibles.',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  AppColors.textSecondary,
              fontSize: 14,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          if (hayFiltro)
            TextButton(
              onPressed:
                  _limpiarCategoria,
              child:
                  const Text(
                'Mostrar todos',
              ),
            ),
        ],
      ),
    );
  }
}

// =====================================================================
// SKELETON CATEGORÍA
// =====================================================================

class _CategoriaSkeleton
    extends StatelessWidget {
  const _CategoriaSkeleton();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          AppDimensions.categoryCardWidth,
      height:
          AppDimensions.categoryCardHeight,
      decoration:
          BoxDecoration(
        color:
            AppColors.surfaceVariant,
        borderRadius:
            BorderRadius.circular(
          AppDimensions.categoryRadius,
        ),
      ),
    );
  }
}

// =====================================================================
// SKELETON SITIO
// =====================================================================

class _SitioCardSkeleton
    extends StatelessWidget {
  const _SitioCardSkeleton();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          AppDimensions.sitioCardWidth,
      height: 330,
      decoration:
          BoxDecoration(
        color:
            AppColors.surfaceVariant,
        borderRadius:
            BorderRadius.circular(
          AppDimensions.sitioCardRadius,
        ),
      ),
    );
  }
}