import 'package:flutter_test/flutter_test.dart';
import 'package:hujan_kata/main.dart';

void main() {
  testWidgets('App smoke test - HomeScreen renders successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HujanKataApp());
    await tester.pump();

    expect(find.text('HUJAN KATA'), findsOneWidget);
    expect(find.text('MULAI MAIN'), findsOneWidget);
  });
}
