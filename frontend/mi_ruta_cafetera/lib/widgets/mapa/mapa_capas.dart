import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/sitio_turistico_model.dart';
import '../../services/routing_service.dart';
import '../../theme/app_colors.dart';
import 'mapa_marcador.dart';

class MapaCapas extends StatelessWidget {
  final MapController mapController;
  final List<SitioTuristicoModel> sitios;
  final RutaResultado? ruta;
  final bool mostrarRuta;
  final LatLng? ubicacionUsuario;

  final bool Function(SitioTuristicoModel sitio) estaSeleccionado;
  final int? Function(SitioTuristicoModel sitio) numeroDeSitio;
  final ValueChanged<SitioTuristicoModel> onTapSitio;

  const MapaCapas({
    super.key,
    required this.mapController,
    required this.sitios,
    required this.ruta,
    required this.mostrarRuta,
    this.ubicacionUsuario,
    required this.estaSeleccionado,
    required this.numeroDeSitio,
    required this.onTapSitio,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: const MapOptions(
        initialCenter: LatLng(2.195, -75.627),
        initialZoom: 10.5,
        minZoom: 5,
        maxZoom: 18,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const [
            'a',
            'b',
            'c',
          ],
          userAgentPackageName:
              'com.miruta.cafetera',
        ),

        if (mostrarRuta && ruta != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: ruta!.puntos,
                strokeWidth: 5,
                color: AppColors.primary,
              ),
            ],
          ),

        MarkerLayer(
          markers: sitios.map((sitio) {
            final seleccionado =
                estaSeleccionado(sitio);

            final numero =
                numeroDeSitio(sitio) ?? 0;

            return Marker(
              point: sitio.ubicacion,
              width: 64,
              height: 72,
              child: MapaMarcador(
                sitio: sitio,
                seleccionado: seleccionado,
                numero: numero,
                onTap: () =>
                    onTapSitio(sitio),
              ),
            );
          }).toList(),
        ),

        if (ubicacionUsuario != null)
          MarkerLayer(
            markers: [
              Marker(
                point: ubicacionUsuario!,
                width: 48,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        AppColors.primary.withValues(
                      alpha: 0.18,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color:
                            AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}