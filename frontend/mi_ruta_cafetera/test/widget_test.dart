import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_ruta_cafetera/main.dart';

void main() {
  testWidgets(
    'La aplicacion inicia correctamente',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MiRutaCafeteraApp());

      // La pantalla de bienvenida programa un Future.delayed de 250 ms
      // (bienvenida_screen.dart) y un temporizador periódico del
      // carrusel. Se avanza el reloj para que el primero se ejecute...
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(MiRutaCafeteraApp), findsOneWidget);

      // ...y se desmonta la app para que el dispose() de la pantalla
      // cancele el temporizador del carrusel antes de terminar la prueba.
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
