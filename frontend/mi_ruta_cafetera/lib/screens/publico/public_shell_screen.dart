import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

import '../mapa_screen_2.dart';

import 'home_publico_screen.dart';
import 'perfil_publico_screen.dart';

class PublicShellScreen extends StatefulWidget {
  /// Índice inicial:
  ///
  /// 0 = Inicio
  /// 1 = Mapa
  /// 2 = Perfil
  final int initialIndex;

  /// Permite decidir desde main.dart si este Shell
  /// debe mostrar o no la navegación inferior.
  ///
  /// Por defecto es false para no modificar
  /// comportamientos existentes hasta que el
  /// flujo de autenticación esté conectado.
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
  // ============================================================
  // ESTADO
  // ============================================================

  late int _indiceActual;

  // ============================================================
  // CICLO DE VIDA
  // ============================================================

  @override
  void initState() {
    super.initState();

    _indiceActual =
        widget.initialIndex.clamp(
      0,
      2,
    );
  }

  // ============================================================
  // CAMBIAR SECCIÓN
  // ============================================================

  void _cambiarSeccion(
    int indice,
  ) {
    if (_indiceActual == indice) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _indiceActual = indice;
    });
  }

  // ============================================================
  // CONTENIDO PRINCIPAL
  // ============================================================
  //
  // IMPORTANTE:
  //
  // Antes utilizábamos IndexedStack:
  //
  //   Home
  //   Mapa
  //   Perfil
  //
  // Eso provocaba que MapaScreen2 también se construyera
  // inmediatamente aunque el usuario estuviera viendo Home.
  //
  // MapaScreen2 ejecuta cargarDatos() en initState().
  //
  // Por eso ahora solamente construimos la sección
  // que realmente está seleccionada.
  // ============================================================

  Widget _construirContenido() {
    switch (_indiceActual) {
      // ========================================================
      // INICIO
      // ========================================================

      case 0:
        return HomePublicoScreen(
          onIrMapa: () {
            _cambiarSeccion(1);
          },
        );

      // ========================================================
      // MAPA
      // ========================================================

      case 1:
        return const MapaScreen2();

      // ========================================================
      // PERFIL
      // ========================================================

      case 2:
        return const PerfilPublicoScreen();

      // ========================================================
      // RESPALDO
      // ========================================================

      default:
        return HomePublicoScreen(
          onIrMapa: () {
            _cambiarSeccion(1);
          },
        );
    }
  }

  // ============================================================
  // NAVEGACIÓN INFERIOR
  // ============================================================

  Widget _construirNavegacion() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppDimensions.pageHorizontalSmall,
          0,
          AppDimensions.pageHorizontalSmall,
          AppDimensions.navigationBarBottomMargin,
        ),
        height:
            AppDimensions.navigationBarHeight,
        decoration: BoxDecoration(
          color:
              AppColors.surface,
          borderRadius:
              BorderRadius.circular(
            AppDimensions.bottomNavigationRadius,
          ),
          border: Border.all(
            color:
                AppColors.border,
          ),
          boxShadow: const [
            BoxShadow(
              color:
                  AppColors.cardShadow,
              blurRadius: 16,
              offset:
                  Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // ==================================================
            // INICIO
            // ==================================================

            Expanded(
              child: _ItemNavegacion(
                icono:
                    Icons.home_rounded,
                etiqueta:
                    'Inicio',
                seleccionado:
                    _indiceActual == 0,
                onTap: () {
                  _cambiarSeccion(0);
                },
              ),
            ),

            // ==================================================
            // MAPA
            // ==================================================

            Expanded(
              child: _ItemNavegacion(
                icono:
                    Icons.map_rounded,
                etiqueta:
                    'Mapa',
                seleccionado:
                    _indiceActual == 1,
                onTap: () {
                  _cambiarSeccion(1);
                },
              ),
            ),

            // ==================================================
            // PERFIL
            // ==================================================

            Expanded(
              child: _ItemNavegacion(
                icono:
                    Icons.person_rounded,
                etiqueta:
                    'Perfil',
                seleccionado:
                    _indiceActual == 2,
                onTap: () {
                  _cambiarSeccion(2);
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
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      // ========================================================
      // CONTENIDO
      // ========================================================

      body:
          _construirContenido(),

      // ========================================================
      // NAVEGACIÓN
      // ========================================================
      //
      // Solo aparece cuando explícitamente la habilitamos.
      //
      // Esto nos permite mantener el Home público sin menú
      // mientras el usuario todavía no ha iniciado sesión.
      // ========================================================

      bottomNavigationBar:
          widget.mostrarNavegacion
              ? _construirNavegacion()
              : null,
    );
  }
}

// ======================================================================
// ITEM DE NAVEGACIÓN
// ======================================================================

class _ItemNavegacion
    extends StatelessWidget {
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
  Widget build(
    BuildContext context,
  ) {
    final color = seleccionado
        ? AppColors.primary
        : AppColors.textSecondary;

    return Material(
      color:
          Colors.transparent,
      child: InkWell(
        onTap:
            onTap,
        borderRadius:
            BorderRadius.circular(
          AppDimensions.bottomNavigationRadius,
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical:
                AppDimensions.spacingXs,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              // ==================================================
              // ICONO
              // ==================================================

              AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds:
                      AppDimensions.animationFast,
                ),
                width:
                    AppDimensions.iconLg + 8,
                height:
                    AppDimensions.iconLg + 8,
                decoration:
                    BoxDecoration(
                  color: seleccionado
                      ? AppColors
                          .getSoftColorForCategory(
                          'naturaleza',
                        )
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(
                    AppDimensions.radiusMd,
                  ),
                ),
                child:
                    Icon(
                  icono,
                  size:
                      AppDimensions.navigationIcon,
                  color:
                      color,
                ),
              ),

              // ==================================================
              // ETIQUETA
              // ==================================================

              const SizedBox(
                height:
                    AppDimensions.spacingXs,
              ),

              Text(
                etiqueta,
                maxLines:
                    1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    TextStyle(
                  color:
                      color,
                  fontSize:
                      11,
                  fontWeight:
                      seleccionado
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