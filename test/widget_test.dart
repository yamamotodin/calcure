import 'package:flutter_test/flutter_test.dart';
import 'package:calcure/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CalcureApp());
    expect(find.text('スタート！'), findsOneWidget);
  });
}
