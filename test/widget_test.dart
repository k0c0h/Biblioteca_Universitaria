import 'package:flutter_test/flutter_test.dart';
import 'package:pry002_api/main.dart';

void main() {
  testWidgets('Muestra los accesos de la biblioteca', (tester) async {
    await tester.pumpWidget(const MiApp());

    expect(find.text('Biblioteca universitaria'), findsOneWidget);
    expect(find.text('Estudiantes'), findsOneWidget);
    expect(find.text('Libros disponibles'), findsOneWidget);
    expect(find.text('Préstamos'), findsOneWidget);
  });
}
