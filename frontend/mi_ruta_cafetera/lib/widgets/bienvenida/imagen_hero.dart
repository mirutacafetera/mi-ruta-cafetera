
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'imagen_bienvenida.dart';

class ImagenHero extends StatelessWidget {
  final ImagenBienvenida imagen;
  final bool activa;

  const ImagenHero({
    super.key,
    required this.imagen,
    required this.activa,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedScale(
        scale: activa ? 1.0 : 1.015,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        child: Image.asset(
          imagen.asset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            return FondoImagenRespaldo(
              imagen: imagen,
            );
          },
        ),
      ),
    );
  }
}

class FondoImagenRespaldo extends StatelessWidget {
  final ImagenBienvenida imagen;

  const FondoImagenRespaldo({
    super.key,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.white.withValues(
                  alpha: 0.05,
                ),
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
                color: AppColors.black.withValues(
                  alpha: 0.12,
                ),
              ),
            ),
          ),
          Center(
            child: Icon(
              imagen.icono,
              size: 170,
              color: AppColors.white.withValues(
                alpha: 0.09,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
