
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

import '../../../../theme/app_dimensions.dart';

class DetalleGaleria extends StatelessWidget {
  final List<String> imagenes;
  final bool cargando;

  const DetalleGaleria({
    super.key,
    required this.imagenes,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    final imagenesValidas = imagenes
        .map((imagen) => imagen.trim())
        .where((imagen) => imagen.isNotEmpty)
        .toSet()
        .toList();

    if (cargando) {
      return Padding(
        padding: EdgeInsets.all(AppDimensions.spacingMd),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (imagenesValidas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GalerÃ­a de imÃ¡genes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: AppDimensions.spacingMd),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: imagenesValidas.length,
              separatorBuilder: (_, _) =>
                  SizedBox(width: AppDimensions.spacingMd),
              itemBuilder: (context, index) {
                final imagen = imagenesValidas[index];

                return SizedBox(
                  width: 210,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _mostrarImagen(
                      context,
                      imagen,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imagen,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.cream,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarImagen(BuildContext context, String imagen) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.black,
        insetPadding: EdgeInsets.all(AppDimensions.spacingMd),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: Image.network(
                imagen,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 250,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.surface,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Cerrar imagen',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.close,
                color: AppColors.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
