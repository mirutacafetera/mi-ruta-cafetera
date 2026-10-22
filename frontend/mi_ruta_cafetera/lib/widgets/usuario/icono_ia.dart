import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../l10n/textos.dart';

/// Icono de "Mi Ruta Cafetera IA" (assets/img/iconoia.png).
///
/// Es el único lugar que conoce la imagen: el botón flotante, la
/// tarjeta del Home, el panel de recomendaciones y el chat lo usan,
/// así que cambiar el icono de la IA es cambiar este archivo.
/// Conserva las proporciones de la imagen (BoxFit.contain). Si la
/// imagen no se puede cargar muestra [iconoRespaldo] y la pantalla
/// no se rompe.
class IconoIa extends StatelessWidget {
  static const String ruta = 'assets/img/iconoia.png';

  final double size;
  final IconData iconoRespaldo;
  final Color colorRespaldo;

  const IconoIa({
    super.key,
    required this.size,
    this.iconoRespaldo = Icons.auto_awesome_rounded,
    this.colorRespaldo = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        ruta,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        semanticLabel: Textos.t('Mi Ruta Cafetera IA'),
        errorBuilder: (context, error, stackTrace) {
          return Icon(iconoRespaldo, size: size, color: colorRespaldo);
        },
      ),
    );
  }
}
