import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'imagen_bienvenida.dart';

class IconoDecorativo extends StatelessWidget {
  final ImagenBienvenida imagen;

  const IconoDecorativo({
    super.key,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 300,
        height: 300,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              imagen.color.withValues(alpha: 0.22),
              imagen.color.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: Icon(
          imagen.icono,
          size: 190,
          color: AppColors.white.withValues(
            alpha: 0.075,
          ),
        ),
      ),
    );
  }
}