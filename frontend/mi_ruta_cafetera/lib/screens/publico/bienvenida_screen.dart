import 'package:flutter/material.dart';

import '../auth/seleccion_rol_screen.dart';
import 'home_publico_screen.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1400,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _comenzarExplorar() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 800,
        ),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const HomePublicoScreen();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==========================================================
          // FONDO
          // ==========================================================

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF17352B),
                  Color(0xFF315C45),
                  Color(0xFF8B6B48),
                ],
              ),
            ),
          ),

          // ==========================================================
          // ELEMENTOS DECORATIVOS
          // ==========================================================

          Positioned(
            top: -90,
            right: -70,
            child: _CirculoDecorativo(
              size: 260,
              opacity: 0.08,
            ),
          ),

          Positioned(
            bottom: -100,
            left: -80,
            child: _CirculoDecorativo(
              size: 300,
              opacity: 0.07,
            ),
          ),

          Positioned(
            top: 130,
            left: -55,
            child: _CirculoDecorativo(
              size: 130,
              opacity: 0.05,
            ),
          ),

          // ==========================================================
          // CONTENIDO
          // ==========================================================

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 30,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 520,
                      ),
                      child: Column(
                        children: [
                          // ==================================================
                          // ICONO PRINCIPAL
                          // ==================================================

                          TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0.85,
                              end: 1,
                            ),
                            duration: const Duration(
                              milliseconds: 1100,
                            ),
                            curve: Curves.elasticOut,
                            builder: (
                              context,
                              scale,
                              child,
                            ) {
                              return Transform.scale(
                                scale: scale,
                                child: child,
                              );
                            },
                            child: Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                  0.13,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(
                                    0.25,
                                  ),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      0.18,
                                    ),
                                    blurRadius: 30,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_cafe_rounded,
                                color: Colors.white,
                                size: 62,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // MARCA
                          // ==================================================

                          const Text(
                            'Mi Ruta',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w300,
                              height: 1,
                            ),
                          ),

                          const Text(
                            'Mágica del Café',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 31,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Descubre · Explora · Vive',
                            style: TextStyle(
                              color: Colors.white.withOpacity(
                                0.82,
                              ),
                              fontSize: 14,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // ==================================================
                          // MENSAJE
                          // ==================================================

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(
                                0.12,
                              ),
                              borderRadius:
                                  BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withOpacity(
                                  0.10,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Bienvenido',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'A una tierra de café, paisajes, '
                                  'tradiciones y experiencias '
                                  'por descubrir.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(
                                      0.84,
                                    ),
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // ==================================================
                          // BOTON PRINCIPAL
                          // ==================================================

                          _BotonComenzar(
                            onPressed: _comenzarExplorar,
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // ACCESO PRIVADO
                          // ==================================================

                          TextButton.icon(
                            onPressed: _abrirAccesoPrivado,
                            icon: Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.white.withOpacity(
                                0.70,
                              ),
                              size: 17,
                            ),
                            label: Text(
                              'Acceso privado',
                              style: TextStyle(
                                color: Colors.white.withOpacity(
                                  0.75,
                                ),
                                fontSize: 13,
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // ==================================================
                          // FRASE
                          // ==================================================

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.eco_outlined,
                                color: Colors.white.withOpacity(
                                  0.55,
                                ),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Más que un destino, una historia por vivir',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(
                                    0.65,
                                  ),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// BOTON COMENZAR
// ======================================================================

class _BotonComenzar extends StatefulWidget {
  final VoidCallback onPressed;

  const _BotonComenzar({
    required this.onPressed,
  });

  @override
  State<_BotonComenzar> createState() =>
      _BotonComenzarState();
}

class _BotonComenzarState extends State<_BotonComenzar> {
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

        widget.onPressed();
      },
      onTapCancel: () {
        setState(() {
          _presionado = false;
        });
      },
      child: AnimatedScale(
        scale: _presionado ? 0.96 : 1,
        duration: const Duration(
          milliseconds: 120,
        ),
        child: Container(
          width: double.infinity,
          height: 62,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                'Comenzar a explorar',
                style: TextStyle(
                  color: Colors.brown.shade800,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.brown.shade700,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 21,
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
// CIRCULO DECORATIVO
// ======================================================================

class _CirculoDecorativo extends StatelessWidget {
  final double size;
  final double opacity;

  const _CirculoDecorativo({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}