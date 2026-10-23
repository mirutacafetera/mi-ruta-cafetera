
import '../../models/ruta_model.dart';
import '../../models/sitio_turistico_model.dart';
import '../../widgets/mapa/mapa_estado_ruta.dart';

class ItinerarioRutaHelper {
  static Map<String, int> minutosDeParadas(
    List<ParadaRutaModel> paradas,
  ) {
    final minutos = <String, int>{};

    for (final parada in paradas) {
      final duracion = parada.duracionMin;

      if (duracion != null &&
          parada.sitioId.isNotEmpty) {
        minutos[parada.sitioId] = duracion;
      }
    }

    return minutos;
  }

  static List<SitioTuristicoModel> sitiosDeRutaApi({
    required RutaModel ruta,
    required List<SitioTuristicoModel> sitios,
  }) {
    final ids = ruta.paradas.isNotEmpty
        ? ruta.paradas.map((p) => p.sitioId).toList()
        : ruta.sitios;

    if (ids.length < MapaEstadoRuta.minSitios ||
        ids.length >
            MapaEstadoRuta.maxSitiosPredefinida) {
      return const [];
    }

    final porId = {
      for (final sitio in sitios) sitio.id: sitio,
    };

    final ordenados = <SitioTuristicoModel>[];

    for (final id in ids) {
      final sitio = porId[id];

      if (sitio == null || !sitio.enAreaTuristica) {
        return const [];
      }

      ordenados.add(sitio);
    }

    return ordenados;
  }
}
