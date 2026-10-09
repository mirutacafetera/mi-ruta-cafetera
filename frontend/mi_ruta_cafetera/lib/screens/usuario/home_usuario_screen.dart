import 'package:flutter/material.dart';

import '../../../models/sitio_turistico_model.dart';
import '../../../services/favorito_service.dart';
import '../../../services/sitio_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/publico/sitio_card.dart';
import '../mapa_screen_2.dart';
import 'detalle_sitio_usuario_screen.dart';
import 'favoritos_usuario_screen.dart';
import 'rutas_usuario_screen.dart';

class HomeUsuarioScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final String token;

  const HomeUsuarioScreen({
    super.key,
    required this.usuario,
    required this.token,
  });

  @override
  State<HomeUsuarioScreen> createState() =>
      _HomeUsuarioScreenState();
}

class _HomeUsuarioScreenState
    extends State<HomeUsuarioScreen> {
  final SitioService _sitioService = SitioService();

  final FavoritoService _favoritoService =
      FavoritoService.instance;

  final TextEditingController _busquedaController =
      TextEditingController();

List<SitioTuristicoModel> _sitios = [];
List<SitioTuristicoModel> _sitiosFiltrados = [];

bool _cargandoSitios = false;

final Map<String, String> _favoritosPorSitio = {};


  String get _usuarioId =>
      (widget.usuario['id'] ??
              widget.usuario['_id'] ??
              '')
          .toString();

  String get _nombreUsuario =>
      (widget.usuario['nombre'] ?? 'Viajero').toString();

  @override
  void initState() {
    super.initState();

    _cargarSitios();
    _cargarFavoritos();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  // ============================================================
  // CARGAR SITIOS
  // ============================================================

  Future<void> _cargarSitios() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _cargandoSitios = true;
    });

    try {
      final sitios = await _sitioService.obtenerSitios();

      if (!mounted) {
        return;
      }

      setState(() {
        _sitios = sitios;
        _sitiosFiltrados = sitios;
        _cargandoSitios = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargandoSitios = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No fue posible cargar los sitios turísticos.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // CARGAR FAVORITOS
  // ============================================================

  Future<void> _cargarFavoritos() async {
    if (_usuarioId.isEmpty) {
      return;
    }

    try {
      final favoritos =
      await _favoritoService.obtenerFavoritos(
      _usuarioId,
      token: widget.token,
      );

      if (!mounted) {
        return;
      }

      final mapa = <String, String>{};

      for (final favorito in favoritos) {
        final sitioId = favorito.sitio.id;

        if (sitioId.isNotEmpty) {
          mapa[sitioId] = favorito.id;
        }
      }

      setState(() {
        _favoritosPorSitio
          ..clear()
          ..addAll(mapa);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
    }
  }

  // ============================================================
  // BUSCAR SITIOS
  // ============================================================

  void _buscarSitios(String texto) {
    final consulta = _normalizarTexto(texto);

    if (consulta.isEmpty) {
      setState(() {
        _sitiosFiltrados = _sitios;
      });
      return;
    }

    final resultados = _sitios.where((sitio) {
      final nombre = _normalizarTexto(sitio.nombre);
      final descripcion =
          _normalizarTexto(sitio.descripcion);
      final ciudad = _normalizarTexto(sitio.ciudad);
      final categoria =
          _normalizarTexto(sitio.categoriaNombre);

      return nombre.contains(consulta) ||
          descripcion.contains(consulta) ||
          ciudad.contains(consulta) ||
          categoria.contains(consulta);
    }).toList();

    setState(() {
      _sitiosFiltrados = resultados;
    });
  }

  // ============================================================
  // FAVORITOS
  // ============================================================

  Future<void> _alternarFavorito(
    SitioTuristicoModel sitio,
  ) async {
    if (_usuarioId.isEmpty) {
      _mostrarMensaje(
        'No se pudo identificar al usuario.',
      );
      return;
    }

    final sitioId = sitio.id;

    if (sitioId.isEmpty) {
      _mostrarMensaje(
        'Este sitio no tiene un identificador válido.',
      );
      return;
    }

    final favoritoId = _favoritosPorSitio[sitioId];

    try {
      if (favoritoId != null) {
        await _favoritoService.eliminarFavorito(
        favoritoId,
        token: widget.token,
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
        usuarioId: _usuarioId,
        sitioId: sitioId,
        token: widget.token,
      );

        if (!mounted) {
          return;
        }

        if (favorito != null) {
          setState(() {
            _favoritosPorSitio[sitioId] =
                favorito.id;
          });
        } else {
          await _cargarFavoritos();
        }

        _mostrarMensaje(
          'Sitio agregado a favoritos.',
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _mostrarMensaje(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  // ============================================================
  // NAVEGACIÓN
  // ============================================================

  void _abrirMapa() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapaScreen2(),
      ),
    );
  }

  void _abrirRutas() {
    if (_usuarioId.isEmpty) {
      _mostrarMensaje(
        'No se pudo identificar al usuario.',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RutasUsuarioScreen(
        usuarioId: _usuarioId,
        token: widget.token,
        ),
      ),
    );
  }

  void _abrirFavoritos() {
    if (_usuarioId.isEmpty) {
      _mostrarMensaje(
        'No se pudo identificar al usuario.',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritosUsuarioScreen(
      usuarioId: _usuarioId,
      token: widget.token,
      ),
      ),
    ).then((_) {
      _cargarFavoritos();
    });
  }

  void _abrirSitio(
    SitioTuristicoModel sitio,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleSitioUsuarioScreen(
          sitio: sitio,
          imagen: _imagenSitio(sitio),
          esFavorito:
              _favoritosPorSitio.containsKey(
            sitio.id,
          ),
          onFavorite: () async {
            await _alternarFavorito(sitio);
          },
        ),
      ),
    ).then((_) {
      _cargarFavoritos();
    });
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Cerrar sesión',
          ),
          content: const Text(
            '¿Deseas cerrar tu sesión?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Cerrar sesión',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    Navigator.pop(context);
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
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              _cargarSitios(),
              _cargarFavoritos(),
            ]);
          },
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(
              AppDimensions.spacingLg + 4,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                // ==================================================
                // BIENVENIDA
                // ==================================================

                Container(
                  padding: const EdgeInsets.all(
                    AppDimensions.spacingXxl,
                  ),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      AppDimensions.radiusXxl,
                    ),
                    color: AppColors.cream,
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.coffee,
                        size: 65,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(
                        height:
                            AppDimensions.spacingLg - 1,
                      ),
                      Text(
                        '¡Hola, $_nombreUsuario! 👋',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color:
                              AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(
                        height:
                            AppDimensions.spacingSm,
                      ),
                      const Text(
                        'Bienvenido a Mi Ruta Cafetera',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height:
                      AppDimensions.spacingXxl + 1,
                ),

                // ==================================================
                // BUSCADOR
                // ==================================================

                TextField(
                  controller: _busquedaController,
                  onChanged: _buscarSitios,
                  decoration: InputDecoration(
                    hintText:
                        '¿Qué quieres descubrir?',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    suffixIcon:
                        _busquedaController
                                .text
                                .isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _busquedaController
                                      .clear();
                                  _buscarSitios('');
                                },
                                icon: const Icon(
                                  Icons.clear,
                                ),
                              )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height:
                      AppDimensions.spacingXxl + 1,
                ),

                // ==================================================
                // OPCIONES PRINCIPALES
                // ==================================================

                const Text(
                  'Explora',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(
                  height:
                      AppDimensions.spacingMd + 3,
                ),

                Row(
                  children: [
                    Expanded(
                      child: _opcionExplorar(
                        icon: Icons.map_outlined,
                        titulo: 'Mapa',
                        onTap: _abrirMapa,
                      ),
                    ),
                    const SizedBox(
                      width: AppDimensions.spacingMd,
                    ),
                    Expanded(
                      child: _opcionExplorar(
                        icon:
                            Icons.route_outlined,
                        titulo: 'Rutas',
                        onTap: _abrirRutas,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: AppDimensions.spacingMd,
                ),

                Row(
                  children: [
                    Expanded(
                      child: _opcionExplorar(
                        icon:
                            Icons.place_outlined,
                        titulo: 'Sitios',
                        onTap: _abrirMapa,
                      ),
                    ),
                    const SizedBox(
                      width: AppDimensions.spacingMd,
                    ),
                    Expanded(
                      child: _opcionExplorar(
                        icon:
                            Icons.favorite_border,
                        titulo: 'Favoritos',
                        onTap: _abrirFavoritos,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height:
                      AppDimensions.spacingSection - 2,
                ),

                // ==================================================
                // SITIOS TURÍSTICOS
                // ==================================================

                const Text(
                  'Descubre el Huila',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(
                  height:
                      AppDimensions.spacingMd + 3,
                ),

                _construirSitios(),

                const SizedBox(
                  height:
                      AppDimensions.spacingSection - 2,
                ),

                // ==================================================
                // CERRAR SESIÓN
                // ==================================================

                OutlinedButton.icon(
                  onPressed: _cerrarSesion,
                  icon: const Icon(
                    Icons.logout,
                  ),
                  label: const Text(
                    'Cerrar sesión',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OPCIÓN EXPLORAR
  // ============================================================

  Widget _opcionExplorar({
    required IconData icon,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusXl,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical:
                AppDimensions.spacingXl - 2,
            horizontal:
                AppDimensions.spacingMd,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 38,
                color: AppColors.secondary,
              ),
              const SizedBox(
                height: AppDimensions.spacingSm,
              ),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LISTADO DE SITIOS
  // ============================================================

  Widget _construirSitios() {
    if (_cargandoSitios) {
      return const Padding(
        padding: EdgeInsets.all(
          AppDimensions.spacingXxl,
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_sitiosFiltrados.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(
          AppDimensions.spacingXxl,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusXl,
          ),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.search_off,
              size: 45,
              color: AppColors.secondary,
            ),
            SizedBox(
              height: AppDimensions.spacingMd,
            ),
            Text(
              'No encontramos lugares',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(
              height: AppDimensions.spacingSm,
            ),
            Text(
              'Prueba con otro nombre, ciudad o categoría.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _sitiosFiltrados.map(
        (sitio) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: AppDimensions.spacingLg,
            ),
            child: SitioCard(
              sitio: sitio,
              imagen: _imagenSitio(sitio),
              onFavorite: () =>
                  _alternarFavorito(sitio),
              onTap: () {
                _abrirSitio(sitio);
              },
            ),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // IMAGEN DEL SITIO
  // ============================================================

  String _imagenSitio(
    SitioTuristicoModel sitio,
  ) {
    final categoria = _normalizarTexto(
      sitio.categoriaNombre,
    );

    if (categoria.contains('cafe')) {
      return 'assets/images/sitios/cafe.jpg';
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

    return 'assets/images/bienvenida/paisaje.jpg';
  }

  String _normalizarTexto(String texto) {
    return texto
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'U')
        .replaceAll('ñ', 'n')
        .replaceAll('Ñ', 'N')
        .toLowerCase()
        .trim();
  }
}