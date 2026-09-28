import 'package:flutter/material.dart';

import '../../models/categoria_model.dart';
import '../../models/ruta_model.dart';
import '../../models/sitio_turistico_model.dart';
import '../../services/categoria_service.dart';
import '../../services/ruta_service.dart';
import '../../services/sitio_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../usuario/login_usuario_screen.dart';

class HomePublicoScreen extends StatefulWidget {
  const HomePublicoScreen({
    super.key,
  });

  @override
  State<HomePublicoScreen> createState() =>
      _HomePublicoScreenState();
}

class _HomePublicoScreenState extends State<HomePublicoScreen> {
  // ============================================================
  // SERVICIOS
  // ============================================================

  final CategoriaService _categoriaService =
      CategoriaService();

  final SitioService _sitioService =
      SitioService();

  final RutaService _rutaService =
      RutaService();

  // ============================================================
  // DATOS
  // ============================================================

  List<CategoriaModel> _categorias = [];
  List<SitioTuristicoModel> _sitios = [];
  List<RutaModel> _rutas = [];

  // ============================================================
  // ESTADO
  // ============================================================

  bool _cargando = true;
  bool _cargandoRutas = true;
  String? _error;

  String _busqueda = '';
  String? _categoriaSeleccionada;

  // ============================================================
  // CONTROLADORES
  // ============================================================

  final TextEditingController _busquedaController =
      TextEditingController();

  // ============================================================
  // CICLO DE VIDA
  // ============================================================

  @override
  void initState() {
    super.initState();

    _cargarContenido();
  }

  @override
  void dispose() {
    _busquedaController.dispose();

    super.dispose();
  }

  // ============================================================
  // CARGAR CONTENIDO
  // ============================================================

