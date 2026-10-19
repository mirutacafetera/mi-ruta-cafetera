import 'dart:math';

/// Selección aleatoria de sitios con diversidad de categorías.
///
/// Se usa para la cuadrícula del Home: muestra como máximo [maximo]
/// sitios reales, sin duplicados, procurando un sitio por categoría.
///
/// * Si hay [maximo] sitios o menos, se devuelven todos (mezclados).
/// * Si hay más categorías que espacios, se toma una muestra al azar
///   de categorías, con un sitio de cada una.
/// * Si hay menos categorías que espacios, se toma un sitio de cada
///   categoría y los espacios restantes se completan al azar con
///   sitios de cualquier categoría (también cuando una categoría no
///   tiene sitios).
/// * Nunca se inventan sitios: solo se usan los recibidos.
class SeleccionSitios {
  SeleccionSitios._();

  static List<T> diversa<T>(
    Iterable<T> sitios, {
    required String Function(T sitio) idDe,
    required String Function(T sitio) categoriaDe,
    int maximo = 10,
    Random? random,
  }) {
    final azar = random ?? Random();

    // 1. Sin duplicados (por id) y sin sitios sin id.
    final vistos = <String>{};
    final unicos = <T>[];

    for (final sitio in sitios) {
      final id = idDe(sitio).trim();

      if (id.isEmpty || !vistos.add(id)) {
        continue;
      }

      unicos.add(sitio);
    }

    if (unicos.length <= maximo) {
      unicos.shuffle(azar);
      return unicos;
    }

    // 2. Agrupar por categoría.
    final porCategoria = <String, List<T>>{};

    for (final sitio in unicos) {
      final clave = categoriaDe(sitio).trim().toLowerCase();

      porCategoria.putIfAbsent(clave, () => <T>[]).add(sitio);
    }

    final claves = porCategoria.keys.toList()..shuffle(azar);

    for (final lista in porCategoria.values) {
      lista.shuffle(azar);
    }

    // 3. Un sitio por categoría (muestra si hay más categorías
    //    que espacios).
    final elegidos = <T>[];

    for (final clave in claves) {
      if (elegidos.length >= maximo) {
        break;
      }

      elegidos.add(porCategoria[clave]!.removeLast());
    }

    // 4. Completar con sitios restantes de cualquier categoría.
    if (elegidos.length < maximo) {
      final restantes = <T>[for (final lista in porCategoria.values) ...lista]
        ..shuffle(azar);

      elegidos.addAll(restantes.take(maximo - elegidos.length));
    }

    elegidos.shuffle(azar);

    return elegidos;
  }
}
