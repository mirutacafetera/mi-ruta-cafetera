import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/usuario/usuario_sesion_model.dart';
import '../../services/usuario/usuario_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/usuario/boton_ia_flotante.dart';
import '../mapa_screen_2.dart';
import '../usuario/favoritos_usuario_screen.dart';
import '../usuario/rutas_usuario_screen.dart';
import 'home_publico_screen.dart';
import 'perfil_publico_screen.dart';
import '../../l10n/textos.dart';

/// Contenedor principal de la aplicación.
///
/// Una sola pantalla con dos modos, según la sesión de usuario:
///
/// * SIN SESIÓN (visitante): solo el Home público, sin menú inferior.
/// * CON SESIÓN: menú inferior de 5 opciones
///   (Inicio, Mapa, Favoritos, Rutas y Perfil).
///
/// Escucha a [UsuarioSesionService.sesionActual], por lo que cambia
/// de modo automáticamente al iniciar o cerrar sesión.
class PublicShellScreen extends StatefulWidget {
  /// Índice inicial (solo aplica con sesión):
  ///
  /// 0 = Inicio, 1 = Mapa, 2 = Favoritos, 3 = Rutas, 4 = Perfil
  final int initialIndex;

  /// Parámetro conservado por compatibilidad con los llamadores
  /// existentes. Ya no tiene efecto: el menú inferior depende
  /// únicamente de que exista una sesión de usuario.
  final bool mostrarNavegacion;

  const PublicShellScreen({
    super.key,
    this.initialIndex = 0,
    this.mostrarNavegacion = false,
  });

  @override
  State<PublicShellScreen> createState() => _PublicShellScreenState();
}

class _PublicShellScreenState extends State<PublicShellScreen> {
  static const int _totalSecciones = 5;

  static const int _indiceMapa = 1;

  // ============================================================
  // ESTADO
  // ============================================================

  late int _indiceActual;

  /// El mapa se crea solo la primera vez que se visita y luego
  /// se conserva, porque su carga inicial y el GPS son costosos.
  bool _mapaCreado = false;

  /// Las demás secciones se reconstruyen cada vez que se entra
  /// en ellas para reflejar cambios (por ejemplo favoritos).
  final List<int> _versiones = List<int>.filled(_totalSecciones, 0);

  UsuarioSesionModel? get _sesion =>
      UsuarioSesionService.instance.sesionActual.value;

  // ============================================================
  // CICLO DE VIDA
  // ============================================================

  @override
  void initState() {
    super.initState();

    _indiceActual = widget.initialIndex
    .clamp(0, _totalSecciones - 1)
    .toInt();

    _mapaCreado = _indiceActual == _indiceMapa;

    UsuarioSesionService.instance.sesionActual.addListener(_alCambiarSesion);
  }

  @override
  void dispose() {
    UsuarioSesionService.instance.sesionActual.removeListener(_alCambiarSesion);

    super.dispose();
  }

  // ============================================================
  // CAMBIO DE SESIÓN
  // ============================================================
  //
  // Al iniciar o cerrar sesión se vuelve al Inicio, se descarta
  // el mapa general y se reconstruye todo el contenido.
  // ============================================================

