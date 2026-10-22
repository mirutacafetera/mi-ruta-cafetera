
import 'package:latlong2/latlong.dart';

import '../../models/sitio_turistico_model.dart';

class OrdenRutaHelper {
  static List<SitioTuristicoModel> ordenarPorCercania(
    List<SitioTuristicoModel> sitios,
  ) {
    if (sitios.length < 3) {
      return sitios;
    }

    const distancia = Distance();

    final pendientes =
        List<SitioTuristicoModel>.from(sitios);

    pendientes.sort(
      (a, b) => b.latitud.compareTo(a.latitud),
    );

    final ordenados = <SitioTuristicoModel>[
      pendientes.removeAt(0),
    ];

    while (pendientes.isNotEmpty) {
      final actual = ordenados.last;

      pendientes.sort(
        (a, b) => distancia(
          actual.ubicacion,
          a.ubicacion,
        ).compareTo(
          distancia(
            actual.ubicacion,
            b.ubicacion,
          ),
        ),
      );

      ordenados.add(pendientes.removeAt(0));
    }

    return ordenados;
  }
}
