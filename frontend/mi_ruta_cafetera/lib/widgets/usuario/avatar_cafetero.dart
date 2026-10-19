import 'package:flutter/material.dart';

import '../../models/usuario/avatar_cafetero_model.dart';
import 'avatar_cafetero_painter.dart';

// ============================================================
// AVATAR CAFETERO (widget)
// ============================================================
//
// Dibuja el avatar ilustrado, cuadrado, dentro de un círculo.
// No usa imágenes ni paquetes: todo se pinta con CustomPainter.
// ============================================================

class AvatarCafetero extends StatelessWidget {
  final AvatarCafeteroModel avatar;
  final double size;

  const AvatarCafetero({
    super.key,
    required this.avatar,
    this.size = 96,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: AvatarCafeteroPainter(avatar),
          ),
        ),
      ),
    );
  }
}
