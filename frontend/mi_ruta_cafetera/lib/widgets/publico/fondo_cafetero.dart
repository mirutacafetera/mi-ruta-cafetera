import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

// ============================================================
// FONDO CAFETERO
// ============================================================
//
// Fondo de las pantallas de inicio: degradado de verde a naranja
// tostado con granos de café que flotan despacio.
//
// - Solo es decorativo: no recibe toques (IgnorePointer) y queda
//   detrás del contenido, que se desplaza encima.
// - La animación es lenta y de bajo contraste para no distraer ni
//   afectar la lectura.
// - Se dibuja con un solo CustomPainter dentro de un
//   RepaintBoundary (no reconstruye el contenido de la pantalla).
// - Respeta "Quitar animaciones" del sistema: en ese caso los
//   granos quedan quietos.
// - No usa paquetes adicionales.
// ============================================================

class FondoCafetero extends StatefulWidget {
  const FondoCafetero({
    super.key,
    required this.child,
    this.granos = 16,
  });

  final Widget child;

  /// Cantidad de granos dibujados.
  final int granos;

  @override
  State<FondoCafetero> createState() => _FondoCafeteroState();
}

class _FondoCafeteroState extends State<FondoCafetero>
    with SingleTickerProviderStateMixin {
  // Una vuelta completa de la animación. Todos los movimientos son
  // múltiplos enteros de este ciclo, por lo que no hay saltos al
  // reiniciar.
  static const Duration _ciclo = Duration(seconds: 90);

  late final AnimationController _controlador;
  late final List<_Grano> _granos;

  bool _sinAnimaciones = false;

  @override
  void initState() {
    super.initState();

    _controlador = AnimationController(
      vsync: this,
      duration: _ciclo,
    );

    final azar = math.Random(7);

    _granos = List<_Grano>.generate(
      widget.granos,
      (_) => _Grano.aleatorio(azar),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final quieto = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (quieto != _sinAnimaciones || !_controlador.isAnimating) {
      _sinAnimaciones = quieto;

      if (quieto) {
        _controlador.stop();
      } else {
        _controlador.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Degradado fijo (no se desplaza con el contenido).
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.homeGradientTop,
                AppColors.homeGradientMid,
                AppColors.homeGradientBottom,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Granos de café.
        IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _PintorGranos(
                granos: _granos,
                animacion: _controlador,
              ),
              size: Size.infinite,
            ),
          ),
        ),

        widget.child,
      ],
    );
  }
}

// ============================================================
// DATOS DE UN GRANO
// ============================================================

class _Grano {
  const _Grano({
    required this.x,
    required this.y,
    required this.tamano,
    required this.angulo,
    required this.vueltas,
    required this.caidas,
    required this.balanceo,
    required this.fase,
    required this.oscuro,
  });

  /// Posición inicial relativa (0 a 1).
  final double x;
  final double y;

  /// Ancho del grano en píxeles.
  final double tamano;

  /// Ángulo inicial y vueltas enteras por ciclo (puede ser negativo).
  final double angulo;
  final int vueltas;

  /// Pasadas completas de arriba abajo por ciclo (1 o 2).
  final int caidas;

  /// Amplitud del balanceo horizontal (en píxeles) y su fase.
  final double balanceo;
  final double fase;

  final bool oscuro;

  factory _Grano.aleatorio(math.Random azar) {
    return _Grano(
      x: azar.nextDouble(),
      y: azar.nextDouble(),
      tamano: 14 + azar.nextDouble() * 18,
      angulo: azar.nextDouble() * math.pi * 2,
      vueltas: azar.nextBool() ? 1 : -1,
      caidas: azar.nextInt(3) == 0 ? 2 : 1,
      balanceo: 10 + azar.nextDouble() * 22,
      fase: azar.nextDouble(),
      oscuro: azar.nextInt(4) != 0,
    );
  }
}

// ============================================================
// PINTOR
// ============================================================

class _PintorGranos extends CustomPainter {
  _PintorGranos({
    required this.granos,
    required this.animacion,
  }) : super(repaint: animacion);

  final List<_Grano> granos;
  final Animation<double> animacion;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final t = animacion.value;

    for (final grano in granos) {
      final largo = grano.tamano * 1.4;

      // Caída lenta con vuelta al inicio (valor entre 0 y 1).
      final avance = (grano.y + t * grano.caidas) % 1.0;

      // Se deja un margen para que entren y salgan sin cortarse.
      final y = -largo + avance * (size.height + largo * 2);

      final balanceo =
          math.sin((t * 2 + grano.fase) * math.pi * 2) * grano.balanceo;

      final x = grano.x * size.width + balanceo;

      final angulo = grano.angulo + t * math.pi * 2 * grano.vueltas;

      _dibujarGrano(canvas, x, y, grano, angulo);
    }
  }

  void _dibujarGrano(
    Canvas canvas,
    double x,
    double y,
    _Grano grano,
    double angulo,
  ) {
    final ancho = grano.tamano;
    final alto = grano.tamano * 1.4;

    final cuerpo = Paint()
      ..color = (grano.oscuro ? AppColors.coffee : AppColors.coffeeLight)
          .withValues(alpha: 0.30);

    final surco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, ancho * 0.09)
      ..strokeCap = StrokeCap.round
      ..color = AppColors.coffeeDark.withValues(alpha: 0.32);

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angulo);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: ancho,
        height: alto,
      ),
      cuerpo,
    );

    final trazo = Path()
      ..moveTo(0, -alto * 0.40)
      ..cubicTo(
        ancho * 0.30,
        -alto * 0.14,
        -ancho * 0.30,
        alto * 0.14,
        0,
        alto * 0.40,
      );

    canvas.drawPath(trazo, surco);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PintorGranos oldDelegate) {
    return oldDelegate.granos != granos;
  }
}
