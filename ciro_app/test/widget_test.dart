import 'package:flutter_test/flutter_test.dart';
import 'package:ciro_app/main.dart';

void main() {
  testWidgets('CIROApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CIROApp());
    expect(find.text('CIRO Command Center'), findsOneWidget);
  });
}
