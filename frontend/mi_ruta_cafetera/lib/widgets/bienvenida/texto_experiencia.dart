
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import 'imagen_bienvenida.dart';

class TextoExperiencia extends StatelessWidget {
  final ImagenBienvenida imagen;

  const TextoExperiencia({
    super.key,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: imagen.color.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMd,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            imagen.icono,
            color: AppColors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Text(
          imagen.titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 29,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          imagen.subtitulo,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.86),
            fontSize: 15,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
