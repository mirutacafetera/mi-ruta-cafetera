
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Botón circular reutilizable para volver o actualizar.
class BotonNavegacionAdmin extends StatelessWidget {
  final IconData icono;
  final String tooltip;
  final VoidCallback? onPressed;

  const BotonNavegacionAdmin({
    super.key,
    required this.icono,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.creamLight,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          icono,
          size: 21,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
