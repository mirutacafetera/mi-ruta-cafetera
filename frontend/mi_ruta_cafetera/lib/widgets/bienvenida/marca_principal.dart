import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class MarcaPrincipal extends StatelessWidget {
  final bool compacto;

  const MarcaPrincipal({
    super.key,
    required this.compacto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Mi Ruta Cafetera',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white,
            fontSize: compacto ? 29 : 34,
            fontWeight: FontWeight.w800,
            height: 1,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(
          height: AppDimensions.spacingSm,
        ),
        Text(
          'Descubre · Explora · Vive',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white.withValues(
              alpha: 0.84,
            ),
            fontSize: 12,
            letterSpacing: 2.1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
