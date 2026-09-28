import 'package:flutter/material.dart';
import '../../models/sitio_turistico_model.dart';
import '../../theme/app_colors.dart';

class MapaMarcador extends StatelessWidget {
  final SitioTuristicoModel sitio;
  final bool seleccionado;
  final int numero;
  final VoidCallback onTap;

  const MapaMarcador({
    super.key,
    required this.sitio,
    required this.seleccionado,
    required this.numero,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Lee la categoría de forma segura (soporta categoriaNombre o categoria)
    final String nombreCategoria = sitio.categoriaNombre;
    
    final colorCategoria = AppColors.getColorForCategory(nombreCategoria);
    final iconoCategoria = AppColors.getIconForCategory(nombreCategoria);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: seleccionado ? AppColors.primary : colorCategoria,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white,
                width: seleccionado ? 3 : 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  iconoCategoria,
                  color: AppColors.white,
                  size: seleccionado ? 22 : 18,
                ),
                if (numero > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$numero',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(8, 5),
            painter: _TrianglePainter(
              color: seleccionado ? AppColors.primary : colorCategoria,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}