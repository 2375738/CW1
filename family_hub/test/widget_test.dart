import 'package:flutter_test/flutter_test.dart';

import 'package:family_hub/main.dart';

void main() {
  testWidgets('App boots to login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FamilyHubApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to FamilyHub'), findsOneWidget);
  });
}
