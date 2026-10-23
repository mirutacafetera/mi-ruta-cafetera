import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_ruta_cafetera/l10n/textos.dart';
import 'package:mi_ruta_cafetera/l10n/textos_en.dart';
import 'package:mi_ruta_cafetera/screens/usuario/preferencias_screen.dart';
import 'package:mi_ruta_cafetera/services/usuario/preferencias_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _desescapar(String s) {
  return s
      .replaceAll(r"\'", "'")
      .replaceAll(r'\$', r'$')
      .replaceAll(r'\n', '\n')
      .replaceAll(r'\\', r'\');
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PreferenciasService.instance.idioma.value = IdiomaApp.es;
  });

  test('cada clave corta en inglés existe en español', () {
    expect(Textos.clavesEn.difference(Textos.clavesEs), isEmpty);
  });

  test('todas las claves cortas en español tienen traducción al inglés', () {
    expect(Textos.clavesEs.difference(Textos.clavesEn), isEmpty);
  });

  test('las traducciones conservan los mismos marcadores {0}, {1}…', () {
    final marcador = RegExp(r'\{\d\}');

    for (final entrada in textosEnLiteral.entries) {
      final origen = marcador.allMatches(entrada.key).map((m) => m.group(0)!);
      final destino = marcador.allMatches(entrada.value).map((m) => m.group(0)!);

      expect(
        destino.toList()..sort(),
        origen.toList()..sort(),
        reason: 'Marcadores distintos en "${entrada.key}"',
      );
    }
  });

  test('una clave inexistente se muestra tal cual', () {
    expect(Textos.de(IdiomaApp.en, 'no.existe'), 'no.existe');
    expect(Textos.de(IdiomaApp.es, 'no.existe'), 'no.existe');
  });

  test('el texto en español es la clave y el inglés viene de la tabla', () {
    expect(Textos.de(IdiomaApp.es, 'Iniciar sesión'), 'Iniciar sesión');
    expect(Textos.de(IdiomaApp.en, 'Iniciar sesión'), 'Sign in');
  });

  test('sin traducción al inglés se conserva el español', () {
    expect(
      Textos.de(IdiomaApp.en, 'Texto que nadie ha traducido'),
      'Texto que nadie ha traducido',
    );
  });

  test('los valores {0}, {1} se sustituyen en ambos idiomas', () {
    expect(Textos.de(IdiomaApp.es, 'Bienvenido, {0}', ['Ana']), 'Bienvenido, Ana');
    expect(Textos.de(IdiomaApp.en, 'Bienvenido, {0}', ['Ana']), 'Welcome, Ana');
    expect(
      Textos.de(IdiomaApp.en, '{0} h {1} min', [2, 5]),
      '2 h 5 min',
    );
  });

  test('un código guardado desconocido vuelve a español', () {
    expect(IdiomaApp.desdeCodigo('fr'), IdiomaApp.es);
    expect(IdiomaApp.desdeCodigo(null), IdiomaApp.es);
    expect(IdiomaApp.desdeCodigo('en'), IdiomaApp.en);
  });

  test('cambiarIdioma guarda y restaurar recupera la preferencia', () async {
    await PreferenciasService.instance.cambiarIdioma(IdiomaApp.en);

    final guardado = await SharedPreferences.getInstance();
    expect(guardado.getString('preferencia_idioma'), 'en');

    PreferenciasService.instance.idioma.value = IdiomaApp.es;
    await PreferenciasService.instance.restaurar();
    expect(PreferenciasService.instance.idioma.value, IdiomaApp.en);
  });

  test('todo texto escrito en Tr(...) o Textos.t(...) tiene su traducción', () {
    final patron = RegExp(
      r"(?:\bTr|Textos\.t|context\.t|dialogContext\.t)\(\s*'((?:\\.|[^'\\])*)'",
    );
    final cortas = Textos.clavesEs;
    final faltan = <String>{};

    for (final entidad in Directory('lib').listSync(recursive: true)) {
      if (entidad is! File || !entidad.path.endsWith('.dart')) {
        continue;
      }

      if (entidad.path.endsWith('textos.dart') ||
          entidad.path.endsWith('textos_en.dart')) {
        continue;
      }

      final contenido = entidad.readAsStringSync();

      for (final m in patron.allMatches(contenido)) {
        final clave = _desescapar(m.group(1)!);

        // Clave dinámica, p. ej. 'pref.tamano.${tamano.id}': se acepta si
        // existe al menos una clave registrada con ese prefijo.
        final dinamica = clave.indexOf(r'${');

        if (dinamica > 0) {
          final prefijo = clave.substring(0, dinamica);

          if (cortas.any((c) => c.startsWith(prefijo))) {
            continue;
          }
        }

        if (cortas.contains(clave) || textosEnLiteral.containsKey(clave)) {
          continue;
        }

        faltan.add('${entidad.path}: $clave');
      }
    }

    expect(faltan, isEmpty, reason: 'Sin traducción:\n${faltan.join('\n')}');
  });

  testWidgets('el selector cambia el texto al instante, sin reiniciar',
      (tester) async {
    await tester.pumpWidget(
      ValueListenableBuilder<IdiomaApp>(
        valueListenable: PreferenciasService.instance.idioma,
        builder: (context, idioma, _) {
          return IdiomaScope(
            idioma: idioma,
            child: const MaterialApp(home: PreferenciasScreen()),
          );
        },
      ),
    );

    expect(find.text('Preferencias'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Preferencias'), findsNothing);
    expect(PreferenciasService.instance.idioma.value, IdiomaApp.en);
  });

  testWidgets('Tr y Textos.t se actualizan al reconstruir el árbol',
      (tester) async {
    PreferenciasService.instance.idioma.addListener(Textos.reconstruirArbol);
    addTearDown(
      () => PreferenciasService.instance.idioma.removeListener(
        Textos.reconstruirArbol,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const Tr('Iniciar sesión'),
              Builder(
                builder: (_) => Text(Textos.t('Crear una cuenta')),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Crear una cuenta'), findsOneWidget);

    PreferenciasService.instance.idioma.value = IdiomaApp.en;
    await tester.pump();

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });
}
