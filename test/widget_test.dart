import 'package:flutter_test/flutter_test.dart';
import 'package:daylo_app/main.dart';

void main() {
  testWidgets('DAYLO app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DayloApp());

    // Verify that DAYLO logo is displayed
    expect(find.text('DAYLO'), findsOneWidget);
  });
}
