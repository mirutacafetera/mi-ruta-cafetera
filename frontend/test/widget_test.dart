import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets(
    'La aplicación inicia correctamente',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MiRutaCafeteraApp(),
      );

      expect(
        find.byType(MiRutaCafeteraApp),
        findsOneWidget,
      );
    },
  );
}