  void _alCambiarSesion() {
    if (!mounted) {
      return;
    }

    final sinSesion = _sesion == null;

    setState(() {
      _indiceActual = 0;
      _mapaCreado = false;

      for (var i = 0; i < _versiones.length; i++) {
        _versiones[i]++;
      }
    });

    if (sinSesion) {
      // Cierre de sesión: se descartan las pantallas privadas que
      // pudieran estar apiladas encima (detalle, rutas, perfil...)
      // para que "atrás" nunca las muestre de nuevo.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        final navegador = Navigator.of(context);

        if (navegador.canPop()) {
          navegador.popUntil((ruta) => ruta.isFirst);
        }
      });
    }
  }

  // ============================================================
  // BOTÓN ATRÁS Y SALIDA
  // ============================================================
  //
  // Política única de la app (Android físico/gestos y navegador):
  //
  // * Con sesión y en Mapa/Favoritos/Rutas/Perfil: atrás vuelve
  //   al Inicio.
  // * Visitante que llegó desde la bienvenida: vuelve a ella, que es
  //   la que pide confirmar la salida.
  // * En el Inicio sin pantalla anterior a la que volver: pide
  //   confirmar la salida.
  //
  // Solo se ejecuta cuando el Shell es la ruta visible; los
  // diálogos, hojas y pantallas apiladas se cierran con normalidad.
  // ============================================================

  bool _permitirSalida = false;

  Future<void> _manejarAtras() async {
    if (_sesion != null && _indiceActual != 0) {
      _cambiarSeccion(0);
      return;
    }

    // Visitante que llegó desde la pantalla de bienvenida: "atrás"
    // vuelve a ella (allí se pregunta si desea salir de la app).
    if (_sesion == null && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    final salir = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Tr('Salir'),
          content: const Tr('¿Deseas salir de Mi Ruta Cafetera?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Tr('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Tr('Salir'),
            ),
          ],
        );
      },
    );

    if (salir != true || !mounted) {
      return;
    }

    setState(() {
      _permitirSalida = true;
    });

    // En Android cierra la app. En Web retrocede fuera de la app
    // en el historial del navegador (no se puede cerrar la pestaña).
    await SystemNavigator.pop();
  }

  // ============================================================
  // CAMBIAR SECCIÓN
  // ============================================================

  void _cambiarSeccion(int indice) {
    if (!mounted) {
      return;
    }

    setState(() {
      if (_indiceActual != indice) {
        _indiceActual = indice;
      }

      if (indice == _indiceMapa) {
        _mapaCreado = true;
      } else {
        // Entrar (o volver a tocar) una sección la refresca.
        _versiones[indice]++;
      }
    });
  }

  // ============================================================
  // CONTENIDO
  // ============================================================

  // Alto total que ocupa el menú inferior flotante, incluida la zona
  // segura del sistema Android.
  double _alturaMenu(BuildContext context) {
    return MediaQuery.viewPaddingOf(context).bottom +
        AppDimensions.navigationBarHeight +
        AppDimensions.navigationBarBottomMargin;
  }

  // El menú flota sobre el cuerpo (extendBody). El Inicio se extiende
  // detrás de los botones para que se vea su fondo; el resto de las
  // secciones conservan su espacio de siempre, sin quedar tapadas.
  Widget _construirSeccion(int indice, UsuarioSesionModel sesion) {
    final seccion = _seccion(indice, sesion);

    if (indice == 0) {
      return seccion;
    }

    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: _alturaMenu(context)),
        child: seccion,
      ),
    );
  }

  Widget _seccion(int indice, UsuarioSesionModel sesion) {
    final llave = ValueKey<String>('seccion-$indice-${_versiones[indice]}');

    switch (indice) {
      case 0:
      return HomePublicoScreen(
        key: llave,
        onAbrirMapa: () => _cambiarSeccion(_indiceMapa),
      );

      case 1:
        return _mapaCreado ? const MapaScreen2() : const SizedBox.shrink();

      case 2:
        return FavoritosUsuarioScreen(
          key: llave,
          usuarioId: sesion.id,
          token: sesion.token,
        );

      case 3:
        return RutasUsuarioScreen(
          key: llave,
          usuarioId: sesion.id,
          token: sesion.token,
          mostrarRegresar: false,
        );

      default:
        return PerfilPublicoScreen(key: llave);
    }
  }

  // ============================================================
  // NAVEGACIÓN INFERIOR
  // ============================================================

  Widget _construirNavegacion() {
    const items = <_DatosItem>[
      _DatosItem(Icons.home_rounded, 'Inicio'),
      _DatosItem(Icons.map_rounded, 'Mapa'),
      _DatosItem(Icons.favorite_rounded, 'Favoritos'),
      _DatosItem(Icons.route_rounded, 'Rutas'),
      _DatosItem(Icons.person_rounded, 'Perfil'),
    ];

    // Cada icono es un botón flotante independiente. No hay barra,
    // fondo ni borde que los agrupe: entre los botones se ve el fondo de
    // la pantalla. Se conservan SafeArea y el margen inferior para no
    // chocar con la barra del sistema Android.
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pageHorizontalSmall,
          0,
          AppDimensions.pageHorizontalSmall,
          AppDimensions.navigationBarBottomMargin,
        ),
        child: SizedBox(
          height: AppDimensions.navigationBarHeight,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingXs,
                    ),
                    child: _ItemNavegacion(
                      icono: items[i].icono,
                      etiqueta: items[i].etiqueta,
                      seleccionado: _indiceActual == i,
                      onTap: () {
                        _cambiarSeccion(i);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTÓN FLOTANTE DE IA
  // ============================================================
  //
  // Un único botón (BotonIaFlotante) sobre las 5 secciones: Inicio,
  // Mapa, Favoritos, Rutas y Perfil. Esta función solo se usa en el
  // modo con sesión, así que el visitante nunca lo ve. En Inicio
  // convive con la tarjeta de IA, que se conserva.
  // La persona puede arrastrarlo donde quiera dentro del cuerpo
  // (queda por encima del menú inferior); su posición se recuerda
  // y es la misma en todas las secciones.
  // La primera vez aparece a la izquierda en el Mapa (a la derecha
  // están sus controles) y a la derecha en las demás. Se oculta con
  // el teclado.
  // ============================================================

  Widget _construirBotonIa() {
    final tecladoVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    if (tecladoVisible) {
      // IMPORTANTE: debe ser un hijo POSICIONADO. Un hijo sin
      // posición (como un SizedBox.shrink suelto) hace que el Stack
      // tome su tamaño (cero) y las pestañas quedarían con 0x0.
      return const Positioned(left: 0, top: 0, child: SizedBox.shrink());
    }

    // Ocupa toda el área del cuerpo para poder moverse libremente;
    // las zonas vacías dejan pasar los toques al contenido.
    // Se mantiene por encima del menú, en la misma posición de siempre.
    return Positioned.fill(
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: Padding(
          padding: EdgeInsets.only(bottom: _alturaMenu(context)),
          child: BotonIaFlotante(
            inicioIzquierda: _indiceActual == _indiceMapa,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _permitirSalida,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _manejarAtras();
        }
      },
      child: _construirPantalla(),
    );
  }

  Widget _construirPantalla() {
    final sesion = _sesion;

    // ----------------------------------------------------------
    // VISITANTE: solo Home público, sin menú inferior.
    // ----------------------------------------------------------

    if (sesion == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: HomePublicoScreen(),
      );
    }

    // ----------------------------------------------------------
    // USUARIO AUTENTICADO: 5 secciones.
    // ----------------------------------------------------------

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Cada sección ocupa siempre todo el cuerpo. Solo se
          // muestra la activa; el mapa se conserva oculto para no
          // volver a cargarlo.
          for (var i = 0; i < _totalSecciones; i++)
            if (i == _indiceActual || i == _indiceMapa)
              Positioned.fill(
                // Clave fija por sección: evita que Flutter mezcle
                // pantallas al cambiar de pestaña y reconstruya el mapa.
                key: ValueKey<String>('pestana-$i'),
                child: Offstage(
                  offstage: i != _indiceActual,
                  child: TickerMode(
                    enabled: i == _indiceActual,
                    child: _construirSeccion(i, sesion),
                  ),
                ),
              ),
          _construirBotonIa(),
        ],
      ),
      bottomNavigationBar: _construirNavegacion(),
    );
  }
}

