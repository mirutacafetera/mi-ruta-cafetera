import 'package:flutter/material.dart';

import 'sitio_badge.dart';
import 'sitio_card_imagen.dart';

class SitioCard extends StatelessWidget {
  final Map<String, dynamic> sitio;
  final String categoria;
  final bool activo;
  final String? imagen;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const SitioCard({
    super.key,
    required this.sitio,
    required this.categoria,
    required this.activo,
    required this.imagen,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final nombre =
        (sitio['nombre'] ?? 'Sin nombre').toString();

    final descripcion =
        (sitio['descripcion'] ?? 'Sin descripción').toString();

    final ciudad =
        (sitio['ciudad'] ?? '').toString();

    final direccion =
        (sitio['direccion'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            SitioCardImagen(
              imagen: imagen,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      PopupMenuButton<String>(
                        onSelected: (opcion) {
                          if (opcion == 'editar') {
                            onEditar();
                          }

                          if (opcion == 'eliminar') {
                            onEliminar();
                          }
                        },
                        itemBuilder: (context) =>
                            const [
                          PopupMenuItem<String>(
                            value: 'editar',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Editar'),
                              ],
                            ),
                          ),

                          PopupMenuItem<String>(
                            value: 'eliminar',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Eliminar'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      SitioBadge(
                        texto: categoria,
                        icono:
                            Icons.category_outlined,
                      ),

                      if (ciudad.isNotEmpty)
                        SitioBadge(
                          texto: ciudad,
                          icono:
                              Icons.location_city_outlined,
                        ),

                      SitioBadge.estado(
                        activo: activo,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    descripcion,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),

                  if (direccion.isNotEmpty) ...[
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color:
                              Colors.grey.shade600,
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          child: Text(
                            direccion,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}