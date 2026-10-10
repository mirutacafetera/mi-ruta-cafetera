import 'package:flutter/material.dart';

import '../../models/categoria_model.dart';
import '../../models/sitio_turistico_model.dart';
import '../../models/usuario/usuario_sesion_model.dart';
import '../../services/categoria_service.dart';
import '../../services/favorito_service.dart';
import '../../services/sitio_service.dart';
import '../../services/usuario/usuario_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../utils/text_utils.dart';
import '../../widgets/publico/banner_cuenta.dart';
import '../../widgets/publico/categoria_card.dart';
import '../../widgets/publico/home_hero.dart';
import '../../widgets/publico/requiere_cuenta_sheet.dart';
import '../../widgets/publico/sitio_card.dart';
import '../usuario/detalle_sitio_usuario_screen.dart';
import '../usuario/login_usuario_screen.dart';
import '../usuario/registro_usuario_screen.dart';

/// Home de la aplicación.
///
/// Se usa tanto para el visitante como para el usuario autenticado.
/// Con sesión conserva la misma identidad visual, pero cambia el
/// carrusel (todas las imágenes), el saludo y las acciones
/// disponibles (mapa general, favoritos persistentes).
class HomePublicoScreen extends StatefulWidget {
  const HomePublicoScreen({
    super.key,
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

  final FavoritoService _favoritoService =
      FavoritoService.instance;

  // ============================================================
  // SESIÓN Y FAVORITOS DEL USUARIO
  // ============================================================
  //
  // _favoritosPorSitio: sitioId → favoritoId.
  // Solo se llena cuando hay una sesión de usuario activa.
  // ============================================================

  final Map<String, String> _favoritosPorSitio = {};

  final Set<String> _sitiosProcesando = {};

  UsuarioSesionModel? get _sesion =>
      UsuarioSesionService.instance.sesionActual.value;

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

    UsuarioSesionService.instance.sesionActual
        .addListener(_alCambiarSesion);

    _cargarContenido();
    _cargarFavoritos();
  }

  @override
  void dispose() {
    UsuarioSesionService.instance.sesionActual
        .removeListener(_alCambiarSesion);

    super.dispose();
  }

  // ============================================================
  // CAMBIO DE SESIÓN
  // ============================================================

  void _alCambiarSesion() {
    if (!mounted) {
      return;
    }

    setState(() {
      if (_sesion == null) {
        _favoritosPorSitio.clear();
      }
    });

    _cargarFavoritos();
  }

  bool _esErrorDeSesion(Object error) {
    final texto = error.toString().toLowerCase();

    return texto.contains('expirado') ||
        texto.contains('token no es válido') ||
        texto.contains('no se proporcionó un token');
  }

  Future<void> _sesionExpirada() async {
    await UsuarioSesionService.instance.cerrarSesion();

    if (!mounted) {
      return;
    }

    _mostrarMensaje(
      'Tu sesión expiró. Inicia sesión nuevamente.',
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
        ),
      );
  }

  // ============================================================
  // CARGAR FAVORITOS
  // ============================================================