// ======================================================================
// DATOS DE UN ITEM
// ======================================================================

class _DatosItem {
  final IconData icono;
  final String etiqueta;

  const _DatosItem(this.icono, this.etiqueta);
}

// ======================================================================
// ITEM DE NAVEGACIÓN
// ======================================================================

class _ItemNavegacion extends StatelessWidget {
  final IconData icono;

  final String etiqueta;

  final bool seleccionado;

  final VoidCallback onTap;

  const _ItemNavegacion({
    required this.icono,
    required this.etiqueta,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorContenido =
        seleccionado ? AppColors.white : AppColors.textSecondary;

    // Botón flotante propio de cada sección. La activa se rellena con el
    // verde principal; las demás son blancas. El área táctil es todo el
    // botón.
    return Semantics(
      button: true,
      selected: seleccionado,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: AppDimensions.animationFast,
            ),
            curve: Curves.easeOut,
            height: AppDimensions.navigationBarHeight - 12,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingXs,
            ),
            decoration: BoxDecoration(
              color: seleccionado ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icono,
                  size: AppDimensions.navigationIcon,
                  color: colorContenido,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Tr(
                    etiqueta,
                    style: TextStyle(
                      color: colorContenido,
                      fontSize: 11,
                      fontWeight:
                          seleccionado ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}