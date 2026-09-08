import 'package:flutter/material.dart';

class SitioSearchBar extends StatelessWidget {
  final String valor;
  final ValueChanged<String> onChanged;
  final VoidCallback onLimpiar;

  const SitioSearchBar({
    super.key,
    required this.valor,
    required this.onChanged,
    required this.onLimpiar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        12,
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText:
              'Buscar por nombre, ciudad, dirección o categoría...',
          prefixIcon: const Icon(
            Icons.search,
          ),
          suffixIcon: valor.isNotEmpty
              ? IconButton(
                  onPressed: onLimpiar,
                  icon: const Icon(
                    Icons.clear,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}