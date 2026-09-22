import 'package:flutter/material.dart';

class SitioListHeader extends StatelessWidget {
  final int cantidadSitios;
  final bool cargando;
  final VoidCallback onActualizar;
  final VoidCallback onNuevoSitio;

  const SitioListHeader({
    super.key,
    required this.cantidadSitios,
    required this.cargando,
    required this.onActualizar,
    required this.onNuevoSitio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sitios turísticos',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$cantidadSitios sitios registrados',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Actualizar',
            onPressed: cargando ? null : onActualizar,
            icon: const Icon(
              Icons.refresh,
            ),
          ),

          const SizedBox(width: 4),

          FilledButton.icon(
            onPressed: onNuevoSitio,
            icon: const Icon(
              Icons.add,
            ),
            label: const Text(
              'Nuevo sitio',
            ),
          ),
        ],
      ),
    );
  }
}