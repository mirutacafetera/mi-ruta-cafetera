import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../google/google_button.dart';
import '../../models/usuario/usuario_sesion_model.dart';
import '../../services/google_auth_service.dart';
import '../../services/usuario/auth_usuario_service.dart';
import '../../services/usuario/usuario_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../auth/seleccion_rol_screen.dart';
import 'public_shell_screen.dart';


class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({
    super.key,
  });

  @override
  State<BienvenidaScreen> createState() =>
      _BienvenidaScreenState();
}

class _BienvenidaScreenState
    extends State<BienvenidaScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // CONTROLADORES
  // ============================================================

  late final PageController _pageController;

  late final AnimationController _entradaController;

  late final AnimationController _contenidoController;

  late final Animation<double> _fadeAnimation;

  late final Animation<Offset> _slideAnimation;

  Timer? _carruselTimer;

  // ============================================================
  // ESTADO
  // ============================================================

  int _paginaActual = 0;

  bool _iniciandoGoogle = false;

  StreamSubscription<GoogleSignInAuthenticationEvent>?
      _googleAuthenticationSubscription;

  // ============================================================
  // IMÁGENES DE BIENVENIDA
  // ============================================================

  static const List<_ImagenBienvenida> _imagenes = [
    _ImagenBienvenida(
      asset: 'assets/images/bienvenida/cafe.jpg',
      titulo: 'El sabor de nuestra tierra',
      subtitulo: 'Descubre la esencia del café huilense.',
      icono: Icons.coffee_rounded,
      color: AppColors.categoryCafe,
    ),
    _ImagenBienvenida(
      asset: 'assets/images/bienvenida/paisaje.jpg',
      titulo: 'Paisajes que inspiran',
      subtitulo:
          'Recorre los rincones más especiales del Huila.',
      icono: Icons.landscape_rounded,
      color: AppColors.categoryMiradores,
    ),
    _ImagenBienvenida(
      asset: 'assets/images/bienvenida/naturaleza.jpg',
      titulo: 'Naturaleza para descubrir',
      subtitulo:
          'Senderos, montañas y experiencias inolvidables.',
      icono: Icons.park_rounded,
      color: AppColors.categoryNaturaleza,
    ),
    _ImagenBienvenida(
      asset: 'assets/images/bienvenida/cultura.jpg',
      titulo: 'Historias que permanecen',
      subtitulo:
          'Conoce nuestra cultura, tradición y patrimonio.',
      icono: Icons.account_balance_rounded,
      color: AppColors.categoryCultura,
    ),
    _ImagenBienvenida(
      asset: 'assets/images/bienvenida/experiencia.jpg',
      titulo: 'Experiencias para vivir',
      subtitulo:
          'Encuentra nuevas formas de disfrutar el territorio.',
      icono: Icons.explore_rounded,
      color: AppColors.categoryAventuras,
    ),
  ];

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _entradaController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1100,
      ),
    );

    _contenidoController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entradaController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(
        0,
        0.10,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entradaController,
        curve: Curves.easeOutCubic,
      ),
    );

    _entradaController.forward();

    Future.delayed(
      const Duration(
        milliseconds: 250,
      ),
      () {
        if (mounted) {
          _contenidoController.forward();
        }
      },
    );

    _iniciarCarrusel();

    // En Web, el botón oficial de Google inicia el proceso
    // y el resultado llega por authenticationEvents.
    if (kIsWeb) {
      _escucharAutenticacionGoogleWeb();
    }
  }

  // ============================================================
  // CARRUSEL AUTOMÁTICO
  // ============================================================

  void _iniciarCarrusel() {
    _carruselTimer = Timer.periodic(
      const Duration(
        seconds: 5,
      ),
      (_) {
        if (!mounted || !_pageController.hasClients) {
          return;
        }

        final siguiente =
            (_paginaActual + 1) % _imagenes.length;

        _pageController.animateToPage(
          siguiente,
          duration: const Duration(
            milliseconds: 850,
          ),
          curve: Curves.easeInOutCubic,
        );
      },
    );
  }

  // ============================================================
  // GOOGLE → BACKEND → SESIÓN
  // ============================================================
  //
  // Obtiene el idToken de Google, lo valida contra
  // POST /api/usuarios/login-google y guarda la sesión.
  // Devuelve true solo si todo salió bien.
  // ============================================================

  Future<bool> _autenticarConBackend() async {
    final idToken =
        await GoogleAuthService.instance.obtenerIdToken();

    if (idToken == null || idToken.isEmpty) {
      if (mounted) {
        _mostrarMensaje(
          'No se pudo obtener el token de Google.',
        );
      }
      return false;
    }

    final resultado =
        await AuthUsuarioService.iniciarSesionConGoogle(
      idToken: idToken,
    );

    if (resultado['exito'] != true ||
        resultado['usuario'] is! Map ||
        resultado['token'] == null) {
      if (mounted) {
        _mostrarMensaje(
          resultado['mensaje']?.toString() ??
              'No fue posible iniciar sesión con Google.',
        );
      }
      return false;
    }

    await UsuarioSesionService.instance.guardarSesion(
      UsuarioSesionModel.fromRespuesta(
        token: resultado['token'].toString(),
        usuario: Map<String, dynamic>.from(
          resultado['usuario'] as Map,
        ),
      ),
    );

    return true;
  }

  // ============================================================
  // GOOGLE WEB
  // ============================================================

  void _escucharAutenticacionGoogleWeb() {
    _googleAuthenticationSubscription =
        GoogleSignIn.instance.authenticationEvents.listen(
      _manejarEventoGoogle,
      onError: (Object error) {
        if (!mounted) {
          return;
        }

        setState(() {
          _iniciandoGoogle = false;
        });

        _mostrarMensaje(
          'No fue posible iniciar sesión con Google.',
        );

        debugPrint(
          'Error de Google Sign-In Web: $error',
        );
      },
    );
  }

  Future<void> _manejarEventoGoogle(
    GoogleSignInAuthenticationEvent evento,
  ) async {
    if (evento
        is! GoogleSignInAuthenticationEventSignIn) {
      return;
    }

    final usuario = evento.user;

    if (!mounted) {
      return;
    }

    setState(() {
      _iniciandoGoogle = true;
    });

    // En Web el usuario llega por el evento; lo registramos
    // en el servicio para poder leer su idToken.
    GoogleAuthService.instance.registrarUsuario(usuario);

    final autenticado = await _autenticarConBackend();

    if (!mounted) {
      return;
    }

    if (!autenticado) {
      setState(() {
        _iniciandoGoogle = false;
      });
      return;
    }

    _mostrarMensaje(
      'Bienvenido, ${usuario.displayName ?? usuario.email}',
    );

    await Future.delayed(
      const Duration(
        milliseconds: 700,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _iniciandoGoogle = false;
    });

    _comenzarExplorar();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _carruselTimer?.cancel();

    _googleAuthenticationSubscription?.cancel();

    _pageController.dispose();

    _entradaController.dispose();

    _contenidoController.dispose();

    super.dispose();
  }

  // ============================================================
  // COMENZAR A EXPLORAR
  // ============================================================

  void _comenzarExplorar() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 750,
        ),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const PublicShellScreen(
            mostrarNavegacion: true,
          );
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  // ============================================================
  // ACCESO PRIVADO
  // ============================================================

  void _abrirAccesoPrivado() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 500,
        ),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const SeleccionRolScreen();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  // ============================================================
  // GOOGLE (ANDROID / IOS)
  // ============================================================

  Future<void> _iniciarSesionConGoogle() async {
    // En Web se utiliza el botón oficial de Google; el resultado
    // llega por authenticationEvents.
    if (kIsWeb || _iniciandoGoogle) {
      return;
    }

    setState(() {
      _iniciandoGoogle = true;
    });

    try {
      final usuario =
          await GoogleAuthService.instance.iniciarSesion();

      if (!mounted) {
        return;
      }

      if (usuario == null) {
        setState(() {
          _iniciandoGoogle = false;
        });

        return;
      }

      final autenticado = await _autenticarConBackend();

      if (!mounted) {
        return;
      }

      if (!autenticado) {
        setState(() {
          _iniciandoGoogle = false;
        });

        return;
      }

      _mostrarMensaje(
        'Bienvenido, ${usuario.displayName ?? usuario.email}',
      );

      await Future.delayed(
        const Duration(
          milliseconds: 700,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _iniciandoGoogle = false;
      });

      _comenzarExplorar();
    } on GoogleSignInException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _iniciandoGoogle = false;
      });

      _mostrarMensaje(
        'No fue posible iniciar sesión con Google: '
        '${e.description ?? e.code}',
      );

      debugPrint(
        'GoogleSignInException: $e',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _iniciandoGoogle = false;
      });

      _mostrarMensaje(
        'Ocurrió un error al iniciar sesión con Google.',
      );

      debugPrint(
        'Error Google Sign-In: $e',
      );
    }
  }

  // ============================================================
  // MENSAJE
  // ============================================================

  void _mostrarMensaje(
    String mensaje,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            mensaje,
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(
            seconds: 3,
          ),
        ),
      );
  }

  // ============================================================
  // CAMBIO DE PÁGINA
  // ============================================================

  void _cambiarPagina(
    int pagina,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _paginaActual = pagina;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final size = MediaQuery.sizeOf(context);

    final esPantallaPequena =
        size.height < 720;

    return Scaffold(
      backgroundColor: AppColors.coffeeDark,
      body: Stack(
        children: [
          // ========================================================
          // FOTOGRAFÍAS
          // ========================================================

          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _imagenes.length,
              onPageChanged: _cambiarPagina,
              physics:
                  const BouncingScrollPhysics(),
              itemBuilder: (
                context,
                index,
              ) {
                return _ImagenHero(
                  imagen: _imagenes[index],
                  activa: index == _paginaActual,
                );
              },
            ),
          ),

          // ========================================================
          // DEGRADADO GENERAL
          // ========================================================

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [
                      0.0,
                      0.32,
                      0.62,
                      1.0,
                    ],
                    colors: [
                      AppColors.coffeeDark
                          .withValues(alpha: 0.58),
                      AppColors.primaryDark
                          .withValues(alpha: 0.16),
                      AppColors.primaryDark
                          .withValues(alpha: 0.30),
                      AppColors.coffeeDark
                          .withValues(alpha: 0.94),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ========================================================
          // ELEMENTO DECORATIVO DE LA EXPERIENCIA
          // ========================================================

          Positioned(
            top: -80,
            right: -60,
            child: _IconoDecorativo(
              imagen:
                  _imagenes[_paginaActual],
            ),
          ),

          // ========================================================
          // CONTENIDO
          // ========================================================

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // ====================================================
                    // PARTE SUPERIOR
                    // ====================================================

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal:
                            AppDimensions.spacingXl,
                        vertical:
                            AppDimensions.spacingMd,
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment:
                                Alignment.centerLeft,
                            child:
                                _LogoPequeno(),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // ====================================================
                    // CONTENIDO CENTRAL
                    // ====================================================

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal:
                            AppDimensions.spacingXl,
                      ),
                      child:
                          AnimatedSwitcher(
                        duration:
                            const Duration(
                          milliseconds: 450,
                        ),
                        switchInCurve:
                            Curves.easeOutCubic,
                        switchOutCurve:
                            Curves.easeInCubic,
                        transitionBuilder:
                            (
                          child,
                          animation,
                        ) {
                          final slide =
                              Tween<Offset>(
                            begin:
                                const Offset(
                              0,
                              0.08,
                            ),
                            end: Offset.zero,
                          ).animate(
                            animation,
                          );

                          return FadeTransition(
                            opacity:
                                animation,
                            child:
                                SlideTransition(
                              position: slide,
                              child: child,
                            ),
                          );
                        },
                        child:
                            _TextoExperiencia(
                          key: ValueKey(
                            _paginaActual,
                          ),
                          imagen:
                              _imagenes[
                                  _paginaActual],
                        ),
                      ),
                    ),

                    SizedBox(
                      height:
                          esPantallaPequena
                              ? 16
                              : 26,
                    ),

                    // ====================================================
                    // MARCA
                    // ====================================================

                    _MarcaPrincipal(
                      compacto:
                          esPantallaPequena,
                    ),

                    SizedBox(
                      height:
                          esPantallaPequena
                              ? 18
                              : 28,
                    ),

                    // ====================================================
                    // INDICADORES
                    // ====================================================

                    _IndicadoresCarrusel(
                      actual:
                          _paginaActual,
                      total:
                          _imagenes.length,
                      onTap:
                          (index) {
                        _pageController
                            .animateToPage(
                          index,
                          duration:
                              const Duration(
                            milliseconds: 500,
                          ),
                          curve: Curves
                              .easeInOutCubic,
                        );
                      },
                    ),

                    SizedBox(
                      height:
                          esPantallaPequena
                              ? 18
                              : 28,
                    ),

                    // ====================================================
                    // BOTÓN PRINCIPAL
                    // ====================================================

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal:
                            AppDimensions.spacingXl,
                      ),
                      child:
                          _BotonComenzar(
                        onPressed:
                            _comenzarExplorar,
                      ),
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.spacingMd,
                    ),

                    // ====================================================
                    // GOOGLE
                    // ====================================================

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal:
                            AppDimensions.spacingXl,
                      ),
                      child:
                          _BotonGoogle(
                        onPressed:
                            _iniciarSesionConGoogle,
                        cargando:
                            _iniciandoGoogle,
                      ),
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.spacingSm,
                    ),

                    // ====================================================
                    // ACCESO PRIVADO
                    // ====================================================

                    TextButton.icon(
                      onPressed:
                          _abrirAccesoPrivado,
                      icon: Icon(
                        Icons
                            .lock_outline_rounded,
                        color: AppColors.white
                            .withValues(
                          alpha: 0.75,
                        ),
                        size:
                            AppDimensions.iconSm,
                      ),
                      label: Text(
                        'Acceso privado',
                        style:
                            TextStyle(
                          color: AppColors.white
                              .withValues(
                            alpha: 0.78,
                          ),
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.spacingMd,
                    ),

                    // ====================================================
                    // FRASE
                    // ====================================================

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal:
                            AppDimensions.spacingXl,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.eco_outlined,
                            color: AppColors.white
                                .withValues(
                              alpha: 0.55,
                            ),
                            size:
                                AppDimensions.iconSm,
                          ),
                          const SizedBox(
                            width:
                                AppDimensions.spacingSm,
                          ),
                          Flexible(
                            child: Text(
                              'Descubre · Explora · Vive',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                color: AppColors.white
                                    .withValues(
                                  alpha: 0.72,
                                ),
                                fontSize: 12,
                                letterSpacing:
                                    1.4,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width:
                                AppDimensions.spacingSm,
                          ),
                          Icon(
                            Icons.eco_outlined,
                            color: AppColors.white
                                .withValues(
                              alpha: 0.55,
                            ),
                            size:
                                AppDimensions.iconSm,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.spacingLg,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MODELO INTERNO DE IMAGEN
// ============================================================================

class _ImagenBienvenida {
  final String asset;
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color color;

  const _ImagenBienvenida({
    required this.asset,
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.color,
  });
}

// ============================================================================
// IMAGEN HERO
// ============================================================================

class _ImagenHero extends StatelessWidget {
  final _ImagenBienvenida imagen;
  final bool activa;

  const _ImagenHero({
    required this.imagen,
    required this.activa,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox.expand(
      child: AnimatedScale(
        scale: activa ? 1.0 : 1.015,
        duration:
            const Duration(
          milliseconds: 900,
        ),
        curve: Curves.easeOutCubic,
        child: Image.asset(
          imagen.asset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality:
              FilterQuality.high,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return _FondoImagenRespaldo(
              imagen: imagen,
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// FONDO DE RESPALDO
// ============================================================================

class _FondoImagenRespaldo
    extends StatelessWidget {
  final _ImagenBienvenida imagen;

  const _FondoImagenRespaldo({
    required this.imagen,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.coffeeDark,
            AppColors.primary,
            imagen.color,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white
                    .withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.black
                    .withValues(alpha: 0.12),
              ),
            ),
          ),
          Center(
            child: Icon(
              imagen.icono,
              size: 170,
              color: AppColors.white
                  .withValues(alpha: 0.09),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LOGO SUPERIOR
// ============================================================================

class _LogoPequeno
    extends StatelessWidget {
  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.black
            .withValues(alpha: 0.20),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white
              .withValues(alpha: 0.20),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black
                .withValues(alpha: 0.20),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/img/mi_ruta_cafetera.png',
          fit: BoxFit.contain,
          filterQuality:
              FilterQuality.high,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return const Icon(
              Icons.coffee_rounded,
              color: AppColors.white,
              size: 28,
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// TEXTO DE EXPERIENCIA
// ============================================================================

class _TextoExperiencia
    extends StatelessWidget {
  final _ImagenBienvenida imagen;

  const _TextoExperiencia({
    super.key,
    required this.imagen,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration:
              BoxDecoration(
            color: imagen.color
                .withValues(alpha: 0.92),
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radiusMd,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black
                    .withValues(alpha: 0.18),
                blurRadius: 14,
                offset:
                    const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            imagen.icono,
            color:
                AppColors.white,
            size: 24,
          ),
        ),
        const SizedBox(
          height:
              AppDimensions.spacingMd,
        ),
        Text(
          imagen.titulo,
          textAlign:
              TextAlign.center,
          style:
              const TextStyle(
            color:
                AppColors.white,
            fontSize: 29,
            fontWeight:
                FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(
          height:
              AppDimensions.spacingSm,
        ),
        Text(
          imagen.subtitulo,
          textAlign:
              TextAlign.center,
          style: TextStyle(
            color: AppColors.white
                .withValues(alpha: 0.86),
            fontSize: 15,
            height: 1.45,
            fontWeight:
                FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// MARCA PRINCIPAL
// ============================================================================

class _MarcaPrincipal
    extends StatelessWidget {
  final bool compacto;

  const _MarcaPrincipal({
    required this.compacto,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        Text(
          'Mi Ruta Cafetera',
          textAlign:
              TextAlign.center,
          style: TextStyle(
            color:
                AppColors.white,
            fontSize:
                compacto ? 29 : 34,
            fontWeight:
                FontWeight.w800,
            height: 1,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(
          height:
              AppDimensions.spacingSm,
        ),
        Text(
          'Descubre · Explora · Vive',
          textAlign:
              TextAlign.center,
          style: TextStyle(
            color: AppColors.white
                .withValues(alpha: 0.84),
            fontSize: 12,
            letterSpacing: 2.1,
            fontWeight:
                FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// INDICADORES DEL CARRUSEL
// ============================================================================

class _IndicadoresCarrusel
    extends StatelessWidget {
  final int actual;
  final int total;
  final ValueChanged<int> onTap;

  const _IndicadoresCarrusel({
    required this.actual,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) {
          final activo =
              index == actual;

          return GestureDetector(
            onTap: () =>
                onTap(index),
            child:
                AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 250,
              ),
              curve:
                  Curves.easeOutCubic,
              margin:
                  const EdgeInsets
                      .symmetric(
                horizontal:
                    AppDimensions
                        .spacingXs,
              ),
              width:
                  activo ? 28 : 7,
              height: 7,
              decoration:
                  BoxDecoration(
                color: activo
                    ? AppColors
                        .secondary
                    : AppColors
                        .white
                        .withValues(
                        alpha: 0.45,
                      ),
                borderRadius:
                    BorderRadius
                        .circular(
                  AppDimensions
                      .radiusPill,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// BOTÓN PRINCIPAL
// ============================================================================

class _BotonComenzar
    extends StatefulWidget {
  final VoidCallback onPressed;

  const _BotonComenzar({
    required this.onPressed,
  });

  @override
  State<_BotonComenzar>
      createState() =>
          _BotonComenzarState();
}

class _BotonComenzarState
    extends State<_BotonComenzar> {
  bool _presionado = false;

  @override
  Widget build(
    BuildContext context,
  ) {
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

        widget.onPressed();
      },
      onTapCancel: () {
        setState(() {
          _presionado = false;
        });
      },
      child:
          AnimatedScale(
        scale:
            _presionado ? 0.96 : 1,
        duration:
            const Duration(
          milliseconds: 120,
        ),
        child: Container(
          width:
              double.infinity,
          height: 58,
          decoration:
              BoxDecoration(
            color:
                AppColors.secondary,
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radiusXl,
            ),
            border: Border.all(
              color: AppColors.white
                  .withValues(alpha: 0.22),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black
                    .withValues(alpha: 0.25),
                blurRadius: 22,
                offset:
                    const Offset(0, 10),
              ),
            ],
          ),
          alignment:
              Alignment.center,
          child: const Text(
            'Comenzar a explorar',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  AppColors.white,
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BOTÓN GOOGLE
// ============================================================================

class _BotonGoogle
    extends StatelessWidget {
  final VoidCallback onPressed;
  final bool cargando;

  const _BotonGoogle({
    required this.onPressed,
    required this.cargando,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    // ==============================================================
    // WEB
    // ==============================================================

    if (kIsWeb) {
      return Container(
        width:
            double.infinity,
        height: 54,
        decoration:
            BoxDecoration(
          color:
              AppColors.white,
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black
                  .withValues(alpha: 0.16),
              blurRadius: 16,
              offset:
                  const Offset(0, 7),
            ),
          ],
        ),
        alignment:
            Alignment.center,
        child:
            crearBotonGoogleWeb(),
      );
    }

    // ==============================================================
    // ANDROID / IOS
    // ==============================================================

    return SizedBox(
      width:
          double.infinity,
      height: 54,
      child: Material(
        color:
            AppColors.white,
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        elevation:
            AppDimensions
                .elevationButton,
        child: InkWell(
          onTap:
              cargando
                  ? null
                  : onPressed,
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
          child:
              AnimatedOpacity(
            duration:
                const Duration(
              milliseconds: 180,
            ),
            opacity:
                cargando ? 0.65 : 1,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center,
              children: [
                if (cargando)
                  const SizedBox(
                    width:
                        AppDimensions
                            .iconMd,
                    height:
                        AppDimensions
                            .iconMd,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  )
                else
                  Container(
                    width: 28,
                    height: 28,
                    alignment:
                        Alignment.center,
                    child:
                        const Text(
                      'G',
                      style:
                          TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(
                          0xFF4285F4,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  width:
                      AppDimensions
                          .spacingMd,
                ),
                Text(
                  cargando
                      ? 'Conectando con Google...'
                      : 'Continuar con Google',
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF333333,
                    ),
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
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

// ============================================================================
// ICONO DECORATIVO
// ============================================================================

class _IconoDecorativo
    extends StatelessWidget {
  final _ImagenBienvenida imagen;

  const _IconoDecorativo({
    required this.imagen,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return IgnorePointer(
      child: Container(
        width: 300,
        height: 300,
        alignment:
            Alignment.center,
        decoration:
            BoxDecoration(
          shape:
              BoxShape.circle,
          gradient:
              RadialGradient(
            colors: [
              imagen.color.withValues(
                alpha: 0.22,
              ),
              imagen.color.withValues(
                alpha: 0.0,
              ),
            ],
          ),
        ),
        child: Icon(
          imagen.icono,
          size: 190,
          color: AppColors.white
              .withValues(
            alpha: 0.075,
          ),
        ),
      ),
    );
  }
}