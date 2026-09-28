import 'package:flutter_test/flutter_test.dart';
import 'package:multivoice_assist/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MultiVoice Assist app loads successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MultiVoiceAssistApp());

    await tester.pump();

    expect(find.byType(MultiVoiceAssistApp), findsOneWidget);
  });
}
