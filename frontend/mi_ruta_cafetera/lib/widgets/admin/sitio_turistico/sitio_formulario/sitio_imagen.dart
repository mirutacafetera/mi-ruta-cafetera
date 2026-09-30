import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_dimensions.dart';

import 'contenedor_seccion_sitio.dart';
import 'titulo_seccion_sitio.dart';

class SitioImagen extends StatelessWidget {
  final Uint8List? imagenBytes;
  final List<String> imagenesExistentes;
  final VoidCallback onSeleccionarImagen;

  const SitioImagen({
    super.key,
    required this.imagenBytes,
    required this.imagenesExistentes,
    required this.onSeleccionarImagen,
  });

  @override
  Widget build(BuildContext context) {
    return ContenedorSeccionSitio(
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TituloSeccionSitio(
            icono: Icons.photo_camera_outlined,
            titulo: 'Imagen principal',
            subtitulo: 'Una buena imagen ayuda a mostrar el sitio',
          ),

          GestureDetector(
            onTap: onSeleccionarImagen,
            child: _imagen(),
          ),

          const SizedBox(
            height: AppDimensions.spacingSm + 2,
          ),

          const Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: AppDimensions.iconSm,
                color: AppColors.textSecondary,
              ),

              SizedBox(
                width: AppDimensions.spacingXs + 3,
              ),

              Expanded(
                child: Text(
                  'Toca la imagen para seleccionar una foto desde la galería.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imagen() {
    // Si el usuario acaba de seleccionar una imagen,
    // mostramos esa imagen.
    if (imagenBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        child: Image.memory(
          imagenBytes!,
          width: double.infinity,
          height: 190,
          fit: BoxFit.cover,
        ),
      );
    }

    // Si estamos editando y ya existe una imagen,
    // mostramos la imagen existente.
    if (imagenesExistentes.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        child: Image.network(
          imagenesExistentes.first,
          width: double.infinity,
          height: 190,
          fit: BoxFit.cover,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return _placeholder();
          },
        ),
      );
    }

    // Si no existe ninguna imagen,
    // mostramos el espacio para agregarla.
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_a_photo_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),

          const SizedBox(
            height: AppDimensions.spacingMd,
          ),

          const Text(
            'Agregar imagen',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),

          const SizedBox(
            height: AppDimensions.spacingXs,
          ),

          const Text(
            'Toca aquí para seleccionar una foto',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}