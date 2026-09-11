import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'sitio_section_card.dart';
import 'sitio_section_title.dart';

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

  static const Color verdePrincipal = Color(0xFF31572C);
  static const Color verdeOscuro = Color(0xFF1B4332);
  static const Color grisTexto = Color(0xFF6B6B6B);
  static const Color grisBorde = Color(0xFFE1E1E1);

  @override
  Widget build(BuildContext context) {
    return SitioSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SitioSectionTitle(
            icono: Icons.photo_camera_outlined,
            titulo: 'Imagen principal',
            subtitulo:
                'Una buena imagen ayuda a mostrar el sitio',
          ),

          GestureDetector(
            onTap: onSeleccionarImagen,
            child: _imagen(),
          ),

          const SizedBox(height: 10),

          const Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 16,
                color: grisTexto,
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Toca la imagen para seleccionar una foto desde la galería.',
                  style: TextStyle(
                    fontSize: 11,
                    color: grisTexto,
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
    if (imagenBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.memory(
          imagenBytes!,
          width: double.infinity,
          height: 190,
          fit: BoxFit.cover,
        ),
      );
    }

    if (imagenesExistentes.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
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

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: grisBorde,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: verdePrincipal.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_a_photo_rounded,
              color: verdePrincipal,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Agregar imagen',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: verdeOscuro,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Toca aquí para seleccionar una foto',
            style: TextStyle(
              fontSize: 12,
              color: grisTexto,
            ),
          ),
        ],
      ),
    );
  }
}