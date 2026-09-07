import 'package:flutter/material.dart';

import '../../data/rutas_predefinidas.dart';
import '../../models/ruta_predefinida_model.dart';

class MapaRutasPredefinidas
    extends StatelessWidget {
  final ValueChanged<RutaPredefinidaModel>
      onSeleccionar;

  const MapaRutasPredefinidas({
    super.key,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.40,
        maxChildSize: 0.90,
        builder: (
          context,
          scrollController,
        ) {
          return Material(
            color: Colors.white,
            borderRadius:
                const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rutas predefinidas',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Elige una experiencia para '
                      'explorar sus sitios.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    controller:
                        scrollController,
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      24,
                    ),
                    itemCount:
                    RutasPredefinidas.todas.length,
                    itemBuilder:
                        (context, index) {
                      final ruta =
                    RutasPredefinidas.todas[index];

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.all(
                            14,
                          ),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor:
                                ruta.color
                                    .withValues(
                              alpha: 0.15,
                            ),
                            child: Icon(
                              ruta.icono,
                              color: ruta.color,
                            ),
                          ),
                          title: Text(
                            ruta.nombre,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding:
                                const EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              ruta.descripcion,
                            ),
                          ),
                          trailing:
                              const Icon(
                            Icons
                                .arrow_forward_ios,
                            size: 17,
                          ),
                          onTap: () {
                            Navigator.pop(
                              context,
                            );
                            onSeleccionar(
                              ruta,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}