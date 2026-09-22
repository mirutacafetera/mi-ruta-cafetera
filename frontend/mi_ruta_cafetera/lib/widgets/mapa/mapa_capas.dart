import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/sitio_turistico_model.dart';
import '../../services/routing_service.dart';
import 'mapa_marcador.dart';

class MapaCapas extends StatelessWidget {
  final MapController mapController;

  final List<SitioTuristicoModel> sitios;

  final RutaResultado? ruta;

  final bool mostrarRuta;

  final bool Function(
    SitioTuristicoModel sitio,
  ) estaSeleccionado;

  final int Function(
    SitioTuristicoModel sitio,
  ) numeroDeSitio;

  final void Function(
    SitioTuristicoModel sitio,
    ) onTapSitio;

  const MapaCapas({
    super.key,
    required this.mapController,
    required this.sitios,
    required this.ruta,
    required this.mostrarRuta,
    required this.estaSeleccionado,
    required this.numeroDeSitio,
    required this.onTapSitio,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: const MapOptions(
        initialCenter: LatLng(
          2.195,
          -75.627,
        ),
        initialZoom: 10.5,
        minZoom: 5,
        maxZoom: 18,
        interactionOptions:
            InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // ========================================================
        // MAPA BASE
        // ========================================================

        TileLayer(
          urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName:
              'com.mirutacafetera.app',
        ),

        // ========================================================
        // RECORRIDO
        // ========================================================

        if (ruta != null &&
            mostrarRuta)
          PolylineLayer(
            polylines: [
              Polyline(
                points: ruta!.puntos,
                strokeWidth: 5,
                color: Colors.orange,
              ),
            ],
          ),

        // ========================================================
        // POI
        // ========================================================

        MarkerLayer(
          markers: sitios
              .where(
                (sitio) =>
                    sitio.tieneCoordenadas,
              )
              .map(
                (sitio) {
                  final seleccionado =
                      estaSeleccionado(
                    sitio,
                  );

                  return Marker(
                    point: sitio.ubicacion,
                    width: 52,
                    height: 64,
                    child: MapaMarcador(
                      sitio: sitio,
                      seleccionado:
                          seleccionado,
                      numero:
                          numeroDeSitio(
                        sitio,
                      ),
                      onTap: () {
                        onTapSitio(
                          sitio,
                        );
                      },
                    ),
                  );
                },
              )
              .toList(),
        ),
      ],
    );
  }
}