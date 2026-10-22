
import '../../models/ruta_predefinida_model.dart';
import '../../models/sitio_turistico_model.dart';
import '../../utils/text_utils.dart';
import '../../widgets/mapa/mapa_estado_ruta.dart';
import 'orden_ruta_helper.dart';

class SeleccionRutaHelper {
  static List<SitioTuristicoModel> buscarSitios({
    required RutaPredefinidaModel ruta,
    required List<SitioTuristicoModel> sitios,
  }) {
    final municipios = ruta.municipios
        .map(TextUtils.normalizar)
        .where((item) => item.isNotEmpty)
        .toSet();

    final categorias = ruta.categorias
        .map(TextUtils.normalizar)
        .where((item) => item.isNotEmpty)
        .toSet();

    if (municipios.isEmpty && categorias.isEmpty) {
      return [];
    }

    return sitios.where((sitio) {
      if (!sitio.activo || !sitio.enAreaTuristica) {
        return false;
      }

      final municipio =
          TextUtils.normalizar(sitio.ciudad);

      final categoria =
          TextUtils.normalizar(sitio.categoriaNombre);

      final coincideMunicipio =
          municipios.contains(municipio);

      final coincideCategoria =
          categoria.isNotEmpty &&
          categorias.any((categoriaRuta) {
            return categoria == categoriaRuta ||
                categoria.contains(categoriaRuta) ||
                categoriaRuta.contains(categoria);
          });

      return coincideMunicipio || coincideCategoria;
    }).toList();
  }

  static List<SitioTuristicoModel> seleccionarSitios({
    required RutaPredefinidaModel ruta,
    required List<SitioTuristicoModel> sitios,
  }) {
    final candidatos = buscarSitios(
      ruta: ruta,
      sitios: sitios,
    );

    if (candidatos.isEmpty) {
      return [];
    }

    const maximo = MapaEstadoRuta.maxSitios;

    final ordenMunicipios = ruta.municipios
        .map(TextUtils.normalizar)
        .toList();

    if (ordenMunicipios.isNotEmpty &&
        ruta.categorias.isEmpty) {
      final grupos = <List<SitioTuristicoModel>>[
        for (final _ in ordenMunicipios) [],
      ];

      for (final sitio in candidatos) {
        final indice = ordenMunicipios.indexOf(
          TextUtils.normalizar(sitio.ciudad),
        );

        if (indice != -1) {
          grupos[indice].add(sitio);
        }
      }

      final elegidos =
          <MapEntry<int, SitioTuristicoModel>>[];

      var ronda = 0;

      while (elegidos.length < maximo) {
        var agregado = false;

        for (var g = 0; g < grupos.length; g++) {
          if (elegidos.length >= maximo) {
            break;
          }

          if (ronda < grupos[g].length) {
            elegidos.add(
              MapEntry(g, grupos[g][ronda]),
            );

            agregado = true;
          }
        }

        if (!agregado) {
          break;
        }

        ronda++;
      }

      final ordenados = <SitioTuristicoModel>[];

      for (var g = 0; g < grupos.length; g++) {
        ordenados.addAll(
          elegidos
              .where((item) => item.key == g)
              .map((item) => item.value),
        );
      }

      return ordenados;
    }

    final ordenCategorias = ruta.categorias
        .map(TextUtils.normalizar)
        .toList();

    final gruposCategoria =
        <List<SitioTuristicoModel>>[
      for (final _ in ordenCategorias) [],
    ];

    final sinGrupo = <SitioTuristicoModel>[];

    for (final sitio in candidatos) {
      final categoria =
          TextUtils.normalizar(sitio.categoriaNombre);

      final indice = ordenCategorias.indexWhere(
        (categoriaRuta) =>
            categoria.isNotEmpty &&
            (categoria == categoriaRuta ||
                categoria.contains(categoriaRuta) ||
                categoriaRuta.contains(categoria)),
      );

      if (indice == -1) {
        sinGrupo.add(sitio);
      } else {
        gruposCategoria[indice].add(sitio);
      }
    }

    final elegidosCategoria = <SitioTuristicoModel>[];

    var rondaCategoria = 0;

    while (elegidosCategoria.length < maximo) {
      var agregadoCategoria = false;

      for (final grupo in gruposCategoria) {
        if (elegidosCategoria.length >= maximo) {
          break;
        }

        if (rondaCategoria < grupo.length) {
          elegidosCategoria.add(
            grupo[rondaCategoria],
          );

          agregadoCategoria = true;
        }
      }

      if (!agregadoCategoria) {
        break;
      }

      rondaCategoria++;
    }

    for (final sitio in sinGrupo) {
      if (elegidosCategoria.length >= maximo) {
        break;
      }

      elegidosCategoria.add(sitio);
    }

    return OrdenRutaHelper.ordenarPorCercania(
      elegidosCategoria,
    );
  }
}
