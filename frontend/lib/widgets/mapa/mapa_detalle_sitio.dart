import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';

class MapaDetalleSitio extends StatelessWidget {
  final SitioTuristicoModel sitio;
  final VoidCallback onVerMapa;
  final VoidCallback onAgregarRuta;

  const MapaDetalleSitio({
    super.key,
    required this.sitio,
    required this.onVerMapa,
    required this.onAgregarRuta,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.58,
        minChildSize: 0.40,
        maxChildSize: 0.85,
        builder: (
          context,
          scrollController,
        ) {
          return Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                20,
                14,
                20,
                24,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    sitio.nombre,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (sitio.categoriaNombre.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 18,
                          color: Colors.brown,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            sitio.categoriaNombre,
                            style: const TextStyle(
                              color: Colors.brown,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (sitio.descripcion.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      sitio.descripcion,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.brown,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${sitio.ciudad}, '
                          '${sitio.departamento}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (sitio.direccion.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          color: Colors.brown,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sitio.direccion,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onVerMapa,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text(
                        'Ver en el mapa',
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onAgregarRuta,
                      icon: const Icon(
                        Icons.add_road,
                      ),
                      label: const Text(
                        'Agregar a mi ruta',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}