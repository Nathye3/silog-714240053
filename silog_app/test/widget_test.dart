import 'package:flutter_test/flutter_test.dart';
import 'package:silog_app/main.dart';

void main() {
  testWidgets('Halaman beranda SiLog tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const SiLogApp());

    expect(find.text('Sistem Informasi Logistik'), findsOneWidget);
    expect(find.text('Nama: Muhamad Maulana Febrian'), findsOneWidget);
  });
}
