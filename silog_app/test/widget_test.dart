import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silog_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Aplikasi SiLog berhasil ditampilkan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SiLogApp());

    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.title, 'SiLog');
  });
}
