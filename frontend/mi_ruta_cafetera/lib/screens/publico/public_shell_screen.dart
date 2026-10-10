import 'package:flutter/material.dart';

import '../../models/usuario/usuario_sesion_model.dart';
import '../../services/usuario/usuario_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../mapa_screen_2.dart';
import '../usuario/favoritos_usuario_screen.dart';
import '../usuario/rutas_usuario_screen.dart';
import 'home_publico_screen.dart';
import 'perfil_publico_screen.dart';

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
  State<PublicShellScreen> createState() =>
      _PublicShellScreenState();
}

class _PublicShellScreenState
    extends State<PublicShellScreen> {
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
  final List<int> _versiones =
      List<int>.filled(_totalSecciones, 0);

  UsuarioSesionModel? get _sesion =>
      UsuarioSesionService.instance.sesionActual.value;

  // ============================================================
  // CICLO DE VIDA
  // ============================================================

  @override
  void initState() {
    super.initState();

    _indiceActual = widget.initialIndex.clamp(
      0,
      _totalSecciones - 1,
    );

    _mapaCreado = _indiceActual == _indiceMapa;

    UsuarioSesionService.instance.sesionActual
        .addListener(_alCambiarSesion);
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
  //
  // Al iniciar o cerrar sesión se vuelve al Inicio, se descarta
  // el mapa general y se reconstruye todo el contenido.
  // ============================================================

  void _alCambiarSesion() {
    if (!mounted) {
      return;
    }

    setState(() {
      _indiceActual = 0;
      _mapaCreado = false;

      for (var i = 0; i < _versiones.length; i++) {
        _versiones[i]++;
      }
    });
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

  Widget _construirSeccion(
    int indice,
    UsuarioSesionModel sesion,
  ) {
    final llave = ValueKey<String>(
      'seccion-$indice-${_versiones[indice]}',
    );

    switch (indice) {
      case 0:
        return HomePublicoScreen(key: llave);

      case 1:
        return _mapaCreado
            ? const MapaScreen2()
            : const SizedBox.shrink();

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

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppDimensions.pageHorizontalSmall,
          0,
          AppDimensions.pageHorizontalSmall,
          AppDimensions.navigationBarBottomMargin,
        ),
        height: AppDimensions.navigationBarHeight,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(
            AppDimensions.bottomNavigationRadius,
          ),
          border: Border.all(
            color: AppColors.border,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _ItemNavegacion(
                  icono: items[i].icono,
                  etiqueta: items[i].etiqueta,
                  seleccionado: _indiceActual == i,
                  onTap: () {
                    _cambiarSeccion(i);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
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
      body: IndexedStack(
        index: _indiceActual,
        children: [
          for (var i = 0; i < _totalSecciones; i++)
            if (i == _indiceActual || i == _indiceMapa)
              _construirSeccion(i, sesion)
            else
              const SizedBox.shrink(),
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
    final color = seleccionado
        ? AppColors.primary
        : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimensions.bottomNavigationRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingXs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(
                  milliseconds: AppDimensions.animationFast,
                ),
                width: AppDimensions.iconLg + 8,
                height: AppDimensions.iconLg + 8,
                decoration: BoxDecoration(
                  color: seleccionado
                      ? AppColors.getSoftColorForCategory(
                          'naturaleza',
                        )
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMd,
                  ),
                ),
                child: Icon(
                  icono,
                  size: AppDimensions.navigationIcon,
                  color: color,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingXs,
              ),
              Text(
                etiqueta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: seleccionado
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}