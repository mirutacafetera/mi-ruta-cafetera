import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_ruta_cafetera/utils/seleccion_sitios.dart';

class _Sitio {
  final String id;
  final String categoria;

  const _Sitio(this.id, this.categoria);
}

List<_Sitio> _crear(Map<String, int> porCategoria) {
  final sitios = <_Sitio>[];

  porCategoria.forEach((categoria, cantidad) {
    for (var i = 0; i < cantidad; i++) {
      sitios.add(_Sitio('$categoria-$i', categoria));
    }
  });

  return sitios;
}

List<_Sitio> _seleccionar(List<_Sitio> sitios, {int maximo = 10}) {
  return SeleccionSitios.diversa<_Sitio>(
    sitios,
    idDe: (s) => s.id,
    categoriaDe: (s) => s.categoria,
    maximo: maximo,
    random: Random(7),
  );
}

void main() {
  group('SeleccionSitios.diversa', () {
    test('devuelve todos si hay 10 o menos y no inventa sitios', () {
      final resultado = _seleccionar(_crear({'a': 2, 'b': 3}));

      expect(resultado.length, 5);
    });

    test('lista vacía devuelve lista vacía', () {
      expect(_seleccionar(<_Sitio>[]), isEmpty);
    });

    test('máximo 10, sin duplicados', () {
      final sitios = _crear({'a': 8, 'b': 8, 'c': 8});
      final resultado = _seleccionar([...sitios, ...sitios]);

      expect(resultado.length, 10);
      expect(resultado.map((s) => s.id).toSet().length, 10);
    });

    test('incluye un sitio de cada categoría si caben', () {
      final resultado = _seleccionar(
        _crear({'a': 10, 'b': 10, 'c': 10, 'd': 1, 'e': 1}),
      );

      final categorias = resultado.map((s) => s.categoria).toSet();

      expect(resultado.length, 10);
      expect(categorias, containsAll(<String>['a', 'b', 'c', 'd', 'e']));
    });

    test('con más categorías que espacios toma una por categoría', () {
      final sitios = _crear({for (var i = 0; i < 14; i++) 'cat$i': 2});

      final resultado = _seleccionar(sitios);

      expect(resultado.length, 10);
      expect(resultado.map((s) => s.categoria).toSet().length, 10);
    });

    test('ignora sitios sin id', () {
      final resultado = _seleccionar([
        const _Sitio('', 'a'),
        const _Sitio('x', 'a'),
      ]);

      expect(resultado.map((s) => s.id), ['x']);
    });
  });
}
