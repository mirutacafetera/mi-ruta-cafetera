import 'package:flutter/material.dart';

class SitioEmptyState extends StatelessWidget {
  final bool buscando;
  final VoidCallback onRegistrar;

  const SitioEmptyState({
    super.key,
    required this.buscando,
    required this.onRegistrar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 16),

            Text(
              buscando
                  ? 'No se encontraron sitios'
                  : 'No hay sitios registrados',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              buscando
                  ? 'Prueba con otro nombre, ciudad, dirección o categoría.'
                  : 'Puedes registrar el primer sitio turístico.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            if (!buscando) ...[
              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: onRegistrar,
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  'Registrar sitio',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}