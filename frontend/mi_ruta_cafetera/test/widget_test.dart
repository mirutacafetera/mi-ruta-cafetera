import 'package:flutter_test/flutter_test.dart';
import 'package:mi_ruta_cafetera/main.dart';

void main() {
  testWidgets(
    'La aplicacion inicia correctamente',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MiRutaCafeteraApp());

      expect(find.byType(MiRutaCafeteraApp), findsOneWidget);
    },
  );
}
