import 'package:flutter/material.dart';

import '../../models/usuario/avatar_cafetero_model.dart';
import '../../theme/app_colors.dart';

// ARCHIVO GENERADO A PARTIR DE LA DEFINICION DE ARTE DEL AVATAR CAFETERO.
// Lienzo logico de 100 x 100. Solo usa Canvas de Flutter (sin paquetes ni imagenes).
// Colores de escenario/ropa salen de AppColors; los tonos de piel y pelo son
// propios del avatar (no existen equivalentes en el tema).

class _Paleta {
  _Paleta(AvatarCafeteroModel a)
      : piel = _pieles[a.piel] ?? _pieles.values.first,
        pelo = _pelos[a.colorPelo] ?? _pelos.values.first,
        ropa = _ropas[a.ropa] ?? _ropas.values.first;

  final Color piel;
  final Color pelo;
  final Color ropa;

  Color get pielSombra => Color.lerp(piel, Colors.black, 0.14)!;
  Color get peloSombra => Color.lerp(pelo, Colors.black, 0.14)!;
  Color get ropaSombra => Color.lerp(ropa, Colors.black, 0.14)!;
  Color get ropaClara => Color.lerp(ropa, Colors.white, 0.22)!;

  static const Map<String, Color> _pieles = {
    'clara': Color(0xFFF6D5BC),
    'trigo': Color(0xFFE9B98F),
    'canela': Color(0xFFC98A5E),
    'morena': Color(0xFFA5683F),
    'oscura': Color(0xFF6B4228),
  };

  static const Map<String, Color> _pelos = {
    'negro': Color(0xFF1E1A18),
    'castano': Color(0xFF4A2E1C),
    'cafe': Color(0xFF8A5A35),
    'rubio': Color(0xFFD8B15C),
    'gris': Color(0xFFB9B9B4),
  };

  static const Map<String, Color> _ropas = {
    'verde': AppColors.primary,
    'cafe': AppColors.coffee,
    'crema': AppColors.coffeeLight,
    'naranja': AppColors.secondary,
  };
}

/// Colores representativos para los selectores de la pantalla de personalizacion.
class AvatarCafeteroPaleta {
  AvatarCafeteroPaleta._();

  static Color piel(String id) => _Paleta._pieles[id] ?? _Paleta._pieles.values.first;
  static Color pelo(String id) => _Paleta._pelos[id] ?? _Paleta._pelos.values.first;
  static Color ropa(String id) => _Paleta._ropas[id] ?? _Paleta._ropas.values.first;
}

class AvatarCafeteroPainter extends CustomPainter {
  const AvatarCafeteroPainter(this.avatar);

  final AvatarCafeteroModel avatar;

  @override
  void paint(Canvas canvas, Size size) {
    final lado = size.shortestSide;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate((size.width - lado) / 2, (size.height - lado) / 2);
    canvas.scale(lado / 100);
    final p = _Paleta(avatar);
    _fondoDibujar(canvas, p, avatar.fondo);
    _accAtrasDibujar(canvas, p, avatar.accesorio);
    _cuerpo(canvas, p);
    _peloAtrasDibujar(canvas, p, avatar.peinado);
    _cuello(canvas, p);
    _orejas(canvas, p);
    _cara(canvas, p);
    _peloFrenteDibujar(canvas, p, avatar.peinado);
    _sombreroDibujar(canvas, p, avatar.sombrero);
    _accFrenteDibujar(canvas, p, avatar.accesorio);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AvatarCafeteroPainter oldDelegate) =>
      oldDelegate.avatar != avatar;

