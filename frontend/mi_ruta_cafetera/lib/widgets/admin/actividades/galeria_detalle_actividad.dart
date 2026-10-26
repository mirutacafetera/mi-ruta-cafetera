
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import 'componentes_detalle_actividad.dart';

class GaleriaDetalleActividad extends StatelessWidget {
  final List<String> imagenes;
  final Function(List<String>, int)? onMostrarGaleria;

  const GaleriaDetalleActividad({
    super.key,
    required this.imagenes,
    this.onMostrarGaleria,
  });

  @override
  Widget build(BuildContext context) {
    return TarjetaDetalleActividad(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TituloDetalleActividad(
              texto: 'Fotografías',
              icono: Icons.photo_library_outlined,
            ),
            const SizedBox(height: 18),
            if (imagenes.isEmpty)
              const SinImagenesActividad()
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final columnas =
                      constraints.maxWidth >= 390 ? 4 : 3;

                  final ancho = (constraints.maxWidth -
                          (columnas - 1) * 8) /
                      columnas;

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      imagenes.length,
                      (i) => GestureDetector(
                        onTap: onMostrarGaleria == null
                            ? null
                            : () => onMostrarGaleria!(
                                  imagenes,
                                  i,
                                ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imagenes[i],
                            width: ancho,
                            height: ancho,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: ancho,
                              height: ancho,
                              color: AppColors.surfaceVariant,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
