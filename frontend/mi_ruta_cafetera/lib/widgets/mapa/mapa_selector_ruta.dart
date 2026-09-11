import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';

class MapaSelectorRuta extends StatelessWidget {
  final bool activo;
  final List<SitioTuristicoModel> sitiosSeleccionados;
  final VoidCallback onIniciar;
  final VoidCallback onCancelar;
  final VoidCallback onCalcular;

  const MapaSelectorRuta({
    super.key,
    required this.activo,
    required this.sitiosSeleccionados,
    required this.onIniciar,
    required this.onCancelar,
    required this.onCalcular,
  });

  @override
  Widget build(BuildContext context) {
    if (!activo) {
      return Positioned(
        left: 16,
        right: 16,
        bottom: 20,
        child: SafeArea(
          top: false,
          child: ElevatedButton.icon(
            onPressed: onIniciar,
            icon: const Icon(Icons.alt_route),
            label: const Text(
              'Crear mi ruta',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 15,
              ),
            ),
          ),
        ),
      );
    }

    final cantidad = sitiosSeleccionados.length;

    return Positioned(
      left: 12,
      right: 12,
      bottom: 20,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.route,
                    color: Colors.brown,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Crear mi ruta',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '$cantidad/4',
                    style: const TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                cantidad == 0
                    ? 'Selecciona entre 2 y 4 sitios del mapa.'
                    : cantidad == 1
                        ? 'Selecciona al menos un sitio más.'
                        : '$cantidad sitios seleccionados.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              if (sitiosSeleccionados.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: sitiosSeleccionados.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final sitio =
                          sitiosSeleccionados[index];

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.brown.shade50,
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.brown.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 11,
                              backgroundColor: Colors.brown,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ConstrainedBox(
                              constraints:
                                  const BoxConstraints(
                                maxWidth: 130,
                              ),
                              child: Text(
                                sitio.nombre,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancelar,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: cantidad >= 2
                          ? onCalcular
                          : null,
                      icon: const Icon(Icons.route),
                      label: const Text(
                        'Calcular ruta',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}