  // ---------------------------------------------------------- primitivas
  static void _ovalo(Canvas canvas, double cx, double cy, double rx, double ry,
      Color relleno, {Color? trazo, double grosor = 0}) {
    final r = Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);
    canvas.drawOval(r, Paint()..color = relleno);
    if (trazo != null) {
      canvas.drawOval(r, Paint()
        ..color = trazo
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosor);
    }
  }

  static void _rect(Canvas canvas, double x, double y, double w, double h,
      double r, Color relleno) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
      Paint()..color = relleno,
    );
  }

  static void _trazar(Canvas canvas, Path ruta,
      {Color? relleno, Color? trazo, double grosor = 0}) {
    if (relleno != null) canvas.drawPath(ruta, Paint()..color = relleno);
    if (trazo != null) {
      canvas.drawPath(ruta, Paint()
        ..color = trazo
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosor
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round);
    }
  }

  static void _degradado(Canvas canvas, double x, double y, double w, double h,
      Color a, Color b) {
    final r = Rect.fromLTWH(x, y, w, h);
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [a, b],
        ).createShader(r),
    );
  }

  // ---------------------------------------------------------- dibujo
  static void _fondoMontanas(Canvas canvas, _Paleta p) {
    _degradado(canvas, 0, 0, 100, 100, AppColors.orangeSoft, AppColors.creamLight);
    _ovalo(canvas, 78, 24, 8, 8, const Color(0xFFFFF3D6).withValues(alpha: 0.95));
    _trazar(canvas, Path()..moveTo(0, 66)..lineTo(20, 42)..lineTo(38, 60)..lineTo(60, 34)..lineTo(84, 58)..lineTo(100, 46)..lineTo(100, 100)..lineTo(0, 100)..close(), relleno: AppColors.natureLight);
    _trazar(canvas, Path()..moveTo(53, 42)..lineTo(60, 34)..lineTo(67, 42)..lineTo(63, 40.5)..lineTo(60, 44)..lineTo(57, 40.5)..close(), relleno: const Color(0xFFFFFFFF));
    _trazar(canvas, Path()..moveTo(0, 80)..lineTo(18, 60)..lineTo(36, 76)..lineTo(56, 56)..lineTo(80, 76)..lineTo(100, 62)..lineTo(100, 100)..lineTo(0, 100)..close(), relleno: AppColors.nature);
    _trazar(canvas, Path()..moveTo(0, 92)..lineTo(22, 76)..lineTo(46, 90)..lineTo(70, 74)..lineTo(100, 88)..lineTo(100, 100)..lineTo(0, 100)..close(), relleno: AppColors.primary);
  }

  static void _fondoCafetal(Canvas canvas, _Paleta p) {
    _degradado(canvas, 0, 0, 100, 100, const Color(0xFFEAF3E4), AppColors.creamLight);
    _ovalo(canvas, 80, 20, 7, 7, const Color(0xFFFFF3D6));
    _trazar(canvas, Path()..moveTo(0, 58)..cubicTo(24, 44, 58, 66, 100, 48)..lineTo(100, 100)..lineTo(0, 100)..close(), relleno: AppColors.nature);
    _trazar(canvas, Path()..moveTo(0, 76)..cubicTo(28, 62, 64, 84, 100, 66)..lineTo(100, 100)..lineTo(0, 100)..close(), relleno: AppColors.primary);
    _trazar(canvas, Path()..moveTo(0, 62)..cubicTo(26, 50, 60, 70, 100, 54), trazo: AppColors.natureDark.withValues(alpha: 0.55), grosor: 1.1);
    _trazar(canvas, Path()..moveTo(0, 68)..cubicTo(26, 56, 60, 76, 100, 60), trazo: AppColors.natureDark.withValues(alpha: 0.55), grosor: 1.1);
    _trazar(canvas, Path()..moveTo(0, 74)..cubicTo(26, 62, 60, 82, 100, 66), trazo: AppColors.natureDark.withValues(alpha: 0.55), grosor: 1.1);
    _trazar(canvas, Path()..moveTo(0, 80)..cubicTo(26, 68, 60, 88, 100, 72), trazo: AppColors.natureDark.withValues(alpha: 0.55), grosor: 1.1);
    _ovalo(canvas, 12, 66, 1.5, 1.5, AppColors.error);
    _ovalo(canvas, 30, 64, 1.5, 1.5, AppColors.error);
    _ovalo(canvas, 48, 70, 1.5, 1.5, AppColors.error);
    _ovalo(canvas, 66, 64, 1.5, 1.5, AppColors.error);
    _ovalo(canvas, 84, 60, 1.5, 1.5, AppColors.error);
    _ovalo(canvas, 22, 78, 1.5, 1.5, AppColors.error);
    _ovalo(canvas, 58, 80, 1.5, 1.5, AppColors.error);
    _ovalo(canvas, 78, 74, 1.5, 1.5, AppColors.error);
    _ovalo(canvas, 92, 70, 1.5, 1.5, AppColors.error);
  }

  static void _fondoAmanecer(Canvas canvas, _Paleta p) {
    _degradado(canvas, 0, 0, 100, 100, AppColors.secondary, AppColors.orangeSoft);
    _ovalo(canvas, 50, 66, 18, 18, const Color(0xFFFFE9B8).withValues(alpha: 0.95));
    _ovalo(canvas, 50, 66, 26, 26, const Color(0xFFFFE9B8).withValues(alpha: 0.25));
    _trazar(canvas, Path()..moveTo(0, 70)..cubicTo(30, 60, 70, 76, 100, 64)..lineTo(100, 100)..lineTo(0, 100)..close(), relleno: AppColors.coffee.withValues(alpha: 0.85));
    _trazar(canvas, Path()..moveTo(0, 84)..cubicTo(34, 74, 66, 90, 100, 78)..lineTo(100, 100)..lineTo(0, 100)..close(), relleno: AppColors.primaryDark);
  }

  static void _fondoTatacoa(Canvas canvas, _Paleta p) {
    _degradado(canvas, 0, 0, 100, 100, const Color(0xFFA9D3E2), const Color(0xFFF4D3AE));
    _ovalo(canvas, 22, 22, 7, 7, const Color(0xFFFFF3D6));
    _trazar(canvas, Path()..moveTo(0, 78)..lineTo(8, 60)..lineTo(16, 64)..lineTo(24, 48)..lineTo(34, 66)..lineTo(46, 56)..lineTo(56, 70)..lineTo(68, 52)..lineTo(78, 64)..lineTo(90, 54)..lineTo(100, 68)..lineTo(100, 100)..lineTo(0, 100)..close(), relleno: AppColors.tertiary);
    _trazar(canvas, Path()..moveTo(0, 88)..lineTo(14, 72)..lineTo(28, 82)..lineTo(44, 68)..lineTo(62, 84)..lineTo(80, 70)..lineTo(100, 82)..lineTo(100, 100)..lineTo(0, 100)..close(), relleno: AppColors.coffeeLight);
    _trazar(canvas, Path()..moveTo(0, 96)..cubicTo(30, 88, 70, 100, 100, 90)..lineTo(100, 100)..lineTo(0, 100)..close(), relleno: const Color(0xFFE7B98A));
  }

  static void _fondoDibujar(Canvas canvas, _Paleta p, String id) {
    switch (id) {
      case 'montanas':
        _fondoMontanas(canvas, p);
      case 'cafetal':
        _fondoCafetal(canvas, p);
      case 'amanecer':
        _fondoAmanecer(canvas, p);
      case 'tatacoa':
        _fondoTatacoa(canvas, p);
      default:
        break;
    }
  }

  static void _peloAtrasCorto(Canvas canvas, _Paleta p) {
    // sin elementos
  }

  static void _peloAtrasOndulado(Canvas canvas, _Paleta p) {
    _trazar(canvas, Path()..moveTo(27.5, 52)..cubicTo(22.5, 30, 37, 21.6, 50, 21.6)..cubicTo(63, 21.6, 77.5, 30, 72.5, 52)..cubicTo(76, 62, 75.5, 72, 71, 80)..quadraticBezierTo(66.5, 84, 62, 78)..quadraticBezierTo(57.5, 84, 53, 78)..quadraticBezierTo(48, 84, 44, 78)..quadraticBezierTo(39.5, 84, 35, 78)..quadraticBezierTo(30.5, 84, 29, 80)..cubicTo(24.5, 72, 24, 62, 27.5, 52)..close(), relleno: p.peloSombra);
  }

  static void _peloAtrasTrenza(Canvas canvas, _Paleta p) {
    _trazar(canvas, Path()..moveTo(28.5, 50)..cubicTo(25, 30, 38, 22, 50, 22)..cubicTo(62, 22, 75, 30, 71.5, 50)..lineTo(68, 60)..lineTo(32, 60)..close(), relleno: p.peloSombra);
  }

  static void _peloAtrasCola(Canvas canvas, _Paleta p) {
    _trazar(canvas, Path()..moveTo(66, 33)..cubicTo(78, 30, 90, 38, 87, 54)..cubicTo(85.4, 64, 80, 70, 73.6, 72)..cubicTo(78, 62, 78, 52, 70, 46)..close(), relleno: p.peloSombra);
    _trazar(canvas, Path()..moveTo(70, 40)..cubicTo(79, 40, 84, 48, 82, 58), trazo: p.pelo.withValues(alpha: 0.55), grosor: 1.1);
  }

  static void _peloAtrasRizado(Canvas canvas, _Paleta p) {
    _ovalo(canvas, 32, 34, 8, 8, p.peloSombra);
    _ovalo(canvas, 40, 27.5, 8.4, 8.4, p.peloSombra);
    _ovalo(canvas, 50, 25, 8.8, 8.8, p.peloSombra);
    _ovalo(canvas, 60, 27.5, 8.4, 8.4, p.peloSombra);
    _ovalo(canvas, 68, 34, 8, 8, p.peloSombra);
    _ovalo(canvas, 27, 44, 7.4, 7.4, p.peloSombra);
    _ovalo(canvas, 73, 44, 7.4, 7.4, p.peloSombra);
    _ovalo(canvas, 26, 54, 6, 6, p.peloSombra);
    _ovalo(canvas, 74, 54, 6, 6, p.peloSombra);
    _ovalo(canvas, 32, 33.2, 7.1, 7.1, p.pelo);
    _ovalo(canvas, 40, 26.7, 7.5, 7.5, p.pelo);
    _ovalo(canvas, 50, 24.2, 7.9, 7.9, p.pelo);
    _ovalo(canvas, 60, 26.7, 7.5, 7.5, p.pelo);
    _ovalo(canvas, 68, 33.2, 7.1, 7.1, p.pelo);
    _ovalo(canvas, 27, 43.2, 6.5, 6.5, p.pelo);
    _ovalo(canvas, 73, 43.2, 6.5, 6.5, p.pelo);
    _ovalo(canvas, 26, 53.2, 5.1, 5.1, p.pelo);
    _ovalo(canvas, 74, 53.2, 5.1, 5.1, p.pelo);
  }

  static void _peloAtrasCalvo(Canvas canvas, _Paleta p) {
    // sin elementos
  }

  static void _peloAtrasDibujar(Canvas canvas, _Paleta p, String id) {
    switch (id) {
      case 'corto':
        _peloAtrasCorto(canvas, p);
      case 'ondulado':
        _peloAtrasOndulado(canvas, p);
      case 'trenza':
        _peloAtrasTrenza(canvas, p);
      case 'cola':
        _peloAtrasCola(canvas, p);
      case 'rizado':
        _peloAtrasRizado(canvas, p);
      case 'calvo':
        _peloAtrasCalvo(canvas, p);
      default:
        break;
    }
  }

  static void _peloFrenteCorto(Canvas canvas, _Paleta p) {
    _trazar(canvas, Path()..moveTo(29.6, 49)..cubicTo(28.6, 32, 39, 24.6, 50.5, 24.6)..cubicTo(62, 24.6, 71.6, 32, 70.4, 49)..cubicTo(69.4, 42.6, 65.6, 38, 58, 36.4)..cubicTo(49, 34.4, 38.5, 38.4, 33, 47.6)..close(), relleno: p.pelo);
    _trazar(canvas, Path()..moveTo(33, 47.6)..cubicTo(38.5, 38.4, 49, 34.4, 58, 36.4), trazo: p.peloSombra.withValues(alpha: 0.6), grosor: 0.9);
  }

  static void _peloFrenteOndulado(Canvas canvas, _Paleta p) {
    _trazar(canvas, Path()..moveTo(29.8, 47)..cubicTo(30.4, 31.6, 40, 25, 50, 25)..cubicTo(60, 25, 69.6, 31.6, 70.2, 47)..cubicTo(63, 41, 58.6, 34.6, 50.6, 32)..cubicTo(45, 36.4, 36.4, 42, 29.8, 47)..close(), relleno: p.pelo);
    _trazar(canvas, Path()..moveTo(50.6, 32)..cubicTo(49, 28.6, 49.6, 26.4, 50, 25), trazo: p.peloSombra, grosor: 0.8);
  }

  static void _peloFrenteTrenza(Canvas canvas, _Paleta p) {
    _trazar(canvas, Path()..moveTo(29.8, 48)..cubicTo(29.6, 32.6, 39.6, 25.2, 50, 25.2)..cubicTo(60.4, 25.2, 70.4, 32.6, 70.2, 48)..cubicTo(65, 42, 58.5, 37, 50, 34.4)..cubicTo(41.5, 37, 35, 42, 29.8, 48)..close(), relleno: p.pelo);
    _trazar(canvas, Path()..moveTo(50, 34.4)..lineTo(50, 25.2), trazo: p.peloSombra.withValues(alpha: 0.7), grosor: 0.9);
    _ovalo(canvas, 73.4, 66, 3.9, 4, p.pelo);
    _trazar(canvas, Path()..moveTo(70.8, 64.8)..quadraticBezierTo(73.4, 67.6, 76, 64.8), trazo: p.peloSombra, grosor: 0.9);
    _ovalo(canvas, 75.8, 72.5, 3.9, 4, p.pelo);
    _trazar(canvas, Path()..moveTo(73.2, 71.3)..quadraticBezierTo(75.8, 74.1, 78.4, 71.3), trazo: p.peloSombra, grosor: 0.9);
    _ovalo(canvas, 73.4, 79, 3.9, 4, p.pelo);
    _trazar(canvas, Path()..moveTo(70.8, 77.8)..quadraticBezierTo(73.4, 80.6, 76, 77.8), trazo: p.peloSombra, grosor: 0.9);
    _ovalo(canvas, 75.8, 85.5, 3.9, 4, p.pelo);
    _trazar(canvas, Path()..moveTo(73.2, 84.3)..quadraticBezierTo(75.8, 87.1, 78.4, 84.3), trazo: p.peloSombra, grosor: 0.9);
    _ovalo(canvas, 73.4, 92, 3.9, 4, p.pelo);
    _trazar(canvas, Path()..moveTo(70.8, 90.8)..quadraticBezierTo(73.4, 93.6, 76, 90.8), trazo: p.peloSombra, grosor: 0.9);
    _trazar(canvas, Path()..moveTo(72.8, 61)..cubicTo(73.6, 64, 75.6, 64, 76.4, 61)..close(), relleno: p.pelo);
    _ovalo(canvas, 74.8, 96.4, 3.1, 2.1, AppColors.secondary);
  }

  static void _peloFrenteCola(Canvas canvas, _Paleta p) {
    _trazar(canvas, Path()..moveTo(29.6, 49)..cubicTo(28.6, 32, 39, 24.6, 50.5, 24.6)..cubicTo(62, 24.6, 71.6, 32, 70.4, 49)..cubicTo(68.6, 42, 64, 37.6, 57, 36.2)..cubicTo(48, 35, 39, 39, 33, 47.6)..close(), relleno: p.pelo);
    _ovalo(canvas, 67.4, 35.4, 2.5, 2.5, AppColors.secondary);
  }

  static void _peloFrenteRizado(Canvas canvas, _Paleta p) {
    _ovalo(canvas, 38, 33.6, 5.2, 5.2, p.peloSombra);
    _ovalo(canvas, 38, 32.9, 4.4, 4.4, p.pelo);
    _ovalo(canvas, 46, 31.4, 5.4, 5.4, p.peloSombra);
    _ovalo(canvas, 46, 30.7, 4.6, 4.6, p.pelo);
    _ovalo(canvas, 54, 31.4, 5.4, 5.4, p.peloSombra);
    _ovalo(canvas, 54, 30.7, 4.6, 4.6, p.pelo);
    _ovalo(canvas, 62, 33.6, 5.2, 5.2, p.peloSombra);
    _ovalo(canvas, 62, 32.9, 4.4, 4.4, p.pelo);
  }

  static void _peloFrenteCalvo(Canvas canvas, _Paleta p) {
    _trazar(canvas, Path()..moveTo(38, 34)..cubicTo(44, 29.6, 56, 29.6, 62, 34), trazo: p.pielSombra.withValues(alpha: 0), grosor: 0.1);
  }

  static void _peloFrenteDibujar(Canvas canvas, _Paleta p, String id) {
    switch (id) {
      case 'corto':
        _peloFrenteCorto(canvas, p);
      case 'ondulado':
        _peloFrenteOndulado(canvas, p);
      case 'trenza':
        _peloFrenteTrenza(canvas, p);
      case 'cola':
        _peloFrenteCola(canvas, p);
      case 'rizado':
        _peloFrenteRizado(canvas, p);
      case 'calvo':
        _peloFrenteCalvo(canvas, p);
      default:
        break;
    }
  }

  static void _sombreroNinguno(Canvas canvas, _Paleta p) {
    // sin elementos
  }

  static void _sombreroAguadeno(Canvas canvas, _Paleta p) {
    _ovalo(canvas, 50, 34.4, 41, 9.4, const Color(0xFFCFC2A6));
    _ovalo(canvas, 50, 33, 41, 9.2, const Color(0xFFF3E8D0));
    _trazar(canvas, Path()..moveTo(31.6, 33)..cubicTo(30.6, 11, 69.4, 11, 68.4, 33)..cubicTo(61, 37.4, 39, 37.4, 31.6, 33)..close(), relleno: const Color(0xFFF7EEDB));
    _trazar(canvas, Path()..moveTo(40, 15.6)..quadraticBezierTo(50, 20.6, 60, 15.6), trazo: const Color(0xFFD9CDB3), grosor: 1.1);
    _trazar(canvas, Path()..moveTo(31.6, 32.4)..cubicTo(39, 37.2, 61, 37.2, 68.4, 32.4)..lineTo(68.9, 27.2)..cubicTo(61, 32, 39, 32, 31.1, 27.2)..close(), relleno: AppColors.coffeeDark);
  }

  static void _sombreroPaja(Canvas canvas, _Paleta p) {
    _ovalo(canvas, 50, 34.6, 43, 10.4, const Color(0xFFB98F49));
    _ovalo(canvas, 50, 33, 43, 10.2, AppColors.categoryFamilia);
    _trazar(canvas, Path()..moveTo(33.4, 32.4)..cubicTo(32.4, 14, 67.6, 14, 66.6, 32.4)..cubicTo(60, 36, 40, 36, 33.4, 32.4)..close(), relleno: const Color(0xFFE2B25A));
    _trazar(canvas, Path()..moveTo(33.2, 31.6)..cubicTo(40, 35.4, 60, 35.4, 66.8, 31.6)..lineTo(67.2, 27.4)..cubicTo(60, 31.2, 40, 31.2, 32.8, 27.4)..close(), relleno: AppColors.secondary);
    _trazar(canvas, Path()..moveTo(18, 36.4)..quadraticBezierTo(23, 40.6, 30, 38.2), trazo: const Color(0xFFB98F49).withValues(alpha: 0.7), grosor: 0.8);
    _trazar(canvas, Path()..moveTo(26, 36.4)..quadraticBezierTo(31, 40.6, 38, 38.2), trazo: const Color(0xFFB98F49).withValues(alpha: 0.7), grosor: 0.8);
    _trazar(canvas, Path()..moveTo(34, 36.4)..quadraticBezierTo(39, 40.6, 46, 38.2), trazo: const Color(0xFFB98F49).withValues(alpha: 0.7), grosor: 0.8);
    _trazar(canvas, Path()..moveTo(54, 38.4)..quadraticBezierTo(60, 40.8, 65, 36), trazo: const Color(0xFFB98F49).withValues(alpha: 0.7), grosor: 0.8);
    _trazar(canvas, Path()..moveTo(62, 38.4)..quadraticBezierTo(68, 40.8, 73, 36), trazo: const Color(0xFFB98F49).withValues(alpha: 0.7), grosor: 0.8);
    _trazar(canvas, Path()..moveTo(70, 38.4)..quadraticBezierTo(76, 40.8, 81, 36), trazo: const Color(0xFFB98F49).withValues(alpha: 0.7), grosor: 0.8);
  }

  static void _sombreroGorra(Canvas canvas, _Paleta p) {
    _trazar(canvas, Path()..moveTo(30.8, 36.4)..cubicTo(30, 15.4, 70, 15.4, 69.2, 36.4)..close(), relleno: AppColors.primary);
    _trazar(canvas, Path()..moveTo(50, 17.4)..cubicTo(44, 22, 42.4, 30, 42.8, 36.4), trazo: AppColors.primaryDark.withValues(alpha: 0.55), grosor: 0.9);
    _trazar(canvas, Path()..moveTo(50, 17.4)..cubicTo(56, 22, 57.6, 30, 57.2, 36.4), trazo: AppColors.primaryDark.withValues(alpha: 0.55), grosor: 0.9);
    _ovalo(canvas, 50, 17.6, 1.7, 1.7, AppColors.primaryDark);
    _trazar(canvas, Path()..moveTo(29.6, 36)..cubicTo(38, 40.6, 62, 40.6, 70.4, 36)..cubicTo(68, 42.4, 58, 44.6, 50, 44.6)..cubicTo(42, 44.6, 32, 42.4, 29.6, 36)..close(), relleno: AppColors.primaryDark);
    _trazar(canvas, Path()..moveTo(30.4, 36.2)..cubicTo(38, 39.4, 62, 39.4, 69.6, 36.2), trazo: AppColors.secondary, grosor: 1.2);
  }

  static void _sombreroDibujar(Canvas canvas, _Paleta p, String id) {
    switch (id) {
      case 'ninguno':
        _sombreroNinguno(canvas, p);
      case 'aguadeno':
        _sombreroAguadeno(canvas, p);
      case 'paja':
        _sombreroPaja(canvas, p);
      case 'gorra':
        _sombreroGorra(canvas, p);
      default:
        break;
    }
  }

  static void _accAtrasNinguno(Canvas canvas, _Paleta p) {
    // sin elementos
  }

  static void _accAtrasCanasto(Canvas canvas, _Paleta p) {
    // sin elementos
  }

  static void _accAtrasTaza(Canvas canvas, _Paleta p) {
    // sin elementos
  }

  static void _accAtrasGafas(Canvas canvas, _Paleta p) {
    // sin elementos
  }

  static void _accAtrasMochila(Canvas canvas, _Paleta p) {
    _rect(canvas, 21, 72, 58, 34, 9, AppColors.tertiary);
    _rect(canvas, 21, 72, 58, 34, 9, const Color(0xFF000000).withValues(alpha: 0));
  }

  static void _accAtrasDibujar(Canvas canvas, _Paleta p, String id) {
    switch (id) {
      case 'ninguno':
        _accAtrasNinguno(canvas, p);
      case 'canasto':
        _accAtrasCanasto(canvas, p);
      case 'taza':
        _accAtrasTaza(canvas, p);
      case 'gafas':
        _accAtrasGafas(canvas, p);
      case 'mochila':
        _accAtrasMochila(canvas, p);
      default:
        break;
    }
  }

  static void _accFrenteNinguno(Canvas canvas, _Paleta p) {
    // sin elementos
  }

  static void _accFrenteCanasto(Canvas canvas, _Paleta p) {
    _trazar(canvas, Path()..moveTo(22, 79)..cubicTo(30, 80, 36, 86, 40, 96), trazo: AppColors.coffee, grosor: 2.6);
    _trazar(canvas, Path()..moveTo(6, 90)..lineTo(12, 100)..lineTo(44, 100)..lineTo(50, 90)..close(), relleno: AppColors.coffeeLight);
    _ovalo(canvas, 28, 90, 22, 4.6, AppColors.coffee);
    _ovalo(canvas, 28, 90.4, 19.4, 3.2, const Color(0xFF3A2216));
    _ovalo(canvas, 16, 87.6, 2.5, 2.5, AppColors.error);
    _ovalo(canvas, 15.3, 86.8, 0.7, 0.7, const Color(0xFFFFFFFF).withValues(alpha: 0.5));
    _ovalo(canvas, 21, 86.2, 2.5, 2.5, AppColors.error);
    _ovalo(canvas, 20.3, 85.4, 0.7, 0.7, const Color(0xFFFFFFFF).withValues(alpha: 0.5));
    _ovalo(canvas, 27, 85.4, 2.5, 2.5, AppColors.error);
    _ovalo(canvas, 26.3, 84.6, 0.7, 0.7, const Color(0xFFFFFFFF).withValues(alpha: 0.5));
    _ovalo(canvas, 33, 86.2, 2.5, 2.5, AppColors.error);
    _ovalo(canvas, 32.3, 85.4, 0.7, 0.7, const Color(0xFFFFFFFF).withValues(alpha: 0.5));
    _ovalo(canvas, 38, 87.6, 2.5, 2.5, AppColors.error);
    _ovalo(canvas, 37.3, 86.8, 0.7, 0.7, const Color(0xFFFFFFFF).withValues(alpha: 0.5));
    _ovalo(canvas, 19, 89.4, 2.5, 2.5, AppColors.error);
    _ovalo(canvas, 18.3, 88.6, 0.7, 0.7, const Color(0xFFFFFFFF).withValues(alpha: 0.5));
    _ovalo(canvas, 25, 88.4, 2.5, 2.5, AppColors.error);
    _ovalo(canvas, 24.3, 87.6, 0.7, 0.7, const Color(0xFFFFFFFF).withValues(alpha: 0.5));
    _ovalo(canvas, 31, 88.4, 2.5, 2.5, AppColors.error);
    _ovalo(canvas, 30.3, 87.6, 0.7, 0.7, const Color(0xFFFFFFFF).withValues(alpha: 0.5));
    _ovalo(canvas, 36, 89.6, 2.5, 2.5, AppColors.error);
    _ovalo(canvas, 35.3, 88.8, 0.7, 0.7, const Color(0xFFFFFFFF).withValues(alpha: 0.5));
    _trazar(canvas, Path()..moveTo(24, 86)..quadraticBezierTo(27, 80.6, 31, 84)..quadraticBezierTo(28.4, 86.4, 24, 86)..close(), relleno: AppColors.nature);
    _trazar(canvas, Path()..moveTo(14, 92)..lineTo(18, 100), trazo: AppColors.coffee.withValues(alpha: 0.7), grosor: 0.9);
    _trazar(canvas, Path()..moveTo(22, 92)..lineTo(26, 100), trazo: AppColors.coffee.withValues(alpha: 0.7), grosor: 0.9);
    _trazar(canvas, Path()..moveTo(30, 92)..lineTo(34, 100), trazo: AppColors.coffee.withValues(alpha: 0.7), grosor: 0.9);
    _trazar(canvas, Path()..moveTo(38, 92)..lineTo(42, 100), trazo: AppColors.coffee.withValues(alpha: 0.7), grosor: 0.9);
    _trazar(canvas, Path()..moveTo(8.6, 94)..lineTo(47.4, 94), trazo: AppColors.coffee.withValues(alpha: 0.7), grosor: 0.9);
  }

  static void _accFrenteTaza(Canvas canvas, _Paleta p) {
    _trazar(canvas, Path()..moveTo(66, 82)..lineTo(66.6, 91)..cubicTo(67, 95.6, 70.4, 98, 74.4, 98)..cubicTo(78.4, 98, 81.8, 95.6, 82.2, 91)..lineTo(82.8, 82)..close(), relleno: const Color(0xFFFBF7F0));
    _ovalo(canvas, 74.4, 82, 8.4, 2.5, const Color(0xFFEFE6D6));
    _ovalo(canvas, 74.4, 82.2, 7.2, 1.9, AppColors.coffeeDark);
    _trazar(canvas, Path()..moveTo(82.4, 85)..cubicTo(88.4, 84, 88.4, 93, 81.6, 93), trazo: const Color(0xFFFBF7F0), grosor: 2);
    _trazar(canvas, Path()..moveTo(71, 78)..quadraticBezierTo(69, 75, 71, 72)..quadraticBezierTo(73, 69, 71, 66), trazo: const Color(0xFFFFFFFF).withValues(alpha: 0.75), grosor: 1.2);
    _trazar(canvas, Path()..moveTo(77, 78)..quadraticBezierTo(75, 75, 77, 72)..quadraticBezierTo(79, 69, 77, 66), trazo: const Color(0xFFFFFFFF).withValues(alpha: 0.75), grosor: 1.2);
  }

  static void _accFrenteGafas(Canvas canvas, _Paleta p) {
    _ovalo(canvas, 41.5, 51.2, 6.3, 6.3, const Color(0xFFFFFFFF).withValues(alpha: 0.14), trazo: AppColors.coffeeDark, grosor: 1.4);
    _ovalo(canvas, 58.5, 51.2, 6.3, 6.3, const Color(0xFFFFFFFF).withValues(alpha: 0.14), trazo: AppColors.coffeeDark, grosor: 1.4);
    _trazar(canvas, Path()..moveTo(47.7, 50.6)..quadraticBezierTo(50, 48.8, 52.3, 50.6), trazo: AppColors.coffeeDark, grosor: 1.3);
    _trazar(canvas, Path()..moveTo(35.2, 50)..lineTo(31, 49.4), trazo: AppColors.coffeeDark, grosor: 1.2);
    _trazar(canvas, Path()..moveTo(64.8, 50)..lineTo(69, 49.4), trazo: AppColors.coffeeDark, grosor: 1.2);
  }

  static void _accFrenteMochila(Canvas canvas, _Paleta p) {
    _trazar(canvas, Path()..moveTo(37, 76.8)..cubicTo(36, 86, 34.6, 94, 34, 100), trazo: AppColors.tertiary, grosor: 5);
    _trazar(canvas, Path()..moveTo(63, 76.8)..cubicTo(64, 86, 65.4, 94, 66, 100), trazo: AppColors.tertiary, grosor: 5);
    _rect(canvas, 32.4, 90, 3.2, 4.4, 1, AppColors.coffeeLight);
    _rect(canvas, 64.4, 90, 3.2, 4.4, 1, AppColors.coffeeLight);
  }

  static void _accFrenteDibujar(Canvas canvas, _Paleta p, String id) {
    switch (id) {
      case 'ninguno':
        _accFrenteNinguno(canvas, p);
      case 'canasto':
        _accFrenteCanasto(canvas, p);
      case 'taza':
        _accFrenteTaza(canvas, p);
      case 'gafas':
        _accFrenteGafas(canvas, p);
      case 'mochila':
        _accFrenteMochila(canvas, p);
      default:
        break;
    }
  }
  static void _cuerpo(Canvas canvas, _Paleta p) {
    _trazar(canvas, Path()..moveTo(12, 100)..cubicTo(12, 85, 27, 79, 41, 76.5)..lineTo(59, 76.5)..cubicTo(73, 79, 88, 85, 88, 100)..close(), relleno: p.ropa);
    _trazar(canvas, Path()..moveTo(12, 100)..cubicTo(12, 85, 27, 79, 41, 76.5)..lineTo(38, 100)..close(), relleno: p.ropaSombra.withValues(alpha: 0.35));
    _trazar(canvas, Path()..moveTo(41.5, 76.5)..lineTo(50, 88)..lineTo(58.5, 76.5)..close(), relleno: p.pielSombra);
    _trazar(canvas, Path()..moveTo(40, 76)..lineTo(50, 90)..lineTo(60, 76), trazo: p.ropaClara, grosor: 2.2);
    _ovalo(canvas, 50, 95, 1.1, 1.1, p.ropaSombra);
  }
  static void _cuello(Canvas canvas, _Paleta p) {
    _trazar(canvas, Path()..moveTo(43, 66)..lineTo(43, 79)..cubicTo(46, 83, 54, 83, 57, 79)..lineTo(57, 66)..close(), relleno: p.pielSombra);
  }
  static void _orejas(Canvas canvas, _Paleta p) {
    _ovalo(canvas, 30.3, 51.5, 3.3, 5, p.pielSombra);
    _ovalo(canvas, 69.7, 51.5, 3.3, 5, p.pielSombra);
    _ovalo(canvas, 30.9, 51.5, 1.5, 3, p.piel.withValues(alpha: 0.45));
    _ovalo(canvas, 69.1, 51.5, 1.5, 3, p.piel.withValues(alpha: 0.45));
  }
  static void _cara(Canvas canvas, _Paleta p) {
    _ovalo(canvas, 50, 50, 19.6, 22.6, p.piel);
    _ovalo(canvas, 36.2, 59, 3.8, 2.3, const Color(0xFFE8847A).withValues(alpha: 0.32));
    _ovalo(canvas, 63.8, 59, 3.8, 2.3, const Color(0xFFE8847A).withValues(alpha: 0.32));
    _ovalo(canvas, 41.5, 51.2, 2.2, 2.8, AppColors.coffeeDark);
    _ovalo(canvas, 58.5, 51.2, 2.2, 2.8, AppColors.coffeeDark);
    _ovalo(canvas, 42.3, 50.2, 0.75, 0.75, const Color(0xFFFFFFFF));
    _ovalo(canvas, 59.3, 50.2, 0.75, 0.75, const Color(0xFFFFFFFF));
    _trazar(canvas, Path()..moveTo(36.5, 45)..quadraticBezierTo(41.5, 42, 46.2, 44.6), trazo: p.peloSombra, grosor: 1.5);
    _trazar(canvas, Path()..moveTo(53.8, 44.6)..quadraticBezierTo(58.5, 42, 63.5, 45), trazo: p.peloSombra, grosor: 1.5);
    _trazar(canvas, Path()..moveTo(50, 53.5)..quadraticBezierTo(52.6, 58.2, 49.4, 59.2), trazo: p.pielSombra, grosor: 1.2);
    _trazar(canvas, Path()..moveTo(44.2, 63.6)..quadraticBezierTo(50, 68.6, 55.8, 63.6), trazo: const Color(0xFF8E3B2F), grosor: 1.7);
  }
}