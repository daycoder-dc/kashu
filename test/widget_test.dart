import 'package:flutter_test/flutter_test.dart';

import 'package:kashu/app/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const KashuApp());
    expect(find.text('Kashu'), findsOneWidget);
  });
}
