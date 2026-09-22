import 'package:flutter/material.dart';

class SitioCardImagen extends StatelessWidget {
  final String? imagen;

  const SitioCardImagen({
    super.key,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    if (imagen == null || imagen!.isEmpty) {
      return Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.place_outlined,
          size: 42,
          color: Colors.green.shade700,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imagen!,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return Container(
            width: 90,
            height: 90,
            color: Colors.green.shade50,
            child: Icon(
              Icons.broken_image_outlined,
              size: 38,
              color: Colors.grey.shade500,
            ),
          );
        },
      ),
    );
  }
}