  Future<void> _cargarContenido() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultados = await Future.wait([
        _categoriaService.obtenerCategorias(),
        _sitioService.obtenerSitios(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _categorias =
            resultados[0] as List<CategoriaModel>;

        _sitios =
            resultados[1] as List<SitioTuristicoModel>;

        _cargando = false;
      });

      _cargarRutas();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargando = false;
        _error =
            'No fue posible cargar la información '
            'turística.';
      });

      _cargarRutas();
    }
  }

  // ============================================================
  // CARGAR RUTAS
  // ============================================================

  Future<void> _cargarRutas() async {
    try {
      final rutas =
          await _rutaService.obtenerRutasPredefinidas();

      if (!mounted) {
        return;
      }

      setState(() {
        _rutas = rutas;
        _cargandoRutas = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _rutas = [];
        _cargandoRutas = false;
      });
    }
  }

  // ============================================================
  // RECARGAR
  // ============================================================

  Future<void> _recargar() async {
    await _cargarContenido();
  }

  // ============================================================
  // FILTRAR SITIOS
  // ============================================================

  List<SitioTuristicoModel> get _sitiosFiltrados {
    final texto =
        _busqueda.trim().toLowerCase();

    return _sitios.where((sitio) {
      final coincideBusqueda =
          texto.isEmpty ||
          sitio.nombre
              .toLowerCase()
              .contains(texto) ||
          sitio.descripcion
              .toLowerCase()
              .contains(texto) ||
          sitio.categoriaNombre
              .toLowerCase()
              .contains(texto) ||
          sitio.ciudad
              .toLowerCase()
              .contains(texto);

      final coincideCategoria =
          _categoriaSeleccionada == null ||
          sitio.categoriaNombre
                  .toLowerCase()
                  .trim() ==
              _categoriaSeleccionada!
                  .toLowerCase()
                  .trim();

      return coincideBusqueda &&
          coincideCategoria;
    }).toList();
  }

  // ============================================================
  // SITIOS DESTACADOS
  // ============================================================

  List<SitioTuristicoModel> get _sitiosDestacados {
    final sitios = _sitiosFiltrados;

    if (sitios.length <= 8) {
      return sitios;
    }

    return sitios.take(8).toList();
  }

  // ============================================================
  // SELECCIONAR CATEGORÍA
  // ============================================================

  void _seleccionarCategoria(
    String? categoria,
  ) {
    setState(() {
      if (_categoriaSeleccionada == categoria) {
        _categoriaSeleccionada = null;
      } else {
        _categoriaSeleccionada = categoria;
      }
    });
  }

  // ============================================================
  // BUSCAR
  // ============================================================

  void _actualizarBusqueda(
    String valor,
  ) {
    setState(() {
      _busqueda = valor;
    });
  }

  // ============================================================
  // IR AL LOGIN
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
  // REQUIERE CUENTA
  // ============================================================

  void _requiereCuenta() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingXxl,
            AppDimensions.spacingMd + 6,
            AppDimensions.spacingXxl,
            AppDimensions.spacingSection - 2,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                AppDimensions.radiusXxl + 6,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius:
                      BorderRadius.circular(
                    AppDimensions.radiusSm,
                  ),
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingXl,
              ),
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.secondary,
                  size: 35,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingMd + 6,
              ),
              const Text(
                'Guarda tus lugares favoritos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingSm + 2,
              ),
              const Text(
                'Crea una cuenta gratuita para guardar '
                'lugares, organizar tus rutas y disfrutar '
                'de una experiencia personalizada.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingLg + 6,
              ),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _irLoginUsuario();
                  },
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingSm,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _irLoginUsuario();
                },
                child: const Text(
                  'Crear mi cuenta',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ABRIR MAPA
  // ============================================================

  void _abrirMapa() {
    Navigator.pushNamed(
      context,
      '/mapa',
    );
  }

  // ============================================================
  // ABRIR SITIO EN MAPA
  // ============================================================

  void _abrirSitio(
    SitioTuristicoModel sitio,
  ) {
    _abrirMapa();
  }

  // ============================================================
  // CONSTRUCCIÓN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _recargar,
        color: AppColors.secondary,
        child: CustomScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          slivers: [
            _construirHero(),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingLg + 4,
                  AppDimensions.spacingLg + 6,
                  AppDimensions.spacingLg + 4,
                  AppDimensions.spacingSection + 3,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _construirBuscador(),

                    const SizedBox(
                      height:
                          AppDimensions.spacingSection - 4,
                    ),

                    _construirCategorias(),

                    const SizedBox(
                      height:
                          AppDimensions.spacingSection - 2,
                    ),

                    _construirSitios(),

                    const SizedBox(
                      height:
                          AppDimensions.spacingSection,
                    ),

                    _construirBannerCuenta(),

                    const SizedBox(
                      height:
                          AppDimensions.spacingSection,
                    ),

                    _construirRutas(),

                    const SizedBox(
                      height:
                          AppDimensions.spacingSection + 3,
                    ),

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
  // HERO
  // ============================================================

  Widget _construirHero() {
    return SliverAppBar(
      expandedHeight: 290,
      pinned: true,
      backgroundColor: AppColors.coffeeDark,
      foregroundColor: AppColors.white,
      elevation: AppDimensions.elevationNone,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/bienvenida/cafe.jpg',
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.coffeeDark,
                        AppColors.primaryDark,
                        AppColors.secondary,
                      ],
                    ),
                  ),
                );
              },
            ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.coffeeDark.withValues(
                      alpha: 0.20,
                    ),
                    AppColors.primaryDark.withValues(
                      alpha: 0.48,
                    ),
                    AppColors.coffeeDark.withValues(
                      alpha: 0.82,
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              right: -35,
              top: 40,
              child: Icon(
                Icons.local_cafe_rounded,
                size: 175,
                color:
                    AppColors.white.withValues(
                  alpha: 0.055,
                ),
              ),
            ),

            Positioned(
              left: -45,
              top: 105,
              child: Icon(
                Icons.eco_rounded,
                size: 145,
                color:
                    AppColors.white.withValues(
                  alpha: 0.035,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingXxl,
                75,
                AppDimensions.spacingXxl,
                AppDimensions.spacingXl + 5,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  Text(
                    'Hola, explorador 👋',
                    style: TextStyle(
                      color:
                          AppColors.white.withValues(
                        alpha: 0.78,
                      ),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingSm,
                  ),
                  const Text(
                    'Descubre la magia\ndel café.',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 34,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height:
                        AppDimensions.spacingSm + 2,
                  ),
                  Text(
                    'Paisajes, sabores, cultura y '
                    'experiencias del Huila.',
                    style: TextStyle(
                      color:
                          AppColors.white.withValues(
                        alpha: 0.82,
                      ),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(
            right: AppDimensions.spacingSm + 4,
          ),
          child: IconButton(
            tooltip: 'Iniciar sesión',
            onPressed: _irLoginUsuario,
            icon: const Icon(
              Icons.person_outline_rounded,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUSCADOR
  // ============================================================

  Widget _construirBuscador() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg + 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppColors.black.withValues(
              alpha: 0.06,
            ),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: AppDimensions.spacingMd + 6,
          ),
          const Icon(
            Icons.search_rounded,
            color: AppColors.textLight,
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(
            child: TextField(
              controller: _busquedaController,
              onChanged: _actualizarBusqueda,
              decoration: const InputDecoration(
                hintText:
                    '¿Qué te gustaría descubrir?',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_busqueda.isNotEmpty)
            IconButton(
              tooltip: 'Limpiar búsqueda',
              onPressed: () {
                _busquedaController.clear();

                _actualizarBusqueda('');
              },
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.textLight,
              ),
            ),
          Container(
            margin: const EdgeInsets.all(7),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radiusMd + 2,
              ),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppColors.white,
              size: AppDimensions.iconMd,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORÍAS
  // ============================================================

  Widget _construirCategorias() {
    if (_cargando) {
      return _construirSeccionCarga(
        titulo: 'Explora por experiencia',
        altura: 112,
      );
    }

    if (_categorias.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Explora por experiencia',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(
          height: AppDimensions.spacingMd + 3,
        ),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categorias.length,
            separatorBuilder: (
              context,
              index,
            ) {
              return const SizedBox(
                width: AppDimensions.spacingMd,
              );
            },
            itemBuilder: (
              context,
              index,
            ) {
              final categoria =
                  _categorias[index];

              final nombre =
                  categoria.nombre.trim();

              final seleccionada =
                  _categoriaSeleccionada
                          ?.toLowerCase() ==
                      nombre.toLowerCase();

              return _CategoriaCard(
                nombre: nombre,
                seleccionada: seleccionada,
                onTap: () {
                  _seleccionarCategoria(
                    nombre,
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
    final sitios = _sitiosDestacados;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Descubre lugares',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: _abrirMapa,
              child: const Text(
                'Ver mapa',
              ),
            ),
          ],
        ),
        const SizedBox(
          height: AppDimensions.spacingSm,
        ),
        if (_cargando)
          SizedBox(
            height: 245,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (
                context,
                index,
              ) {
                return const SizedBox(
                  width:
                      AppDimensions.spacingMd + 3,
                );
              },
              itemBuilder: (
                context,
                index,
              ) {
                return const _SitioCardSkeleton();
              },
            ),
          )
        else if (_error != null &&
            _sitios.isEmpty)
          _construirEstadoError()
        else if (sitios.isEmpty)
          _construirEstadoVacio()
        else
          SizedBox(
            height: 245,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sitios.length,
              separatorBuilder: (
                context,
                index,
              ) {
                return const SizedBox(
                  width:
                      AppDimensions.spacingMd + 3,
                );
              },
              itemBuilder: (
                context,
                index,
              ) {
                final sitio = sitios[index];

                return _SitioCard(
                  sitio: sitio,
                  onFavorite:
                      _requiereCuenta,
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
  // BANNER CUENTA
  // ============================================================

  Widget _construirBannerCuenta() {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.spacingXl + 2,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.coffeeLight,
          ],
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXxl,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vive la experiencia completa',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingSm,
                ),
                Text(
                  'Inicia sesión para guardar '
                  'favoritos y crear tus rutas.',
                  style: TextStyle(
                    color:
                        AppColors.white.withValues(
                      alpha: 0.78,
                    ),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(
                  height:
                      AppDimensions.spacingMd + 4,
                ),
                OutlinedButton(
                  onPressed: _irLoginUsuario,
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        AppColors.white,
                    side: const BorderSide(
                      color: AppColors.white,
                    ),
                  ),
                  child: const Text(
                    'Iniciar sesión',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Icon(
            Icons.local_cafe_rounded,
            size: 75,
            color:
                AppColors.white.withValues(
              alpha: 0.16,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RUTAS
  // ============================================================

  Widget _construirRutas() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Rutas para inspirarte',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (_rutas.isNotEmpty)
              TextButton(
                onPressed: _abrirMapa,
                child: const Text(
                  'Ver mapa',
                ),
              ),
          ],
        ),
        const SizedBox(
          height: AppDimensions.spacingSm,
        ),
        if (_cargandoRutas)
          const _RutaSkeleton()
        else if (_rutas.isEmpty)
          _construirRutasVacias()
        else
          Column(
            children: _rutas
                .take(4)
                .map(
                  (ruta) => Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom:
                          AppDimensions.spacingMd,
                    ),
                    child: _RutaCard(
                      ruta: ruta,
                      onTap: _abrirMapa,
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  // ============================================================
  // ESTADO VACÍO DE RUTAS
  // ============================================================

  Widget _construirRutasVacias() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppColors.cream,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.route_rounded,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          const Expanded(
            child: Text(
              'Pronto encontrarás rutas diseñadas '
              'para descubrir el Huila.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
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
            color: AppColors.coffeeLight,
            size: AppDimensions.iconLg + 6,
          ),
          const SizedBox(
            height: AppDimensions.spacingSm + 2,
          ),
          const Text(
            'En cada taza hay una historia, '
            'un paisaje y un corazón que late.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ESTADO DE ERROR
  // ============================================================

  Widget _construirEstadoError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.textSecondary,
            size: 38,
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          const Text(
            'No pudimos cargar los sitios.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingSm,
          ),
          TextButton(
            onPressed: _recargar,
            child: const Text(
              'Intentar nuevamente',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ESTADO VACÍO
  // ============================================================

  Widget _construirEstadoVacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.travel_explore_rounded,
            color: AppColors.coffeeLight,
            size: 42,
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          Text(
            _busqueda.isNotEmpty ||
                    _categoriaSeleccionada != null
                ? 'No encontramos lugares con estos filtros.'
                : 'Todavía no hay lugares disponibles.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          if (_busqueda.isNotEmpty ||
              _categoriaSeleccionada != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _busqueda = '';
                  _categoriaSeleccionada = null;
                });

                _busquedaController.clear();
              },
              child: const Text(
                'Limpiar filtros',
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // CARGA
  // ============================================================

  Widget _construirSeccionCarga({
    required String titulo,
    required double altura,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        SizedBox(
          height: altura,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (
              context,
              index,
            ) {
              return const SizedBox(
                width: AppDimensions.spacingMd,
              );
            },
            itemBuilder: (
              context,
              index,
            ) {
              return const _CategoriaSkeleton();
            },
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// IMÁGENES DE CATEGORÍAS
// ======================================================================

String _imagenCategoria(String nombre) {
  final categoria = nombre.toLowerCase().trim();

  if (categoria.contains('café') ||
      categoria.contains('cafe')) {
    return 'assets/images/sitios/cafe.jpg';
  }

  if (categoria.contains('artesanía') ||
      categoria.contains('artesania')) {
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

  return 'assets/images/bienvenida/paisaje.jpg';
}

// ======================================================================
// CATEGORÍA
// ======================================================================

class _CategoriaCard extends StatelessWidget {
  final String nombre;
  final bool seleccionada;
  final VoidCallback onTap;

  const _CategoriaCard({
    required this.nombre,
    required this.seleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        AppColors.getColorForCategory(nombre);

    final icono =
        AppColors.getIconForCategory(nombre);

    return InkWell(
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusXl + 2,
      ),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        width: 105,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingSm + 1,
          horizontal: AppDimensions.spacingSm,
        ),
        decoration: BoxDecoration(
          color: seleccionada
              ? color
              : AppColors.surface,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusXl + 2,
          ),
          border: Border.all(
            color: seleccionada
                ? color
                : AppColors.border,
          ),
          boxShadow: seleccionada
              ? [
                  BoxShadow(
                    color: color.withValues(
                      alpha: 0.20,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusLg,
              ),
              child: SizedBox(
                width: 58,
                height: 58,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      _imagenCategoria(nombre),
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          color: seleccionada
                              ? AppColors.white
                                  .withValues(alpha: 0.18)
                              : color.withValues(
                                  alpha: 0.10,
                                ),
                          child: Icon(
                            icono,
                            color: seleccionada
                                ? AppColors.white
                                : color,
                            size: 25,
                          ),
                        );
                      },
                    ),
                    Container(
                      color: AppColors.coffeeDark
                          .withValues(
                        alpha:
                            seleccionada ? 0.18 : 0.08,
                      ),
                    ),
                    Icon(
                      icono,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: AppDimensions.spacingXs,
            ),
            Expanded(
              child: Center(
                child: Text(
                  nombre,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.05,
                    fontWeight:
                        FontWeight.w600,
                    color: seleccionada
                        ? AppColors.white
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// SITIO
// ======================================================================

class _SitioCard extends StatefulWidget {
  final SitioTuristicoModel sitio;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const _SitioCard({
    required this.sitio,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  State<_SitioCard> createState() =>
      _SitioCardState();
}

class _SitioCardState
    extends State<_SitioCard> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final color =
        AppColors.getColorForCategory(
      widget.sitio.categoriaNombre,
    );

    final icono =
        AppColors.getIconForCategory(
      widget.sitio.categoriaNombre,
    );

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _presionado = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _presionado = false;
        });

        widget.onTap();
      },
      onTapCancel: () {
        setState(() {
          _presionado = false;
        });
      },
      child: AnimatedScale(
        scale: _presionado ? 0.97 : 1,
        duration: const Duration(
          milliseconds: 130,
        ),
        child: Container(
          width: 255,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radiusXxl - 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.black.withValues(
                  alpha: 0.07,
                ),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(
                    top: Radius.circular(
                      AppDimensions.radiusXxl - 2,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        _imagenCategoria(
                          widget.sitio.categoriaNombre,
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient:
                                  LinearGradient(
                                begin:
                                    Alignment.topLeft,
                                end:
                                    Alignment.bottomRight,
                                colors: [
                                  color,
                                  AppColors
                                      .coffeeLight,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        color: AppColors.coffeeDark
                            .withValues(
                          alpha: 0.24,
                        ),
                      ),
                      Positioned(
                        right: -15,
                        bottom: -20,
                        child: Icon(
                          icono,
                          size: 120,
                          color: AppColors.white
                              .withValues(
                            alpha: 0.09,
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(
                          icono,
                          size: 70,
                          color: AppColors.white
                              .withValues(
                            alpha: 0.28,
                          ),
                        ),
                      ),
                      Positioned(
                        top:
                            AppDimensions
                                    .spacingSm +
                                4,
                        right:
                            AppDimensions
                                    .spacingSm +
                                4,
                        child: Material(
                          color:
                              AppColors.white,
                          shape:
                              const CircleBorder(),
                          child: IconButton(
                            onPressed:
                                widget
                                    .onFavorite,
                            icon: const Icon(
                              Icons
                                  .favorite_border_rounded,
                            ),
                            color:
                                AppColors.secondary,
                            iconSize:
                                AppDimensions
                                        .iconSm +
                                    3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.all(
                  AppDimensions.spacingMd + 2,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.sitio.nombre,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  AppColors
                                      .textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width:
                              AppDimensions
                                  .spacingXs,
                        ),
                        Icon(
                          Icons
                              .arrow_forward_rounded,
                          size:
                              AppDimensions.iconSm,
                          color: color,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height:
                          AppDimensions.spacingXs + 1,
                    ),
                    Text(
                      widget.sitio.descripcion,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color:
                            AppColors
                                .textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(
                      height:
                          AppDimensions.spacingSm,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons
                              .location_on_rounded,
                          size: 14,
                          color: color,
                        ),
                        const SizedBox(
                          width:
                              AppDimensions
                                  .spacingXs,
                        ),
                        Expanded(
                          child: Text(
                            widget.sitio.ciudad,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
}

// ======================================================================
// RUTA
// ======================================================================

class _RutaCard extends StatefulWidget {
  final RutaModel ruta;
  final VoidCallback onTap;

  const _RutaCard({
    required this.ruta,
    required this.onTap,
  });

  @override
  State<_RutaCard> createState() =>
      _RutaCardState();
}

class _RutaCardState
    extends State<_RutaCard> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _presionado = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _presionado = false;
        });

        widget.onTap();
      },
      onTapCancel: () {
        setState(() {
          _presionado = false;
        });
      },
      child: AnimatedScale(
        scale: _presionado ? 0.98 : 1,
        duration: const Duration(
          milliseconds: 130,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            AppDimensions.spacingMd + 3,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusXl + 1,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(
                  alpha: 0.035,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.coffeeLight,
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    AppDimensions.radiusMd + 4,
                  ),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(
                width: AppDimensions.spacingMd + 2,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.ruta.nombre,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(
                      height:
                          AppDimensions.spacingXs + 1,
                    ),
                    Text(
                      _textoRuta(),
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color:
                            AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(
                      height:
                          AppDimensions.spacingSm,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_rounded,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(
                          width: AppDimensions.spacingXs,
                        ),
                        Text(
                          '${widget.ruta.sitios.length} '
                          '${widget.ruta.sitios.length == 1 ? 'lugar' : 'lugares'}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w600,
                            color:
                                AppColors.secondary,
                          ),
                        ),
                        if (widget.ruta.distanciaKm > 0) ...[
                          const SizedBox(
                            width:
                                AppDimensions.spacingMd,
                          ),
                          const Icon(
                            Icons.route_rounded,
                            size: 14,
                            color:
                                AppColors.coffeeLight,
                          ),
                          const SizedBox(
                            width:
                                AppDimensions.spacingXs,
                          ),
                          Text(
                            '${widget.ruta.distanciaKm.toStringAsFixed(1)} km',
                            style:
                                const TextStyle(
                              fontSize: 11,
                              color:
                                  AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: AppDimensions.spacingSm,
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppDimensions.iconSm,
                color: AppColors.coffeeLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _textoRuta() {
    if (widget.ruta.sitios.isEmpty) {
      return 'Ruta turística del Huila';
    }

    return 'Una experiencia para descubrir '
        '${widget.ruta.sitios.length} '
        '${widget.ruta.sitios.length == 1 ? 'lugar' : 'lugares'} '
        'del Huila.';
  }
}

// ======================================================================
// SKELETON CATEGORÍA
// ======================================================================

class _CategoriaSkeleton
    extends StatelessWidget {
  const _CategoriaSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radiusXl + 2,
        ),
      ),
    );
  }
}

// ======================================================================
// SKELETON SITIO
// ======================================================================

class _SitioCardSkeleton
    extends StatelessWidget {
  const _SitioCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 255,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radiusXxl - 2,
        ),
      ),
    );
  }
}

// ======================================================================
// SKELETON RUTA
// ======================================================================

class _RutaSkeleton
    extends StatelessWidget {
  const _RutaSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 115,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radiusXl + 1,
        ),
      ),
    );
  }
}