  Future<void> _cargarFavoritos() async {
    final sesion = _sesion;

    if (sesion == null) {
      return;
    }

    try {
      final favoritos =
          await _favoritoService.obtenerFavoritos(
        sesion.id,
        token: sesion.token,
      );

      // Si la sesión cambió mientras cargaba, se descarta.
      if (!mounted || _sesion?.id != sesion.id) {
        return;
      }

      final mapa = <String, String>{};

      for (final favorito in favoritos) {
        if (favorito.sitio.id.isNotEmpty) {
          mapa[favorito.sitio.id] = favorito.id;
        }
      }

      setState(() {
        _favoritosPorSitio
          ..clear()
          ..addAll(mapa);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      if (_esErrorDeSesion(error)) {
        await _sesionExpirada();
      }

      debugPrint(
        'HOME - ERROR FAVORITOS: $error',
      );
    }
  }

  // ============================================================
  // AGREGAR / QUITAR FAVORITO
  // ============================================================

  Future<void> _alternarFavorito(
    SitioTuristicoModel sitio,
  ) async {
    final sesion = _sesion;

    // Sin sesión se invita a crear una cuenta.
    if (sesion == null) {
      _requiereCuenta();
      return;
    }

    final sitioId = sitio.id;

    if (sitioId.isEmpty ||
        _sitiosProcesando.contains(sitioId)) {
      return;
    }

    _sitiosProcesando.add(sitioId);

    final favoritoId = _favoritosPorSitio[sitioId];

    try {
      if (favoritoId != null) {
        await _favoritoService.eliminarFavorito(
          favoritoId,
          token: sesion.token,
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _favoritosPorSitio.remove(sitioId);
        });

        _mostrarMensaje(
          'Sitio eliminado de favoritos.',
        );
      } else {
        final favorito =
            await _favoritoService.agregarFavorito(
          usuarioId: sesion.id,
          sitioId: sitioId,
          token: sesion.token,
        );

        if (!mounted) {
          return;
        }

        if (favorito != null) {
          setState(() {
            _favoritosPorSitio[sitioId] = favorito.id;
          });
        } else {
          await _cargarFavoritos();
        }

        _mostrarMensaje(
          'Sitio agregado a favoritos.',
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      final mensaje = error.toString().replaceFirst(
            'Exception: ',
            '',
          );

      // El backend responde 400 si ya estaba guardado:
      // se sincroniza el estado local en vez de mostrar error.
      if (mensaje.toLowerCase().contains('ya está')) {
        await _cargarFavoritos();
        return;
      }

      if (_esErrorDeSesion(error)) {
        await _sesionExpirada();
        return;
      }

      _mostrarMensaje(mensaje);
    } finally {
      _sitiosProcesando.remove(sitioId);
    }
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
    // Con sesión activa no se vuelve a pedir el login.
    final sesion = _sesion;

    if (sesion != null) {
      _mostrarMensaje(
        'Ya iniciaste sesión como ${sesion.nombre}. '
        'Tus datos están en la pestaña Perfil.',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LoginUsuarioScreen(),
      ),
    );
  }

  // ============================================================
  // REGISTRO
  // ============================================================

  void _irRegistroUsuario() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const RegistroUsuarioScreen(),
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
      onCrearCuenta:
          _irRegistroUsuario,
    );
  }

  // ============================================================
  // ABRIR MAPA GENERAL
  // ============================================================
  //
  // El mapa general con todos los sitios es exclusivo de usuarios
  // con sesión. Un visitante recibe la invitación a iniciar sesión;
  // un usuario autenticado lo abre en pantalla completa.
  // ============================================================

  void _abrirMapa() {
    if (_sesion == null) {
      RequiereCuentaSheet.mostrar(
        context: context,
        titulo: 'Explora todo el mapa',
        mensaje:
            'Inicia sesión para ver todos los sitios en el '
            'mapa, filtrar por categoría y crear tus rutas.',
        icono: Icons.map_rounded,
        onIniciarSesion: _irLoginUsuario,
        onCrearCuenta: _irRegistroUsuario,
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/mapa',
    );
  }

  // ============================================================
  // ABRIR DETALLE DEL SITIO
  // ============================================================
  //
  // Visitante y usuario ven el mismo detalle. Desde el detalle,
  // "Ver mapa" abre el mapa individual (solo ese sitio).
  //
  // * Con sesión: el corazón guarda/quita el favorito.
  // * Sin sesión: el corazón invita a iniciar sesión.
  // ============================================================

  void _abrirSitio(
    SitioTuristicoModel sitio,
  ) {
    final conSesion = _sesion != null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleSitioUsuarioScreen(
          sitio: sitio,
          imagen: _imagenSitio(sitio),
          esFavorito:
              _favoritosPorSitio.containsKey(sitio.id),
          onFavorite: conSesion
              ? () => _favoritoDesdeDetalle(sitio)
              : null,
          onRequiereCuenta: _requiereCuenta,
        ),
      ),
    );
  }

  // ============================================================
  // FAVORITO DESDE EL DETALLE
  // ============================================================
  //
  // A diferencia de _alternarFavorito, aquí los errores se
  // propagan para que el detalle revierta el corazón.
  // ============================================================

  Future<void> _favoritoDesdeDetalle(
    SitioTuristicoModel sitio,
  ) async {
    final sesion = _sesion;

    if (sesion == null) {
      throw Exception('Inicia sesión para usar favoritos.');
    }

    final sitioId = sitio.id;
    final favoritoId = _favoritosPorSitio[sitioId];

    try {
      if (favoritoId != null) {
        await _favoritoService.eliminarFavorito(
          favoritoId,
          token: sesion.token,
        );

        if (mounted) {
          setState(() {
            _favoritosPorSitio.remove(sitioId);
          });
        }
      } else {
        final favorito =
            await _favoritoService.agregarFavorito(
          usuarioId: sesion.id,
          sitioId: sitioId,
          token: sesion.token,
        );

        if (!mounted) {
          return;
        }

        if (favorito != null) {
          setState(() {
            _favoritosPorSitio[sitioId] = favorito.id;
          });
        } else {
          await _cargarFavoritos();
        }
      }
    } catch (error) {
      final mensaje = error.toString().toLowerCase();

      // Ya estaba guardado: se sincroniza y no es un error.
      if (mensaje.contains('ya está')) {
        await _cargarFavoritos();
        return;
      }

      if (_esErrorDeSesion(error)) {
        await _sesionExpirada();
      }

      rethrow;
    }
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
              usuarioAutenticado:
                  _sesion != null,
              nombre:
                  _sesion?.nombre,
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

                    if (_sesion == null) ...[
                      BannerCuenta(
                        onLogin:
                            _irLoginUsuario,
                      ),

                      const SizedBox(
                        height:
                            AppDimensions.spacingSection - 2,
                      ),
                    ],

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
                  esFavorito:
                      _favoritosPorSitio
                          .containsKey(sitio.id),
                  onFavorite: () {
                    _alternarFavorito(sitio);
                  },

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