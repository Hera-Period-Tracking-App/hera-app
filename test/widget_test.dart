import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hera_app/app.dart';

void main() {
  testWidgets('shows onboarding welcome copy', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HeraApp()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Hera'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
